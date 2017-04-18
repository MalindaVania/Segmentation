function surf2OBJ(Mat,ISOval,fileName)

fileOBJ=fopen([fileName '.obj'],'w');

% [vertices,faces]=surf2tripatch(x,y,z);
[faces,vertices]=isosurface(Mat,ISOval);

[mVertices,nVertices]=size(vertices);

[mFaces,nFaces]=size(faces);

for count=1:mVertices
   fprintf(fileOBJ,'v  %g   %g   %g\n',vertices(count,:));
end


if nFaces==3
    for count=1:mFaces
       fprintf(fileOBJ,'f  %d   %d   %d\n',faces(count,:));
    end
elseif nFaces==4
    for count=1:mFaces
       fprintf(fileOBJ,'f  %d   %d   %d %d\n',faces(count,:));
    end
end  
fclose(fileOBJ);