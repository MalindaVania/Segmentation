function [Region,L]=ExtractRegion_minArea(u,minArea)
%ExtractRegion

BW=u;
BW(u<=0)=0;
BW(u>0)=1;

%% labeling
[L,~]=bwlabel(BW);

%% area
a  = regionprops(L, 'area');
areas = cat(1, a.Area);

%% 이전 u와 가장 교집합 많은 라벨 index 추출
Region=zeros(size(u));
for k=1:length(areas)
  if areas(k)>minArea
    Region(L(:)==k)=1;
  end
end

end