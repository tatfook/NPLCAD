--wait for a moment
color({1,0,0});
intersection();
    cube({size = 2, center = true});
    difference();
		local s = sphere({ r = 1.35, fn = 50 });
        color({0,0,1},s);
	    union();
            color({0,1,0});
	        cylinder({ r1 = 0.7, r2 = 0.7, from = {-1,0,0}, to = {1,0,0} });
	        cylinder({ r1 = 0.7, r2 = 0.7, from = {0,-1,0}, to = {0,1,0} });
	        cylinder({ r1 = 0.7, r2 = 0.7, from = {0,0,-1}, to = {0,0,1} });
    


		