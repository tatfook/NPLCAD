--[[
Title: DomCSGModel 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomCSGModel.lua");
local DomCSGModel = commonlib.gettable("Mod.NPLCAD.doms.DomCSGModel");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NPLCAD/drawables/CSGModel.lua");
local CSGModel = commonlib.gettable("Mod.NPLCAD.drawables.CSGModel");
local DomCSGModel = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.doms.DomBase"), commonlib.gettable("Mod.NPLCAD.doms.DomCSGModel"));
function DomCSGModel:ctor()
end
function DomCSGModel:read(xmlnode,parentObj)
	if(not xmlnode or not parentObj)then
		return
	end
	self:checkAttr(xmlnode);
	local model;
	local options = {};
	local model_type = xmlnode.attr.model_type or "cube";
	if(model_type == "cube"  or model_type == "c")then
		options.center = self:getXYZ(xmlnode.attr["center"] or "0,0,0");
		options.radius = self:getXYZ(xmlnode.attr["radius"] or "1,1,1");
		local color = self:getColor(xmlnode.attr["color"] or "1,1,1");
		model = CSGModel.createCube(options);
		model:setColor(color);
	elseif(model_type == "sphere" or model_type == "s")then
		options.center = self:getXYZ(xmlnode.attr["center"] or "0,0,0");
		options.radius = self:getNumber(xmlnode.attr["radius"] or "1");
		options.slices = self:getNumber(xmlnode.attr["slices"] or "16");
		options.stacks = self:getNumber(xmlnode.attr["stacks"] or "8");
		local color = self:getColor(xmlnode.attr["color"] or "1,1,1");

		model = CSGModel.createSphere(options);
		model:setColor(color);
	elseif(model_type == "cylinder" or model_type == "c")then
		options.from = self:getXYZ(xmlnode.attr["from"] or "0,-1,0");
		options.to = self:getXYZ(xmlnode.attr["to"] or "0,1,0");
		options.radius = self:getNumber(xmlnode.attr["radius"] or "1");
		options.slices = self:getNumber(xmlnode.attr["slices"] or "16");
		local color = self:getColor(xmlnode.attr["color"] or "1,1,1");

		model = CSGModel.createCylinder(options);
		model:setColor(color);
	end
	parentObj:setDrawable(model);
	return model;
end
function DomCSGModel:write(obj)
end