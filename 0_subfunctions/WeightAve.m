function [weight,A] = WeightAve(M,gamma,target_intensity)
%% 2015.07.10

%% target intensity�� Val�� ����� ���� ���� �κе��� ��� ǥ��. ������ gamma ����.
nM = M./max(M(:));
B = zeros(size(M));   	B(:,:) = target_intensity;
A = (nM-B).^2;
weight = exp(-gamma*A);  % gamma Ŭ���� B�� ����� �κи� ��� ���� (ex : gamma=10)

end