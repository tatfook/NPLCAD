--[[
Title: Node
Author(s): leio
Date: 2016/8/16
Desc: 
Defines a hierarchical structrue of objects in 3D transformation spaces.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/core/Node.lua");
local Node = commonlib.gettable("Mod.NPLCAD.core.Node");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)Mod/NPLCAD/core/Transform.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Node = commonlib.inherit(commonlib.gettable("Mod.NPLCAD.core.Transform"), commonlib.gettable("Mod.NPLCAD.core.Node"));
local NODE_DIRTY_WORLD = 1;
local NODE_DIRTY_BOUNDS = 2;
local NODE_DIRTY_HIERARCHY = 4;
function Node.create(id)
	local node = Node:new();
	node:setId(id);
	return node;
end
function Node:ctor()
	-- The nodes id.
	self.id = "";
	-- The nodes first child.
	self.firstChild = nil;
	-- The nodes next sibling.
	self.nextSibling = nil;
	-- The nodes previous sibling.
	self.prevSibling  = nil;
	-- The nodes parent.
	self.parent = nil;
	-- The number of child nodes.
	self.childCount = 0;
	-- If this node is enabled. Maybe different if parent is enabled/disabled.
	self.enabled  = true;
	-- Tags assigned to this node.
	self.tags = {};
	-- The drawable component attated to this node.
	self.drawable = nil;
	-- The world matrix for this node.
	self.world = Matrix4:new():identity();
	-- The bounding sphere for this node.
	self.bounds = nil;
	-- The dirty bits used for optimization.
	self.dirtyBits = 0;
end
-- Return the type name of this class.
-- @return The type name of this class:"Node".
function Node:getTypeName()
	return "Node";
end
function Node:getId()
	return self.id;
end
function Node:setId(id)
	self.id = id;
end
function Node:addChild(child)
	if(not child)then return end
	if(child.parent == self)then
		-- This node is already present in our hierarchy.
		return;
	end
	-- If the item belongs to another hierarchy,remove if first.
	if(child.parent)then
		child.parent:removeChild(child);
	end
	-- Add child to the end of the list.
	if(self.firstChild)then
		local n = self:getFirstChild();
		while(n:getNextSibling())do
			n = n:getNextSibling();
		end
		n.nextSibling = child;
		child.prevSibling = n;
	else
		self.firstChild = child;
	end
	child.parent = self;
	self.childCount = self.childCount + 1;
	self:setBoundsDirty();
	if(mathlib.bit.band(self.dirtyBits, NODE_DIRTY_HIERARCHY) ~= 0)then
		self:hierarchyChanged();
	end
end
function Node:removeChild(child)
	if(not child or child.parent ~= self)then 
		return;
	end
	-- Call remove on the child.
	child:remove();
end
function Node:removeAllChildren()
	self.dirtyBits = mathlib.bit.band(self.dirtyBits, NODE_DIRTY_HIERARCHY)
	while(self.firstChild) do
		self:removeChild(self.firstChild);
	end
	self.dirtyBits = mathlib.bit.bor(self.dirtyBits, NODE_DIRTY_HIERARCHY)
	self:hierarchyChanged();
end
function Node:remove()
	-- Re-link our neighbours.
	if(self.prevSibling)then
		self.prevSibling.nextSibling = self.nextSibling;
	end
	if(self.nextSibling)then
		self.nextSibling.prevSibling = self.prevSibling;
	end
	-- Update our parent.
	local parent = self.parent;
	if(parent)then
		if(self == parent.firstChild)then
			parent.firstChild = self.nextSibling;
		end
		parent.childCount = parent.childCount - 1;
	end
	self.nextSibling = nil;
	self.prevSibling = nil;
	self.parent = nil;
	if(parent and mathlib.bit.band(parent.dirtyBits, NODE_DIRTY_HIERARCHY) ~= 0)then
		parent:hierarchyChanged();
	end
end
function Node:getFirstChild()
	return self.firstChild;
end
function Node:getNextSibling()
	return self.nextSibling;
end
function Node:getPreviousSibling()
	return self.prevSibling;
end
function Node:getParent()
	return self.parent;
end
function Node:getChildCount()
	return self.childCount;
end
function Node:getRootNode()
	local n = self;
	while(n:getParent())do
		n = n:getParent();
	end
	return n;
end
function Node:getScene()
	local parent = self:getParent();
	if(not parent)then
		return
	end
	local node = parent;
	while(node:getParent()) do
		node = node:getParent();
	end
	if(node:getTypeName() == "Scene")then
		return node;
	end
end
function Node:setTag(name,value)
	if(name)then
		self.tags[name] = value;
	end
end
function Node:getTag(name)
	if(not name)then return end
	return self.tags[name];
end
function Node:hasTag(name)
	if(not name)then return end
	for k,v in pairs(self.tags) do
		if(k == name)then
			return true;
		end
	end
end
function Node:setEnabled(value)
	if(self.enabled ~= value)then
		self.enabled = value;
	end
end
function Node:isEnabled()
	return self.enabled;
end
function Node:isEnabledInHierarchy()
	if(not self.enabled)then
		return false;
	end
	local node = self.parent;
	while(node) do
		if(not node.enabled)then
			return false;
		end
		node = node.parent;
	end
end
function Node:update()
end
function Node:transformChanged()
	-- Our local transform was changed, so mark our world matrices dirty.
	local a = mathlib.bit.bor(NODE_DIRTY_WORLD, NODE_DIRTY_BOUNDS);
	self.dirtyBits = mathlib.bit.bor(self.dirtyBits, a);
	local node = self:getFirstChild();
	while(node) do
		if(Node._super.isTransformChangedSuspended(self))then
			if(not node:isDirty())then
				node:transformChanged(Transform.DIRTY_NOTIFY);
				Transform.suspendTransformChange(node);
			end
		else
			node:transformChanged();
		end
		node = node:getNextSibling();
	end
	Node._super.transformChanged(self);
end
function Node:hierarchyChanged()
	-- When our hierarchy changes our world transform is affected, so we must dirty it.
	self.dirtyBits = mathlib.bit.bor(self.dirtyBits, NODE_DIRTY_HIERARCHY);
	self:transformChanged();
end
function Node:setBoundsDirty()
	-- Mark ourself and our parent nodes as dirty
	self.dirtyBits = mathlib.bit.bor(self.dirtyBits, NODE_DIRTY_HIERARCHY);
	-- Mark our parent bounds as dirty as well
	if(self.parent)then
		self.parent:setBoundsDirty();
	end
end
-- Gets the world matrix corresponding to this node.
-- @return The world matrix of this node.
function Node:getWorldMatrix()
	if(mathlib.bit.band(self.dirtyBits, NODE_DIRTY_WORLD) ~= 0)then
		self.dirtyBits = mathlib.bit.band(self.dirtyBits, mathlib.bit.bnot(NODE_DIRTY_WORLD));
		if(not self:isStatic())then
			local parent = self:getParent();
			if(parent)then
				self.world = parent:getWorldMatrix() * self:getMatrix();
			else
				self.world = self:getMatrix();
			end
			local child = self:getFirstChild();
			while(child) do
				child:getWorldMatrix();
				child = child:getNextSibling();
			end
		end
	end
	return self.world;
end
-- Gets the drawable object attached to this node.
-- @return The drawable component attached to this node.
function Node:getDrawable()
	return self.drawable;
end
-- Set the drawable object to be attached to this node.

-- @param drawable The new drawable component. Maybe nil
function Node:setDrawable(drawable)
	if(self.drawable ~= drawable)then
		if(self.drawable)then
			self.drawable:setNode(nil);
		end
		self.drawable = drawable;
		if(drawable)then
			drawable:setNode(self);
		end
	end
	 self:setBoundsDirty();
end
-- Returns the first child node that matches the given ID.
-- This method checks the specified ID against it immediate child nodes
-- but doest not check the ID against itself.
-- If recursive is true, it also traverses the Node's hierarchy with a breadth first search.
-- @param id The ID of the child to find.
-- @param recursive True to search recursively all the node's children,false for only direct children.
-- @param exactMatch True if only nodes whose ID exactly matches the specified ID are returned.
-- @return The Node found or nil if not found.
function Node:findNode(id,recursive,exactMatch)
	if(not id)then
		return;
	end
	local child = self:getFirstChild();
	while(child) do
		if((exactMatch and child:getId() == id) or (not exactMatch and string.find(child:getId(),id)))then
			return child;
		end
		child = child:getNextSibling();
	end
	if(recursive)then
		local child = self:getFirstChild();
		while(child) do
			local match = child:findNode(id,recursive,exactMatch);
			if(match)then
				return match;
			end
			child = child:getNextSibling();
		end
	end
end
-- Returns all child nodes that match the given ID.
-- @param id The ID of the child to find.
-- @param nodes_result A list of nodes to be populated with matches.
-- @param recursive True to search recursively all the node's children,false for only direct children.
-- @param exactMatch True if only nodes whose ID exactly matches the specified ID are returned.
-- @return The number of matches found.
function Node:findNodes(id,nodes_result,recursive,exactMatch)
	if(not id)then
		return;
	end
	local count = 0;
	local child = self:getFirstChild();
	while(child) do
		if((exactMatch and child:getId() == id) or (not exactMatch and string.find(child:getId(),id)))then
			table.insert(nodes_result,child);
			count = count + 1;
		end
		child = child:getNextSibling();
	end
	if(recursive)then
		local child = self:getFirstChild();
		while(child) do
			count = count + child:findNodes(id,nodes_result,recursive,exactMatch);
			child = child:getNextSibling();
		end
	end
	return count;
end