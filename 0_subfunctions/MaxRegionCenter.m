function [xc,yc] = MaxRegionCenter( f )

if sum(f(:)>0)~=0
    max_f = ExtractRegion_NmaxArea(f>0, 1);
    s   = regionprops(max_f, 'Centroid');
    centers = round(s.Centroid);
    xc = centers(2);
    yc = centers(1);
else
    xc=[]; yc=[];
end

end

