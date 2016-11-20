--[[
Title: TestBsp
Author(s): leio
Date: 2016/11/8
Desc: 
-------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/test/TestBsp.lua");
local TestBsp = commonlib.gettable("Mod.NPLCAD.test.TestBsp");
TestBsp.testSphere();
TestBsp.testCube();
-------------------------------------------------------
--]]
NPL.load("(gl)Mod/NplCadLibrary/csg/CSG.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGFactory.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGBSPNode.lua");
NPL.load("(gl)Mod/NplCadLibrary/csg/CSGPolygon.lua");
local CSGPolygon = commonlib.gettable("Mod.NplCadLibrary.csg.CSGPolygon");
local CSG = commonlib.gettable("Mod.NplCadLibrary.csg.CSG");
local CSGFactory = commonlib.gettable("Mod.NplCadLibrary.csg.CSGFactory");
local CSGBSPNode = commonlib.gettable("Mod.NplCadLibrary.csg.CSGBSPNode");
local TestBsp = commonlib.gettable("Mod.NPLCAD.test.TestBsp");
function TestBsp.testCube()
	local cube = CSGFactory.cube();
	LOG.std(nil, "info", "TestBsp.testCube", "start to build csg node");
	local node = CSGBSPNode:new():init();
	LOG.std(nil, "info", "TestBsp.testCube", "vertex length of polygons:%d",cube:getVertexCnt());
	node:build(cube.polygons);
	LOG.std(nil, "info", "TestBsp.testCube", "finished");
	_guihelper.MessageBox("TestBsp.testCube finished");
end

function TestBsp.testSphere()
	local resolutions = {10, 20, 30, 40, 50}
	for i, res in ipairs(resolutions) do
		local fromTime = ParaGlobal.timeGetTime();
		local sphere = CSGFactory.sphere({
			resolution = res
		});
		LOG.std(nil, "info", "TestBsp.testSphere", "start to build csg node");
		local node = CSGBSPNode:new():init();
		node:build(sphere.polygons);
		LOG.std(nil, "info", "TestBsp.testSphere", "finished %.3f with vertex count:%d", (ParaGlobal.timeGetTime()-fromTime)/1000, sphere:getVertexCnt());
	end
	-- _guihelper.MessageBox("TestBsp.testSphere finished");
end

