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
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
local vector3d = commonlib.gettable("mathlib.vector3d");
local DomBase = commonlib.inherit(nil, commonlib.gettable("Mod.NPLCAD.doms.DomBase"));
function DomBase:ctor()
end
function DomBase:read(xmlnode,parentObj)
end
function DomBase:write(obj)
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
function DomBase:getNumber(v)
	if(not v)then return end
	return tonumber(v);
end
function DomBase:getColor(v)
	return self:getXYZ(v)
end


