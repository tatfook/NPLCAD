--[[
Title: DomScene 
Author(s): leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomScene.lua");
local DomScene = commonlib.gettable("Mod.NPLCAD.doms.DomScene");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NPLCAD/core/Scene.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomBase.lua");
local Scene = commonlib.gettable("Mod.NPLCAD.core.Scene");
local DomScene = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.doms.DomBase"), commonlib.gettable("Mod.NPLCAD.doms.DomScene"));
function DomScene:ctor()
end
function DomScene:read(xmlnode,parentObj)
	if(not xmlnode)then
		return
	end
	self:checkAttr(xmlnode);
	local id = xmlnode.attr.id;
	local scene = Scene.create(id);

	self:readChildren(xmlnode,scene);
	return scene;
end
function DomScene:write(obj)
end