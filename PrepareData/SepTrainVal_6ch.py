import os
import random
import shutil

ori_mask_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/trainannot/'
ori_img_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/train/'
ori_img_cont_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/traincont/'
res_mask_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/valannot/'
res_img_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/val/'
res_img_cont_rp = '/home/yangle/TCyb/dataset/tiramisu_6ch_std/valcont/'

if not os.path.exists(res_mask_rp):
    os.makedirs(res_mask_rp)
if not os.path.exists(res_img_rp):
    os.makedirs(res_img_rp)
if not os.path.exists(res_img_cont_rp):
    os.makedirs(res_img_cont_rp)


img_set = os.listdir(ori_img_rp)
for i in range(2000):
    print(i)
    num_img = len(img_set)
    order = random.randint(0, num_img - 1)
    name_img = img_set[i]
    shutil.move(ori_img_rp+name_img, res_img_rp+name_img)
    shutil.move(ori_mask_rp+name_img, res_mask_rp+name_img)
    shutil.move(ori_img_cont_rp + name_img, res_img_cont_rp + name_img)
    del(img_set[order])





