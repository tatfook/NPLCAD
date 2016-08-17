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

	local id = xmlnode.attr.id;
	local node = Node.create(id);
	parentObj:addChild(node);
	self:readChildren(xmlnode,node);
	return node;
end
function DomNode:write(obj)
end