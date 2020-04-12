function [sc_codes,signal_patch] = signal_pooling(X, B, pyramid, gamma, knn,grids)
%================================================
%% �Ǹ��ֵ����

dSize = size(B, 2);%100
nSmp = size(X, 1);%55
signal_length = grids.tol(2),%300
%idxBin = zeros(nSmp, 1);%55x1 double
sc_codes = zeros(dSize, nSmp);%100x55 double
% compute the local feature for each local feature
D = X*B;%ͼƬ���ֵ���ˣ�55*17*17*100=55*100
IDX = zeros(nSmp, knn);%55x200 double
for ii = 1:nSmp,%55
	d = D(ii, :);%d=1*100
	[dummy, idx] = sort(d, 'descend');%�������У�dummy1*100��idx1*100
	IDX(ii, :) = idx(1:knn);%��idx�������е�ǰ20��
end
%IDX����Ϊ55*20,20Ϊidx
for ii = 1:nSmp,%55
    y = X(ii,:)';%17*1
    idx = IDX(ii, :);%ȡ20����idx�ó���,1*20
    BB = B(:, idx);%100�����ʵ��ֵ䰴idx�������е�ǰ20����17*20���������Ϊ�ֵ��ͼƬ��˺�ֻ��ÿ��SIFT����ǰ20�������йأ����治��
    sc_codes(idx, ii) = feature_sign(BB, y, 2*gamma);% 2*gamma=0.3
    %������Andrew Ng��L1������⣬�����ݶȷ���⣻
end
sc_codes = abs(sc_codes);
%% pooling,�ֵ�ֱ��ͼ����
grids.f=sc_codes;%���뵽�ṹ����
% Times levels
pLevels = length(pyramid);%3
tBins = sum(pyramid);%1+2+4=7
signal_patch = zeros(dSize, tBins);%100x7 double
bId = 0;
pat=1;
c=1;
grids.x=grids.x+15;
for iter1 = 1:pLevels,%3
   if iter1==3;
       c=0;
    end
   nBins = pyramid(iter1);%1,2,4;
  for i=1:pat;
   x_l=floor(signal_length/pat*(i-1));
   x_h=floor(signal_length/pat*i);
   signal_patch(:,i+iter1-c)=max(grids.f(:,(grids.x>x_l)&(grids.x<x_h)),[],2);
   end
   pat=pat*2;
end
%% signal_patchΪֱ��ͼ��ʾ��maxʱʧȥ��һ������Ϣ��ʱ�������ƥ��һ���̶��ϱ�������Ӧ��ʱ����Ϣ
%% sc_codesΪ���źŵķǸ���ϡ���ʾ���������������ź�������


