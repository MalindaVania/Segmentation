function [weight,A] = WeightAve(M,gamma,target_intensity)
%% 2015.07.10

%% target intensity인 Val과 비슷한 색깔 가진 부분들을 밝게 표현. 정도는 gamma 조절.
nM = M./max(M(:));
B = zeros(size(M));   	B(:,:) = target_intensity;
A = (nM-B).^2;
weight = exp(-gamma*A);  % gamma 클수록 B와 가까운 부분만 밝게 나와 (ex : gamma=10)

end