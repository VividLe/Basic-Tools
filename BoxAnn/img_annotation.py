'''
write by yu zhang
'''
import matplotlib as plt
import os
from PIL import Image, ImageDraw
from pylab import *
import numpy as np
import scipy.io as scio

root = './'
savePath = './save'
img_folds = [
    os.path.join(root, fold) for fold in sorted(os.listdir(root))
    if os.path.isdir(os.path.join(root, fold))
    and not fold == 'save']
locations = []
print(len(img_folds))
for i in range(0, len(img_folds)):
    imlist = sorted(os.listdir(img_folds[i]))
    fold_imNum = len(imlist)
    fold_loc = np.ndarray(shape=(fold_imNum, 4), dtype=np.float32)
    new_fold = os.path.join(savePath, os.path.split(img_folds[i])[1])
    if not os.path.isdir(new_fold):
        os.makedirs(new_fold)
    for j in range(fold_imNum):
        img_name = os.path.join(img_folds[i], imlist[j])
        im = Image.open(img_name)
        # im = np.array(.convert('L'))
        plt.imshow(im)
        print('Please click two points')
        x = plt.ginput(2)
        show()
        print('Choosed position:', x)
        fold_loc[j][0] = x[0][0]
        fold_loc[j][1] = x[0][1]
        fold_loc[j][2] = x[1][0]
        fold_loc[j][3] = x[1][1]
        draw = ImageDraw.Draw(im)
        draw.rectangle(fold_loc[j], outline='red')
        im.save(os.path.join(savePath, os.path.split(img_folds[i])[1],
                             os.path.splitext(imlist[j])[0], '.jpg'), "JPEG")
    scio.savemat('./positions.mat',
                 {os.path.split(img_folds[i])[1].replace('-', '_'): fold_loc})
    locations = locations.append(fold_loc)


