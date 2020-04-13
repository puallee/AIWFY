train =traindatas
train_label = trainlabels
test =testdatas 
test_label =testlabels
[train,pstrain] = mapminmax(train');
pstrain.ymin = 0;
pstrain.ymax = 1;
[train,pstrain] = mapminmax(train,pstrain);
[test,pstest] = mapminmax(test');
pstest.ymin = 0;
pstest.ymax = 1;
[test,pstest] = mapminmax(test,pstest);
train = train';
test = test';
%% ������ʼ��
%����Ⱥ�㷨�е���������
c1 = 1.6; % c1 belongs to [0,2]
c2 = 1.5; % c2 belongs to [0,2]
maxgen=300;   % �������� 
sizepop=30;   % ��Ⱥ��ģ
popcmax=10^(2);
popcmin=10^(-1);
popgmax=10^(3);
popgmin=10^(-2);
k = 0.6; % k belongs to [0.1,1.0];
Vcmax = k*popcmax;
Vcmin = -Vcmax ;
Vgmax = k*popgmax;
Vgmin = -Vgmax ;
% SVM������ʼ�� 
v = 3;
%% ������ʼ���Ӻ��ٶ�
for i=1:sizepop
    % ���������Ⱥ
    pop(i,1) = (popcmax-popcmin)*rand+popcmin;    % ��ʼ��Ⱥ
    pop(i,2) = (popgmax-popgmin)*rand+popgmin;
    V(i,1)=Vcmax*rands(1);  % ��ʼ���ٶ�
    V(i,2)=Vgmax*rands(1);
    % �����ʼ��Ӧ��
    cmd = ['-v ',num2str(v),' -c ',num2str( pop(i,1) ),' -g ',num2str( pop(i,2) )];
    fitness(i) = svmtrain(train_label, train, cmd);
    fitness(i) = -fitness(i);
end
% �Ҽ�ֵ�ͼ�ֵ��
[global_fitness bestindex]=min(fitness); % ȫ�ּ�ֵ
local_fitness=fitness;   % ���弫ֵ��ʼ��
global_x=pop(bestindex,:);   % ȫ�ּ�ֵ��
local_x=pop;    % ���弫ֵ���ʼ��
tic
%% ����Ѱ��
for i=1:maxgen
   
    for j=1:sizepop
       
        %�ٶȸ���
        wV = 0.9; % wV best belongs to [0.8,1.2]
        V(j,:) = wV*V(j,:) + c1*rand*(local_x(j,:) - pop(j,:)) + c2*rand*(global_x - pop(j,:));
        if V(j,1) > Vcmax
            V(j,1) = Vcmax;
        end
        if V(j,1) < Vcmin
            V(j,1) = Vcmin;
        end
        if V(j,2) > Vgmax
            V(j,2) = Vgmax;
        end
        if V(j,2) < Vgmin
            V(j,2) = Vgmin;
        end
       
        %��Ⱥ����
        wP = 0.6;
        pop(j,:)=pop(j,:)+wP*V(j,:);
        if pop(j,1) > popcmax
            pop(j,1) = popcmax;
        end
        if pop(j,1) < popcmin
            pop(j,1) = popcmin;
        end
        if pop(j,2) > popgmax
            pop(j,2) = popgmax;
        end
        if pop(j,2) < popgmin
            pop(j,2) = popgmin;
        end
       
        % ����Ӧ���ӱ���
        if rand>0.5
            k=ceil(2*rand);
            if k == 1
                pop(j,k) = (20-1)*rand+1;
            end
            if k == 2
                pop(j,k) = (popgmax-popgmin)*rand+popgmin;
            end           
        end
       
        %��Ӧ��ֵ
        cmd = ['-v ',num2str(v),' -c ',num2str( pop(j,1) ),' -g ',num2str( pop(j,2) )];
        fitness(j) = svmtrain(train_label', train, cmd);
        fitness(j) = -fitness(j);
    end
   
    %�������Ÿ���
    if fitness(j) < local_fitness(j)
        local_x(j,:) = pop(j,:);
        local_fitness(j) = fitness(j);
    end
   
    %Ⱥ�����Ÿ���
    if fitness(j) < global_fitness
        global_x = pop(j,:);
        global_fitness = fitness(j);
    end
   
    fit_gen(i)=global_fitness;   
       
end
toc
%% �������
plot(-fit_gen,'LineWidth',5);
title(['��Ӧ������','(����c1=',num2str(c1),',c2=',num2str(c2),',��ֹ����=',num2str(maxgen),')'],'FontSize',13);
xlabel('��������');ylabel('��Ӧ��');
bestc = global_x(1)
bestg = global_x(2)
bestCVaccuarcy = -fit_gen(maxgen)
cmd = ['-c ',num2str( bestc ),' -g ',num2str( bestg )];
model = svmtrain(train_label,train,cmd);
[trainpre,trainacc] = svmpredict(train_label,train,model);
trainacc
[testpre,testacc] = svmpredict(test_label,test,model);
testacc
 