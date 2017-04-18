function g = ExpansionShrinkage( f, dist, choice  )

f(f<=0) = 0; f(f>0) = 1;
if strcmp(choice,'in')
    h = bwdist(logical(1-f),'euclidean');
    g = double(h>dist);
elseif strcmp(choice,'out')
    h = bwdist(logical(f),'euclidean');
    g = double(h<=dist);
else
    error('choice should be out or in...');
end

end

