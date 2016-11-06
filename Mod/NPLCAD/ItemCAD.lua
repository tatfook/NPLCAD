--[[
Title: ItemCAD
Author(s): LiXizhi
Date: 2016/11/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/ItemCAD.lua");
local ItemCAD = commonlib.gettable("MyCompany.Aries.Game.Items.ItemCAD");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemBlockModel.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Files.lua");
local ItemBlockModel = commonlib.gettable("MyCompany.Aries.Game.Items.ItemBlockModel");
local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");

local ItemCAD = commonlib.inherit(ItemBlockModel, commonlib.gettable("MyCompany.Aries.Game.Items.ItemCAD"));

block_types.RegisterItemClass("ItemCAD", ItemCAD);

-- @param template: icon
-- @param radius: the half radius of the object. 
function ItemCAD:ctor()
	self:SetOwnerDrawIcon(true);
end

function ItemCAD:HasRealPhysics()
	return true;
end

function ItemCAD:TryCreate(itemStack, entityPlayer, x,y,z, side, data, side_region)
	local local_filename = itemStack:GetDataField("tooltip");
	local filename = local_filename;
	if(filename) then
		filename = Files.FindFile(commonlib.Encoding.Utf8ToDefault(filename));
		if(filename) then
			filename = commonlib.Encoding.DefaultToUtf8(filename);
		end
	end
	if(not filename) then
		self:OpenChangeFileDialog(itemStack);
		return;
	end
	
	if (itemStack and itemStack.count == 0) then
		return;
	elseif (entityPlayer and not entityPlayer:CanPlayerEdit(x,y,z, data, itemStack)) then
		return;
	elseif (self:CanPlaceOnSide(x,y,z,side, data, side_region, entityPlayer, itemStack)) then
		-- create here ItemBlockModel here
		local bmaxFilename = self:GetBMAXFileName(itemStack);
		if(Files.FindFile(commonlib.Encoding.Utf8ToDefault(bmaxFilename))) then
			NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemClient.lua");
			local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
			local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names");
			local item = ItemClient.GetItem(names.PhysicsModel);
			if(item) then
				NPL.load("(gl)script/apps/Aries/Creator/Game/Items/ItemStack.lua");
				local ItemStack = commonlib.gettable("MyCompany.Aries.Game.Items.ItemStack");
				local item_stack = ItemStack:new():Init(names.PhysicsModel, 1);
				item_stack:SetTooltip(bmaxFilename);
				return item:TryCreate(item_stack, entityPlayer, x,y,z, side, data, side_region);
			end
		else
			_guihelper.MessageBox(L"还没有保存为BMAX文件，是否现在保存?", function()
				self:OpenNPLCadEditor(filename);
			end)
		end
	end
end


-- called whenever this item is clicked on the user interface when it is holding in hand of a given player (current player). 
function ItemCAD:OnClickInHand(itemStack, entityPlayer)
	-- if there is selected blocks, we will replace selection with current block in hand. 
	if(GameLogic.GameMode:IsEditor()) then
		self:OpenChangeFileDialog(itemStack);
	end
end

function ItemCAD:PickItemFromPosition(x,y,z)
	local entity = self:GetBlock():GetBlockEntity(x,y,z);
	if(entity) then
		if(entity.GetModelFile) then
			local filename = entity:GetModelFile();
			if(filename and filename:match("cad%.%w%w%w$")) then
				filename = filename:gsub("cad%.%w%w%w$", "cad.npl");
				local itemStack = ItemStack:new():Init(self.id, 1);
				-- transfer filename from entity to item stack. 
				itemStack:SetTooltip(filename);
				return itemStack;
			end
		end
	end
end

-- return true if items are the same. 
-- @param left, right: type of ItemStack or nil. 
function ItemCAD:CompareItems(left, right)
	if(self._super.CompareItems(self, left, right)) then
		if(left and right and left:GetTooltip() == right:GetTooltip()) then
			return true;
		end
	end
end

function ItemCAD:OpenChangeFileDialog(itemStack)
	if(itemStack) then
		local local_filename = itemStack:GetDataField("tooltip");
		NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenFileDialog.lua");
		local OpenFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenFileDialog");
		OpenFileDialog.ShowPage(L"请输入NPL CAD文件名", function(result)
			result = result or "";
			if(not result:match("%.") and result~= "") then
				result = result .. ".cad.npl";
			else
				result = result:gsub("bmax$", "npl");
			end
			if(result~="" and result~=local_filename) then
				itemStack:SetDataField("tooltip", result);
				self:RefreshTask(itemStack);
				local filename = Files.FindFile(commonlib.Encoding.Utf8ToDefault(result));
				if(not filename) then
					self:OpenNPLCadEditor(result);
				end
			end
		end, local_filename, L"选择NPL CAD文件", {
			{L"NPL CAD(*.cad.npl, bmax)",  "*.cad.npl;*.cad.bmax"},
			{L"NPL CAD(*.cad.npl)",  "*.cad.npl"},
		}, nil, {
		text=L"展开", 
		callback = function(filename)
			filename = filename:gsub("npl$", "bmax");
			self:UnpackIntoWorld(itemStack, filename);
		end})
	end
end

function ItemCAD:RefreshTask(itemStack)
	local task = self:GetTask();
	if(task) then
		task:SetItemStack(itemStack);
		task:RefreshPage();
	end
end


-- open external editor for current file
function ItemCAD:OpenEditor(itemStack)
	if(not itemStack) then
		return
	end
	local filename = itemStack:GetDataField("tooltip");
	if(not filename or filename == "") then
		self:OpenChangeFileDialog(itemStack);
	else
		self:OpenNPLCadEditor(filename);
	end
end

-- private function:
function ItemCAD:OpenNPLCadEditor(filename)
	if(not filename:match("%.") and filename~= "") then
		filename = filename .. ".cad.npl";
	end
	filename = commonlib.Encoding.Utf8ToDefault(filename);
	local fullpath = Files.FindFile(filename);
	if(not fullpath) then
		fullpath = GameLogic.GetWorldDirectory() .. filename;
	end
	GameLogic.RunCommand("/open npl://nplcad?src=".. commonlib.Encoding.url_encode(commonlib.Encoding.DefaultToUtf8(fullpath or "")));
end

function ItemCAD:GetModelFileName(itemStack)
	return itemStack and itemStack:GetDataField("tooltip");
end

function ItemCAD:GetBMAXFileName(itemStack)
	local filename = self:GetModelFileName(itemStack);
	if(filename and filename:match("cad%.%w%w%w$")) then
		return filename:gsub("cad%.%w%w%w$", "cad.bmax");
	end
end

-- virtual function: when selected in right hand
function ItemCAD:OnSelect(itemStack)
	ItemCAD._super.OnSelect(self, itemStack);
	GameLogic.SetStatus(L"CAD文件保存为BMAX模型后，可右键点击场景创造");
end

function ItemCAD:OnDeSelect()
	ItemCAD._super.OnDeSelect(self);
	GameLogic.SetStatus(nil);
end

-- virtual: draw icon with given size at current position (0,0)
-- @param width, height: size of the icon
-- @param itemStack: this may be nil. or itemStack instance. 
function ItemCAD:DrawIcon(painter, width, height, itemStack)
	ItemCAD._super.DrawIcon(self, painter, width, height, itemStack);
	local filename = self:GetModelFileName(itemStack);
	if(filename and filename~="") then
		filename = filename:match("[^/]+$"):gsub("%..*$", "");
		filename = filename:sub(1, 6);
		painter:SetPen("#33333380");
		painter:DrawRect(0,0, width, 14);
		painter:SetPen("#ffffff");
		painter:DrawText(1,0, filename);
	end
end

-- virtual function: 
function ItemCAD:CreateTask(itemStack)
	NPL.load("(gl)Mod/NPLCAD/EditCadTask.lua");
	local EditCadTask = commonlib.gettable("MyCompany.Aries.Game.Tasks.EditCadTask");
	local task = EditCadTask:new();
	task:SetItemStack(itemStack);
	return task;
end