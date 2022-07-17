clc,clear
% n = 7;
g = 5;
n_x = 0;
%0≤x≤p≤m,m+g≤2^n,g≥0,2^k≤m,2^n/n∈Z^+
Psol = [];
nlist = 3:8;
for n = nlist
    Psolve = 1/(nchoosek(n+g,n-n_x)*prod(1:n-n_x));
    Psol = [Psol Psolve];
end
hold on
plot(nlist, Psol,'-o','DisplayName',['添加人工噪声的节点数量g = ',num2str(g)])
% plot(nlist, -log(Psol),'-o','DisplayName',['边缘节点数量 n=',num2str(n)])
% xlabel('射频特征遭到泄露节点数量','FontSize',13,'Color','k')%k
% xlabel('添加人工噪声的格点数量','FontSize',13,'Color','k')%k
xlabel('边缘节点数量','FontSize',13,'Color','k')%k

legend('FontSize',12)
ylabel('密钥被攻破概率','FontSize',13,'Color','k')

% hold on
% plot(glist, -log(Psol),'-o','DisplayName',['Total Number of Terminals m=',num2str(m)])
% xlabel('The Number of Noise Grids','FontSize',13,'Color','k')%g

% plot(nlist, -log(Psol),'-o','DisplayName',['Total Number of Terminals m=',num2str(m)])
% xlabel('The Number of Time-Frequency Resource Grids(log_2)','FontSize',13,'Color','k')%n

% plot(plist, -log(Psol),'-o','DisplayName',['Total Number of Terminals m=',num2str(m)])
% xlabel('The Number of Terminals of RF Feature Leakage','FontSize',13,'Color','k')%p

% plot(mlist, -log(Psol),'-o','DisplayName',['The Number of Terminals of RF Feature Leakage p=',num2str(p)])
% xlabel('Total Number of Terminals','FontSize',13,'Color','k')%m

