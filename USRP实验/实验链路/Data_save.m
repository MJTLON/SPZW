% packet_num = 800;
% distance = 'case2';
% tx = '310BR054D';
% rx = '316986B';
% label = 'air';
% day = 'day1';
packet_num = 100;
distance = 'case2';
tx = 'C6';
rx = 'C';
label = 'sim';
day = 'day4.6';

% samplenum_AfterCarrierSynchronizer = Data_AfterCarrierSynchronizer.signals.dimensions(1);
% data_AfterCarrierSynchronizer = Data_AfterCarrierSynchronizer.signals.values((end + 1 - packet_num * samplenum_AfterCarrierSynchronizer):end,:);

samplenum_AfterRCRxFilter = Data_AfterRCRxFilter.signals.dimensions(1);
data_AfterRCRxFilter = Data_AfterRCRxFilter.signals.values((end + 1 - packet_num * samplenum_AfterRCRxFilter):end,:);

% samplenum_AfterSymbolSynchronizer = Data_AfterSymbolSynchronizer.signals.dimensions(1);
% data_AfterSymbolSynchronizer = Data_AfterSymbolSynchronizer.signals.values((end + 1 - packet_num * samplenum_AfterSymbolSynchronizer):end,:);

% filename = ['D:\MyDoc\KGS\QPSKTxRx\RFSample_Data\Data_AfterRCRxFilter\','Tx',tx,'_',distance,'_',label,'_',day,'_Rx',rx,'.txt'];
% dlmwrite(filename,data_AfterCarrierSynchronizer)

filename = ['D:\MyDoc\KGS\QPSKTxRx\RFSample_Data\Data_AfterRCRxFilter\','Tx',tx,'_',distance,'_',label,'_',day,'_Rx',rx,'.txt'];
dlmwrite(filename,data_AfterRCRxFilter)

% filename = ['D:\MyDoc\KGS\QPSKTxRx\RFSample_Data\Data_AfterRCRxFilter\','Tx',tx,'_',distance,'_',label,'_',day,'_Rx',rx,'.txt'];
% dlmwrite(filename,data_AfterSymbolSynchronizer)

scatterplot(data_AfterRCRxFilter(1:samplenum_AfterRCRxFilter))

% clear
