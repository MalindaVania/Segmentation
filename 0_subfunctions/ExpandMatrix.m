function K1 = ExpandMatrix( J1,r1,r2,c1,c2, nRows,nCols, val )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

K1 = zeros(nRows,nCols)+val;
K1(r1:r2,c1:c2) = J1;

end

