function Coverage = ObjectiveFunc( pop, Rsensor, Area )

% AUB = A+B - intesect(A,B)

xIndex = 1:2:length(pop);
yIndex = 2:2:length(pop);

sumCircles = union(pop(xIndex) , pop(yIndex), Rsensor);

Coverage = sumCircles/Area;



