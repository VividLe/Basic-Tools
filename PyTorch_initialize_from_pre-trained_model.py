import torch
import torch.optim as optim

import tiramisu_preTrain as tiramisu_ori
import tiramisu


model_ori = tiramisu_ori.FCDenseNet57(in_channels=3, n_classes=2)
model_ori = torch.nn.DataParallel(model_ori).cuda()
fpath = '/weights.pth'
state = torch.load(fpath)
pretrained_dict = state['state_dict']

model = tiramisu.FCDenseNet57(in_channels=3, n_classes=2)
model = torch.nn.DataParallel(model).cuda()
model_dict = model.state_dict()

# 1. filter out unnecessary keys
pretrained_dict = {k: v for k, v in pretrained_dict.items() if k in model_dict}
# 2. overwrite entries in the existing state dict
model_dict.update(pretrained_dict)
# 3. load the new state dict
model.load_state_dict(model_dict)

# origional model is trained with multiple GPUs, convert it to single GPU model
model = model.module

# not train existing layers
count = 0
para_optim = []
for k in model.children():
    count += 1
    if count > 6:
        for param in k.parameters():
            para_optim.append(param)
    else:
        for param in k.parameters():
            param.requires_grad = False
    # print(k)
print('para_optim')
print(len(para_optim))

optimizer = optim.RMSprop(para_optim, lr=1e-4, weight_decay=0.995, eps=1e-12)

'continue training ...'
