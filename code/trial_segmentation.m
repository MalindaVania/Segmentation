function [ u1,psi1 ] = trial_segmentation(  M, psi0, u0, uprev, Parameters, AlphaControlRegion, nPlot )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

[nRows, nCols] = size(M);

[nIter, dt, EPS, sgmphi, alpha, sgml, mu, lambda_l, nu,...
                                   tau_Less, ~] = ParaGet(Parameters);
u0const = Parameters.u0const;
Tol         = 1/(nRows*nCols);
Heaviside   = @Heaviside_local;

%% ◈◈◈◈◈ initialization ◈◈◈◈◈
u   = u0;       % variable level set function
psi = psi0;
Hpsi0 = Heaviside(psi0, EPS); 

%%%%%%%%%%%% 초기 shape이나 초기 contour가 없으면 함수 끝내기 %%%%%%%%%%%%
if sum(psi0(:)>0) == 0 || sum(u0(:)>0) == 0
    fprintf('No Shape or No Contour...\n');
    u1 = zeros(nRows, nCols);
    psi1 = zeros(nRows, nCols);
    return;
end

%% ◈◈◈◈◈ Weak Edge Function ◈◈◈◈◈
Kgaussian 	= fspecial('gaussian', [2*round(sgmphi)+1 2*round(sgmphi)+1], sgmphi);
[Ix, Iy]	= gradient( conv2(M.*255, Kgaussian, 'same') );
normM       = Ix.^2 + Iy.^2;
g     	= 1 ./ ( 1 + tau_Less*normM );     
W_Over	= g;


Kaverage    = fspecial('average', 2*round(sgml)+1);
%---------- 추가 부분 -----------%
Alpha = ones(nRows, nCols)*alpha;
Alpha(AlphaControlRegion>0)=1;
Alpha2 = ones(nRows, nCols)*2-Alpha;
%-----------------------------%
R       = uprev +5*u0const; 
R(R<=0)=0; R(R>0)=1;  


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

    R2  = (Hpsi0).*(1-Hu).*(1-Hpsi);   
    d   = sum(abs(u(:)-psi0(:)) .* R2(:)) / (sum(R2(:)) + eps);
    psi     = psi0 - d;  
    psi	= SignedDistance(psi); 

    %% 2. Compute Total Force (F) 
    F = lambda_l*Fl+ mu*Fr-2*W_Over ;

    %%  3. Update phi 
    norm_phi = Dirac_local(u,EPS);   norm_phi = norm_phi./max(norm_phi(:)+eps);
    u = u + dt* F.*norm_phi.*double(R>0);

    %%  4. Stopping    
    unew      = double(u>0);
    errorMat(:,:,iter+1) = abs(uold-unew);
    Error = sum(sum(abs(errorMat(:,:,iter+1)-errorMat(:,:,iter))))/(nRows*nCols);
    if  iter>1 && ( Error<Tol )
        u1 = u;
        psi1 = psi;
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
        subplot(223); im(W_Over,[]); cn(u,'r');cn(R,'c'); hold off;
        subplot(224); im(M,[]);  cn(R,'y',2); 
                                cn(u);  hold off;
        drawnow;      
    end 
end       
u1 = u;
psi1 = psi;

end

