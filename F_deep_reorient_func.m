function out = F_deep_reorient_func(rest_path,T1_path,output_path,tmp_path,clear_flag)
%main function of Deep Reorient Toolbox (DRT)
% input_path: the path of input T1 MRI data, It is recommended to put 
% the files as the T1Img Dir in DPABI format:
%     input_path----sub01----XXX.nii
%               ----sub02----XXX.nii
%               ----sub n----XXX.nii
% '-out_path' output_path: the path to store output files. It should be
% different from input_path
% tmp_path: DRT utilized Matlab/Python
% coding, a temporary path was needed to store files which was used to
% communicate between Matlab and Python. It should be an empty dir.
% '-clear_tmpfile' 1/0: whether to clear the temporaty file created by DRT.
% The default parameter is 1 (true). If the user want to check the
% temporary files, it should be set as 0.

%% initial parameters
DRT_path = fileparts(which('F_deep_reorient_func'));
if(~exist(tmp_path,'dir'))
    mkdir(tmp_path);
else
    tmp_file = dir(tmp_path);
    if(length(tmp_file)~=2)
        error('tmp_path should be an empty dir');
    end
end
if(nargin==4)
    clear_flag=1;
end

disp('preparing data');

%% coregister T1 to rest
subs = dir(rest_path);
subs(1:2) = [];
load([DRT_path,filesep,'coregist_est.mat'],'matlabbatch');
for i = 1:length(subs)
    sub_name = subs(i).name;
    if(~exist([tmp_path,filesep,sub_name],'dir'))
        mkdir([tmp_path,filesep,sub_name]);
    end
    if(~exist([output_path,filesep,sub_name],'dir'))
        mkdir([output_path,filesep,sub_name]);
    end
    
    rest_niis = dir([rest_path,filesep,sub_name,filesep,'*.nii']);
    T1_niis = dir([T1_path,filesep,sub_name,filesep,'*.nii']);
    rest_nii_name = rest_niis(1).name;
    T1_nii_name = T1_niis(1).name;
    copyfile([T1_path,filesep,sub_name,filesep,T1_nii_name],...
        [tmp_path,filesep,sub_name,filesep,'T1.nii']);
    matlabbatch{1}.spm.spatial.coreg.estimate.ref{1} = ...
        [rest_path,filesep,sub_name,filesep,rest_nii_name,',1'];
    matlabbatch{1}.spm.spatial.coreg.estimate.source{1} = ...
        [tmp_path,filesep,sub_name,filesep,'T1.nii,1'];
    spm_jobman('run',matlabbatch);
    if(exist([tmp_path,filesep,sub_name,filesep,'T1.mat'],'file'))
        delete([tmp_path,filesep,sub_name,filesep,'T1.mat']);
    end
end
    

%% prepare data
input_path = tmp_path;
subs = dir(input_path);
subs(1:2) = [];
for i = 1:length(subs)
    sub_name = subs(i).name;
    if(~exist([tmp_path,filesep,sub_name],'dir'))
        mkdir([tmp_path,filesep,sub_name]);
    end
    if(~exist([output_path,filesep,sub_name],'dir'))
        mkdir([output_path,filesep,sub_name]);
    end
    
    niis = dir([input_path,filesep,sub_name,filesep,'*.nii']);
    if(length(niis) ~= 1)
        niis = dir([input_path,filesep,sub_name,filesep,'*.img']);
    end
    if(length(niis) ~= 1)
        error(['please the Nifti files of ',sub_name]);
    end
    nii_name = niis(1).name;
    
    [data4,head4] = y_Reslice([input_path,filesep,sub_name,filesep,nii_name],...
        [tmp_path,filesep,sub_name,filesep,'v4_',nii_name],[4,4,4],1,'ImageItself');
    data4 = squeeze(data4(:,:,:,1));
    x_st = floor((80-size(data4,1))/2)-1;
    y_st = floor((80-size(data4,2))/2)-1;
    z_st = floor((80-size(data4,2))/2)-1;
    point_st = [x_st;y_st;z_st];
    
    data4_tmp = zeros(80,80,80);
    data4_tmp(x_st+1:x_st+size(data4,1),...
        y_st+1:y_st+size(data4,2),...
        z_st+1:z_st+size(data4,3)) = data4;
    data4_tmp = data4_tmp(9:72,9:72,9:72);

    a = data4_tmp(data4_tmp>0);
    a = a./max(a);
    b = histeq(a);
    data4_tmp(data4_tmp>0) = b;
    head4_mat = head4.mat;
    
    save([tmp_path,filesep,sub_name,filesep,'data_he.mat'],'point_st',...
        'data4_tmp','head4_mat','-v6');
