--[[
Title: NplCadCompiler 
Author(s):  leio
Date: 2016/8/4
Desc: 
In nplcad environment one can code like this:
function main()
   
end
Note: The entrance of nplcad programme is main function.
A mesh will be rendered when run echo() once.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/NplCadCompiler.lua");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
local NplCadCompiler = commonlib.gettable("Mod.NPLCAD.NplCadCompiler");
NplCadCompiler.Reset()
NplCadCompiler.cube()
NplCadCompiler.cube()

NplCadCompiler.beginUnion();
	--Todo
NplCadCompiler.endUnion();

NplCadCompiler.beginDifference();
	--Todo
NplCadCompiler.endDifference();

NplCadCompiler.beginIntersection();
	--Todo
NplCadCompiler.endIntersection();

local render_list = DomParser.getRenderList(NplCadCompiler.scene)
commonlib.echo("========render_list");
commonlib.echo(render_list);
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)Mod/NPLCAD/core/Transform.lua");
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
NPL.load("(gl)Mod/NPLCAD/core/Scene.lua");
NPL.load("(gl)Mod/NPLCAD/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomParser.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Transform = commonlib.gettable("Mod.NPLCAD.core.Transform");
local Node = commonlib.gettable("Mod.NPLCAD.core.Node");
local Scene = commonlib.gettable("Mod.NPLCAD.core.Scene");
local CSGModel = commonlib.gettable("Mod.NPLCAD.drawables.CSGModel");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");

local NplCadCompiler = commonlib.gettable("Mod.NPLCAD.NplCadCompiler");
-- csg environment
NplCadCompiler.env = nil;
NplCadCompiler.nodes_stack = nil;
function NplCadCompiler.Reset()
	NplCadCompiler.nodes_stack = {};
	NplCadCompiler.scene = Scene.create("nplcad_scene");
end
function NplCadCompiler.CreateSandBoxEnv()
	if(NplCadCompiler.env)then
		return NplCadCompiler.env;
	end
	local env = {
		pushNode = NplCadCompiler.pushNode,
		popNode = NplCadCompiler.popNode,
		beginUnion = NplCadCompiler.beginUnion,
		endUnion = NplCadCompiler.endUnion,
		beginDifference = NplCadCompiler.beginDifference,
		endDifference = NplCadCompiler.endDifference,
		beginIntersection = NplCadCompiler.beginIntersection,
		endIntersection = NplCadCompiler.endIntersection,
		cube = NplCadCompiler.cube,
		sphere = NplCadCompiler.sphere,
		cylinder = NplCadCompiler.cylinder,
		translate = NplCadCompiler.translate,
		rotate = NplCadCompiler.rotate,
		scale = NplCadCompiler.scale,
		color = NplCadCompiler.color,
	};
	local meta = {__index = _G};
	setmetatable (env, meta);
	return env;
end
--[[
	return {
		success = success,
		csg_node_values = csg_node_values,
		compile_error = compile_error,
	}
--]]
function NplCadCompiler.Build(code)
	if(not code or code == "") then
		return;
	end
	NplCadCompiler.Reset();

	local output = {}
	local code_func, errormsg = loadstring(code);
	if(code_func) then
		local env = NplCadCompiler.CreateSandBoxEnv();
		setfenv(code_func, env);
		local ok, result = pcall(code_func);
		if(ok) then
			if(type(env.main) == "function") then
				setfenv(env.main, env);
				ok, result = pcall(env.main);
			end
		end
		local render_list = DomParser.getRenderList(NplCadCompiler.scene)
		output.success = ok;
		output.csg_node_values = render_list;
	else
		output.compile_error =  errormsg;
	end
	return output;
end

function NplCadCompiler.getNode()
	if(NplCadCompiler.nodes_stack)then
		local len = #NplCadCompiler.nodes_stack;
		local node = NplCadCompiler.nodes_stack[len];
		if(node)then
			return node;
		end
		return NplCadCompiler.scene;
	end
end
function NplCadCompiler.pushNode()
	local parent = NplCadCompiler.getNode()
	local node = Node.create("");
	table.insert(NplCadCompiler.nodes_stack,node);

	parent:addChild(node);
	return node;
end
function NplCadCompiler.popNode()
	if(NplCadCompiler.nodes_stack)then
		local len = #NplCadCompiler.nodes_stack;
		table.remove(NplCadCompiler.nodes_stack,len);
	end
end
function NplCadCompiler.beginUnion()
	local node = NplCadCompiler.pushNode();
	if(node)then
		--node:setCsgAction("union");
	end
end
function NplCadCompiler.endUnion()
	local node = NplCadCompiler.getNode();
	if(node)then
		--node:doCsgAction("union");
	end
	NplCadCompiler.popNode()
end
function NplCadCompiler.beginDifference()
	local node = NplCadCompiler.pushNode();
	if(node)then
		--node:setCsgAction("difference");
	end
end
function NplCadCompiler.endDifference()
	local node = NplCadCompiler.getNode();
	if(node)then
		--node:doCsgAction("difference");
	end
	NplCadCompiler.popNode()
end
function NplCadCompiler.beginIntersection()
	local node = NplCadCompiler.pushNode();
	if(node)then
		--node:setCsgAction("intersection");
	end
end
function NplCadCompiler.endIntersection()
	local node = NplCadCompiler.getNode();
	if(node)then
		--node:doCsgAction("intersection");
	end
	NplCadCompiler.popNode()
end
function NplCadCompiler.cube(options)
	local parent = NplCadCompiler.getNode();
	local node = Node.create("");
	node:setDrawable(CSGModel.createCube(options));
	parent:addChild(node);
end
function NplCadCompiler.sphere(options)
	local parent = NplCadCompiler.getNode();
	local node = Node.create("");
	node:setDrawable(CSGModel.createSphere(options));
	parent:addChild(node);
end
function NplCadCompiler.cylinder(options)
	local parent = NplCadCompiler.getNode();
	local node = Node.create("");
	node:setDrawable(CSGModel.createCylinder(options));
	parent:addChild(node);
end
function NplCadCompiler.translate(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = NplCadCompiler.pushNode();
	if(node)then
		node:setTranslation(x,y,z);
	end
end
function NplCadCompiler.rotate(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = NplCadCompiler.pushNode();
	if(node)then
		local q =  Quaternion:new();
		q =  q:FromEulerAngles(x,y,z) 
		node:setRotation(q[1],q[2],q[3],q[4]);
	end
end
function NplCadCompiler.scale(x,y,z)
	if(not x or not y or not z)then
		return
	end
	local node = NplCadCompiler.pushNode();
	if(node)then
		node:setScale(x,y,z);
	end
end
