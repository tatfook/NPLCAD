--[[
Title: NplCadEnvironment 
Author(s): leio
Date: 2016/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/services/NplCadEnvironment.lua");
local NplCadEnvironment = commonlib.gettable("Mod.NPLCAD.services.NplCadEnvironment");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)Mod/NPLCAD/core/Transform.lua");
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
NPL.load("(gl)Mod/NPLCAD/core/Scene.lua");
NPL.load("(gl)Mod/NPLCAD/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomParser.lua");
NPL.load("(gl)Mod/NPLCAD/services/CSGService.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Transform = commonlib.gettable("Mod.NPLCAD.core.Transform");
local Node = commonlib.gettable("Mod.NPLCAD.core.Node");
local Scene = commonlib.gettable("Mod.NPLCAD.core.Scene");
local CSGModel = commonlib.gettable("Mod.NPLCAD.drawables.CSGModel");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");

local NplCadEnvironment = commonlib.gettable("Mod.NPLCAD.services.NplCadEnvironment");
function NplCadEnvironment:new()
	local o = {
		scene =  Scene.create("nplcad_scene");
		nodes_stack = {},
	};
	setmetatable(o, self);
	self.__index = self
	return o;
end

function NplCadEnvironment.getNode()
	local self = getfenv(2);
	return self:getNode__();
end
function NplCadEnvironment:getNode__()
	if(self.nodes_stack)then
		local len = #self.nodes_stack;
		local node = self.nodes_stack[len];
		if(node)then
			return node;
		end
		return self.scene;
	end
end
function NplCadEnvironment.push()
	local self = getfenv(2);
	self:push__();
end
function NplCadEnvironment:push__()
	local parent = self:getNode__()
	local node = Node.create("");
	table.insert(self.nodes_stack,node);
	parent:addChild(node);
	return node;
end
function NplCadEnvironment.pop()
	local self = getfenv(2);
	self:pop__();
end
function NplCadEnvironment:pop__()
	if(self.nodes_stack)then
		local len = #self.nodes_stack;
		table.remove(self.nodes_stack,len);
	end
end
function NplCadEnvironment.union()
	local self = getfenv(2);
	self:union__();
end
function NplCadEnvironment:union__()
	local node = self:getNode__();
	if(node)then
		node:setTag("csg_action","union");
	end
end
function NplCadEnvironment.difference()
	local self = getfenv(2);
	self:difference__();
end
function NplCadEnvironment:difference__()
	local node = self:getNode__();
	if(node)then
		node:setTag("csg_action","difference");
	end
end
function NplCadEnvironment.intersection()
	local self = getfenv(2);
	self:intersection__();
end
function NplCadEnvironment:intersection__()
	local node = self:getNode__();
	if(node)then
		node:setTag("csg_action","intersection");
	end
end
function NplCadEnvironment.cube(options)
	local self = getfenv(2);
	self:cube__(options);
end
--[[
	local options = {
		radius = radius,
		center = center,
		color = color,
	}
]]
function NplCadEnvironment:cube__(options)
	options = options or {};
	local parent = self:getNode__();
	local node = Node.create("");
	node:setTag("color",options.color);
	node:setDrawable(CSGModel.createCube(options));
	parent:addChild(node);
end
function NplCadEnvironment.sphere(options)
	local self = getfenv(2);
	self:sphere__(options);
end
--[[
	local options = {
		radius = radius,
		slices = slices,
		stacks = stacks,
		center = center,
		color = color,
	}
--]]
function NplCadEnvironment:sphere__(options)
	options = options or {};
	local parent = self:getNode__();
	local node = Node.create("");
	node:setTag("color",options.color);
	node:setDrawable(CSGModel.createSphere(options));
	parent:addChild(node);
end

function NplCadEnvironment.cylinder(options)
	local self = getfenv(2);
	self:cylinder__(options);
end
--[[
	local options = {
		from = from,
		to = to,
		radius = radius,
		slices = slices,
		color = color,
	}
]]
function NplCadEnvironment:cylinder__(options)
	options = options or {};
	local parent = self:getNode__();
	local node = Node.create("");
	node:setTag("color",options.color);
	node:setDrawable(CSGModel.createCylinder(options));
	parent:addChild(node);
end
function NplCadEnvironment.translate(x,y,z)
	local self = getfenv(2);
	self:translate__(x,y,z);
end
function NplCadEnvironment:translate__(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = self:getNode__();
	if(node)then
		node:setTranslation(x,y,z);
	end
end
function NplCadEnvironment.rotate(x,y,z)
	local self = getfenv(2);
	self:rotate__(x,y,z);
end
function NplCadEnvironment:rotate__(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = self:getNode__();
	if(node)then
		local q =  Quaternion:new();
		q =  q:FromEulerAngles(x,y,z) 
		node:setRotation(q[1],q[2],q[3],q[4]);
	end
end
function NplCadEnvironment.scale(x,y,z)
	local self = getfenv(2);
	self:scale__(x,y,z);
end
function NplCadEnvironment:scale__(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = self:getNode__();
	if(node)then
		node:setScale(x,y,z);
	end
end
function NplCadEnvironment.color(r,g,b)
	local self = getfenv(2);
	self:color__(r,g,b);
end
function NplCadEnvironment:color__(r,g,b)
	if(not r or not g or not b)then
		return
	end
	local node = self:getNode__();
	if(node)then
		node:setTag("color",{r,g,b});
	end
end