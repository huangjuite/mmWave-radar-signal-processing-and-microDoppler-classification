
import os
import argparse
import PIL
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
from PIL import Image
from tqdm import tqdm
from os.path import join as pjoin

VEL_SCALE = 0.0633692797111743

parser = argparse.ArgumentParser(description='read mat file.')
parser.add_argument('directory', help='directory of mat files.')
arg = parser.parse_args()

mat_dir = arg.directory
mat_files = os.listdir(mat_dir)
mat_files.sort()


def mkd(name):
    try:
        os.makedirs(name)
    except:
        pass


save_vis_folder = pjoin(mat_dir, '../vis/sp')
save_speed_folder = pjoin(mat_dir, '../sp_full')
mkd(save_vis_folder)
mkd(save_speed_folder)


def read_mat(f):
    mat = sio.loadmat(f)
    return mat['Dopdata_crop']


def get_speed(dop, thresh=2e5):
    mag = np.abs(dop)
    sp = np.argmax(mag, axis=2)
    mag = np.max(mag, axis=2)
    mag[mag > thresh] = thresh
    mag = mag/thresh
    sp = (sp-128) * VEL_SCALE
    sp *= mag
    return mag, sp


def save_fig(v, name, vmin=VEL_SCALE*-128, vmax=VEL_SCALE*127):
    # plt.imshow(v, vmin=vmin, vmax=vmax, extent=[-60, 60, 2, 25])
    fig, ax = plt.subplots()
    im = ax.imshow(v, origin='lower', vmin=vmin,
                   vmax=vmax, extent=[-60, 60, 2, 25])
    ax.set_aspect(5)
    fig.colorbar(im)
    plt.savefig(name)
    plt.close()


for f in tqdm(mat_files):
    frame = int(f[6:12])
    dop_cube = read_mat(pjoin(mat_dir, f))
    # dop_cube = np.flipud(dop_cube)
    mag, sp = get_speed(dop_cube)
    save_fig(sp, pjoin(save_vis_folder, '%04d.png' % frame))
    np.save(pjoin(save_speed_folder, '%04d.npy' % frame), sp)
