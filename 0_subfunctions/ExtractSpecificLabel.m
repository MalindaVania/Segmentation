function C = ExtractSpecificLabel( A, B )
     
A(A>0)=1;   A(A<=0)=0;
B(B>0)=1;   B(B<=0)=0;

LA = bwlabel(A>0); 

C = zeros(size(A));
for k=1:max(LA(:))
    idx = B>0;
    if sum(LA(idx)==k)~=0
        C(LA==k) = 1;
    end
end
C(C<=0) = -1;

end

