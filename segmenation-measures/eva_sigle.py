from PIL import Image
import numpy as np
import os

import jaccard

mask_rp = '/home/yangle/TCyb/result/mask/MSRA10K/'
anno_rp = '/home/yangle/TCyb/dataset/MSRA10K/valannot/'

img_set = os.listdir(mask_rp)
img_num = len(img_set)
iou = np.zeros((img_num, 1))
# for iimg in range(img_num):
for iimg in range(5):
    img_name = img_set[iimg]
    mask_file = mask_rp + img_name
    anno_file = anno_rp + img_name

    anno = Image.open(anno_file)
    mask = Image.open(mask_file)
    mask = mask.convert('L')
    mask = mask.resize(anno.size)

    mask = np.asarray(mask)
    anno = np.asarray(anno)

    iou[iimg] = jaccard.db_eval_iou(anno, mask)

print(np.mean(iou))
