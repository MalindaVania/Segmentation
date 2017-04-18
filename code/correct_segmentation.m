function [ u2,psi2 ] = correct_segmentation( M, psi0, u0, Parameters, AlphaControlRegion, R, OverUnderSegm, nPlot )
%UNTITLED4 이 함수의 요약 설명 위치
%   자세한 설명 위치
    
[nRows, nCols] = size(M);

[nIter, dt, EPS, sgmphi, alpha, sgml, mu, lambda_l, nu,...
                                     tau_Less, ~] = ParaGet(Parameters);
Tol         = 1/(nRows*nCols);
Heaviside   = @Heaviside_local;

%% ◈◈◈◈◈ initialization ◈◈◈◈◈
u   = u0;       % variable level set function
psi = psi0;
Hpsi0 = Heaviside(psi0, EPS); 

OverSegm = double(OverUnderSegm==2);
UnderSegm = double(OverUnderSegm==1);

%%%%%%%%%%%% 초기 shape이나 초기 contour가 없으면 함수 끝내기 %%%%%%%%%%%%
if sum(psi0(:)>0) == 0 || sum(u0(:)>0) == 0
    fprintf('No Shape or No Contour...\n');
    u2 = zeros(nRows, nCols);
    psi2 = zeros(nRows, nCols);
    return;
end

Kaverage    = fspecial('average', 2*round(sgml)+1);
%---------- 추가 부분 -----------%
Alpha = ones(nRows, nCols)*alpha;
Alpha(AlphaControlRegion>0)=1;
Alpha2 = ones(nRows, nCols)*2-Alpha;
%-----------------------------%

%% ◈◈◈◈◈ Weak Edge Function ◈◈◈◈◈
Kgaussian 	= fspecial('gaussian', [2*round(sgmphi)+1 2*round(sgmphi)+1], sgmphi);
[Ix, Iy]	= gradient( conv2(M.*255, Kgaussian, 'same') );
normM       = Ix.^2 + Iy.^2;
g     	= 1 ./ ( 1 + tau_Less*normM );     
W_Under	= g;

W_Over = 1 ./ ( 1 + 0.01*normM );

%▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶ iteration ◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀%
figure('units','normalized','outerposition',[0 0 1 1]); 
errorMat(:,:,1) = ones(nRows,nCols); % error matrix    

for iter = 1:nIter  
    uold	= double(u>0);
    u       = SignedDistance(u); 
    Hu      = Heaviside(u, EPS); 

    if sum(u(:) == -Inf)>0 || isempty(u)
        break;
    end       

    %% 1. Compute Each Force (Fl, Fr, Fs)  
    %%%%%%% (1) Fl - local forces   
    [f1, f2] = Local_WeightedAvr(M,Hu,Kaverage,1); 
    Fl = - Alpha.*(M-f1).^2 + Alpha2.*(M-f2).^2;  Fl = Fl/(max(abs(Fl(:)))+eps); 
    %%%%%%% (2) Fr - regularizing force 
    Fr = Curvature(u);        
    %%%%%%% (3) Fs - shape force            
    Hu      = Heaviside(u, EPS);   
    Hpsi	= Heaviside(psi, EPS); 
    
%     %% contour가 밖으로 나갈때 shape 계산
%     R1  = (1-Hpsi0).*Hu.*Hpsi;       
%     d   = sum(abs(u(:)-psi0(:)) .* R1(:)) / (sum(R1(:)) + eps);
%     psi = psi0 + d;
    
    %% contour가 안으로 들어갈때 shape 계산
    R2  = (Hpsi0).*(1-Hu).*(1-Hpsi);   
    [~,~,r2,~,~] = BoundingBox(u0,0);
    R2(1:r2-20,:)=0;
    d   = sum(abs(u(:)-psi0(:)) .* R2(:)) / (sum(R2(:)) + eps);
    psi     = psi0 - d;

    Hpsi    = Heaviside(psi, EPS);              
    Fs = Hpsi-Hu;     Fs = Fs/(max(abs(Fs(:)))+eps);


    %% 2. Compute Total Force (F) 
    D = double( OverUnderSegm<=0 );
%     F = (lambda_l*Fl+ mu*Fr ).*D ...
%         + (nu*Fs.*W_Less + 5*nu*Fl.*(1-W_Less) + nu/10*Fr -3*W_Less ).*double(OverUnderSegm>0);

%      F = (lambda_l*Fl+ mu*Fr ).*D ...
%         + (nu*Fs.*W_Over + 5*nu*Fl.*(1-W_Over) -1*W_Over+ 0*mu*Fr).*double(OverSegm>0)...
%         + (lambda_l*Fl+ mu*Fr +5*W_Over).*double(UnderSegm>0);
    
    F = (lambda_l*Fl+ mu*Fr-2* W_Over ).*D ...
        + (nu*Fs.*W_Under + 20*nu*Fl.*(1-W_Under) -3*W_Under).*double(UnderSegm>0)...
        + (nu*Fs.*W_Over + 50*nu*Fl.*(1-W_Over) +0*W_Over ).*double(OverSegm>0);
    

    %%  3. Update phi 
    norm_phi = Dirac_local(u,EPS);   norm_phi = norm_phi./max(norm_phi(:)+eps);
    u = u + dt* F.*norm_phi.*double(R>0);

    %%  4. Stopping    
    unew      = double(u>0);
    errorMat(:,:,iter+1) = abs(uold-unew);
    Error = sum(sum(abs(errorMat(:,:,iter+1)-errorMat(:,:,iter))))/(nRows*nCols);
    if  iter>1 && ( Error<Tol )
        u2 = u;
        psi2 = psi;
%          	fprintf('▶ segmentation iteration : %d, Error : %e', iter, Error);
%             fprintf('\n');
        break;
    end

    %% Plotting
    if mod(iter,nPlot)==0  
%             subplot(121); im(M,[]); 
%             subplot(122); im(M,[]); cn(u0,'b'); cn(u); title(['iter: ',num2str(iter)]);  

        subplot(221); im(M,[]); cn(u0,'b'); cn(u,'r'); hold off;     title(['iter: ',num2str(iter)]); 
        subplot(222); im(Fl,[]); cn( Fl,'b'); cn( u,'r'); hold off;   title('Fl'); 
        subplot(223); im(W_Over,[]); cn( u,'r'); hold off;            title('Less edge'); 
        subplot(224); im(M,[]);  cn(R,'y',2); cn(OverSegm,'m',2); cn(UnderSegm,'g',2); 
                                cn(u);  cn(psi,'y');hold off;
        drawnow;      
    end 
end   
u2 = u;
psi2 = psi;
end

