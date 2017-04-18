function B = CropExpandMatrix( A, r1,r2,c1,c2,const,Action,nRows,nCols )
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치

if strcmp(Action,'crop')
    B = CropMatrix( A,r1-const,r2+const,c1-const,c2+const );
elseif strcmp(Action,'expand')
    B = ExpandMatrix( A,r1-const,r2+const,c1-const,c2+const, nRows,nCols );
end


function [ K1] = CropMatrix( J1,r1,r2,c1,c2 )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

K1 = J1(r1:r2,c1:c2);

function K1 = ExpandMatrix( J1,r1,r2,c1,c2, nRows,nCols )
%UNTITLED3 이 함수의 요약 설명 위치
%   자세한 설명 위치

K1 = zeros(nRows,nCols)+min(J1(:));
K1(r1:r2,c1:c2) = J1;



