echo "Compute mean file of the image set..."
GLOG_logtostderr=0 GLOG_log_dir=./Log/ \
/home/yangle/software/caffe/.build_release/tools/compute_image_mean \
/home/yangle/TCyb/dataset/patch_MSRA/lmdb/train_img_lmdb \
/home/yangle/TCyb/dataset/patch_MSRA/lmdb/imageMean.binaryproto 

echo "Done."