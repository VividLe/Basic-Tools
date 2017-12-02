from PIL import Image
import numpy as np
import os
import random

import utils

ori_mask_rp = '/home/yangle/TCyb/dataset/resize_MSRA/mask/'
ori_img_rp = '/home/yangle/TCyb/dataset/resize_MSRA/image/'
res_mask_rp = '/home/yangle/TCyb/dataset/tiramisu_7ch_large/trainannot/'
res_img_rp = '/home/yangle/TCyb/dataset/tiramisu_7ch_large/train/'
res_img_cont_rp = '/home/yangle/TCyb/dataset/tiramisu_7ch_large/traincont/'
res_box_rp = '/home/yangle/TCyb/dataset/tiramisu_7ch_large/trainbox/'

if not os.path.exists(res_mask_rp):
    os.makedirs(res_mask_rp)
if not os.path.exists(res_img_rp):
    os.makedirs(res_img_rp)
# if not os.path.exists(res_mask_cont_rp):
#     os.makedirs(res_mask_cont_rp)
if not os.path.exists(res_img_cont_rp):
    os.makedirs(res_img_cont_rp)
if not os.path.exists(res_box_rp):
    os.makedirs(res_box_rp)


mask_set = os.listdir(ori_mask_rp)
for iimg in range(0, len(mask_set), 10):
# for iimg in range(1):
    print(iimg)
    img_name = mask_set[iimg]

    mask = Image.open(ori_mask_rp + img_name)
    img = Image.open(ori_img_rp + img_name)

    # move right, horizon difference
    mask = np.asarray(mask)
    img = np.asarray(img)

    (wid, hei) = mask.shape
    mask_r = np.zeros((wid, hei))
    mask_r[1:wid, :] = mask[0:wid-1, :]
    mask_dif_r = mask - mask_r
    # [x, y] = np.nonzero(mask_dif_r)
    # move left, vertical difference
    mask_d = np.zeros((wid, hei))
    mask_d[:, 1:hei] = mask[:, 0:hei-1]
    mask_dif_d = mask - mask_d
    # [x, y] = np.nonzero(mask_dif_d)

    # overall bounding box point
    bound_mat = np.fabs(mask_dif_r) + np.fabs(mask_dif_d)
    [x, y] = np.nonzero(bound_mat)

    box_h = 64
    cont_h = 128
    box_list = []
    cont_list = []
    num_point = len(x)
    # print(num_point)
    while True:
        if len(x) == 0:
            break

        px, py = x[0], y[0]
        # print(px, py)
        box_crop = utils.crop_patch(px, py, box_h, wid, hei)
        box_list.append(box_crop)
        cont_crop = utils.crop_patch(px, py, cont_h, wid, hei)
        cont_list.append(cont_crop)

        # delete points insides the cropped the box
        edge_l = box_crop[0]
        edge_r = box_crop[1]
        edge_u = box_crop[2]
        edge_d = box_crop[3]
        while True:
            if len(x) == 0:
                break
            # every time only dispose the first number
            x_place, y_place = x[0], y[0]

            # print('x_place: %d, y_place: %d' % (x_place, y_place))
            # delete insides point
            if (x_place >= edge_l) and (x_place < edge_r) and (y_place >= edge_u) and (y_place < edge_d):
                x = np.delete(x, 0)
                y = np.delete(y, 0)
            else:
                break

    # crop the image and mask
    # random select 20 images
    if len(box_list) >= 20:
        num_sel = 20
    else:
        num_sel = len(box_list)

    name_pre = img_name[:-4] + '_'
    for iord in range(num_sel):
        order = str(iord)
        order = order.zfill(2)
        name_img_pre = name_pre + order

        iord_r = random.randint(0, len(box_list)-1)
        box = box_list[iord_r]
        del box_list[iord_r]
        utils.save_patch(box, name_img_pre, img, res_img_rp, mask=mask, res_mask_rp=res_mask_rp)

        cont = cont_list[iord_r]
        del cont_list[iord_r]
        utils.save_patch(cont, name_img_pre, img, res_img_cont_rp)

        utils.save_box_ch(box, cont, mask, name_img_pre, res_box_rp)
