#!/usr/bin/env python

'''
compute the mean and std value for the image dataset
images should contain RGB 3 channels, preserve the same shape

the data range:
numpy.finfo(numpy.float32).max = 3.4028235e+38
numpy.finfo(numpy.float32).min = -3.4028235e+38

if the image size is 224 * 224 * 3
we can dispose
    numpy.finfo(numpy.float32).max / 255 / (224 * 224 * 3)
    =8.8650654698996486e+30
images without consider data overflow
'''

import os
import numpy as np
from PIL import Image
import math

# images directory
img_rp = '/home/yangle/TCyb/dataset/tiramisu/whole_dataset/train/'
cha = 3

img_set = os.listdir(img_rp)
img_num = len(img_set)
# first image
name_img = img_set[0]
img = Image.open(img_rp + name_img)
hei, wid = img.size

data = np.zeros((hei, wid, cha))
x_mean = np.zeros((hei, wid, cha))
x_std = np.zeros((hei, wid, cha))

for iimg in range(0, img_num):
    if iimg % 1000 == 0:
        print('process %d images' % iimg)
    img_name = img_set[iimg]
    img = Image.open(img_rp+img_name)
    data_img = np.asarray(img)
    data_img = data_img.astype(np.float32) / 255
    x_mean = x_mean + data_img
    data_sqrt = np.multiply(data_img, data_img)
    x_std = x_std + data_sqrt

means = []
stdevs = []
for i in range(cha):
    # mean
    pix_mean = x_mean[:, :, i].ravel()
    value_mean = np.mean(pix_mean) / img_num
    means.append(value_mean)

    # std
    pix_std = x_std[:, :, i].ravel()
    value_std = math.sqrt(np.mean(pix_std) / img_num - value_mean * value_mean)
    stdevs.append(value_std)

print("means: {}".format(means))
print("stdevs: {}".format(stdevs))