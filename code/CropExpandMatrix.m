function B = CropExpandMatrix( A, r1,r2,c1,c2,const,Action,nRows,nCols )
%UNTITLED2 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

if strcmp(Action,'crop')
    B = CropMatrix( A,r1-const,r2+const,c1-const,c2+const );
elseif strcmp(Action,'expand')
    B = ExpandMatrix( A,r1-const,r2+const,c1-const,c2+const, nRows,nCols );
end


function [ K1] = CropMatrix( J1,r1,r2,c1,c2 )
%UNTITLED3 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

K1 = J1(r1:r2,c1:c2);

function K1 = ExpandMatrix( J1,r1,r2,c1,c2, nRows,nCols )
%UNTITLED3 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

K1 = zeros(nRows,nCols)+min(J1(:));
K1(r1:r2,c1:c2) = J1;



