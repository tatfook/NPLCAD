pushNode();
    rotate(45,0,0);
    cube({ center = {0,3,0}, radius = {1,1,1}, color = {1,0,0}, });
popNode();

sphere({ center = {-3,0,0}, radius = 1, slices = 16, stacks = 16, color = {1,1,0}, });
translate(2,0,3);
	cylinder({ from = {0,-1,0}, to = {0,1,0}, radius = 1, slices = 16, color = {0,0,1}, });
    cube({center = {5,0,0}});

beginUnion();
	--Todo
endUnion();

beginDifference();
	--Todo
endDifference();

beginIntersection();
	--Todo
endIntersection();
