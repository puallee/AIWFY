function [bestC,bestsig,besterr] = mypso(X,Y,trainlabel,trainlabel1);

bestC = zeros(1,2);
bestsig = zeros(1,2);
besterr = zeros(1,2);
y_dim = size(Y,2);

for dim=1:y_dim,
% ������ʼ��

%����Ⱥ�㷨�е���������
c1 = 1.6; % c1 belongs to [0,2] c1:��ʼΪ1.5,pso�����ֲ���������
c2 = 1.7; % c2 belongs to [0,2] c2:��ʼΪ1.7,pso����ȫ����������

maxgen=50; % �������� 
sizepop=5; % ��Ⱥ��ģ

popcmax=10^(2); % popcmax:��ʼΪ1000,SVM ����c�ı仯�����ֵ.
popcmin=10^(-1); % popcmin:��ʼΪ0.1,SVM ����c�ı仯����Сֵ.
popgmax=10^(2); % popgmax:��ʼΪ1000,SVM ����g�ı仯�����ֵ
popgmin=10^(-1); % popgmin:��ʼΪ0.01,SVM ����c�ı仯����Сֵ.
k = 0.2; % k belongs to [0.1,1.0];
Vcmax = k*popcmax;%���� c �����ٶ����ֵ  20
Vcmin = -Vcmax ;%-20
Vgmax = k*popgmax;%���� g �����ٶ����ֵ  20
Vgmin = -Vgmax ; %-20

eps = 10^(-3);

% ������ʼ���Ӻ��ٶ�
for i=1:sizepop%5

% ���������Ⱥ
pop(i,1) = (popcmax-popcmin)*rand(1,1)+popcmin ; % ��ʼ��Ⱥ (100-0.1)*rand(1,1)+0.1
pop(i,2) = (popgmax-popgmin)*rand(1,1)+popgmin;  %(100-0.1)*rand(1,1)+0.1
V(i,1)=Vcmax*rands(1,1); % ��ʼ���ٶ� 20*rands(1,1);
V(i,2)=Vgmax*rands(1,1); % -20*rans(1,1);

% �����ʼ��Ӧ��
gam = pop(i,1);
sig2 = pop(i,2);

%���ѵ�����Ͳ��Լ���Ԥ��ֵ

%fitness(i) = fcrossvalidatelssvm(X,'RBF_kernel',gam, sig2 ,Y(:,dim), 5 ,'mae');%������֤
traindata=X;
traindata1=Y;
model = svmtrain(trainlabel'traindata -s 0 -t 2 -c gam -g sig2');
[ptrain,acctrain,decision] = svmpredict(trainlabel1,traindata1,model);
fitness(i)=acctrain(i);
end

% �Ҽ�ֵ�ͼ�ֵ��
[global_fitness ,bestindex]=min(fitness); % ȫ�ּ�ֵ
local_fitness = fitness; % ���弫ֵ��ʼ�� 

global_x = pop(bestindex,:); % ȫ�ּ�ֵ��
local_x = pop; % ���弫ֵ���ʼ��

% ÿһ����Ⱥ��ƽ����Ӧ��
avgfitness_gen = zeros(1,maxgen);%1*50

tic

% ����Ѱ��
for i=1:maxgen%50

for j=1:sizepop% 5

%�ٶȸ�
wV = 1; % wV best belongs to [0.8,1.2]Ϊ���ʸ��¹�ʽ���ٶ�ǰ��ĵ���ϵ��
V(j,:) = wV*V(j,:) + c1*rand*(local_x(j,:) - pop(j,:)) + c2*rand*(global_x - pop(j,:));
if V(j,1) > Vcmax %���¼�������ʽ��Ϊ���޶��ٶ��������С֮��
V(j,1) = Vcmax;
end
if V(j,1) < Vcmin
V(j,1) = Vcmin;
end
if V(j,2) > Vgmax
V(j,2) = Vgmax;
end
if V(j,2) < Vgmin
V(j,2) = Vgmin; %���ϼ�������ʽ��Ϊ���޶��ٶ��������С֮��
end

%��Ⱥ����
wP = 1; % wP:��ʼΪ1,��Ⱥ���¹�ʽ���ٶ�ǰ��ĵ���ϵ��
pop(j,:)=pop(j,:)+wP*V(j,:);
if pop(j,1) > popcmax %���¼�������ʽ��Ϊ���޶� c �������С֮��
pop(j,1) = popcmax;
end
if pop(j,1) < popcmin
pop(j,1) = popcmin;
end
if pop(j,2) > popgmax %���¼�������ʽ��Ϊ���޶� g �������С֮��
pop(j,2) = popgmax;
end
if pop(j,2) < popgmin
pop(j,2) = popgmin;
end


%�������Ÿ���
if fitness(j) < local_fitness(j)
local_x(j,:) = pop(j,:);
local_fitness(j) = fitness(j);
end

if abs( fitness(j)-local_fitness(j) )<=eps && pop(j,1) < local_x(j,1)
local_x(j,:) = pop(j,:);
local_fitness(j) = fitness(j);
end 

%Ⱥ�����Ÿ���
if fitness(j) < global_fitness
global_x = pop(j,:);
global_fitness = fitness(j);
end

if abs( fitness(j)-global_fitness )<=eps && pop(j,1) < global_x(1)
global_x = pop(j,:);
global_fitness = fitness(j);
end
end
fit_gen(i)=global_fitness; 
avgfitness_gen(i) = sum(fitness)/sizepop;

end

toc

bestC(dim) = global_x(1);
bestsig(dim) = global_x(2);
besterr(dim) = fit_gen(maxgen);


%��ӡ��Ϣ
fprintf('\n')
disp(['         ����Ⱥ�㷨���:  [C]         ' num2str(bestC(dim))]);
disp(['                      [sig2]       ' num2str(bestsig(dim))]);
disp(['                      error=       ' num2str(besterr(dim))]);
disp(' ')

end