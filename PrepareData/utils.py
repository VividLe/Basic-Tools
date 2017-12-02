from PIL import Image
import numpy as np
import os
import random


def cal_mean(patch_box):
    _, _, channels = patch_box.shape
    assert channels == 3

    mean_val = np.zeros(3)
    for i in range(3):
        pixels = patch_box[:,:,i]
        mean_val[i] = np.mean(pixels)
    return mean_val


def crop_patch(point_x, point_y, edge_half, width, height):
    # horizon
    edge_left = point_x - edge_half
    edge_right = point_x + edge_half
    if edge_left < 0:
        edge_left = 0
        edge_right = edge_half * 2
    if edge_right > width:
        edge_right = width
        edge_left = width - edge_half * 2

    # vertical
    edge_up = point_y - edge_half
    edge_down = point_y + edge_half
    if edge_up < 0:
        edge_up = 0
        edge_down = edge_half * 2
    if edge_down > height:
        edge_down = height
        edge_up = height - edge_half * 2

    box_crop = (edge_left, edge_right, edge_up, edge_down)
    return box_crop


def save_patch(box, name_img_pre, img, res_img_rp, mask=None, res_mask_rp=None):
    edge_l = box[0]
    edge_r = box[1]
    edge_u = box[2]
    edge_d = box[3]

    img_c = img[edge_l:edge_r, edge_u:edge_d, :]
    img_c = Image.fromarray(img_c, mode='RGB')
    img_save_name = res_img_rp + name_img_pre + '.png'
    if mask is None:
        img_c = img_c.resize((128, 128))
    img_c.save(img_save_name)

    if mask is not None:
        mask_c = mask[edge_l:edge_r, edge_u:edge_d]
        mask_c = mask_c / 255
        mask_c = Image.fromarray(mask_c, mode='L')
        mask_save_name = res_mask_rp + name_img_pre + '.png'
        mask_c.save(mask_save_name)


def save_box_ch(box, cont, mask, name_img_pre, res_box_rp):
    box_ch = np.zeros(mask.shape, dtype=np.int8)
    edge_l = box[0]
    edge_r = box[1]
    edge_u = box[2]
    edge_d = box[3]
    box_ch[edge_l:edge_r, edge_u:edge_d] = 255
    edge_l = cont[0]
    edge_r = cont[1]
    edge_u = cont[2]
    edge_d = cont[3]
    box_c = box_ch[edge_l:edge_r, edge_u:edge_d]
    box_c = Image.fromarray(box_c, mode='L')
    box_c = box_c.resize((128, 128))
    box_save_name = res_box_rp + name_img_pre + '.png'
    box_c.save(box_save_name)


def save_cont(box, cont, img, name_img_pre, res_box_rp):
    # box
    edge_l = box[0]
    edge_r = box[1]
    edge_u = box[2]
    edge_d = box[3]
    cont_cont = np.random.randint(0, 256, (edge_r-edge_l, edge_d-edge_u, 3), dtype=np.uint8)
    img_tmp = np.copy(img)
    img_tmp[edge_l:edge_r, edge_u:edge_d,:] = cont_cont
    # image
    edge_l = cont[0]
    edge_r = cont[1]
    edge_u = cont[2]
    edge_d = cont[3]
    cont_c = img_tmp[edge_l:edge_r, edge_u:edge_d, :]
    cont_c = Image.fromarray(cont_c, mode='RGB')
    cont_c = cont_c.resize((128, 128))
    box_save_name = res_box_rp + name_img_pre + '.png'
    cont_c.save(box_save_name)


def save_cont_mean(box, cont, img, name_img_pre, res_box_rp):
    # box
    edge_l = box[0]
    edge_r = box[1]
    edge_u = box[2]
    edge_d = box[3]
    patch_box = img[edge_l:edge_r, edge_u:edge_d, :]
    cont_patch = np.empty((edge_r-edge_l, edge_d-edge_u, 3), dtype=np.uint8)
    # implicitly dtype convert
    # mean_val = cal_mean(patch_box)
    mean_val = [119, 108, 95]
    for ich in range(3):
        cont_patch[:, :, ich] = mean_val[ich]
    img_tmp = np.copy(img)
    img_tmp[edge_l:edge_r, edge_u:edge_d, :] = cont_patch
    # image
    edge_l = cont[0]
    edge_r = cont[1]
    edge_u = cont[2]
    edge_d = cont[3]
    cont_c = img_tmp[edge_l:edge_r, edge_u:edge_d, :]
    cont_c = Image.fromarray(cont_c, mode='RGB')
    cont_c = cont_c.resize((64, 64))
    box_save_name = res_box_rp + name_img_pre + '.png'
    cont_c.save(box_save_name)
