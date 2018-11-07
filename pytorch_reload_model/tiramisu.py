# coding: utf-8

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.nn import init
from torch.autograd import Variable


def center_crop(layer, max_height, max_width):
    #https://github.com/Lasagne/Lasagne/blob/master/lasagne/layers/merge.py#L162
    #Author does a center crop which crops both inputs (skip and upsample) to size of minimum dimension on both w/h
    batch_size, n_channels, layer_height, layer_width = layer.size()
    xy1 = (layer_width - max_width) // 2
    xy2 = (layer_height - max_height) // 2
    return layer[:, :, xy2:(xy2 + max_height), xy1:(xy1 + max_width)]


class DenseLayer(nn.Sequential):
	def __init__(self, in_channels, growth_rate):
		super(DenseLayer, self).__init__()
		self.add_module('norm', nn.BatchNorm2d(num_features=in_channels))
		#self.add_module('relu', nn.ReLU(inplace=True))
		self.add_module('prelu', nn.PReLU())

		# author's impl - lasange 'same' pads with half
		# filter size (rounded down) on "both" sides
		self.add_module('conv', nn.Conv2d(in_channels=in_channels,
										  out_channels=growth_rate, kernel_size=3, stride=1,
										  padding=1, bias=True))

		self.add_module('drop', nn.Dropout2d(0.2))

	def forward(self, x):
		return super(DenseLayer, self).forward(x)


class DenseBlock(nn.Module):
	def __init__(self, in_channels, growth_rate, n_layers, upsample=False):
		super(DenseBlock, self).__init__()
		self.upsample = upsample
		self.layers = nn.ModuleList([DenseLayer(
			in_channels + i * growth_rate, growth_rate)
			for i in range(n_layers)])

	def forward(self, x):
		if self.upsample:
			new_features = []
			# we pass all previous activations into each dense layer normally
			# But we only store each dense layer's output in the new_features array
			for layer in self.layers:
				out = layer(x)
				x = torch.cat([x, out], 1)
				new_features.append(out)
			return torch.cat(new_features, 1)
		else:
			for layer in self.layers:
				out = layer(x)
				x = torch.cat([x, out], 1)  # 1 = channel axis
			return x


class TransitionDown(nn.Sequential):
	def __init__(self, in_channels):
		super(TransitionDown, self).__init__()
		self.add_module('norm', nn.BatchNorm2d(num_features=in_channels))
		#self.add_module('relu', nn.ReLU(inplace=True))
		self.add_module('prelu', nn.PReLU())
		self.add_module('conv', nn.Conv2d(in_channels=in_channels,
										  out_channels=in_channels, kernel_size=1, stride=1,
										  padding=0, bias=True))
		self.add_module('drop', nn.Dropout2d(0.2))
		self.add_module('maxpool', nn.MaxPool2d(2))

	def forward(self, x):
		return super(TransitionDown, self).forward(x)


class TransitionUp(nn.Module):
	def __init__(self, in_channels, out_channels):
		super(TransitionUp, self).__init__()
		self.convTrans = nn.ConvTranspose2d(in_channels=in_channels,
											out_channels=out_channels, kernel_size=3, stride=2,
											padding=0,
											bias=True)  # crop = 'valid' means padding=0. Padding has reverse effect for transpose conv (reduces output size)

	# http://lasagne.readthedocs.io/en/latest/modules/layers/conv.html#lasagne.layers.TransposedConv2DLayer
	# self.updample2d = nn.UpsamplingBilinear2d(scale_factor=2)

	def forward(self, x, skip):
		out = self.convTrans(x)
		out = center_crop(out, skip.size(2), skip.size(3))
		out = torch.cat([out, skip], 1)
		return out


class Bottleneck(nn.Sequential):
    def __init__(self, in_channels, growth_rate, n_layers):
        super(Bottleneck, self).__init__()
        self.add_module('bottleneck', DenseBlock(in_channels, growth_rate, n_layers, upsample=True))

    def forward(self, x):
        return super(Bottleneck, self).forward(x)


class ConvGRUCell(nn.Module):
    """
    Generate a convolutional GRU cell
    in implementation, merge two convolutions into one. why?
    """

    def __init__(self, input_size, hidden_size, kernel_size):
        super().__init__()
        padding = kernel_size // 2
        self.input_size = input_size
        self.hidden_size = hidden_size
        # self.batch_size = batch_size
        self.reset_gate = nn.Conv2d(input_size + hidden_size, hidden_size, kernel_size, padding=padding)
        self.update_gate = nn.Conv2d(input_size + hidden_size, hidden_size, kernel_size, padding=padding)
        self.out_gate = nn.Conv2d(input_size + hidden_size, hidden_size, kernel_size, padding=padding)

        init.orthogonal(self.reset_gate.weight)
        init.orthogonal(self.update_gate.weight)
        init.orthogonal(self.out_gate.weight)
        init.constant(self.reset_gate.bias, 0.)
        init.constant(self.update_gate.bias, 0.)
        init.constant(self.out_gate.bias, 0.)

    def forward(self, input_, prev_state):
        # get batch and spatial sizes
        batch_size = input_.size()[0]
        spatial_size = input_.size()[2:]

        # # generate empty prev_state, if None is provided
        if prev_state is None:
            state_size = [batch_size, self.hidden_size] + list(spatial_size)
            prev_state = Variable(torch.zeros(state_size)).cuda()

        # data size is [batch, channel, height, width]
        stacked_inputs = torch.cat([input_, prev_state], dim=1)
        update = F.sigmoid(self.update_gate(stacked_inputs))
        reset = F.sigmoid(self.reset_gate(stacked_inputs))
        out_inputs = F.tanh(self.out_gate(torch.cat([input_, prev_state * reset], dim=1)))
        new_state = prev_state * (1 - update) + out_inputs * update

        return new_state


