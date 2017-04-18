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

%% ���� u�� ���� ������ ���� �� index ����
Region=zeros(size(u));
for k=1:length(areas)
  if areas(k)>minArea
    Region(L(:)==k)=1;
  end
end

end