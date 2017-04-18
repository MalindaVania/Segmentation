function fv = Isosurface( M,Thresh )
%ISOSURFACE Summary of this function goes here

fv=isosurface(M,Thresh);
figure;
p=patch(fv);
isonormals(M,p);
% set(p,'FaceColor','cyan','EdgeColor','none');
set(p,'FaceColor','red','EdgeColor','none');
daspect([1,1,1]);view(3); camlight; lighting gouraud;
axis([1 size(M,1) 1 size(M,2) 1 size(M,3)])  

end

