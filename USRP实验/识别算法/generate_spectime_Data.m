clc,clear;close all
%
packet_num = 800;
rxSampleRate = 400000;
nfft = 128;
% packet_num = 100;
length_train = 128;
device = ['30BC4F3  '; '31E2BEC  '; '310BR054D'; '310BR0558'; '316983F  '; '8000324  '];
% device = ['C1'; 'C2'; 'C3'; 'C4'; 'C5'; 'C6'];
distance = ['case1';'case2'];
M = 4;
evm = comm.EVM;
release(evm)
evm.ReferenceSignalSource = 'Estimated from reference constellation';
evm.ReferenceConstellation = 2*pskmod(0:M-1,M,pi/M);

day = 'day1';
% 
label = 'air';
% label = 'sim';
% day = 'day4.6';
% SNR_real = 8;
for SNR_real = 9:11
    RFData = [];
    RFlabel = {};


    for type_num = 1:1
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

                RawDatafile_path = ['E:\MyDoc\KGS\QPSKTxRx\RFSample_Data\',data_type]; % 待读取的文件路径
                device_num = device(k,:);
                device_num(device_num == ' ') = '';
                file_path = RawDatafile_path;
                filename = ['\Tx',device_num,'_',distance(j,:),'_',label,'_',day,'_Rx316986B'];
    %             filename = ['\Tx',device_num,'_',distance(j,:),'_',label,'_',day,'_RxC'];
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
    %             sample = reshape(sample,length(sample)/packet_num,packet_num);
    %             sample = sample(46:end-45,:);
    %             sample = reshape(sample,[length(sample)*packet_num,1]);
    %             sample = reshape(sample,length_train,length(sample)/length_train);

                %type_num = 1或3时的分割方案
                sample = reshape(sample,length(sample)/packet_num,packet_num);
                len_n = length(RFData);
                m = 0;
                for ii = 1:packet_num
                    sample_temp = sample(:,ii);
                    rmsEVM = evm(sample_temp(1:5614));
                    snr_p = (100/rmsEVM)^2;
                    snr = 10*log10(snr_p);
                    
                    SNR_Y = 10 * log10 ((1 + 1/snr_p)/(1/(10^(SNR_real/10)) - 1/snr_p));
                    if isreal(SNR_Y)
                        m = m + 1;
                        sample_temp = awgn(sample_temp,SNR_Y,'measured');

                        spec_time = spectrogram(sample_temp,ones(nfft,1),0,nfft,'centered',rxSampleRate,'yaxis','MinThreshold',-150);
                        spec_time_real=real(spec_time);
                        spec_time_imag=imag(spec_time);
                        spec_time_3D=cat(3,spec_time_real,spec_time_imag);
                        RFData(:,:,:,m+len_n)=spec_time_3D;  
                        RFlabel = [RFlabel;cellstr(device_num)];
                    end
                end
            end
        end
    end

    % RFData = RFData.';
    RFlabel = categorical(RFlabel);

    save(['D1_spec_time_RFData_SNR=',num2str(SNR_real),'.mat'],'RFData','RFlabel','packet_num','rxSampleRate','nfft');
end
