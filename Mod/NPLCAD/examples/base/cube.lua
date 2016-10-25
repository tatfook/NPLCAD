--[[
Title: Test cube 
Author(s): leio
Date: 2016/10/25
--]]
color(1,0,0);
	cube(); 
translate(2,0,0);
	cube(1);
translate(2,0,0);
	cube({size = 1});
translate(2,0,0);
	cube({size = {1,2,3}});
translate(2,0,0);
	cube({size = 1, center = true}); -- default center:false
translate(2,0,0);
	cube({size = 1, center = {true,true,false}}); -- individual axis center true or false