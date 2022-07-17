clc,clear;close all
%
% packet_num = 800;
packet_num = 100;
length_train = 128;
% device = ['30BC4F3  '; '31E2BEC  '; '310BR054D'; '310BR0558'; '316983F  '; '8000324  '];
device = ['C1'; 'C2'; 'C3'; 'C4'; 'C5'; 'C6'];
distance = ['case1';'case2'];

% day = 'day1';
% 
% label = 'air';
label = 'sim';
day = 'day4.6';
RFData = [];
RFlabel = {};

for type_num = 2:2
    for j = 2:2 %距离
        for k = 1:6 %设备
            
            if type_num == 1
                data_type = 'Data_AfterCarrierSynchronizer';
            end
            if type_num == 2
                data_type = 'Data_AfterRCRxFilter';
            end
            if type_num == 3
                data_type = 'Data_AfterSymbolSynchronizer';
            end
            
            RawDatafile_path = ['D:\MyDoc\KGS\QPSKTxRx\RFSample_Data\',data_type]; % 待读取的文件路径
            device_num = device(k,:);
            device_num(device_num == ' ') = '';
            file_path = RawDatafile_path;
%             filename = ['\Tx',device_num,'_',distance(j,:),'_',label,'_',day,'_Rx316986B'];
            filename = ['\Tx',device_num,'_',distance(j,:),'_',label,'_',day,'_RxC'];
            filename_data = [file_path, filename, '.txt'];

            % meta_Data=loadjson(file_name); % jsonData是个struct结构
            
            fin=fopen(filename_data,'r');
            sample_c = textscan(fin,'%s');
            fclose(fin);
            sample_c = sample_c{1, 1};
            sample = (1+1i)*ones(length(sample_c),1);
            for s_num = 1:length(sample_c)
                sample(s_num) = str2double(cell2mat(sample_c(s_num)));
            end
            %type_num = 2时的分割方案
            sample = reshape(sample,length(sample)/packet_num,packet_num);
            sample = sample(46:end-45,:);
            sample = reshape(sample,[length(sample)*packet_num,1]);
            sample = reshape(sample,length_train,length(sample)/length_train);

%             %type_num = 1或3时的分割方案
%             sample = reshape(sample,length(sample)/packet_num,packet_num);
%             sample = sample(16:end-16,:);
%             sample = reshape(sample,[length(sample)*packet_num,1]);
%             sample = reshape(sample,length_train,length(sample)/length_train);
            
            len_n = length(RFData);
            for idx = 1:length(sample)
                sample_complex128 = sample(:,idx);
                sample_IQ128(1,:) = real(sample_complex128');
                sample_IQ128(2,:) = imag(sample_complex128');
                RFData(:,:,:,idx+len_n) = sample_IQ128;
                RFlabel = [RFlabel;cellstr(device_num)];
            end
        end
    end
end

% RFData = RFData.';
RFlabel = categorical(RFlabel);

save('D2_simRFData.mat','RFData','RFlabel','packet_num','length_train');
