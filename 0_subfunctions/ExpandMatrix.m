function K1 = ExpandMatrix( J1,r1,r2,c1,c2, nRows,nCols, val )
%UNTITLED3 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

K1 = zeros(nRows,nCols)+val;
K1(r1:r2,c1:c2) = J1;

end

