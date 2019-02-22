'''
The TSNE code is borrowed from 
https://github.com/DmitryUlyanov/Multicore-TSNE
'''

import numpy as np
import matplotlib.pyplot as plt
from MulticoreTSNE import MulticoreTSNE as TSNE
import cv2
import os

img_rp = './datasets/val/'
gt_rp = './datasets/valannot/'
vis_rp = './result/visualize/RGB/'
img_set = os.listdir(img_rp)
img_set.sort()

for name in img_set:
    print(name)
    img_path = img_rp + name
    img = cv2.imread(img_path)
    img = cv2.resize(img, (112, 112))
    rows, cols, _ = img.shape
    num_points = rows * cols
    feas_rgb = np.reshape(img, (num_points, 3))
    features = feas_rgb.astype('float32')

    mask_path = gt_rp + name
    mask = cv2.imread(mask_path, flags=0)
    mask = cv2.resize(mask, (112, 112))
    mask = mask / 255
    mask = np.where(mask < 0.5, 0, mask)
    mask = np.where(mask >= 0.5, 1, mask)
    mask = mask.astype('int')
    rows, cols = mask.shape
    num_points = rows * cols
    gt = np.reshape(mask, num_points)

    '''t-SNE'''
    tsne = TSNE(n_jobs=4)
    X_tsne = tsne.fit_transform(features)

    x_min, x_max = X_tsne.min(0), X_tsne.max(0)
    X_norm = (X_tsne - x_min) / (x_max - x_min)
    plt.figure(figsize=(8, 8))
    for i in range(X_norm.shape[0]):
        plt.text(X_norm[i, 0], X_norm[i, 1], str(gt[i]), color=plt.cm.Set1(gt[i]),
                 fontdict={'weight': 'bold', 'size': 9})
    plt.xticks([])
    plt.yticks([])
    plt.savefig(vis_rp+name)

