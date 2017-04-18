function [B,r1,r2,c1,c2] = BoundingBox( A,val )
%UNTITLED �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ

[nRows, nCols] = size(A);
Abnry = double(A>0);

for r = 1:nRows
    if sum(Abnry(r,:))>0
        r1 = r-val;
       break; 
    end
end    
for r = nRows:-1:1
    if sum(Abnry(r,:))>0
        r2 = r+val;
       break; 
    end
end
for c = 1:nCols
    if sum(Abnry(:,c))>0
        c1 = c-val;
       break; 
    end
end    
for c = nCols:-1:1
    if sum(Abnry(:,c))>0
        c2 = c+val;
       break; 
    end
end

B = zeros(nRows, nCols)-1;

if sum(A(:)>0)==0
    r1=0;r2=0;c1=0;c2=0;    
else
    B(r1:r2,c1:c2)=1;
end

end

