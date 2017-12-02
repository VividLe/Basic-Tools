from PIL import Image
import numpy as np
import os

ori_mask_rp = '/home/yangle/BasicDataset/dataset/DAVIS/mGroundTruth/'
ori_img_rp = '/home/yangle/BasicDataset/dataset/DAVIS/mImage/'
res_mask_rp = '/home/yangle/TCyb/dataset/patch_DAVIS/mask/'
res_img_rp = '/home/yangle/TCyb/dataset/patch_DAVIS/image/'

if not os.path.exists(res_mask_rp):
    os.makedirs(res_mask_rp)
if not os.path.exists(res_img_rp):
    os.makedirs(res_img_rp)

mask_set = os.listdir(ori_mask_rp)
for iimg in range(0, len(mask_set), 50):
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

    box_list = []
    boxl = 32
    num_point = len(x)
    # print(num_point)
    while True:
        if len(x) == 0:
            break

        px, py = x[0], y[0]
        # print(px, py)

        # horizon
        edge_l = px - boxl
        edge_r = px + boxl
        if edge_l < 0:
            edge_l = 0
            edge_r = boxl * 2
        if edge_r > wid:
            edge_r = wid
            edge_l = wid - boxl * 2

        # vertical
        edge_u = py - boxl
        edge_d = py + boxl
        if edge_u < 0:
            edge_u = 0
            edge_d = boxl * 2
        if edge_d > hei:
            edge_d = hei
            edge_u = hei - boxl * 2

        # print(edge_l, edge_r, edge_u, edge_d)
        box_crop = (edge_l, edge_r, edge_u, edge_d)
        box_list.append(box_crop)

        # delete points insides the cropped the box
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
    name_pre = img_name[:-4] + '_'
    for iord in range(len(box_list)):
        box = box_list[iord]
        edge_l = box[0]
        edge_r = box[1]
        edge_u = box[2]
        edge_d = box[3]

        order = str(iord)
        order = order.zfill(4)

        mask_c = mask[edge_l:edge_r, edge_u:edge_d]
        # mask_c = mask_c / 255
        mask_c = Image.fromarray(mask_c, mode='L')
        mask_save_name = res_mask_rp + name_pre + order + '.png'
        mask_c.save(mask_save_name)

        img_c = img[edge_l:edge_r, edge_u:edge_d, :]
        img_c = Image.fromarray(img_c, mode='RGB')
        img_save_name = res_img_rp + name_pre + order + '.png'
        img_c.save(img_save_name)

    print('image name: %s, patch number: %d' % (img_name, iord))


