import os

img_dir = '/home/yangle/TCyb/dataset/patch_MSRA/image/'
txt_path = '/home/yangle/TCyb/dataset/patch_MSRA/name.txt'

fid = open(txt_path, 'w')
img_set = os.listdir(img_dir)

for itxt in range(len(img_set)-1):
    name_img = img_set[itxt]
    str_w = name_img + ' 0\n'
    fid.write(str_w)

str_w = img_set[-1] + ' 0'
fid.write(str_w)

fid.close()

