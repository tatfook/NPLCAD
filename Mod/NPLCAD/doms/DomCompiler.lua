--[[
Title: DomCompiler
Author(s):  leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomCompiler.lua");
local DomCompiler = commonlib.gettable("Mod.NPLCAD.doms.DomCompiler");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomScene.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomNode.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomCSGModel.lua");
local DomScene = commonlib.gettable("Mod.NPLCAD.doms.DomScene");
local DomNode = commonlib.gettable("Mod.NPLCAD.doms.DomNode");
local DomCSGModel = commonlib.gettable("Mod.NPLCAD.doms.DomCSGModel");
local DomCompiler = commonlib.gettable("Mod.NPLCAD.doms.DomCompiler");
DomCompiler.parsers = {};
function DomCompiler.initParser()
	if(not DomCompiler.is_init)then
		DomCompiler.is_init = true;
		
		DomCompiler.parsers["Scene"] = DomScene:new();
		DomCompiler.parsers["Node"] = DomNode:new();
		DomCompiler.parsers["Model"] = DomCSGModel:new();
	end
end
function DomCompiler.getParser(name)
	if(not name)then
		return;
	end
	return DomCompiler.parsers[name];
end
function DomCompiler.loadStr(content)
	local xmlRoot = ParaXML.LuaXML_ParseString(content);
	return DomCompiler.loadScene(xmlRoot);
end
function DomCompiler.load(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	return DomCompiler.loadScene(xmlRoot);
end
function DomCompiler.loadScene(xmlRoot)
	DomCompiler.initParser();
	local scene = nil;
	if(xmlRoot) then
		local scene_item;
		for scene_item in commonlib.XPath.eachNode(xmlRoot, "/Scene") do
			local p = DomCompiler.getParser(scene_item.name);
			if(p)then
				scene = p:read(scene_item);
			end
			break
		end
	end
	return scene;
end
function DomCompiler.getRenderList(scene)
	if(not scene)then
		return
	end
	local render_list = {};
	scene:visit(function(node)
		if(node)then
			local drawable = node:getDrawable();
			if(drawable and drawable.getCSGNode)then
				local csg_node = drawable:getCSGNode();
				if(csg_node)then
					local vertices,indices,normals,colors = drawable:toMesh();
					local world_matrix = node:getWorldMatrix();
					table.insert(render_list,{
						world_matrix = world_matrix,
						vertices = vertices,
						indices = indices,
						normals = normals,
						colors = colors,
					});
				end
			end
		end
	end);
	return render_list;
end
