--[[
Title: Build matrix and sample matrix operations
Author(s): zhuzhikun15973
Date: 2016/7/4
Desc:Generation of basis matrix and print matrix in a row-column form.A collections of sample matrix operations like 
add, multiplication, etc. 
Use Lib:
-------------------------------------------------------
local Matrix = commonlib.gettable("System.Math.Matrix");
local m1=Matrix:new():init(5,5,"i")
prinitMatrix(m1)
local m2=Matrix:new():init(5,5,"ut")
prinitMatrix(m2)
local m3 = m1*m2
prinitMatrix(m3)
-------------------------------------------------------]]


local Matrix = commonlib.inherit(nil, commonlib.gettable("System.Math.Matrix"));

--[[
Matrix.__index = Matrix;

function Matrix:new(o)
	o = o or {};
	setmetatable(o, Matrix);
	return o;
end
]]

--  Initialize new metrix
--	if mode = "i" this function will build a identity matrix of given rows
--	if mode = "ut" this function will build a upper triangular matrix of given row
--	if mode = "lt" this function will build a lower triangular matrix of given row
function Matrix:init(row,column,mode)
	local matrix = self;
	if mode == "i" then
		for i = 1,row do
			matrix[i] = {}
			for j = 1,row do
				if i == j then
					matrix[i][j] = 1
				else
					matrix[i][j] = 0
				end
			end
		end
	elseif mode == "ut" then
		for i = 1,row do
			matrix[i] = {}
			for j = 1,i do
				matrix[i][j] = 1
			end
			for j = i+1,row do
			matrix[i][j] = 0
			end
		end
	elseif (mode == "lt") then
		for i = 1,row do
			matrix[i] = {}
			for j = i,row do
				matrix[i][j] = 1
			end
			for j = 1,i-1 do
				matrix[i][j] = 0
			end
		end
	end
	return self;
end
-- Matrix add
function matrix_meta.__add (m1,m2)
	local matrix = {}
	if #m1 ~= #m2 then print('Invliad input')
		else 
	for i = 1,#m1 do
			matrix[i] = {}
			for j = 1,#m1[#m1] do
				matrix[i][j] = m1[i][j] + m2[i][j]
			end
		end
	end
	return setmetatable( matrix,matrix_meta )
end
function matrix_meta.__sub (m1,m2)
local matrix = {}
	if #m1 ~= #m2 then print('Invliad input')
		else 
	for i = 1,#m1 do
			matrix[i] = {}
			for j = 1,#m1[#m1] do
				matrix[i][j] = m1[i][j] - m2[i][j]
			end
		end
	end
	return setmetatable( matrix,matrix_meta )
end



function matrix_meta.__mul (m1,m2)
	local matrix = {}
	for i = 1,#m1 do
	matrix[i] = {}
		for j = 1,#m2[#m2] do	
		local num =0
			for m=1,#m1 do
			num = num + m1[i][m] * m2[m][j]
			end
		matrix[i][j]=num
		end
	end

	return setmetatable( matrix, matrix_meta )
end
-- Print matrix in a row-column form
function prinitMatrix(matrix)

	for i,v in pairs(matrix) do
		if type(v) == "table" then
		prinitMatrix(v) 
		else
			print(table.concat(matrix, " ")); break
		end	
	end
	print("\t")
end
























