%function []=Ksvd_OMP()
%try
    %eval(config_file);
%catch
    %disp('config file failed!')
%end
%% load the feature_data
%load([FEATURE_DIR,'data_tran.mat']);% use the standarlized features
%% descriptors for the sparse dictionary learning or Online sparse dictionary learning��only use several sequence for each class
temp_index = randperm(size(data_tran{1},2));%��Ϊsize=100,�õ�1��100���������
all_descriptors = [];
for i = 1:size(data_tran,2)  %i��1��5
    for j = 1:size(temp_index,2)/18 % only use a subset (1/19 here) of training data to construct the codebook    j��1��5
        all_descriptors = [all_descriptors;data_tran{i}{temp_index(j)}];%�±�Ϊi��temp_index(j),��i��cell��ĵ�temp_index(j)��
    end                                                                 %{temp_index(j)}������ģ�j��1��5��
end
param.K=100;  % learns a dictionary with 100 elements
param.lambda=0.15;
param.numIteration=50;
param.preserveDCAtom=1;
param.displayProgress=1;
 [Dictionary,output] = KSVD(all_descriptors,param)