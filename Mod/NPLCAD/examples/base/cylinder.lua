--[[
Title: Test sphere 
Author(s): leio
Date: 2016/10/25
--]]
color(1,0,0);
	cylinder({r = 1, h = 10});                 
translate(3,0,0);
	cylinder({d = 1, h = 10});
translate(3,0,0);
	cylinder({r = 1, h = 10, center = true});   -- default: center = false
translate(3,0,0);
	cylinder({r = 1, h = 10, center = {true, true, false}});  -- individual x,y,z center flags
translate(3,-5,0);
	cylinder({r1 = 3, r2 = 0, h = 10});
translate(4,0,0);
	cylinder({d1 = 1, d2 = 0.5, h = 10});
translate(3,0,0);
	cylinder({from = {0,0,0}, to = {0,0,10}, r1 = 1, r2 = 2, fn = 50});
