function [B, S, stat]=Sc_Dic_learing(config_file)
%% Evaluate global configuration file
try
    eval(config_file);
catch
    disp('config file failed!')
end
%config_file���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If no Sc_structure specifying codebook
%% give some defaults
if ~exist('Sc')%���ϡ���ֵ����
 %% 100 words is standard setting
  Sc.Codebook_Size = 100;
  %% Max number of sparse coding iterations
  Sc.Max_Iterations = 50;%����������
  %% a small regularization parameter for stablizing
  beta=1e-5;
end
%% load the feature_data
load([FEATURE_DIR,'data_tran.mat']);% use the standarlized features
%% descriptors for the sparse dictionary learning or Online sparse dictionary learning��only use several sequence for each class
temp_index = randperm(size(data_tran{1},2));%��Ϊsize=100,�õ�1��100���������
all_descriptors = [];
for i = 1:size(data_tran,2)  %i��1��5
    for j = 1:size(temp_index,2)/18 % only use a subset (1/19 here) of training data to construct the codebook    j��1��5
        all_descriptors = [all_descriptors;data_tran{i}{temp_index(j)}];%�±�Ϊi��temp_index(j),��i��cell��ĵ�temp_index(j)��
    end                                                                 %{temp_index(j)}������ģ�j��1��5��
end
%�õ�all_descriptors=17*55*6*��2318/19��=17*40260��
clear data_tran; % save memory
%% sparse codebook size
codebook_size = Sc.Codebook_Size;
%% form options structure for saprse coding
cluster_options.maxiters = Sc.Max_Iterations;
cluster_options.verbose  = Sc.Verbosity;
gamma=0.15;
%% OK, now start sparse coding 
[B, S, stat] = do_sparse_coding( all_descriptors', codebook_size, eye(codebook_size), beta, gamma,cluster_options.maxiters);
%% form name to save codebook
%du_mkdir(CODEBOOK_DIR);
fname = [CODEBOOK_DIR , 'Scode','_', num2str(codebook_size) , '.mat']; 
%% save Dictionary to file...
save(fname,'B');%����ΪScode_100.mat
end