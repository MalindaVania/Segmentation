function [weight] = WeightAveMultiple(M,u0,r,Option,L,sgml,u0const)
%% 2015.04.20

u0_bnry = double(u0-2*u0const>=0);
[bw,num] = bwlabel(u0_bnry);

weight = zeros(size(M));


for k=1:num
    R = double(bw==k);
    R = imdilate(R,strel('disk',sgml));
    
    Mtmp = R; Mtmp(R>0) = M(R>0); Mtmp(R==0) = min(M(R(:)>0));
    u0tmp = R; u0tmp(R>0) = u0(R>0); u0tmp(R==0) = min(u0(R(:)>0));
    
    E = Mtmp>=max(Mtmp(u0(:)>0));
    E = imdilate(E,strel('disk',5));
    Mtmp(E>0)=min(Mtmp(u0(:)>0));
    
    
    [weight_tmp,~,~] = WeightAve(Mtmp,u0tmp,r,Option,L);
    
     weight(R>0) = weight_tmp(R>0);        
end

end