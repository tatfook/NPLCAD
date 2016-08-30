--[[
Title: DomBase 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomBase.lua");
local DomBase = commonlib.gettable("Mod.NPLCAD.doms.DomBase");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomParser.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
local vector3d = commonlib.gettable("mathlib.vector3d");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local DomBase = commonlib.inherit(nil, commonlib.gettable("Mod.NPLCAD.doms.DomBase"));
function DomBase:ctor()
end
function DomBase:read(xmlnode,parentObj)
end

function DomBase:getParser(name)
	return DomParser.getParser(name);
end
function DomBase:readChildren(xmlnode,parentObj)
	local len = #xmlnode;
	for k = 1,len do
		local node = xmlnode[k];
		local p = self:getParser(node.name);
		if(p)then
			p:read(node,parentObj);
		end
	end
end
function DomBase:checkAttr(xmlnode)
	if(xmlnode)then
		xmlnode.attr = xmlnode.attr or {};
	end
end
function DomBase:getXYZ(v)
	if(not v)then return end
	local x,y,z = string.match(v,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	return {x,y,z}
end
function DomBase:toXYZ(v)
	if(not v)then return end
	local s = string.format("%.2f,%.2f,%.2f",v[1],v[2],v[3]);
	return s;
end
function DomBase:toXYZ_Int(v)
	if(not v)then return end
	local s = string.format("%d,%d,%d",v[1],v[2],v[3]);
	return s;
end
function DomBase:toInt(v)
	if(not v)then return end
	local s = string.format("%d",v);
	return s;
end
function DomBase:toFloat(v)
	if(not v)then return end
	local s = string.format("%.2f",v);
	return s;
end
function DomBase:getNumber(v)
	if(not v)then return end
	return tonumber(v);
end
function DomBase:getColor(v)
	return self:getXYZ(v)
end
function DomBase:writeProperties(obj)
	local output_str = "";
	if(obj)then
		if(obj.getId and obj:getId())then
			local id = obj:getId();
			if(id ~= "")then
				output_str = string.format("%s id=%s",output_str,obj:getId());
			end
		end
		if(obj.getTag and obj:getTag("csg_action"))then
			output_str = string.format("%s csg_action=\"%s\"",output_str,obj:getTag("csg_action"));
		end
		if(obj.getTag and obj:getTag("color"))then
			local color = obj:getTag("color");
			output_str = string.format([[%s color="%.2f,%.2f,%.2f"]],output_str,color[1],color[2],color[3]);
		end
		
		if(obj.getTranslation)then
			local v = obj:getTranslation();
			if(not v:equals(vector3d:new_from_pool(0,0,0)))then
				output_str = string.format([[%s position="%.2f,%.2f,%.2f"]],output_str,v[1],v[2],v[3]);
			end
		end
		if(obj.getScale)then
			local v = obj:getScale();
			if(not v:equals(vector3d:new_from_pool(1,1,1)))then
				output_str = string.format([[%s scale="%.2f,%.2f,%.2f"]],output_str,v[1],v[2],v[3]);
			end
		end
		if(obj.getRotation)then
			local v = obj:getRotation();
			if(not v:equals(Quaternion.IDENTITY))then
				output_str = string.format([[%s rotation="%.2f,%.2f,%.2f"]],output_str,v[1],v[2],v[3]);
			end
		end
		
	end
	return output_str;
end

function DomBase:write(obj)
	local output_str = "";
	if(obj)then
		local name = obj:getTypeName();
		local attrs = self:writeProperties(obj);
		if(attrs and attrs ~= "")then
			attrs = " " .. attrs;
		end
		output_str = DomParser.write_children(obj);
		if(obj.getDrawable)then
			drawable = obj:getDrawable();
			if(drawable)then
				output_str = DomParser.write_internal(drawable);
			end
		end
		output_str = string.format([[<%s%s>%s</%s>]],name,attrs, output_str,name);
	end
	return output_str;
end


