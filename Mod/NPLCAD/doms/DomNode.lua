--[[
Title: DomNode 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomNode.lua");
local DomNode = commonlib.gettable("Mod.NPLCAD.doms.DomNode");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Quaternion.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
local Node = commonlib.gettable("Mod.NPLCAD.core.Node");
local DomNode = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.doms.DomBase"), commonlib.gettable("Mod.NPLCAD.doms.DomNode"));
function DomNode:ctor()
end
function DomNode:read(xmlnode,parentObj)
	if(not xmlnode or not parentObj)then
		return
	end
	self:checkAttr(xmlnode);
	-- id
	local node = Node.create(xmlnode.attr["id"]);
	parentObj:addChild(node);
	-- position
	local position = self:getXYZ(xmlnode.attr["position"]);
	if(position)then
		node:setTranslation(position[1],position[2],position[3]);
	end
	-- rotation
	local rotation = self:getXYZ(xmlnode.attr["rotation"]);
	if(rotation)then
		local q =  Quaternion:new();
		q =  q:FromEulerAngles(rotation[1],rotation[2],rotation[3]) 
		node:setRotation(q[1],q[2],q[3],q[4]);
	end
	-- scale
	local scale = self:getXYZ(xmlnode.attr["scale"]);
	if(scale)then
		node:setScale(scale[1],scale[2],scale[3]);
	end

	--color
	local color = self:getXYZ(xmlnode.attr["color"]);
	if(color)then
		node:setTag("color",color);
	end
	-- csg_action
	node:setTag("csg_action",xmlnode.attr["csg_action"]);

	self:readChildren(xmlnode,node);
	return node;
end
