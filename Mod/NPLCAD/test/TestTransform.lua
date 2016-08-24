--[[
Title: test transform changed values
Author(s):  leio
Date: 2016/8/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/test/TestTransform.lua");
local TestTransform = commonlib.gettable("Mod.NPLCAD.test.TestTransform");
TestTransform.Test_Env();
------------------------------------------------------------
]]
NPL.load("(gl)Mod/NPLCAD/core/Transform.lua");
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
NPL.load("(gl)Mod/NPLCAD/core/Scene.lua");
NPL.load("(gl)Mod/NPLCAD/drawables/CSGModel.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomParser.lua");
NPL.load("(gl)Mod/NPLCAD/services/CSGService.lua");
NPL.load("(gl)Mod/NPLCAD/services/NplCadEnvironment.lua");
local Transform = commonlib.gettable("Mod.NPLCAD.core.Transform");
local Node = commonlib.gettable("Mod.NPLCAD.core.Node");
local Scene = commonlib.gettable("Mod.NPLCAD.core.Scene");
local CSGModel = commonlib.gettable("Mod.NPLCAD.drawables.CSGModel");
local TestTransform = commonlib.gettable("Mod.NPLCAD.test.TestTransform");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");
local NplCadEnvironment = commonlib.gettable("Mod.NPLCAD.services.NplCadEnvironment");
function TestTransform.Test()


	local scene = Scene.create("first_scene");
	local root_node = Node.create("root_node");
	scene:addChild(root_node);

	local node_1 = Node.create("node_1");
	node_1:setDrawable(CSGModel.createCube());
	local node_2 = Node.create("node_2");
	local node_3 = Node.create("node_3");
	node_3:setDrawable(CSGModel.createSphere());
	local node_4 = Node.create("node_4");
	node_4:setDrawable(CSGModel.createCylinder());

	root_node:addChild(node_1);
	node_1:addChild(node_2);
	node_2:addChild(node_3);
	node_2:addChild(node_4);

	scene:visit(TestTransform.visitMethod);
	commonlib.echo("=========renderQueues");
	commonlib.echo(CSGService.getRenderList(scene));
end
function TestTransform.Test2()
	local scene = DomParser.load("Mod/NPLCAD/test/TestCad.xml");
	commonlib.echo("=========renderQueues");
	commonlib.echo(CSGService.getRenderList(scene));
end
function TestTransform.Test_Env()
	local code = [[
color(1,0,0);
intersection();
cube();
push()
	difference();
		sphere({ radius = 1.35, stacks = 12, color = {0,0,1}, });
	push()
		union();
		cylinder({ radius = 0.7, from = {-1,0,0}, to = {1,0,0}, color = {0,1,0}, });
		cylinder({ radius = 0.7, from = {0,-1,0}, to = {0,1,0}, color = {0,1,0}, });
		cylinder({ radius = 0.7, from = {0,0,-1}, to = {0,0,1}, color = {0,1,0}, });
	pop()
pop()
	]]
	local output = CSGService.buildPageContent(code)
	commonlib.echo(output);
end