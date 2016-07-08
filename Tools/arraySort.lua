--[[
@author: Marx Wolf
@date: 07.04.2016
@desc: This is my first try in lua.
Array-sort algorithm implementation in lua.
@usage:
--------------------------
NPL.load("(gl)scritp/ide/System/Algorithm/arraySort.lua");
local arraySort = commonlib.gettable("System.Algorithm.arraySort");
arraySort.swap(arr,i,j)
--------------------------
--]]

local arraySort = commonlib.gettable("System.Algorithm.arraySort");

local tostring = tostring;
local select = select;

-- swap the element at specified index of the input array
-- @param arr,i,j: is the input array, i and j is the element index that need to be swaped
function arraySort.swap(arr,i,j)
	local temp = arr[i]
	arr[i] = arr[j]
	arr[j] = temp
end
local swap = arraySort.swap;

-- @param arr is the input array
local function arraySort.selectSort(arr)
	for i = 1,#arr-1 do 
		local minIndex = i
		for j = i+1,#arr do
			minIndex = arr[minIndex] > arr[j] and j or minIndex;
		end
		if (arr[i] ~= arr[minIndex]) then
			swap(arr, i, minIndex);
		end
	end
end



local function arraySort.insertSort(arr)
	local currentValue;
	for i = 2,#arr do
		currentValue = arr[i]
		index = i
		for j = i-1,1,-1 do
			if (currentValue < arr[j]) then
				arr[j+1] = arr[j];
				index = j;
			end
		end
		arr[index] = currentValue
	end
end

local function arraySort.bubbleSort(arr)
	for i = 1,#arr do
		for j = 1,(#arr-i) do
			if (arr[j] > arr[j+1]) then
				swap(arr,j,j+1)
			end
		end
	end
end


-- reverse the input arrays
local function arraySort.reversed(arr)
	for i = 1, #arr/2 do
		swap(arr,i,#arr+1-i)
	end
end


-- @param variable input parameters, with separetor "\t" and a newline at last  
function nowrapprint(...)
	local write = io.write
    local n = select("#",...)
    for i = 1,n do
        local v = tostring(select(i,...))
        write(v)
        if i~=n then write'\t' end
    end
    write('\n');
end

-- print array in the same line with the input separetor such as "/t" or " " or ","
function arrayprint(arr,sep)
	-- invarient string
	print(table.concat(arr, sep));
end


-------Test for the upper functions--------------




