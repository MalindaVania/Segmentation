function cn( A ,color, width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    hold on, contour(A,[0 0],'r');
elseif nargin == 2
    hold on, contour(A,[0 0],color);
elseif nargin == 3
    hold on, contour(A,[0 0],color,'linewidth',width);
end

end

