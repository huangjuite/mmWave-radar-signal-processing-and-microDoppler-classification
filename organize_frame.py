
import os
import numpy as np
import argparse
from os.path import join as pjoin
from shutil import copy, copyfile


def get_sec(time_str):
    """Get Seconds from time."""
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + float(s)


def calculate_frame_offset(start_time_txt):
    try:
        hhmmss = np.zeros((3, ))
        two_start_time = False
        with open(start_time_txt, 'r') as f:
            data = f.readlines()

        if len(data) <= 1:
            return 0, None, None

        start_time_readable = data[:3]
        if start_time_readable[2].rstrip() == '':
            two_start_time = True

        for idx, line in enumerate(start_time_readable[:2]):
            hhmmss_str = line.split(' ')[1]
            hhmmss[idx] = get_sec(hhmmss_str)

        offset01 = (hhmmss[1] - hhmmss[0]) * 30
        offset01 = int(round(offset01))

        if not two_start_time:
            offset02 = (hhmmss[2] - hhmmss[0]) * 30
            offset12 = (hhmmss[2] - hhmmss[1]) * 30

            offset02 = int(round(offset02))
            offset12 = int(round(offset12))

            return offset01, offset02, offset12

        return offset01, None, None

    except:
        return 0, None, None


def trim_frame(folder, offset):
    offset += 40
    files = os.listdir(folder)
    files.sort()
    new_folder = pjoin(folder, '../sp_new')
    try:
        os.mkdir(new_folder)
    except:
        pass

    files = files[offset:]
    for i, f in enumerate(files):
        frame = int(f.split('.')[0])
        f = pjoin(folder, f)
        nf = pjoin(new_folder, "%04d.npy" % i)
        copy(f, nf)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='read offset.')
    parser.add_argument('file', help='start time file.')
    parser.add_argument('npyfolder', help='np folder.')
    arg = parser.parse_args()

    offsets = calculate_frame_offset(arg.file)
    print(offsets)
    trim_frame(arg.npyfolder, offsets[0])
