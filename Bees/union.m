function res = union(xc, yc, r)
 
%
% Size of my grid -- higher values => higher accuracy.
%
ngrid = 100;
 

r2 = r .* r;
 
ncircles = length(xc);
 
%
% Compute the bounding box of the circles.
%
xmin = min(xc-r);
xmax = max(xc+r);
ymin = min(yc-r);
ymax = max(yc+r);
 
%
% Keep a counter.
%
inside = 0;
 
%
% For every point in my grid.
%
for x = linspace(xmin,xmax,ngrid)
    for y = linspace(ymin,ymax,ngrid)
        if any(r2 > (x - xc).^2 + (y - yc).^2)
            inside = inside + 1;
        end
    end
end
 
box_area = (xmax-xmin) * (ymax-ymin);
 
res = box_area * inside / ngrid^2;
 
end