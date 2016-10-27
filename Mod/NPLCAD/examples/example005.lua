--[[
Title: Example 005
Author(s): leio
Date: 2016/9/20
Desc: This example based on example005.jscad in OpenJSCAD.
]]
local pi_2 = 6.28;
scale(1/6);
union();
push();
	color("blue");
	translate({0,0,200});
	cylinder({ h = 80, r1 = 120, r2 = 0 });
pop();
for i = 0,5 do
	push();
		color("red");
		translate({math.sin(pi_2*i/6)*80, math.cos(pi_2*i/6)*80, 0});
		cylinder({ h = 200, r = 10});
	pop();		
end
difference();
push();
	color("yellow");
	difference();
	cylinder({h = 50, r = 100});
	translate({0,0,10});
	cylinder({ h = 50, r = 80 });
pop();
color("lime");
translate({100,0,35});
cube({ size = 50, center = true, });
