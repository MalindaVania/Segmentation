function [weight] = WeightAve0(P,u0,r,Option,L,T,Tmask,bw,num)
%% 2015.03.17
if strcmp(Option,'average')
    A = double( u0>0 );	 A0 = A; % target intensity �κ��� �뷫������ ��Ÿ��
elseif strcmp(Option,'bright')
    vv = P>=mean(P(u0>0));  % u>0 ���ο� �����κа� ��ο� �κ� ���� ���, ���� �κ��� �츮�� target�� ��
    A = double( vv>0 & u0>0 );	 A0 = A; % target intensity �κ��� �뷫������ ��Ÿ��
elseif strcmp(Option,'dark')
	vv = P<=mean(P(u0>0));  % u>0 ���ο� �����κа� ��ο� �κ� ���� ���, ��ο� �κ��� �츮�� target�� ��
    A = double( vv>0 & u0>0 );	 A0 = A; % target intensity �κ��� �뷫������ ��Ÿ��
end

%% u>0 ������ ���ϴ� Ÿ���� �߰� ������ ���
% ���� A0 : �߰��̻��� ���� ���� ������ ��Ÿ��
if nargin>4  
    A(L==max(L(:))) = 0;  % maximal label �κ�(���� �κ�)�� ����
    if sum(A(:)>0)/sum(A0(:)>0) < 0.2  % ������ ���� ������ �� ���ٸ�, �װ��� ���� �κ��� �������̶�� ��.
        A = A0;                         % => ���� �κ��� �츮�� Ÿ������ ���� (���� ����ε�, slice contrast ���� ��� ���� ���� �ִ� ���̴�..)
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

% C = exp(-r*(nM-A).^2);  % Cw Ŭ���� B�� ����� �κи� ��� ���� (ex : Cw=10)
% %% target intensity�� ������ A������ ����� ���� ���� �κе��� ��� ǥ��. ������ Cw�� ����.
%     nM = M./max(M(:));
%     B = zeros(size(A));   	B(:,:) = mean(M(A(:)>0));   B = B./max(M(:));
% C = exp(-r*(nM-B).^2);  % Cw Ŭ���� B�� ����� �κи� ��� ���� (ex : Cw=10)
    h = 2;
weight = conv2(C,fspecial('gaussian', [2*h+1 2*h+1], 1),'same'); 

% Y = (nM-B).^2;
end