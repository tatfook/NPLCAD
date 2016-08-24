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
NPL.load("(gl)script/ide/CSG/CSGVector.lua");
NPL.load("(gl)Mod/NPLCAD/services/CSGService.lua");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");
local CSGVector = commonlib.gettable("CSG.CSGVector");
local CSG = commonlib.gettable("CSG.CSG");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.core.Drawable"), commonlib.gettable("Mod.NPLCAD.drawables.CSGModel"));
function CSGModel.createCube(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.cube(options);
	return model;
end
function CSGModel.createSphere(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.sphere(options);
	return model;
end
function CSGModel.createCylinder(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.cylinder(options);
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
	CSGService.setColor(self.csg_node,color);
end
function CSGModel:toMesh()
	return CSGService.toMesh(self.csg_node);
end
function CSGModel:applyMatrix(matrix)
	CSGService.applyMatrix(self.csg_node,matrix);
end