function uout = MotionMeanCurv( u, iterSmooth, R, sgm0, dt0, sgm1, dt1)
%% 2015.03.17
%% �ΰ��� ������ ���Ͽ� ���� �ٸ� ������ Motion by Mean Curvature.
%% ���ϰ� ���η��� �κ��� ���� (ex: star -> circle ȿ��)

%% input
%   u : binary image ��
%   iterSmooth : iteration of smoothing
%   R : indicates two regions(1.R==0, 2.R==1)
%           ���� R=zeros(r,c)�̸�, ��ü �����ο� ���� sgm0�� h0 smoothing
%       	���� R=ones(r,c)�̸�, ��ü �����ο� ���� sgm1�� h1 smoothing
%   sgm0 : R==0 �� ���� sigma (kernel size1 : 2*round(sgm0)+1)
%   dt0   : R==0 �� ���� curvature based evolution�� timestep
%   sgm1 : R==1 �� ���� sigma (kernel size2 : 2*round(sgm1)+1)
%   dt1   : R==1 �� ���� curvature based evolution�� timestep
%% output
%   u : �ٸ� ������ smoothing�� ���� ���

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
fprintf('�� flattenning iteration : %d, Error : %e', k, Error(k));
fprintf('\n');

uout = uexp(2*sgm+1:2*sgm+nRows, 2*sgm+1:2*sgm+nCols); % ���� ������ �κ��� ����
end

