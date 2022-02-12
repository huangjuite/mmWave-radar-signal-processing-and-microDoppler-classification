#!/usr/bin/env python

from datetime import date
import os
import argparse
import matlab.engine
from os.path import join as pjoin

file_folder = 'data/2019_04_30_mlms001/rad_reo_zerf'
file_name = '2019_04_30_mlms001'

file_location = os.getcwd()
eng = matlab.engine.start_matlab()
eng.addpath(file_location)
eng.process(file_folder, file_name, nargout=0)

