import os
import random
import shutil

ori_mask_rp = '/home/yangle/TCyb/dataset/tiramisu/train/'
ori_img_rp = '/home/yangle/TCyb/dataset/tiramisu/trainannot/'
res_mask_rp = '/home/yangle/TCyb/dataset/tiramisu/val/'
res_img_rp = '/home/yangle/TCyb/dataset/tiramisu/valannot/'

img_set = os.listdir(ori_img_rp)
for i in range(2000):
    print(i)
    num_img = len(img_set)
    order = random.randint(0, num_img - 1)
    name_img = img_set[i]
    shutil.move(ori_img_rp+name_img, res_img_rp+name_img)
    shutil.move(ori_mask_rp+name_img, res_mask_rp+name_img)
    del(img_set[order])





