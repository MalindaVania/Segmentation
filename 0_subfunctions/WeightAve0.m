function [weight] = WeightAve0(P,u0,r,Option,L,T,Tmask,bw,num)
%% 2015.03.17
if strcmp(Option,'average')
    A = double( u0>0 );	 A0 = A; % target intensity 부분을 대략적으로 나타냄
elseif strcmp(Option,'bright')
    vv = P>=mean(P(u0>0));  % u>0 내부에 밝은부분과 어두운 부분 섞인 경우, 밝은 부분이 우리의 target일 때
    A = double( vv>0 & u0>0 );	 A0 = A; % target intensity 부분을 대략적으로 나타냄
elseif strcmp(Option,'dark')
	vv = P<=mean(P(u0>0));  % u>0 내부에 밝은부분과 어두운 부분 섞인 경우, 어두운 부분이 우리의 target일 때
    A = double( vv>0 & u0>0 );	 A0 = A; % target intensity 부분을 대략적으로 나타냄
end

%% u>0 영역에 원하는 타겟이 중간 색깔인 경우
% 현재 A0 : 중간이상의 색을 가진 영역을 나타냄
if nargin>4  
    A(L==max(L(:))) = 0;  % maximal label 부분(밝은 부분)을 제거
    if sum(A(:)>0)/sum(A0(:)>0) < 0.2  % 제거해 보니 영역이 얼마 없다면, 그것은 밝은 부분이 지배적이라는 뜻.
        A = A0;                         % => 밝은 부분을 우리의 타겟으로 변경 (같은 대상인데, slice contrast 땜에 밝게 나올 수도 있는 것이니..)
    end
end


% u0_bnry = double(uprev>=0);
    [Tmaskbw,num] = bwlabel(Tmask);
nM = P./max(P(:));
 C=zeros(size(P));
for k=1:num
    val = mean(T(bw(:)==k))
    C(Tmaskbw==k) = exp(-r*(nM(Tmaskbw==k)-val).^2);  
end

% C = exp(-r*(nM-A).^2);  % Cw 클수록 B와 가까운 부분만 밝게 나와 (ex : Cw=10)
% %% target intensity의 집합인 A영역과 비슷한 색깔 가진 부분들을 밝게 표현. 정도는 Cw로 조절.
%     nM = M./max(M(:));
%     B = zeros(size(A));   	B(:,:) = mean(M(A(:)>0));   B = B./max(M(:));
% C = exp(-r*(nM-B).^2);  % Cw 클수록 B와 가까운 부분만 밝게 나와 (ex : Cw=10)
    h = 2;
weight = conv2(C,fspecial('gaussian', [2*h+1 2*h+1], 1),'same'); 

% Y = (nM-B).^2;
end