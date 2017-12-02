from PIL import Image
import os
import numpy as np

ori_mask_path = '/home/yangle/BasicDataset/dataset/MSRA10K/mask/'
ori_img_path = '/home/yangle/BasicDataset/dataset/MSRA10K/img/'
res_mask_path = '/home/yangle/TCyb/dataset/patch_MSRA/mask/'
res_img_path = '/home/yangle/TCyb/dataset/patch_MSRA/image/'

mask_set = os.listdir(ori_mask_path)
for iimg in range(0, len(mask_set)):
    img_name = mask_set[iimg]
    print(img_name)
    mask = Image.open(ori_mask_path+img_name)
    img = Image.open(ori_img_path+img_name)
    (wid, hei) = mask.size
    if wid > hei:
        mask = mask.resize((854, 480))
        img = img.resize((854, 480))
    else:
        mask = mask.resize((480, 854))
        img = img.resize((480, 854))

    mask_tmp = np.asarray(mask)
    mask_file_path = res_mask_path + img_name
    mask.save(mask_file_path)

    img_file_path = res_img_path + img_name
    img.save(img_file_path)



