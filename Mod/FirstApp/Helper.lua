--[[
Title: 
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/FirstApp/Helper.lua");
local Helper = commonlib.gettable("Mod.FirstApp.Helper");
------------------------------------------------------------
]]
local Helper = commonlib.gettable("Mod.FirstApp.Helper")

function Helper:Hello()
	_guihelper.MessageBox("hello from helper class")
end

