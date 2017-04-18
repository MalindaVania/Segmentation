function h = over_under_segmentation( f,g )
%UNTITLED5 이 함수의 요약 설명 위치
%   자세한 설명 위치

Hf	= double(f>0);
Hg	= double(g>0);

Under0    = double(Hf<Hg);
Under = imdilate(Under0, strel('disk',5));

Over0	= double(Hf>Hg);
Over_erode  = imerode(Over0, strel('disk',1));
Over_erode_dilate = imdilate(Over_erode,strel('disk',1));      
Over = Over_erode_dilate;

h = zeros(size(f));
h(Over>0)=2;
h(Under>0)=1;

% h = Under;
% h(Over>0)=1;
% h(h==0)=-1;

end