class FCDenseNet(nn.Module):
	def __init__(self, in_channels=3, down_blocks=(5, 5, 5, 5, 5),
				 up_blocks=(5, 5, 5, 5, 5), bottleneck_layers=5,
				 growth_rate=16, out_chans_first_conv=48, n_classes=12):
		super(FCDenseNet, self).__init__()
		self.down_blocks = down_blocks
		self.up_blocks = up_blocks

		cur_channels_count = 0
		skip_connection_channel_counts = []

		#####################
		# First Convolution #
		#####################

		self.add_module('firstconv', nn.Conv2d(in_channels=in_channels,
											   out_channels=out_chans_first_conv, kernel_size=3,
											   stride=1, padding=1, bias=True))
		cur_channels_count = out_chans_first_conv

		#####################
		# Downsampling path #
		#####################

		self.denseBlocksDown = nn.ModuleList([])
		self.transDownBlocks = nn.ModuleList([])
		for i in range(len(down_blocks)):
			self.denseBlocksDown.append(
				DenseBlock(cur_channels_count, growth_rate, down_blocks[i]))
			cur_channels_count += (growth_rate * down_blocks[i])
			skip_connection_channel_counts.insert(0, cur_channels_count)
			self.transDownBlocks.append(TransitionDown(cur_channels_count))

		#####################
		#     Bottleneck    #
		#####################

		self.add_module('bottleneck', Bottleneck(cur_channels_count,
												 growth_rate, bottleneck_layers))
		prev_block_channels = growth_rate * bottleneck_layers
		cur_channels_count += prev_block_channels

		#######################
		#   Upsampling path   #
		#######################

		self.transUpBlocks = nn.ModuleList([])
		self.denseBlocksUp = nn.ModuleList([])
		for i in range(len(up_blocks) - 1):
			self.transUpBlocks.append(TransitionUp(prev_block_channels, prev_block_channels))
			cur_channels_count = prev_block_channels + skip_connection_channel_counts[i]

			self.denseBlocksUp.append(DenseBlock(
				cur_channels_count, growth_rate, up_blocks[i],
				upsample=True))
			prev_block_channels = growth_rate * up_blocks[i]
			cur_channels_count += prev_block_channels

		# One final dense block
		self.transUpBlocks.append(TransitionUp(
			prev_block_channels, prev_block_channels))
		cur_channels_count = prev_block_channels + skip_connection_channel_counts[-1]

		self.denseBlocksUp.append(DenseBlock(
			cur_channels_count, growth_rate, up_blocks[-1],
			upsample=False))
		cur_channels_count += growth_rate * up_blocks[-1]

		#####################
		# convolutional GRU #
		#####################
		self.hidden_size = 128
		self.kernel_size = 3
		self.hidden = None
		self.add_module('convgru', ConvGRUCell(input_size=cur_channels_count, hidden_size=self.hidden_size, kernel_size=self.kernel_size))

		#####################
		#      Softmax      #
		#####################

		self.finalConvGRU = nn.Conv2d(in_channels=self.hidden_size,
								   out_channels=n_classes, kernel_size=1, stride=1,
								   padding=0, bias=True)
		self.softmaxGRU = nn.LogSoftmax(dim=1)

	def forward(self, x):
		# print("INPUT",x.size())
		out = self.firstconv(x)

		skip_connections = []
		for i in range(len(self.down_blocks)):
			# print("DBD size",out.size())
			out = self.denseBlocksDown[i](out)
			skip_connections.append(out)
			out = self.transDownBlocks[i](out)

		out = self.bottleneck(out)
		# print ("bnecksize",out.size())
		for i in range(len(self.up_blocks)):
			skip = skip_connections.pop()
			# print("DOWN_SKIP_PRE_UPSAMPLE",out.size(),skip.size())
			out = self.transUpBlocks[i](out, skip)
			# print("DOWN_SKIP_AFT_UPSAMPLE",out.size(),skip.size())
			out = self.denseBlocksUp[i](out)

        # convGRU
		hidden = None
		out_size = [out.size()[0], self.hidden_size] + list(out.size()[2:])
		out_gru = Variable(torch.zeros(out_size)).cuda()
		for ibat in range(out.size()[0]):
			data_in = out[ibat]
			data_in.unsqueeze_(0)
			out_hid = self.convgru(data_in, hidden)
			hidden = out_hid
			out_gru[ibat] = out_hid.squeeze(0)

		out = self.finalConvGRU(out_gru)
		out = self.softmaxGRU(out)
		return out


def FCDenseNet57(in_channels, n_classes):
    return FCDenseNet(in_channels=in_channels, down_blocks=(4, 4, 4, 4, 4),
                 up_blocks=(4, 4, 4, 4, 4), bottleneck_layers=4,
                 growth_rate=12, out_chans_first_conv=48, n_classes=n_classes)

def FCDenseNet67(n_classes):
    return FCDenseNet(in_channels=4, down_blocks=(5, 5, 5, 5, 5),
                 up_blocks=(5, 5, 5, 5, 5), bottleneck_layers=5,
                 growth_rate=16, out_chans_first_conv=48, n_classes=n_classes)

def FCDenseNet103(n_classes):
    return FCDenseNet(in_channels=4, down_blocks=(4,5,7,10,12),
                 up_blocks=(12,10,7,5,4), bottleneck_layers=15,
                 growth_rate=16, out_chans_first_conv=48, n_classes=n_classes)



