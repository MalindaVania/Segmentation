function Region=ExtractRegion_NmaxArea(u, N)
%ExtractRegion

if sum(u(:)>0)==0
    Region = zeros(size(u));
    return;
else
    BW=u;
    BW(u<=0)=0;
    BW(u>0)=1;

    tmpBW=BW;

    %% labeling
    [L,~]=bwlabel(BW);
    [tmpL,~]=bwlabel(tmpBW);

    %% area
    a  = regionprops(L, 'area');
    areas = cat(1, a.Area);
    [sort_areas,idx]=sort(areas,'descend');


    %% 이전 u와 가장 교집합 많은 라벨 index 추출
    Region=zeros(size(u));
    for k=1:N
        Region(L(:)==idx(k))=1;
    end
end

end


