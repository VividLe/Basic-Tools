from PIL import Image
import os
import numpy as np
import matplotlib.pyplot as plt


ori_mask_path = '/home/yangle/TCyb/dataset/SegmentationClass/'
ori_img_path = '/home/yangle/BasicDataset/dataset/VOCtrainval_11-May-2012/VOCdevkit/VOC2012/JPEGImages/'
res_mask_path = '/home/yangle/TCyb/dataset/mask/'
res_img_path = '/home/yangle/TCyb/dataset/image/'


def set_bound(pix):
    if pix == 255:
        pix = 0
    return pix


def set_object(pix):
    if pix > 0:
        pix = 255
    return pix

Threshold = 0
mask_set = os.listdir(ori_mask_path)
for iimg in range(len(mask_set)):
# for iimg in range(1):
    img_name = mask_set[iimg]
    # img_name = '2007_008714.png'
    print(img_name)
    mask = Image.open(ori_mask_path+img_name)
    # plt.imshow(mask)
    # mask = mask.point(lambda pix: set_bound(pix))
    mask = mask.point(lambda pix: set_object(pix))
    mask_np = np.asarray(mask)

    mask = Image.fromarray(mask_np, mode='L')
    mask_file_path = res_mask_path + img_name
    mask.save(mask_file_path)

    img_name_t = img_name.replace('.png', '.jpg')
    img = Image.open(ori_img_path + img_name_t)
    img_file_path = res_img_path + img_name
    img.save(img_file_path)



    # plt.imshow(mask_img)
    # plt.show()
    # print(mask_np.max())
    # print('here')
    # mask = np.asarray(mask)

