--[[
Title: CSGModel 
Author(s): leio
Date: 2016/8/17
Desc: 
Defines a drawable object that can be attached to a Node.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/drawables/CSGModel.lua");
local CSGModel = commonlib.gettable("Mod.NPLCAD.drawables.CSGModel");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NPLCAD/core/Drawable.lua");
NPL.load("(gl)script/ide/CSG/CSG.lua");

local CSG = commonlib.gettable("CSG.CSG");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.core.Drawable"), commonlib.gettable("Mod.NPLCAD.drawables.CSGModel"));
function CSGModel.createCube(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.cube(options);
	model:setColor(options.color);
	return model;
end
function CSGModel.createSphere(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.sphere(options);
	model:setColor(options.color);
	return model;
end
function CSGModel.createCylinder(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.cylinder(options);
	model:setColor(options.color);
	return model;
end
function CSGModel:ctor()
	self.csg_node = nil;
end
function CSGModel:getTypeName()
	return "CSGModel";
end
function CSGModel:getCSGNode()
	return self.csg_node;
end
function CSGModel:setColor(color)
	if(not self.csg_node or not self.csg_node.polygons)then return end
	color = color or {};
	color[1] = color[1] or 1;
	color[2] = color[2] or 1;
	color[3] = color[3] or 1;
	for k,v in ipairs(self.csg_node.polygons) do
		v.shared = v.shared or {};
		v.shared.color = color;
	end
end
function CSGModel:toMesh()
	if(not self.csg_node)then return end
	local vertices = {};
	local indices = {};
	local normals = {};
	local colors = {};
	for __,polygon in ipairs(self.csg_node.polygons) do
		local start_index = #vertices+1;
		for __,vertex in ipairs(polygon.vertices) do
			table.insert(vertices,{vertex.pos.x,vertex.pos.y,vertex.pos.z});
			table.insert(normals,{vertex.normal.x,vertex.normal.y,vertex.normal.z});
			local shared = polygon.shared or {};
			local color = shared.color or {1,1,1};
			table.insert(colors,color);
		end
		local size = #(polygon.vertices) - 1;
		for i = 2,size do
			table.insert(indices,start_index);
			table.insert(indices,start_index + i-1);
			table.insert(indices,start_index + i);
		end
	end
	return vertices,indices,normals,colors;
end