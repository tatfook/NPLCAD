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
push()
        difference() ;
    	color(0,0.5,1);
    	cube({radius=3,});
    	sphere({ radius = 4, color = {0,0,1}, });
pop()
push()
        difference() ;
        translate(6,6,6);
        scale(2,2,2);
    	color(0,0.5,1);
    	cube({radius=3,});
    	sphere({ radius = 4, color = {0,0,1}, });
pop()

	]]
	local output = CSGService.buildPageContent(code)
	commonlib.echo(output);
	local env =  getfenv(2);
	local output_str = DomParser.write(CSGService.scene);
	DomParser.writeToFile("test/nplcad.xml",CSGService.scene)
end
function TestTransform.Test_Env2()
	local code = [[
<!--nplcad-->
<Scene csg_action="union">
  <Node >
    <Node  csg_action="difference">
      <Node  color="0.00,0.50,1.00">
        <Node >
          <Model  model_type="cube" radius="3.00"></Model>
        </Node>
        <Node  color="0.00,0.00,1.00">
          <Model  model_type="sphere" radius="4.00"></Model>
        </Node>
      </Node>
    </Node>
  </Node>
  <Node >
    <Node  csg_action="difference">
      <Node  position="6.00,6.00,6.00">
        <Node  scale="2.00,2.00,2.00">
          <Node  color="0.00,0.50,1.00">
            <Node >
              <Model  model_type="cube" radius="3.00"></Model>
            </Node>
            <Node  color="0.00,0.00,1.00">
              <Model  model_type="sphere" radius="4.00"></Model>
            </Node>
          </Node>
        </Node>
      </Node>
    </Node>
  </Node>
</Scene>
	]]
	local output = CSGService.buildPageContent(code)
	commonlib.echo(output);
end