end
disp('done');

%% call DRT.py 
% perparing reorienting parameters
curr_path = cd(DRT_path);
disp('Reorienting');
eval(['!python F_Reorient.py ',tmp_path]);
cd(curr_path);
disp('done');

%% apply DRT parameters to the niis
for i = 1:length(subs)
    sub_name = subs(i).name;
    niis = dir([tmp_path,filesep,sub_name,filesep,'T1.nii']);
    if(length(niis) ~= 1)
        niis = dir([tmp_path,filesep,sub_name,filesep,'T1.img']);
    end
    if(length(niis) ~= 1)
        error(['please the Nifti files of ',sub_name]);
    end
    nii_name = niis(1).name;
    [~,head_org] = y_Read([tmp_path,filesep,sub_name,filesep,nii_name]);
    head_org_mat = head_org.mat;
    load([tmp_path,filesep,sub_name,filesep,'data_he.mat'],'head4_mat','point_st');
    
    load([tmp_path,filesep,sub_name,filesep,'DR_para_rot12.mat'],'rot12');
    load([tmp_path,filesep,sub_name,filesep,'DR_para_rot13.mat'],'rot13');
    load([tmp_path,filesep,sub_name,filesep,'DR_para_rot23.mat'],'rot23');
    load([tmp_path,filesep,sub_name,filesep,'DR_para_mov1.mat'],'mov1');
    load([tmp_path,filesep,sub_name,filesep,'DR_para_mov2.mat'],'mov2');
    load([tmp_path,filesep,sub_name,filesep,'DR_para_mov3.mat'],'mov3');
    rsc4_tmp = [[mov1;mov2;mov3]-point_st;1];
    mni4_tmp = head4_mat*rsc4_tmp;
    rsc_org_tmp = head_org_mat\mni4_tmp;
    
    rot12_tmp = rot12;
    rot12_mat = diag(ones(1,4));
    rot12_mat(1,2) = rot12_tmp;
    rot12_mat(2,1) = -rot12_tmp;
    rot12_mat(1,1) = sqrt(1-rot12_tmp^2);
    rot12_mat(2,2) = sqrt(1-rot12_tmp^2);
    
    rot13_tmp = rot13;
    rot13_mat = diag(ones(1,4));
    rot13_mat(1,3) = rot13_tmp;
    rot13_mat(3,1) = -rot13_tmp;
    rot13_mat(1,1) = sqrt(1-rot13_tmp^2);
    rot13_mat(3,3) = sqrt(1-rot13_tmp^2);
    
    rot23_tmp = rot23;
    rot23_mat = diag(ones(1,4));
    rot23_mat(2,3) = rot23_tmp;
    rot23_mat(3,2) = -rot23_tmp;
    rot23_mat(2,2) = sqrt(1-rot23_tmp^2);
    rot23_mat(3,3) = sqrt(1-rot23_tmp^2);
    
    head_roted_mat = head_org_mat*inv(rot23_mat)*inv(rot13_mat)*inv(rot12_mat);
    head_roted_mat = head_roted_mat(1:3,1:3);
    rsc_org_tmp = rsc_org_tmp(1:3);
    mni_org_tmp = -1.*head_roted_mat*rsc_org_tmp;
    head_roted_moved_mat = head_roted_mat;
    head_roted_moved_mat(1:3,4) = mni_org_tmp;
    head_roted_moved_mat(4,1:3) = 0;
    head_roted_moved_mat(4,4)= 1;
%     head_reoriented = head_org;
%     head_reoriented.mat = head_roted_moved_mat;
    rest_niis = dir([rest_path,filesep,sub_name,filesep,'*.nii']);
    rest_nii_name = rest_niis(1).name;
    copyfile([rest_path,filesep,sub_name,filesep,rest_nii_name],...
        [output_path,filesep,sub_name,filesep,'r_',rest_nii_name]);
    [~,head_rest_tmp] = y_Read([output_path,filesep,sub_name,filesep,'r_',rest_nii_name]);
    head_rest_org_mat = head_rest_tmp.mat;
    tran_mat = head_roted_moved_mat*inv(head_org_mat);
    head_rest_reorient_mat = tran_mat*head_rest_org_mat;
    spm_get_space([output_path,filesep,sub_name,filesep,'r_',rest_nii_name],...
        head_rest_reorient_mat);
    delete([output_path,filesep,sub_name,filesep,'r_*.mat']);
%     y_Write(data_org,head_reoriented,[output_path,filesep,sub_name,filesep,'r_',nii_name]);
end

%% coregister to T1 images




if(clear_flag)
    rmdir(tmp_path,'s');
end