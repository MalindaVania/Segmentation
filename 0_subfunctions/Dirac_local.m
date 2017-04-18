function d = Dirac_local(z, EPS)

d = (1/2/EPS)*(1+cos(pi*z/EPS));
b = (z<=EPS) & (z>=-EPS);
d = d.*b;
end