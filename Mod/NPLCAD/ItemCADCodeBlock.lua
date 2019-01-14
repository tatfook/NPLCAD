--[[
Title: ItemCADCodeBlock
Author(s): LiXizhi
Date: 2019/1/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/ItemCADCodeBlock.lua");
local ItemCADCodeBlock = commonlib.gettable("MyCompany.Aries.Game.Items.ItemCADCodeBlock");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");

local ItemCADCodeBlock = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Items.Item"), commonlib.gettable("MyCompany.Aries.Game.Items.ItemCADCodeBlock"));

block_types.RegisterItemClass("ItemCADCodeBlock", ItemCADCodeBlock);

function ItemCADCodeBlock:ctor()
end

function ItemCADCodeBlock:TryCreate(itemStack, entityPlayer, x,y,z, side, data, side_region)
	if (itemStack and itemStack.count == 0) then
		return;
	elseif (entityPlayer and not entityPlayer:CanPlayerEdit(x,y,z, data, itemStack)) then
		return;
	elseif (self:CanPlaceOnSide(x,y,z,side, data, side_region, entityPlayer, itemStack)) then
		NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
		local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
		local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");
		local item = ItemClient.GetItem(names.CodeBlock);
		if(item) then
			NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemStack.lua");
			local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
			local item_stack = ItemStack:new():Init(names.CodeBlock, 1);
			item_stack:SetDataField("langConfigFile", "npl_cad");
			item_stack:SetDataField("nplCode", "-- sphere(1)");
			return item:TryCreate(item_stack, entityPlayer, x,y,z, side, data, side_region);
		end
	end
end
