--[[
Title: 
Author(s): leio
Date: 2016/9/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/main.lua");
------------------------------------------------------------
]]
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	

local NPLCAD = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.NPLCAD"));

function NPLCAD:ctor()
end

-- virtual function get mod name
function NPLCAD:GetName()
	return "NPLCAD"
end

-- virtual function get mod description 
function NPLCAD:GetDesc()
	return "NPLCAD is a plugin in paracraft"
end

function NPLCAD:init()
	LOG.std(nil, "info", "NPLCAD", "plugin initialized");
	NPL.load("npl_packages/NplCadLibrary/");
	NPL.load("npl_packages/ModelVoxelizer/");
	-- add a menu item to NPL code wiki's `Tools:nplcad`
	NPL.load("(gl)script/apps/WebServer/WebServer.lua");
	WebServer:GetFilters():add_filter( 'wp_nav_menu_objects', function(sorted_menu_items)
		sorted_menu_items[sorted_menu_items:size()+1] = {
			url="nplcad",
			menu_item_parent="Tools",
			title="NPL CAD",
			id="nplcad",
		};
		return sorted_menu_items;
	end);
end

function NPLCAD:OnLogin()
end
-- called when a new world is loaded. 

function NPLCAD:OnWorldLoad()
end
-- called when a world is unloaded. 

function NPLCAD:OnLeaveWorld()
end

function NPLCAD:OnDestroy()
end

