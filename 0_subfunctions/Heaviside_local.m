function val = Heaviside_local( z,EPS )

val=0.5*(1+z/EPS + sin(pi*z/EPS)/pi);
b = (z<=EPS) & (z>=-EPS);
val=b.*val;
val(z>EPS)=1;
val(z<-EPS)=0;

end

