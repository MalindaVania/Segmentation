function U = Distance( u, side)

Tol = 1e-6;

if strcmp(side,'in')
    
    bu1 = bwdist(u<=Tol);    bu1(bu1<Tol)=-1;
    U = u; 
    U(u>0) = bu1(u>0);
    
elseif strcmp(side,'out')
    
%     bu1 = bwdist(u<=Tol);    bu1(bu1<Tol)=-1;
    bu2 = bwdist(u>Tol);

    U = u; 
%     U(u>0) = bu1(u>0);
    U(u<=0) = -bu2(u<=0);
    
else
    
    bu1 = bwdist(u<=Tol);    bu1(bu1<Tol)=-1;
    bu2 = bwdist(u>Tol);

    U = u; 
    U(u>0) = bu1(u>0);
    U(u<=0) = -bu2(u<=0); 
    
end

end

