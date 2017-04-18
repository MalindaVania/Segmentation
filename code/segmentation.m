function [u,psi,Fl] = segmentation( M, u0, psi0, Parameters, R, Leak, Less, AlphaControlRegion, nPlot)

    %% ◈◈◈◈◈ parameters ◈◈◈◈◈
    [nIter, dt, EPS, sgmphi, alpha, sgml, mu, lambda_l, nu, tau_Less, ~] = ParaGet(Parameters);
    
    [nRows, nCols] = size(M);
    Tol         = 1/(nRows*nCols);
    alpha2    	= 2-alpha;
    Heaviside   = @Heaviside_local;
    
    %---------- 추가 부분 -----------%
    Alpha = ones(nRows, nCols)*alpha;
    Alpha(AlphaControlRegion>0)=1;
    Alpha2 = ones(nRows, nCols)*2-Alpha;
    %-----------------------------%
    
   %% ◈◈◈◈◈ initialization ◈◈◈◈◈
    u   = u0;       % variable level set function
    psi = psi0;
    Hpsi0 = Heaviside(psi0, EPS);   
    R(R>0)=1; R(R<=0)=-1;
    
    %% ◈◈◈◈◈ Kernels ◈◈◈◈◈
    Kgaussian 	= fspecial('gaussian', [2*round(sgmphi)+1 2*round(sgmphi)+1], sgmphi);
    Kaverage    = fspecial('average', 2*round(sgml)+1);
            
    %%%%%%%%%%%% 초기 shape이나 초기 contour가 없으면 함수 끝내기 %%%%%%%%%%%%
    if sum(psi0(:)>0) == 0 || sum(u0(:)>0) == 0
        fprintf('No Shape or No Contour...\n');
        u   = zeros(nRows,nCols); 
        M   = zeros(nRows,nCols); 
        psi = zeros(nRows,nCols); 
        return;
    end
    %-------------------------------------------------------%
    
    %% ◈◈◈◈◈ Strong Edge Function ◈◈◈◈◈
    [Ix, Iy]	= gradient( conv2(M.*255, Kgaussian, 'same') );
    normM       = Ix.^2 + Iy.^2;
    g           = 1 ./ ( 1 + tau_Leak*normM );     
    W_Leak  	= g;%imfilter(g,Kgaussian,'replicate');
    
    %% ◈◈◈◈◈ Edge Function ◈◈◈◈◈
    [Ix, Iy]	= gradient( conv2(M.*255, Kgaussian, 'same') );
    normM       = Ix.^2 + Iy.^2;
    g	= 1 ./ ( 1 + tau*normM );     
    W	= g;%imfilter(g,Kgaussian,'replicate');
%     im(W); pause;
    
    %% ◈◈◈◈◈ Weak Edge Function ◈◈◈◈◈
    Kgaussian 	= fspecial('gaussian', [2*round(sgmphi)+1 2*round(sgmphi)+1], sgmphi);
    [Ix, Iy]	= gradient( conv2(M.*255, Kgaussian, 'same') );
    normM       = Ix.^2 + Iy.^2;
    g     	= 1 ./ ( 1 + tau_Less*normM );     
    W_Less	= g;%imfilter(g,Kgaussian,'replicate');
    
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

%         R1  = (1-Hpsi0).*Hu.*Hpsi;      
%         d   = sum(abs(u(:)-psi0(:)) .* R1(:)) / (sum(R1(:)) + eps);  
%         psi     = psi0 + d;
        
        R2  = (Hpsi0).*(1-Hu).*(1-Hpsi);   
        d   = sum(abs(u(:)-psi0(:)) .* R2(:)) / (sum(R2(:)) + eps);
        psi     = psi0 - d;
        
        Hpsi    = Heaviside(psi, EPS);              
        Fs = Hpsi-Hu;     Fs = Fs/(max(abs(Fs(:)))+eps);
        
        
        %% 2. Compute Total Force (F) 
%         Leak = zeros(size(M));
        D = double( Leak<=0 & Less<=0 );
        F = (lambda_l*Fl.*W + mu*Fr - 2*W_Leak ).*D + (lambda_l*Fl.*W_Leak+ mu*Fr ).*double(Leak>0)...
            + (nu*Fs.*W_Less + 5*nu*Fl.*(1-W_Less) + nu/10*Fr -3*W_Less ).*double(Less>0);

        %%  3. Update phi 
        norm_phi = Dirac_local(u,EPS);   norm_phi = norm_phi./max(norm_phi(:)+eps);
        u = u + dt* F.*norm_phi.*double(R>0);

        %%  4. Stopping    
        unew      = double(u>0);
        errorMat(:,:,iter+1) = abs(uold-unew);
        Error = sum(sum(abs(errorMat(:,:,iter+1)-errorMat(:,:,iter))))/(nRows*nCols);
        if  iter>1 && ( Error<Tol )
%          	fprintf('▶ segmentation iteration : %d, Error : %e', iter, Error);
%             fprintf('\n');
            break;
        end

        %% Plotting
        if mod(iter,nPlot)==0  
%             subplot(121); im(M,[]); 
%             subplot(122); im(M,[]); cn(u0,'b'); cn(u); title(['iter: ',num2str(iter)]);  
            
            subplot(231); im(M,[]); cn(u0,'b'); cn(u,'r'); hold off;     title(['iter: ',num2str(iter)]); 
            subplot(232); im(Fl,[]); cn( Fl,'b'); cn( u,'r'); hold off;   title('Fl'); 
         	subplot(233); im(W_Leak,[]); cn( u,'r'); hold off;            title('Leak edge');    
            subplot(234); im(W_Less,[]); cn( u,'r'); hold off;            title('Less edge'); 
            subplot(235); im(M,[]);  cn(R,'y',2); cn(Leak,'g',2); cn(Less,'m',2); 
                                    cn(u);  hold off;
            drawnow;      
        end 
    end   
    psi	= SignedDistance(psi); 
end

