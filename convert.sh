#! /bin/bash


PATTERN=/mnt/nas_crdataset2/rodnet/speed_data/*/mat/
for mat in $PATTERN
do
    python read_mat.py $mat
done

sudo python organize_frame.py data/2019_09_18_onrd004/start_time.txt /mnt/nas_crdataset2/rodnet/speed_data/2019_09_18_onrd004/sp_map
sudo python organize_frame.py data/2019_09_18_onrd009/start_time.txt /mnt/nas_crdataset2/rodnet/speed_data/2019_09_18_onrd009/sp_map
sudo python organize_frame.py data/2019_09_29_onrd012/start_time.txt /mnt/nas_crdataset2/rodnet/speed_data/2019_09_29_onrd012/sp_map
sudo python organize_frame.py data/2019_10_13_onrd048/start_time_h.txt /mnt/nas_crdataset2/rodnet/speed_data/2019_10_13_onrd048/sp_map