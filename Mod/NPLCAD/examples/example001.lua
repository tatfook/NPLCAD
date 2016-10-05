color(1,0,0);
intersection();
    cube();
    difference();
		sphere({ radius = 1.35, stacks = 12, color = {0,0,1}, });
	    union();
	        cylinder({ radius = 0.7, from = {-1,0,0}, to = {1,0,0}, color = {0,1,0}, });
	        cylinder({ radius = 0.7, from = {0,-1,0}, to = {0,1,0}, color = {0,1,0}, });
	        cylinder({ radius = 0.7, from = {0,0,-1}, to = {0,0,1}, color = {0,1,0}, });


		