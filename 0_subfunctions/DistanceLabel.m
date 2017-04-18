function [C, arrDist] = DistanceLabel( A, val )
%UNTITLED4 이 함수의 요약 설명 위치
%   자세한 설명 위치

A_label = bwlabel(A); 
C = zeros(size(A));
arrDist = [];
for label = 1:max(A_label(:))
    B = double(A_label==label);
    [~,r1,r2,c1,c2] = BoundingBox( B,0 );
%     Ratio = (r2-r1)/(c2-c1+eps);
    Dist = sqrt((r1-r2)^2+(c1-c2)^2);
    arrDist(label)=Dist;
    if Dist>=val
        fprintf('yes...\n');
        C(B>0)=1;
    end
    
end


end

