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
NPL.load("(gl)script/ide/CSG/CSGVertex.lua");
NPL.load("(gl)script/ide/CSG/CSGPolygon.lua");
NPL.load("(gl)Mod/NPLCAD/services/CSGService.lua");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");
local CSGVector = commonlib.gettable("CSG.CSGVector");
local CSGVertex = commonlib.gettable("CSG.CSGVertex");
local CSGPolygon = commonlib.gettable("CSG.CSGPolygon");
local CSG = commonlib.gettable("CSG.CSG");
local CSGModel = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.core.Drawable"), commonlib.gettable("Mod.NPLCAD.drawables.CSGModel"));
CSGModel.csg_node = nil;
CSGModel.model_type = nil;
CSGModel.options = nil;
function CSGModel.createCube(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.cube(options);
	model.model_type = "cube";
	model.options = options;
	return model;
end
function CSGModel.createSphere(options)
	options = options or {};
	local model = CSGModel:new();
	model.csg_node = CSG.sphere(options);
	model.model_type = "sphere";
	model.options = options;
	return model;
end
function CSGModel.createCylinder(options)
	options = options or {};
	local model = CSGModel:new();
	--model.csg_node = CSG.cylinder(options);
	model.csg_node = CSGModel.cylinder(options);
	model.model_type = "cylinder";
	model.options = options;
	return model;
end
function CSGModel:ctor()
	self.csg_node = nil;
end
function CSGModel:getTypeName()
	return "Model";
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
-- a new method to create a cylinder
-- added two params:"radiusStart" and "radiusEnd"
-- CSG.cylinder hasn't included these params.
function CSGModel.cylinder(options)
	options = options or {};
	local s = CSGVector:new():init(options["from"] or {0,-1,0});
	local e = CSGVector:new():init(options["to"] or {0,1,0});
	local ray = e:minus(s);
	local r = options["radius"] or 1;
	local radiusStart = options["radiusStart"] or r;
	local radiusEnd = options["radiusEnd"] or r;

	if(radiusStart < 0 or radiusEnd < 0)then
		return;
	end
	if(radiusStart == 0 and radiusEnd == 0)then
		return;
	end
	local slices = options.slices or 16;
	local axisZ = ray:unit()
	local isY = (math.abs(axisZ.y) > 0.5);
	local isY_v1;
	local isY_v2;
	if(isY)then
		isY_v1 = 1;
		isY_v2 = 0;
	else
		isY_v1 = 0;
		isY_v2 = 1;
	end
	local axisX = CSGVector:new():init(isY_v1, isY_v2, 0):cross(axisZ):unit();
	local axisY = axisX:cross(axisZ):unit();
	local start_value = CSGVertex:new():init(s, axisZ:negated());
	local end_value = CSGVertex:new():init(e, axisZ:unit());
	local polygons = {};


	function point(stack, slice, radius,normalBlend)
		normalBlend = normalBlend or 0;
		local angle = slice * math.pi * 2;
		local out = axisX:times(math.cos(angle)):plus(axisY:times(math.sin(angle)));
		local pos = s:plus(ray:times(stack)):plus(out:times(radius));
		local normal = out:times(1 - math.abs(normalBlend)):plus(axisZ:times(normalBlend));
		return CSGVertex:new():init(pos, normal);
	end
	local i;
	for i = 0,slices-1 do
		local t0 = i / slices;
		local t1 = (i + 1) / slices;
		if(radiusStart == radiusEnd)then
			table.insert(polygons,CSGPolygon:new():init({start_value:clone(), point(0, t0, radiusEnd, -1), point(0, t1, radiusEnd, -1)}));
			table.insert(polygons,CSGPolygon:new():init({point(0, t1, radiusEnd), point(0, t0, radiusEnd, 0), point(1, t0, radiusEnd, 0), point(1, t1, radiusEnd, 0)}));
			table.insert(polygons,CSGPolygon:new():init({end_value:clone(), point(1, t1, radiusEnd, 1), point(1, t0, radiusEnd, 1)}));
		else
			if(radiusStart > 0)then
				table.insert(polygons,CSGPolygon:new():init({start_value:clone(), point(0, t0, radiusStart, -1), point(0, t1, radiusStart, -1)}));
				table.insert(polygons,CSGPolygon:new():init({point(0, t0, radiusStart), point(1, t0, radiusEnd, 0), point(0, t1, radiusStart, 0)}));
			end
			if(radiusEnd > 0)then
				table.insert(polygons,CSGPolygon:new():init({end_value:clone(), point(1, t1, radiusEnd, 0), point(1, t0, radiusEnd, 0)}));
				table.insert(polygons,CSGPolygon:new():init({point(1, t0, radiusEnd, 1), point(1, t1, radiusEnd, 1), point(0, t1, radiusStart, 1)}));
			end
		end
		
	end
  return CSG.fromPolygons(polygons);
end