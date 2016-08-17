--[[
Title: Scene 
Author(s): leio
Date: 2016/8/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/core/Scene.lua");
local Scene = commonlib.gettable("Mod.NPLCAD.core.Scene");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
local Scene = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.core.Node"), commonlib.gettable("Mod.NPLCAD.core.Scene"));
function Scene.create(id)
	local scene = Scene:new();
	scene:setId(id);
	return scene;
end

function Scene:getTypeName()
	return "Scene";
end
function Scene:visit(visitMethod)
	local node = self:getFirstChild();
	while(node) do
		self:visitNode(node,visitMethod);
		node = node:getNextSibling();
	end
end
function Scene:visitNode(node,visitMethod)
	if(not node)then
		return;
	end
	if(visitMethod)then
		visitMethod(node);
	end
	local child = node:getFirstChild();
	while(child) do
		self:visitNode(child,visitMethod);
		child = child:getNextSibling();
	end
end
