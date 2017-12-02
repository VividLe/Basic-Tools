echo "Creating train rgb lmdb..."

/home/yangle/software/caffe/.build_release/tools/convert_imageset \
/home/yangle/TCyb/dataset/patch_MSRA/image/ \
/home/yangle/TCyb/dataset/patch_MSRA/name.txt \
/home/yangle/TCyb/dataset/patch_MSRA/lmdb/train_img_lmdb \

echo "Done."
