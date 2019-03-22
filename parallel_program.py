'''
an exemplar for parallel program
based on multiprocessing module
'''

import time
from multiprocessing import Pool
import os
import shutil

ori_rp = 'C:/Users/leyang/Desktop/12-18/parallel/ori/'
res_rp = 'C:/Users/leyang/Desktop/12-18/parallel/res/'


def img_copy(img_name):
    # print(img_name)
    shutil.copyfile(ori_rp+img_name, res_rp+img_name)

if __name__ == '__main__':
    num_processor = 6
    name_set = os.listdir(ori_rp)

    t1 = time.time()
    for name in name_set:
        img_copy(name)
    e1 = time.time() - t1
    print('order time: ', e1)

    t2 = time.time()
    pool = Pool(num_processor)
    run = pool.map(img_copy, name_set)
    pool.close()
    pool.join()
    e2 = time.time() - t2
    print('parallel time: ', e2)

if __name__ == '__main__':
    num_processor = 32
    name_set = os.listdir(ref_rp)

    pool = Pool(num_processor)
    run = pool.map(mask_color, name_set)
    pool.close()
    pool.join()
