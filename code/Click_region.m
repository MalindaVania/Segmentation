function phi0 = Click_region( f, p, q, doSmoothing  )
%% 2015.03.17
%% �󺧸� �� ������ �Ϻκи��� �����ϴ� �Լ�

%% input
%   f : grayscale image
%   p : binary image ��
%   q : lablled image of p ��
%   doSmoothing = 'yes' or 'no'
%% output
%   phi0 : ���õ� �κ��� �ణ smoothing�� ���� ���

figure('units','normalized','outerposition',[0 0 1 1])
%% ���ϴ� ���� ����Ʈ�� ��� (�ѱ��� Ŭ���� ��, ����Ŭ��)
subplot(121); im(f,'121'); title('original'); subplot(122); im(p,'122'); title('labelling');
statusbar('�� ���ϴ� ������ ����Ʈ�� ��������!(�ѱ��� Ŭ���� ��, ����Ŭ��)...'); 
h = impoint(gca,[]);  
    position = round(wait(h));     
rf_label = p(position(2),position(1));

%% ���õ� �κи� binary��!
phi0 = ExtractSpecificLabel( q, double(p==rf_label) );
%% SECTION TITLE
% DESCRIPTIVE TEXT

%% Smoothing
if strcmp(doSmoothing,'yes')
        iterSmooth = 50; sgm0 = 1.5; dt0 = 2; R = zeros(size(f));
    phi0 = MotionMeanCurv( phi0, iterSmooth, R, sgm0, dt0);
end

end

