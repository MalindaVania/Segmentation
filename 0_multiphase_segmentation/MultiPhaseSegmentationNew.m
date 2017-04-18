function [M3D_scale, phi_AGMC_3D] = MultiPhaseSegmentationNew(M3D, sgm, omg, Index)

 %% AGMC
[~,bin0]=hist(M3D(:),256); % original histogram
M3D_scale=Rescale(M3D,[],[],0,1);
[counts,bin]=hist(M3D_scale(Index),256); % scaled histogram
h=counts/sum(counts); % probability distribution function
[ Intv_str,Intv_end ] = AGMC_New( h,sgm,omg,bin0,M3D );

%  plot(bin0,h,'k-','LineWidth',4); 
%  pause;
%% 끝부분 cluster로 인정
% Intv_str=[Intv_str Intv_end(end)+1];
% Intv_end=[Intv_end 256];
N=length(Intv_str);  
PlotHistogram(Intv_str,Intv_end,bin0,h)
% pause;
 %% Initialize phi    
% Each Centres
for i=1:length(Intv_str)
    Intv=Intv_str(i):Intv_end(i);
    c(i)=sum(bin(Intv).*h(Intv))/sum(h(Intv)+eps);
end
c=sort(c,'ascend');
% Initialize
u=M3D_scale(:); init_phi=zeros(size(M3D_scale));
Min_org=min(u(:));  Max_org=max(u(:));    
for k=1:N
   if k==1
       init_phi(u(:)<=(c(1)+c(2))/2)=k;
   elseif k==N
       init_phi((c(k-1)+c(k))/2<u(:))=k;
   else       
       init_phi((c(k-1)+c(k))/2<u(:) & u(:)<=(c(k)+c(k+1))/2)=k;
   end
end

phi_AGMC_3D=init_phi;
%% ============ Multi-phase Segmentation ===============%%
max_iter=30; tol=1e-10; 
phi=init_phi; oldPhi=ones(size(M3D_scale));
for iter=1:max_iter
    %% compute c
    for k=1:N
       c(k)= mean(u(phi(:)==k));
    end
    for k=2:N-1
        phi( phi(:)==k &  (c(k-1)+c(k))/2>=u(:) ) = k-1; 
    end
    phi( phi(:)==N &  (c(N-1)+c(N))/2>u(:) ) = N-1;  
    %% stop criterion
    Err=sum(sqrt((phi(:)-oldPhi(:)).^2))./(numel(phi));        
    if Err<tol
        break;
    end    
    oldPhi=phi;
end
phi_AGMC_3D=phi;

%% check intervals after segmentation (option)
ssIntv_str=[]; ssIntv_end=[];
for k=1:N
   ssIntv_str= [ssIntv_str min(u(phi(:)==k))];
   ssIntv_end= [ssIntv_end max(u(phi(:)==k))];
end
sIntv_str= round(Rescale(ssIntv_str,0,1,1,256));
sIntv_end= round(Rescale(ssIntv_end,0,1,1,256));
PlotHistogram(sIntv_str,sIntv_end,bin0,h)   
% pause;
% close all;