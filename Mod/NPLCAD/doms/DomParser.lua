--[[
Title: DomParser
Author(s):  leio
Date: 2016/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/doms/DomParser.lua");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomScene.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomNode.lua");
NPL.load("(gl)Mod/NPLCAD/doms/DomCSGModel.lua");
local DomScene = commonlib.gettable("Mod.NPLCAD.doms.DomScene");
local DomNode = commonlib.gettable("Mod.NPLCAD.doms.DomNode");
local DomCSGModel = commonlib.gettable("Mod.NPLCAD.doms.DomCSGModel");
local DomParser = commonlib.gettable("Mod.NPLCAD.doms.DomParser");
DomParser.parsers = {};
function DomParser.initParser()
	if(not DomParser.is_init)then
		DomParser.is_init = true;
		
		DomParser.parsers["Scene"] = DomScene:new();
		DomParser.parsers["Node"] = DomNode:new();
		DomParser.parsers["Model"] = DomCSGModel:new();


	end
end
function DomParser.getParser(name)
	if(not name)then
		return;
	end
	return DomParser.parsers[name];
end
function DomParser.loadStr(content)
	local xmlRoot = ParaXML.LuaXML_ParseString(content);
	return DomParser.loadScene(xmlRoot);
end
function DomParser.load(filename)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	return DomParser.loadScene(xmlRoot);
end
function DomParser.loadScene(xmlRoot)
	DomParser.initParser();
	local scene = nil;
	if(xmlRoot) then
		local scene_item;
		for scene_item in commonlib.XPath.eachNode(xmlRoot, "/Scene") do
			local p = DomParser.getParser(scene_item.name);
			if(p)then
				scene = p:read(scene_item);
			end
			break
		end
	end
	return scene;
end


