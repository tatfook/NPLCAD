--[[
Title: TestBsp
Author(s): leio
Date: 2016/11/8
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/test/TestBsp.lua");
local TestBsp = commonlib.gettable("Mod.NPLCAD.test.TestBsp");
TestBsp.testCube();
TestBsp.testSphere();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGNode.lua");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGNode");
local TestBsp = commonlib.gettable("Mod.NPLCAD.test.TestBsp");
function TestBsp.testCube()
	local cube = CSGFactory.cube();
	LOG.std(nil, "info", "TestBsp.testCube", "start to build csg node");
	local node = CSGNode:new():init();
	LOG.std(nil, "info", "TestBsp.testCube", "vertex length of polygons:%d",cube:getVertexCnt());
	node:build(cube.polygons);
	LOG.std(nil, "info", "TestBsp.testCube", "finished");
	_guihelper.MessageBox("TestBsp.testCube finished");
end
function TestBsp.testSphere()
	local sphere = CSGFactory.sphere({
		resolution = 100
	});
	LOG.std(nil, "info", "TestBsp.testSphere", "start to build csg node");
	local node = CSGNode:new():init();
	LOG.std(nil, "info", "TestBsp.testSphere", "vertex length of polygons:%d",sphere:getVertexCnt());
	node:build(sphere.polygons);
	LOG.std(nil, "info", "TestBsp.testSphere", "finished");
	_guihelper.MessageBox("TestBsp.testSphere finished");
end


