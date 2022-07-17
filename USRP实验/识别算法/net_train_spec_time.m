%%
%train the net
%数据读取与分割
clear variables;
close all;

XTest = [];
XTrain = [];
YTest = [];
YTrain = [];
load('D1_spec_time_RFData.mat','RFData','RFlabel');
%train : Test = 8:2
RFLabel = RFlabel;
Ra = randperm(length(RFLabel));  %创建突发索引

XTrain_tem = zeros(128,16,2,floor(length(RFLabel)*0.8)*3);

temp = 1;
for xx = Ra(1:floor(length(RFLabel)*0.8))

    for yy = 1:3  %每个突发包含3个样本，每个样本size 128*16*2
        XTrain_tem(:,:,:,temp) = RFData(:,1+16*(yy-1) : 16*yy ,:, xx);
%             XTrain = cat(4,XTrain, RFData_4D(:,2+16*(yy-1) : 1+16*yy ,:, xx));
        YTrain = [YTrain; RFLabel(xx)];
        temp = temp+1;
    end
end
XTrain = XTrain_tem;

XTest_tem = zeros(128,16,2,(length(RFLabel)-floor(length(RFLabel)*0.8))*3);
temp = 1;
for xx = Ra(1+floor(length(RFLabel)*0.8) : length(RFLabel))

    for yy = 1:3  %每个突发包含3个样本，每个样本size 128*16*2
        XTest_tem(:,:,:,temp) = RFData(:,1+16*(yy-1) : 16*yy ,:, xx);
        YTest = [YTest; RFLabel(xx)];
%             Test_Tr = [Test_Tr yy];
        temp = temp+1;
    end
end
XTest = XTest_tem;

YTrain = categorical(YTrain);
YTest = categorical(YTest);


%%

% Batch size
miniBatchSize = 500;%500

% Iteration
maxEpochs = 50;%50

ValidationFrequency = 100;
LearnRateDropPeriod = 50;

%%
%训练网络
numClasses = length(categories(RFlabel));
net = netdesign_spec_time(numClasses);
%%
analyzeNetwork(net)

options = trainingOptions('adam', ...
    'ValidationData',{XTest,YTest}, ...
    'ValidationFrequency',ValidationFrequency, ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',1e-4, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.2, ...
    'LearnRateDropPeriod',LearnRateDropPeriod, ...
    'Shuffle','every-epoch', ...
    'Verbose',1, ...
    'Plots','training-progress');
%'ExecutionEnvironment','parallel', ...
tic;
netTransfer = trainNetwork(XTrain,YTrain,net,options);
toc;
save('CNN_spec_train.mat','netTransfer');

%%
%迁移学习
YPred = classify(netTransfer,XTest);
YP= predict(netTransfer,XTest);
accuracy = mean(YPred == YTest);
figure
plotconfusion(YTest,YPred)

YTest_Tr = YTest(1:length(YTest)/3);
YPred_Tr = YTest(1:length(YTest)/3);
for i = 1:length(YTest)/3
    YTest_Tr(i) = YTest(3*i);
end

%迁移学习
% YPred = classify(netTransfer,XTest);
% YP= predict(netTransfer,XTest);
for i = 1:length(YPred)/3
    Y_decision = YPred(1+3*(i-1) : 3*i);
    [M,F,C] = mode(Y_decision);
    if length(C{1,1}) == 1
        YPred_Tr(i) = mode(Y_decision);
    end
    if length(C{1,1}) ~= 1
        Y_decision = YPred(1+3*(i-1) : 3*i);
        index = [];
        for ii = 1:length(C{1,1})
            index = find(Y_decision == C{1,1}(ii));
            YP_decision(ii) = mean(YP(index+3*(i-1),double(string(C{1,1}(ii)))+1));
        end
        YPred_Tr(i) = C{1,1}(find(max(YP_decision)));
    end
%     YPred_Tr(i) = mode(Y_decision);
end
accuracy_Tr = mean(YTest_Tr == YPred_Tr);
figure
plotconfusion(YTest_Tr,YPred_Tr)


