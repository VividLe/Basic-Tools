import os
import numpy as np
from PIL import Image

from measure import jaccard
from measure import f_boundary

gt_rp = '/disk2/yangle/dataset/DUTS/valannot/'
mask_rp = '/disk2/yangle/result/LearnModel/QNet_nsteps/val_mask_ori/'

mask_set = os.listdir(mask_rp)
mask_set.sort()

num = len(mask_set)
measure_j = [0] * num
measure_f = [0] * num

for i, name in enumerate(mask_set):
    print(name)
    mask = Image.open(mask_rp + name)
    mask = mask.point(lambda i:i/255)
    mask_np = np.asarray(mask, dtype=np.uint8)

    # gt_name = name[:-6] + '.png'
    gt = Image.open(gt_rp + name)
    gt = gt.resize((112, 112), Image.NEAREST)
    gt = gt.point(lambda  i:i/255)
    gt_np = np.asarray(gt, dtype=np.uint8)

    measure_j[i] = jaccard.db_eval_iou(gt_np, mask_np)
    measure_f[i] = f_boundary.db_eval_boundary(mask_np, gt_np)

measure_j.sort()
measure_f.sort()
measure_j_np = np.asarray(measure_j)
measure_f_np = np.asarray(measure_f)
measure_j_m = measure_j_np.mean()
measure_f_m = measure_f_np.mean()
print('measure_j_np.mean()', measure_j_m)
print('measure_f_np.mean()', measure_f_m)
score = (measure_j_m + measure_f_m) / 2
print('score', score)

