clc;clear;close all

%假设所有传输过程是完美传输
% global Acc N_R N_G N_MU
Acc_L = 0.99:0.001:1;%识别平均准确率，不考虑在同一时频资源下的性能下降

N_R = 64; %资源格数量0~15
N_G = 15; %扩频码数量0~7     

%%%%%N_R与N_G需要互质

N_MU = 5; %边缘节点数量
N = 100000;%仿真次数
p_c = [];%中心节点认证成功次数/概率
p_s = [];%网格与扩频码选择不冲突的次数/概率
p_m = [];%边缘节点认证成功次数/概率
p_k = [];%成功生成密钥次数/概率
P_kT = [];%成功生成密钥概率理论值
for i = 1:length(Acc_L)
    Acc = Acc_L(i);
    N_c = 0;N_s = 0;N_m = 0;N_k = 0;
    for p = 1:N
        p_pass_aut = binopdf(N_MU,N_MU ,Acc);%%%认证中心节点
        Aut = randsrc(1,1,[[1 0]; [p_pass_aut 1-p_pass_aut]]);%中心节点是否认证成功
        N_c = N_c+Aut;
        if Aut == 1
            ck = randi(2^8,1,N_MU)-1;%明文长度假设为128bits
%             ck = floor(2^8*rand(1,N_MU));
            N_Rb = mod(ck,N_R);
            N_Gc = mod(ck,N_G);

            for k = 0:N_G-1%判断是否有资源格与扩频码选择冲突
                uniq = 0;%0表示选择不冲突；非0表示冲突
                gc_same = find(N_Gc == k);
                if length(gc_same) >1
                    N_Rb_temp = N_Rb(gc_same);
                    uniq=length(N_Rb_temp)-length(unique(N_Rb_temp));
                    if uniq ~= 0
                        break
                    end
                end
            end

            if uniq == 0
                N_s = N_s+1;
                p_pass_aut = binopdf(N_MU,N_MU ,Acc);%%%认证边缘节点
                Aut_m = randsrc(1,1,[[1 0]; [p_pass_aut 1-p_pass_aut]]);%边缘节点是否全部认证成功
                N_m = N_m+Aut_m;
                if Aut_m == 1
                    p_pass_aut = binopdf(N_MU-1,N_MU-1 ,Acc);%每个边缘节点识别其他边缘节点
                    p_pass = binopdf(N_MU,N_MU,p_pass_aut);%边缘节点全部成功识别其他节点
                    Aut_k = randsrc(1,1,[[1 0]; [p_pass 1-p_pass]]);%边缘节点是否全部被其他节点识别成功
                    N_k = N_k+Aut_k;%成功生成密钥次数
                end
            end

        end
    end
    p_c = [p_c N_c/N];
    p_s = [p_s N_s/N];
    p_m = [p_m N_m/N];
    p_k = [p_k N_k/N];
    E_Nv = 1./p_k;
    %%理论值
    p_pass_aut = binopdf(N_MU-1,N_MU-1 ,Acc);%每个边缘节点识别其他边缘节点
    p_pass = binopdf(N_MU,N_MU,p_pass_aut);%边缘节点全部成功识别其他节点
    P_kT = [P_kT Acc^N_MU * Acc^N_MU * p_pass];
end



figure(1)
semilogy(Acc_L,p_c,'-*',Acc_L,p_s,'-o',Acc_L,p_m,'-^',Acc_L,p_k,'-+',Acc_L,P_kT,'-v')
legend('中心节点认证成功率','网格与扩频码选择不冲突率',...
    '边缘节点全部认证成功率','成功生成密钥率','成功生成密钥率理论值')
xlabel('Recognition Accuracy')
ylabel('Success Rate(SR)')
figure(2)
semilogy(Acc_L,E_Nv,'-*')
xlabel('Recognition Accuracy')
ylabel('E(N_v)')
% semilogy

