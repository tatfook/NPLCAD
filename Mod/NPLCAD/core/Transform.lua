--[[
Title: Transform
Author(s): leio
Date: 2016/8/16
Desc: 
Defines a 3-dimensional transformation.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/core/Transform.lua");
local Transform = commonlib.gettable("Mod.NPLCAD.core.Transform");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local vector3d = commonlib.gettable("mathlib.vector3d");
local EventSystem = commonlib.gettable("commonlib.EventSystem");
local Transform = commonlib.inherit(nil, commonlib.gettable("Mod.NPLCAD.core.Transform"));

local DIRTY_TRANSLATION		= 0x01;
local DIRTY_SCALE			= 0x02;
local DIRTY_ROTATION		= 0x04;
local DIRTY_NOTIFY			= 0x08;

local transformsChanged = {};
local suspendTransformChanged = 0;

Transform.DIRTY_TRANSLATION		= DIRTY_TRANSLATION;
Transform.DIRTY_SCALE			= DIRTY_SCALE;
Transform.DIRTY_ROTATION		= DIRTY_ROTATION;
Transform.DIRTY_NOTIFY			= DIRTY_NOTIFY;
-- surpport events:
--					"TransformChanged"
function Transform:ctor()
	-- The scale component of the transform.
	self.scale			=	vector3d:new({1,1,1});
	-- The rotation component of the transform.
	self.rotation		=	Quaternion:new():identity();
	-- The translation component of the transform.
	self.translation	=	vector3d:new();
	-- The matrix representation of the transform.
	self.matrix			=	Matrix4:new():identity();
	self.matrixDirtyBits =	0x00;
	self.events = EventSystem:new();
end
-- Add a default transform listener.
function Transform:addDefaultEventListener(func,funcHolder)
	local type = "TransformChanged";
	self:addEventListener(type,func,funcHolder);
end
function Transform:addEventListener(type,func,funcHolder)
	self.events:AddEventListener(type,func,funcHolder);
end
function Transform:removeEventListener(type,func,funcHolder)
	self.events:RemoveEventListener(type,func,funcHolder);
end
-- Globally suspends all transform changed events.
function Transform.suspendTransformChanged()
	suspendTransformChanged = suspendTransformChanged + 1;
end
-- Globally resumes all transform changed events.
function Transform.resumeTransformChanged()
	if(suspendTransformChanged == 0)then
		return;
	end
	if(suspendTransformChanged == 1)then
		-- Call transformChanged() on all transforms in the list
		local transformCount = #transformsChanged;
		for k = 1,transformCount do
			local t = transformsChanged[k];
			t:transformChanged();
		end
		--Go through list and reset DIRTY_NOTIFY bit. The list could potentially be larger here if the 
        -- transforms we were delaying calls to transformChanged() have any child nodes.
		transformCount = #transformsChanged;
		for k = 1,transformCount do
			local t = transformsChanged[k];
			t.matrixDirtyBits = mathlib.bit.band(t.matrixDirtyBits,mathlib.bit.bnot(DIRTY_NOTIFY));
		end
		transformsChanged = {};
	end
	suspendTransformChanged = suspendTransformChanged -1;
end
-- Gets whether all transform changed events are suspended.
-- @return True if transform changed events are suspended;False otherwise.
function Transform.isTransformChangedSuspended()
	return (suspendTransformChanged > 0);
end
-- Marks this transform as dirty and fires transformChanged().
function Transform:dirty(matrixDirtyBits)
	self.matrixDirtyBits = mathlib.bit.bor(self.matrixDirtyBits,matrixDirtyBits);
	if(self:isTransformChangedSuspended())then
		if(self:isDirty(DIRTY_NOTIFY))then
			Transform.suspendTransformChange(self);
		end
	else
		self:transformChanged();
	end
end

-- Determines if the specified matrix dirty bit is set.
-- @parma matrixDirtyBits the matrix dirty bit to check for dirtniss.
-- @return True if the specified matrix dirty bit is set; otherwise return False.
function Transform:isDirty(matrixDirtyBits)
	return (mathlib.bit.band(self.matrixDirtyBits,matrixDirtyBits) == matrixDirtyBits);
end
function Transform:isTransformChangedSuspended()
end
-- Adds the specified transform to the list of transforms waiting to be notified of a change.
-- Sets the DIRTY_NOTIFY bit on the transform.
function Transform.suspendTransformChange(transform)
	if(not transform)then
		return
	end
	transform.matrixDirtyBits = mathlib.bit.bor(transform.matrixDirtyBits,DIRTY_NOTIFY);
	table.insert(transformsChanged,transform);
end
-- Called when the transform changes.
function Transform:transformChanged()
	self.events:DispatchEventByType("TransformChanged",self);
end
-- Returns whether or not this Transform object is static.
-- A static transform object cannot be transformed.This may be the case for special types of Transform objects,such as Nodes that have a static rigid body attached to them.
-- @return True if this Transform is static,False otherwise.
function Transform:isStatic()
	return false;
end
-- Return the type name of this class.
-- @return The type name of this class:"Transform".
function Transform:getTypeName()
	return "Transform";
end
-- Gets the matirx corresponding to this transform.
-- The matrix returned from this method is mathematically equivalent
-- to this transform only as long as this transform is not changed
-- (i.e. by calling set(), setScale(), translate(), rotateX(), etc.).
-- Once the transform has been changed, the user must call getMatrix()
-- again to get the updated matrix. Also note that changing the matrix
-- returned from this method does not change this transform.
-- @return The matrix of this transform.
function Transform:getMatrix()
	local a = mathlib.bit.bor(DIRTY_TRANSLATION, DIRTY_ROTATION);
	a = mathlib.bit.bor(a, DIRTY_SCALE);
	a = mathlib.bit.band(self.matrixDirtyBits, a);
	if(a ~= 0)then
		if(not self:isStatic())then
			local hasScale = true;
			if(self.scale[1] == 1 and self.scale[2] == 1 and self.scale[3] == 1 )then
				hasScale = false;
			end
			local hasRotation = (not self.rotation:equals(Quaternion.IDENTITY));
			self.matrix = self.matrix:makeTrans(self.translation[1], self.translation[2], self.translation[3]);
			if(hasRotation)then
				local r_matrix = self.rotation:ToRotationMatrix();
				self.matrix = r_matrix * self.matrix;
			end
			if(hasScale)then
				self.matrix:setScale(self.scale[1], self.scale[2], self.scale[3]);	
			end
			local a = mathlib.bit.bor(DIRTY_TRANSLATION, DIRTY_ROTATION);
			a = mathlib.bit.bor(a, DIRTY_SCALE);
			self.matrixDirtyBits = mathlib.bit.band(self.matrixDirtyBits, mathlib.bit.bnot(a));
		end
	end
	return self.matrix;
end
function Transform:getRotation()
	return self.rotation;
end
function Transform:getTranslation()
	return self.translation;
end
function Transform:getScale()
	return self.scale;
end
-- Scales this transform's scale component by the given factors along each axis.
-- @param sx The factor to scale by in the x direction.
-- @param sy The factor to scale by in the y direction.
-- @param sz The factor to scale by in the z direction.
function Transform:scale(sx,sy,sz)
	if(self:isStatic())then
		return;
	end
	self.scale:MulByVector({sx,sy,sz});
	self:dirty(DIRTY_SCALE);
end
-- Scales this transform's scale component by the given scale factor along the x axis.
-- @param value The scale factor along the x axis.
function Transform:scaleX(value)
	if(self:isStatic())then
		return;
	end
	self.scale[1] = self.scale[1] * value;
	self:dirty(DIRTY_SCALE);
end
-- Scales this transform's scale component by the given scale factor along the y axis.
-- @param value The scale factor along the y axis.
function Transform:scaleY(value)
	if(self:isStatic())then
		return;
	end
	self.scale[2] = self.scale[2] * value;
	self:dirty(DIRTY_SCALE);
end
-- Scales this transform's scale component by the given scale factor along the z axis.
-- @param value The scale factor along the z axis.
function Transform:scaleZ(value)
	if(self:isStatic())then
		return;
	end
	self.scale[3] = self.scale[3] * value;
	self:dirty(DIRTY_SCALE);
end
-- Rotates this transform's rotation component by the given rotation.
function Transform:rotate(qx,qy,qz,qw)
	if(self:isStatic())then
		return;
	end
	local q = Quaternion:new({qx,qy,qz,qw});
	self.rotation = self.rotation * q;
	self:dirty(DIRTY_ROTATION);
end
-- Rotates this transform's rotation component by the given angel about the x-axis.
-- @param value The angle to rotate by about the x-axis (in radians).
function Transform:rotateX(value)
	if(self:isStatic())then
		return;
	end
	local rotationQuat = Quaternion:new();
	rotationQuat = rotationQuat:FromAngleAxis(value,vector3d.unit_x);
	self.rotation = self.rotation * rotationQuat;
	self:dirty(DIRTY_ROTATION);
end
-- Rotates this transform's rotation component by the given angel about the y-axis.
-- @param value The angle to rotate by about the y-axis (in radians).
function Transform:rotateY(value)
	if(self:isStatic())then
		return;
	end
	local rotationQuat = Quaternion:new();
	rotationQuat = rotationQuat:FromAngleAxis(value,vector3d.unit_y);
	self.rotation = self.rotation * rotationQuat;
	self:dirty(DIRTY_ROTATION);
end
-- Rotates this transform's rotation component by the given angel about the z-axis.
-- @param value The angle to rotate by about the z-axis (in radians).
function Transform:rotateZ(value)
	if(self:isStatic())then
		return;
	end
	local rotationQuat = Quaternion:new();
	rotationQuat = rotationQuat:FromAngleAxis(value,vector3d.unit_z);
	self.rotation = self.rotation * rotationQuat;
	self:dirty(DIRTY_ROTATION);
end
-- Translates this transform's translation component by the given values along each axis.
-- @param tx The amount to translate along the x axis.
-- @param ty The amount to translate along the y axis.
-- @param tz The amount to translate along the z axis.
function Transform:translate(tx,ty,tz)
	if(self:isStatic())then
		return;
	end
	local v = vector3d:new({tx,ty,tz});
	self.translation = self.translation + v;
	self:dirty(DIRTY_TRANSLATION);
end
-- Translates this transform's translation component by the given values along the x axis.
-- @param value The amount to translate along the x axis.
function Transform:translateX(value)
	if(self:isStatic())then
		return;
	end
	self.translation[1] = self.translation[1] + value;
	self:dirty(DIRTY_TRANSLATION);
end
-- Translates this transform's translation component by the given values along the y axis.
-- @param value The amount to translate along the y axis.
function Transform:translateY(value)
	if(self:isStatic())then
		return;
	end
	self.translation[2] = self.translation[2] + value;
	self:dirty(DIRTY_TRANSLATION);
end
-- Translates this transform's translation component by the given values along the z axis.
-- @param value The amount to translate along the z axis.
function Transform:translateZ(value)
	if(self:isStatic())then
		return;
	end
	self.translation[3] = self.translation[3] + value;
	self:dirty(DIRTY_TRANSLATION);
end
-- Sets the transform to the specified values.
-- @param scale The scale vector.
-- @param rotation The rotation quaternion.
-- @param translation The translation vector.
function Transform:set(scale,rotation,translation)
	if(self:isStatic())then
		return;
	end
	self.scale:set(scale);
	self.rotation:set(rotation);
	self.translation:set(translation);
	local a = mathlib.bit.bor(DIRTY_TRANSLATION,DIRTY_ROTATION);
	a = mathlib.bit.bor(a,DIRTY_SCALE);
	self:dirty(a);
end
-- Sets this transform to the identity transform.
function Transform:setIdentity()
	if(self:isStatic())then
		return;
	end
	self.scale:set({1,1,1});
	self.rotation:set({0,0,0,1});
	self.translation:set({0,0,0});
	local a = mathlib.bit.bor(DIRTY_TRANSLATION,DIRTY_ROTATION);
	a = mathlib.bit.bor(a,DIRTY_SCALE);
	self:dirty(a);
end
-- Sets the scale component of this transform to the specified values.
-- @param sx The scale factor along the x axis.
-- @param sy The scale factor along the y axis.
-- @param sz The scale factor along the z axis.
function Transform:setScale(sx,sy,sz)
	if(self:isStatic())then
		return;
	end
	if(not sx or not sy or not sz)then
		return;
	end
	self.scale:set({sx,sy,sz});
	self:dirty(DIRTY_SCALE);
end
-- Sets the scale factor along the x-axis for this transform to the specified value.
-- @param value The scale factor along the x-axis.
function Transform:setScaleX(value)
	if(self:isStatic())then
		return;
	end
	self.scale[1] = value;
	self:dirty(DIRTY_SCALE);
end
-- Sets the scale factor along the y-axis for this transform to the specified value.
-- @param value The scale factor along the y-axis.
function Transform:setScaleY(value)
	if(self:isStatic())then
		return;
	end
	self.scale[2] = value;
	self:dirty(DIRTY_SCALE);
end
-- Sets the scale factor along the z-axis for this transform to the specified value.
-- @param value The scale factor along the z-axis.
function Transform:setScaleZ(value)
	if(self:isStatic())then
		return;
	end
	self.scale[3] = value;
	self:dirty(DIRTY_SCALE);
end
-- Sets the rotation component for this transform to the specified values.
-- @param qx The quaternion x value.
-- @param qy The quaternion y value.
-- @param qz The quaternion z value.
-- @param qw The quaternion w value.
function Transform:setRotation(qx,qy,qz,qw)
	if(self:isStatic())then
		return;
	end
	self.rotation:set({qx,qy,qz,qw});
	self:dirty(DIRTY_ROTATION);
end
-- Sets the rotation component for this transform to the rotation from the specified axis and angle.
function Transform:setRotation2(axis,angle)
	if(self:isStatic())then
		return;
	end
	local rotationQuat = Quaternion:new();
	self.rotation = rotationQuat:FromAngleAxis(angle,axis);
	self:dirty(DIRTY_ROTATION);
end
-- Sets the translation component for this transform to the specified values.
-- @param tx The translation amount in the x direction.
-- @param ty The translation amount in the y direction.
-- @param tz The translation amount in the z direction.
function Transform:setTranslation(tx,ty,tz)
	if(self:isStatic())then
		return;
	end
	if(not tx or not ty or not tz)then
		return;
	end
	self.translation:set({tx,ty,tz});
	self:dirty(DIRTY_TRANSLATION);
end
-- Sets the translation factor along the x-axis for thie transform to the specified values.
-- @param value The translation factor along the x-axis.
function Transform:setTranslationX(value)
	if(self:isStatic())then
		return;
	end
	self.translation[1] = value;
	self:dirty(DIRTY_TRANSLATION);
end
-- Sets the translation factor along the y-axis for thie transform to the specified values.
-- @param value The translation factor along the y-axis.
function Transform:setTranslationY(value)
	if(self:isStatic())then
		return;
	end
	self.translation[2] = value;
	self:dirty(DIRTY_TRANSLATION);
end
-- Sets the translation factor along the z-axis for thie transform to the specified values.
-- @param value The translation factor along the z-axis.
function Transform:setTranslationZ(value)
	if(self:isStatic())then
		return;
	end
	self.translation[3] = value;
	self:dirty(DIRTY_TRANSLATION);
end