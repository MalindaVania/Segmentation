function [x1,x2,y1,y2,Box] = MaxRegionBox( f )

if sum(f(:)>0)~=0
    max_f = ExtractRegion_NmaxArea(f>0, 1);
    s   = regionprops(max_f, 'BoundingBox');
    Boxes = round(s.BoundingBox);
    x1 = Boxes(2);
    x2 = Boxes(2)+Boxes(4);
    y1 = Boxes(1);
    y2 = Boxes(1)+Boxes(3);
    Box = zeros(size(f));
    Box(x1:x2,y1:y2)=1;
else
    x1=[]; x2=[]; y1=[]; y2=[]; 
    Box = zeros(size(f)); 
end

end