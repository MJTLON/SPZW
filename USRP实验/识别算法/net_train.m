%%
%train the net
%数据读取与分割
clear variables;
close all;

distance = 'case1';%case1 case2 case12 D1_case1

% Load training data and essential parameters
load([distance,'RFData.mat'],'RFData','RFlabel');
% x_d = find(RFlabel == '8000324');
% RFData(:,:,:,x_d) = [];
% RFlabel(x_d) = [];
load('noise_RFData.mat','noise_RFData','noise_RFlabel');
RFData = cat(4, RFData, noise_RFData);
RFlabel = cat(1, RFlabel, noise_RFlabel);
n_train = 0.7;

ndata = length(RFData);     %ndata表示数据集样本数

R = randperm(ndata);    %创建索引

XTrain = RFData(:,:,:,R(1:ndata*n_train));%以索引的前70%数据点作为测试样本Xtrain

YTrain = RFlabel(R(1:ndata*n_train),:);  % 设置测试集样本标签

XValidation = RFData(:,:,:,R((ndata*n_train+1):end));

YValidation = RFlabel(R((ndata*n_train+1):end),:);

%%

% Batch size
miniBatchSize = 500;

% Iteration
maxEpochs = 50;

%%
%训练网络
net = netdesign;
%%

analyzeNetwork(net)

options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');
tic;
netTransfer = trainNetwork(XTrain,YTrain,net,options);
toc;
save(['CNN_',distance,'_noise.mat'],'netTransfer');

%%
%迁移学习
YPred = classify(netTransfer,XValidation);

accuracy = mean(YPred == YValidation);
plotconfusion(YValidation,YPred)
