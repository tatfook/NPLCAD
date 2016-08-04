--[[
Title: NplCadCompiler 
Author(s):  leio
Date: 2016/8/4
Desc: 
In nplcad environment one can code like this:
function main()
    local a = CSG.cube();
    local b = CSG.sphere({ radius = 1.35, stacks = 12 });
    local c = CSG.cylinder({ radius= 0.7, ["from"] = {-1, 0, 0}, ["to"] = {1, 0, 0} });
    local d = CSG.cylinder({ radius= 0.7, ["from"] = {0, -1, 0}, ["to"] = {0, 1, 0} });
    local e = CSG.cylinder({ radius= 0.7, ["from"] = {0, 0, -1}, ["to"] = {0, 0, 1} });
    a:SetColor({255,255,0});
    b:SetColor({0,255,255});
    c:SetColor({255,0,0});
    local csg_node = a:intersect(b):subtract(c:union(d):union(e));
    echo(csg_node);
    echo(c)
end
Note: The entrance of nplcad programme is main function.
A mesh will be rendered when run echo() once.
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/NplCadCompiler.lua");
local NplCadCompiler = commonlib.gettable("Mod.NPLCAD.NplCadCompiler");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/CSG/CSG.lua");
local CSG = commonlib.gettable("CSG.CSG");

local NplCadCompiler = commonlib.gettable("Mod.NPLCAD.NplCadCompiler");
-- compiled result
NplCadCompiler.csg_node_values = nil;
-- csg environment
NplCadCompiler.env = nil;
function NplCadCompiler.CSG_SetColor(csg_node,color)
	if(not csg_node or not csg_node.polygons)then return end
	color = color or {};
	color[1] = color[1] or 255;
	color[2] = color[2] or 255;
	color[3] = color[3] or 255;
	for k,v in ipairs(csg_node.polygons) do
		v.shared = color
	end
end
function NplCadCompiler.CSG_ToMesh(csg_node)
	if(not csg_node)then return end
	local vertices = {};
	local indices = {};
	local normals = {};
	local colors = {};
	for __,polygon in ipairs(csg_node.polygons) do
		local start_index = #vertices+1;
		for __,vertex in ipairs(polygon.vertices) do
			table.insert(vertices,{vertex.pos.x,vertex.pos.y,vertex.pos.z});
			table.insert(normals,{vertex.normal.x,vertex.normal.y,vertex.normal.z});
			table.insert(colors,polygon.shared or {255,255,255});
		end
		local size = #(polygon.vertices) - 1;
		for i = 2,size do
			table.insert(indices,start_index);
			table.insert(indices,start_index + i-1);
			table.insert(indices,start_index + i);
		end
	end
	return vertices,indices,normals,colors;
end
function NplCadCompiler.echo(csg_node)
	if(not csg_node)then return end
	local vertices,indices,normals,colors = NplCadCompiler.CSG_ToMesh(csg_node);
	local v = {
		vertices = vertices,
		indices = indices,
		normals = normals,
		colors = colors,
	}
	table.insert(NplCadCompiler.csg_node_values,v);
end
-- compiled result
-- format is {
--	{vertices = vertices, indices = indices, normals = normals, colors = colors, },
--	{vertices = vertices, indices = indices, normals = normals, colors = colors, },
--  ...
--}
function NplCadCompiler.GetCompiledResult()
	return NplCadCompiler.csg_node_values;
end
function NplCadCompiler.Reset()
	CSG.SetColor = nil;
	NplCadCompiler.csg_node_values = {};
end
function NplCadCompiler.CreateSandBoxEnv()
	if(NplCadCompiler.env)then
		return NplCadCompiler.env;
	end
	-- attach a new function to set color
	CSG.SetColor = NplCadCompiler.CSG_SetColor;
	local env = {
		echo = NplCadCompiler.echo,
		CSG = CSG,
	};
	local meta = {__index = _G};
	setmetatable (env, meta);
	return env;
end
--[[
	return {
		success = success,
		csg_node_values = csg_node_values,
		compile_error = compile_error,
	}
--]]
function NplCadCompiler.Build(code)
	if(not code or code == "") then
		return;
	end
	NplCadCompiler.Reset();
	local output = {

	}
	local code_func, errormsg = loadstring(code);
	if(code_func) then
		local env = NplCadCompiler.CreateSandBoxEnv();
		setfenv(code_func, env);
		local ok, result = pcall(code_func);
		if(ok) then
			if(type(env.main) == "function") then
				setfenv(env.main, env);
				ok, result = pcall(env.main);
			end
		end
		output.success = ok;
		output.csg_node_values = NplCadCompiler.GetCompiledResult();
	else
		output.compile_error =  errormsg;
	end
	return output;
end
