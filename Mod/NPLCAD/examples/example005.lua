--[[
Title: Example 005
Author(s): leio
Date: 2016/9/20
Desc: This example based on example005.jscad in OpenJSCAD.
]]
local pi_2 = 6.28;
union();
push();
	translate(0,200,0);
	cylinder({ from = {0,0,0}, to = {0,80,0}, radiusStart = 120, radiusEnd = 0, color = {0,0,1,}})
pop();
for i = 0,5 do
	push();
		translate(math.sin(pi_2*i/6)*80, 0, math.cos(pi_2*i/6)*80);
		cylinder({ from = {0,0,0}, to = {0,200,0}, radius = 10, color = {1,0,0,}})
	pop();		
end
difference();
push();
	difference();
	cylinder({ from = {0,0,0}, to = {0,50,0}, radius = 100, color = {1,0,0,}})
	translate(0,10,0);
	cylinder({ from = {0,0,0}, to = {0,50,0}, radius = 80, color = {1,1,0,}})
pop();
translate(100,0,0);
cube({radius = {30,50,30}, color = {1,1,0,}});