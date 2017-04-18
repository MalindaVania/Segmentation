function [f1,f2] = Local_WeightedAvr(f,H,Klocal,A)
f1 = conv2(f.*H.*A,Klocal,'same');
% f11 = conv2(f.*H,Klocal,'same');
c1 = conv2(H.*A,Klocal,'same');
f1 = f1./(c1+eps);
f2 = conv2(f.*(1-H).*A,Klocal,'same');
c2 = conv2((1-H).*A,Klocal,'same');
f2 = f2./(c2+eps);
end
