# -*- coding: utf-8 -*-
"""
Created on Mon Sep 30 21:17:48 2019

@author: cain
"""

import sys
import numpy as np
import scipy.io as scio
from keras.models import load_model
import os

if(len(sys.argv) == 1):
    print('no input parameters')
    exit('error')
    
tmp_path = sys.argv[1]
subs = os.listdir(tmp_path)

# designed for user with low RAM. For the users who have large RAM, the order 
# could be changed as: 1)load all 6 keras model, 2) loop all subs only once
DR_model_tmp = load_model('mov_5_final.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    [rsc1_tmp, rsc2_tmp, rsc3_tmp] = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_mov.mat'),{'mov1':rsc1_tmp,'mov2':rsc2_tmp,'mov3':rsc3_tmp})
    
DR_model_tmp = load_model('rot_5_final.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    [rot12_tmp, rot13_tmp, rot23_tmp] = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_rot.mat'),{'rot12':rot12_tmp,'rot13':rot13_tmp,'rot23':rot23_tmp})

exit()
    
    
    
    
    


