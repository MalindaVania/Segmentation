function U = SignedDistance( u )

U = zeros(size(u));

u_in = Distance( u, 'in');
u_out = Distance( u, 'out');

U(u>0) = u_in(u>0);
U(u<=0) = u_out(u<=0);

end

