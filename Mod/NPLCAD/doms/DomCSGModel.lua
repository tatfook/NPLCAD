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
		if(xmlnode.attr["radius"])then
			local v = xmlnode.attr["radius"];
			if(tonumber(v))then
				options.radius = tonumber(v);
			else
				options.radius = self:getXYZ(xmlnode.attr["radius"] or "1,1,1");
			end
		end
		model = CSGModel.createCube(options);
	elseif(model_type == "sphere" or model_type == "s")then
		options.center = self:getXYZ(xmlnode.attr["center"] or "0,0,0");
		options.radius = self:getNumber(xmlnode.attr["radius"] or "1");
		options.slices = self:getNumber(xmlnode.attr["slices"] or "16");
		options.stacks = self:getNumber(xmlnode.attr["stacks"] or "8");

		model = CSGModel.createSphere(options);
	elseif(model_type == "cylinder" or model_type == "c")then
		options.from = self:getXYZ(xmlnode.attr["from"] or "0,-1,0");
		options.to = self:getXYZ(xmlnode.attr["to"] or "0,1,0");
		options.radius = self:getNumber(xmlnode.attr["radius"] or "1");
		options.slices = self:getNumber(xmlnode.attr["slices"] or "16");

		model = CSGModel.createCylinder(options);
	end
	parentObj:setDrawable(model);
	return model;
end
function DomCSGModel:writeProperties(obj)
	local output_str = "";
	if(obj)then
		local model_type = obj.model_type or "cube";
		local options = obj.options;
		output_str = string.format([[%s model_type="%s"]],output_str,model_type);
		if(options)then
			if(model_type == "cube")then
				if(options["center"])then
					output_str = string.format([[%s center="%s"]],output_str,self:toXYZ(options["center"]));
				end
				if(options["radius"])then
					if(type(options["radius"]) == "number")then
						output_str = string.format([[%s radius="%s"]],output_str,self:toFloat(options["radius"]));
					else
						output_str = string.format([[%s radius="%s"]],output_str,self:toXYZ(options["radius"]));
					end
				end
			elseif(model_type == "sphere")then
				if(options["center"])then
					output_str = string.format([[%s center="%s"]],output_str,self:toXYZ(options["center"]));
				end
				if(options["radius"])then
					output_str = string.format([[%s radius="%s"]],output_str,self:toFloat(options["radius"]));
				end
				if(options["slices"])then
					output_str = string.format([[%s slices="%s"]],output_str,self:toInt(options["slices"]));
				end
				if(options["stacks"])then
					output_str = string.format([[%s stacks="%s"]],output_str,self:toInt(options["stacks"]));
				end
			elseif(model_type == "cylinder")then
				if(options["from"])then
					output_str = string.format([[%s from="%s"]],output_str,self:toXYZ(options["from"]));
				end
				if(options["to"])then
					output_str = string.format([[%s to="%s"]],output_str,self:toXYZ(options["to"]));
				end
				if(options["radius"])then
					output_str = string.format([[%s radius="%s"]],output_str,self:toFloat(options["radius"]));
				end
				if(options["slices"])then
					output_str = string.format([[%s slices="%s"]],output_str,self:toInt(options["slices"]));
				end
			end
			
		end
	end
	return output_str;
end
