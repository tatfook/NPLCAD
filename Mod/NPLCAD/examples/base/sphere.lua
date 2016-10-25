--[[
Title: Test cylinder 
Author(s): leio
Date: 2016/10/25
--]]
color(1,0,0);
	sphere();                          
translate(6,0,0);
	sphere(1);
translate(6,0,0);
	sphere({r = 2});                    -- Note: center = true is default 
translate(6,0,0);
	sphere({r = 2, center = false});    
translate(6,0,0);
	sphere({r = 2, center = {true, true, false}}); -- individual axis center 
translate(6,0,0);
	sphere({r = 2, fn = 100 });
