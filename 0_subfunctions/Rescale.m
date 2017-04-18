function y = Rescale(x,im,iM,om,oM)

if isempty(im)
    im=min(x(:));
end
if isempty(iM)    
    iM=max(x(:));
end

x(x<im)=im;
x(x>iM)=iM;

if iM-im<eps
    y = x;
else
    y = (oM-om) * (x-im)/(iM-im) + om;
end


