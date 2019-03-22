from utils import decode_segmap
import numpy as np
from PIL import Image

mask = Image.open('mask.png')
mask_np = np.asarray(mask, dtype=np.uint8)
mask_color = decode_segmap(mask_np, 'pascal') * 255
mask_color = mask_color.astype(np.uint8)
mask_c_img = Image.fromarray(mask_color, mode='RGB')
mask_c_img.save('color.png')
