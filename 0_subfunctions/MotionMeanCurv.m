function uout = MotionMeanCurv( u, iterSmooth, R, sgm0, dt0, sgm1, dt1)
%% 2015.03.17
%% 두개의 영역에 대하여 각기 다른 정도의 Motion by Mean Curvature.
%% 심하게 구부러진 부분을 펴줌 (ex: star -> circle 효과)

%% input
%   u : binary image ★
%   iterSmooth : iteration of smoothing
%   R : indicates two regions(1.R==0, 2.R==1)
%           만약 R=zeros(r,c)이면, 전체 도메인에 대해 sgm0와 h0 smoothing
%       	만약 R=ones(r,c)이면, 전체 도메인에 대해 sgm1와 h1 smoothing
%   sgm0 : R==0 에 대한 sigma (kernel size1 : 2*round(sgm0)+1)
%   dt0   : R==0 에 대한 curvature based evolution의 timestep
%   sgm1 : R==1 에 대한 sigma (kernel size2 : 2*round(sgm1)+1)
%   dt1   : R==1 에 대한 curvature based evolution의 timestep
%% output
%   u : 다른 정도로 smoothing한 후의 결과

if nargin == 5
    sgm1 = sgm0; dt1 = dt0; 
end
[nRows, nCols] = size(u);

%% distance
u = SignedDistance( u );

%% expanded data
    sgm = max(sgm0,sgm1);
uexp = padarray(u,[2*sgm 2*sgm],'replicate');
Rexp = padarray(R,[2*sgm 2*sgm],'replicate');

%% smoothing
for k = 1:iterSmooth
    uexp_old = uexp;
    
    %%% curvature
    uexp       = NeumannBoundCond(uexp);
    [uexp_x,uexp_y] = gradient(uexp);  
    normu   = sqrt(uexp_x.^2+uexp_y.^2);
        smallNumber = 1e-10;  
    Nx = uexp_x./(normu+smallNumber); 
    Ny = uexp_y./(normu+smallNumber);
    curv_uexp = Div(Nx,Ny);
    
    %%% update
    uexp = uexp + ( dt0*(Rexp==0) + dt1*(Rexp==1) ) .* curv_uexp;  
    uexp = SignedDistance( uexp );
    Error(k) = norm(uexp_old-uexp,2)/(length(uexp));
    
   if (k > 1) && (abs(Error(k)-Error(k-1)) < eps)
        break;
   end
end
fprintf('▶ flattenning iteration : %d, Error : %e', k, Error(k));
fprintf('\n');

uout = uexp(2*sgm+1:2*sgm+nRows, 2*sgm+1:2*sgm+nCols); % 원래 사이즈 부분을 선택
end

