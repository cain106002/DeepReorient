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
DR_model_tmp = load_model('DR_model_rot12.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    rot12_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_rot12.mat'),{'rot12':rot12_tmp})
    
DR_model_tmp = load_model('DR_model_rot13.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    rot13_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_rot13.mat'),{'rot13':rot13_tmp})
    
DR_model_tmp = load_model('DR_model_rot23.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    rot23_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_rot23.mat'),{'rot23':rot23_tmp})
    
DR_model_tmp = load_model('DR_model_mov1.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    mov1_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_mov1.mat'),{'mov1':mov1_tmp})
    
DR_model_tmp = load_model('DR_model_mov2.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    mov2_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_mov2.mat'),{'mov2':mov2_tmp})
    
DR_model_tmp = load_model('DR_model_mov3.h5')
data_he_tmp = np.zeros([1,64,64,64,1],dtype='float16')
for sub_name in subs:
    mat_tmp_path = os.path.join(tmp_path,sub_name,'data_he.mat')
    mat_tmp = scio.loadmat(mat_tmp_path)
    data_he_tmp[0,:,:,:,0] = mat_tmp['data4_tmp']
    mov3_tmp = DR_model_tmp.predict(data_he_tmp)
    scio.savemat(os.path.join(tmp_path,sub_name,'DR_para_mov3.mat'),{'mov3':mov3_tmp})
    
exit()
    
    
    
    
    


