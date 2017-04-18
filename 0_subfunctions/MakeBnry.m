function B = MakeBnry( A, val )
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치

B = double(A>=val);
B(B==0)=-1;

end

