function val = Heaviside_step( z,Eps )
%HEAVISIDE Summary of this function goes here
z(z>=0)=1;
z(z<0)=0;
val=z;

% val=0.5.*(1+2/pi.*atan(z./EPS));
% val= rescale(val,0,1);

end

