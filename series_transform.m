function [tran,grids,norm1,sub_sequence2] = series_transform(data)
data=mapminmax(data)
tran=[]
for i = 1:20:length(data)-20+1%1��5��300-30+1=271 ;55�����
tra=data(:,i+19);
tran=[tran;tra]
end
end
