--[[
Title: EditCad Task/Command
Author(s): LiXizhi
Date: 2016/11/6
Desc: 
- Left click to select model
- Right click create model or edit existing model.
- Ctrl + left click to select block
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/EditCadTask.lua");
local EditCadTask = commonlib.gettable("MyCompany.Aries.Game.Tasks.EditCadTask");
local task = EditCadTask:new();
task:Run();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/UndoManager.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/System/Windows/Keyboard.lua");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local UndoManager = commonlib.gettable("MyCompany.Aries.Game.UndoManager");
local vector3d = commonlib.gettable("mathlib.vector3d");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local EditCadTask = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Task"), commonlib.gettable("MyCompany.Aries.Game.Tasks.EditCadTask"));

EditCadTask:Property({"LeftLongHoldToDelete", false, auto=true});

local curInstance;

-- this is always a top level task. 
EditCadTask.is_top_level = true;

function EditCadTask:ctor()
	self.position = vector3d:new(0,0,0);
	self.transformMode = false;
end

function EditCadTask:SetItemStack(itemStack)
	self.itemStack = itemStack;
end

function EditCadTask:GetItemStack()
	return self.itemStack;
end

local page;
function EditCadTask.InitPage(Page)
	page = Page;
end

-- get current instance
function EditCadTask.GetInstance()
	return curInstance;
end

function EditCadTask.OnClickEditCadScript()
	local self = EditCadTask.GetInstance();
	local item = self:GetItem();
	if(item) then
		item:OpenEditor(self:GetItemStack());
	end
end

function EditCadTask.OnClickChangeCadScript()
	local self = EditCadTask.GetInstance();
	local item = self:GetItem();
	if(item) then
		item:OnClickInHand(self:GetItemStack(), EntityManager.GetPlayer());
	end
end

function EditCadTask:GetItem()
	local itemStack = self:GetItemStack();
	if(itemStack) then
		return itemStack:GetItem();
	end
end

function EditCadTask:GetCadScript()
	local item = self:GetItem();
	if(item) then
		return item:GetModelFileName(self:GetItemStack()) or "";
	end
end

function EditCadTask:RefreshPage()
	if(page) then
		page:Refresh(0.01);
	end
end

function EditCadTask:Run()
	curInstance = self;
	self.finished = false;

	self:LoadSceneContext();
	self:GetSceneContext():setMouseTracking(true);
	self:GetSceneContext():setCaptureMouse(true);
	self:ShowPage();
end

function EditCadTask:OnExit()
	self:SetFinished();
	self:UnloadSceneContext();
	self:CloseWindow();
	curInstance = nil;
end

function EditCadTask:SelectModel(entityModel)
	if(self.entityModel~=entityModel) then
		self.entityModel = entityModel;
		self:UpdateManipulators();
	end
end

function EditCadTask:GetSelectedModel()
	return self.entityModel;
end

function EditCadTask:UpdateManipulators()
	self:DeleteManipulators();

	if(self.entityModel) then
		NPL.load("(gl)Mod/NPLCAD/EditCadManipContainer.lua");
		local EditCadManipContainer = commonlib.gettable("MyCompany.Aries.Game.Manipulators.EditCadManipContainer");
		local manipCont = EditCadManipContainer:new();
		manipCont:init();
		self:AddManipulator(manipCont);
		manipCont:connectToDependNode(self.entityModel);

		self:RefreshPage();
	end
end

function EditCadTask:Redo()
end

function EditCadTask:Undo()
end

function EditCadTask:ShowPage()
	local window = self:CreateGetToolWindow();
	window:Show({
		name="EditCadTask", 
		url="Mod/NPLCAD/EditCadTask.html",
		alignment="_ctb", left=0, top=-55, width = 350, height = 64,
	});
end


-- @param result: can be nil
function EditCadTask:PickModelAtMouse(result)
	local result = result or Game.SelectionManager:MousePickBlock(true, true, false);
	if(result.blockX) then
		local x,y,z = result.blockX,result.blockY,result.blockZ;
		local modelEntity = BlockEngine:GetBlockEntity(x,y,z) or result.entity;
		if(modelEntity and modelEntity:isa(EntityManager.EntityBlockModel)) then
			return modelEntity;
		end
	end
end

function EditCadTask:OnLeftLongHoldBreakBlock()
	local modelEntity = self:PickModelAtMouse()
	if(modelEntity) then
		self:GetSceneContext():TryDestroyBlock(Game.SelectionManager:GetPickingResult());
	end
end

function EditCadTask:handleLeftClickScene(event, result)
	local modelEntity = self:PickModelAtMouse();
	if(modelEntity) then
		self:SelectModel(modelEntity);
	end
end

function EditCadTask:handleRightClickScene(event, result)
	local modelEntity = self:PickModelAtMouse();
	if(modelEntity) then
		modelEntity:OpenEditor("entity", modelEntity);
	else
		-- create model here 
		local item = self:GetItem();
		if(item) then
			local side = BlockEngine:GetOppositeSide(result.side);
			local x, y, z = BlockEngine:GetBlockIndexBySide(result.blockX,result.blockY,result.blockZ, result.side);
			local task = MyCompany.Aries.Game.Tasks.CreateBlock:new({blockX = x,blockY = y, blockZ = z, entityPlayer = EntityManager.GetPlayer(), 
				itemStack = self:GetItemStack(), block_id = item.id});
			task:Run();
			-- item:TryCreate(self:GetItemStack(), EntityManager.GetPlayer(), x,y,z,side);
		end
	end
end

function EditCadTask:mousePressEvent(event)
	self:GetSceneContext():mousePressEvent(event);
	if(self:GetLeftLongHoldToDelete()) then
		self:GetSceneContext():EnableMouseDownTimer(true);
	end
end

function EditCadTask:mouseMoveEvent(event)
	self:GetSceneContext():mouseMoveEvent(event);
end

function EditCadTask:mouseWheelEvent(event)
	self:GetSceneContext():mouseWheelEvent(event);
end

function EditCadTask:keyPressEvent(event)
	local dik_key = event.keyname;
	if(dik_key == "DIK_ADD" or dik_key == "DIK_EQUALS") then
		-- increase scale
		
	elseif(dik_key == "DIK_SUBTRACT" or dik_key == "DIK_MINUS") then
		-- decrease scale
		
	elseif(dik_key == "DIK_Z")then
		UndoManager.Undo();
	elseif(dik_key == "DIK_Y")then
		UndoManager.Redo();
	end
	self:GetSceneContext():keyPressEvent(event);
end