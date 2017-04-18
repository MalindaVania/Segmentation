function phi0 = Click_region( f, p, q, doSmoothing  )
%% 2015.03.17
%% 라벨링 된 영상의 일부분만을 선택하는 함수

%% input
%   f : grayscale image
%   p : binary image ★
%   q : lablled image of p ★
%   doSmoothing = 'yes' or 'no'
%% output
%   phi0 : 선택된 부분을 약간 smoothing한 후의 결과

figure('units','normalized','outerposition',[0 0 1 1])
%% 원하는 라벨을 포인트로 찍기 (한군데 클릭한 후, 더블클릭)
subplot(121); im(f,'121'); title('original'); subplot(122); im(p,'122'); title('labelling');
statusbar('▶ 원하는 영역을 포인트로 찍으세요!(한군데 클릭한 후, 더블클릭)...'); 
h = impoint(gca,[]);  
    position = round(wait(h));     
rf_label = p(position(2),position(1));

%% 선택된 부분만 binary로!
phi0 = ExtractSpecificLabel( q, double(p==rf_label) );
%% SECTION TITLE
% DESCRIPTIVE TEXT

%% Smoothing
if strcmp(doSmoothing,'yes')
        iterSmooth = 50; sgm0 = 1.5; dt0 = 2; R = zeros(size(f));
    phi0 = MotionMeanCurv( phi0, iterSmooth, R, sgm0, dt0);
end

end

