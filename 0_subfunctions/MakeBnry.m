function B = MakeBnry( A, val )
%UNTITLED2 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

B = double(A>=val);
B(B==0)=-1;

end

