--[[
Title: CSGService 
Author(s): leio
Date: 2016/8/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/NPLCAD/services/CSGService.lua");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");
local output = CSGService.buildPageContent("cube();")
commonlib.echo(output);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/CSG/CSGVector.lua");
NPL.load("(gl)script/ide/math/Matrix4.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)Mod/NPLCAD/services/NplCadEnvironment.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local CSGVector = commonlib.gettable("CSG.CSGVector");
local CSGService = commonlib.gettable("Mod.NPLCAD.services.CSGService");
local math3d = commonlib.gettable("mathlib.math3d");
local NplCadEnvironment = commonlib.gettable("Mod.NPLCAD.services.NplCadEnvironment");
CSGService.default_color = {1,1,1};
function CSGService.setColor(csg_node,color)
	if(not csg_node or  not csg_node.polygons)then return end
	color = color or {};
	color[1] = color[1] or 1;
	color[2] = color[2] or 1;
	color[3] = color[3] or 1;
	for k,v in ipairs(csg_node.polygons) do
		v.shared = v.shared or {};
		v.shared.color = color;
	end
end
function CSGService.toMesh(csg_node)
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
			local shared = polygon.shared or {};
			local color = shared.color or {1,1,1};
			table.insert(colors,color);
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
function CSGService.applyMatrix(csg_node,matrix)
	if(not matrix or not csg_node)then return end
	for __,polygon in ipairs(csg_node.polygons) do
		for __,vertex in ipairs(polygon.vertices) do
			local pos = {vertex.pos.x,vertex.pos.y,vertex.pos.z};
			pos = math3d.VectorMultiplyMatrix(nil, pos, matrix);
			vertex.pos.x = pos[1];
			vertex.pos.y = pos[2];
			vertex.pos.z = pos[3];

			--local normal = {vertex.normal.x,vertex.normal.y,vertex.normal.z};
			--normal = math3d.VectorMultiplyMatrix(nil, normal, matrix);
			--vertex.normal.x = normal[1];
			--vertex.normal.y = normal[2];
			--vertex.normal.z = normal[3];
		end
	end
end
function CSGService.operateTwoNodes(pre_csg_node,cur_csg_node,csg_action)
	if(pre_csg_node and cur_csg_node)then
		if(csg_action == "union")then
			cur_csg_node = pre_csg_node:union(cur_csg_node);
		elseif(csg_action == "difference")then
			cur_csg_node = pre_csg_node:subtract(cur_csg_node);
		elseif(csg_action == "intersection")then
			cur_csg_node = pre_csg_node:intersect(cur_csg_node);
		else
			-- Default action is "union".
			cur_csg_node = pre_csg_node:union(cur_csg_node);
		end
	end
	return cur_csg_node;
end
function CSGService.findTagValue(node,name)
	if(not node)then
		return
	end
	local p = node;
	while(p) do
		local v = p:getTag(name);
		if(v)then
			return v;
		end
		p = p:getParent();
	end
end
function CSGService.equalsColor(color_1,color_2)
	if(color_1 and color_2)then
		return (color_1[1] == color_2[1] and color_1[2] == color_2[2] and color_1[3] == color_2[3]);
	end
end
function CSGService.getRenderList(scene)
	if(not scene)then
		return
	end
	local csg_nodes = {};
	local csg_nodes_none_action = {};
	scene:visit(function(node)
		if(node)then
			local csg_action = CSGService.findTagValue(node,"csg_action");
			local drawable = node:getDrawable();
			if(drawable and drawable.getCSGNode)then
				local csg_node = drawable:getCSGNode();
				if(csg_node)then
					-- set color
					local color = CSGService.findTagValue(node,"color");
					if(color)then
						if(not CSGService.equalsColor(color,CSGService.default_color))then
							drawable:setColor(color);
						end
					end
					local world_matrix = node:getWorldMatrix();
					-- changes to world matrix.
					drawable:applyMatrix(world_matrix);
					if(csg_action and csg_action  ~= "")then
						table.insert(csg_nodes,{
							csg_action = csg_action,
							csg_node = csg_node,
						});
					
					else
						table.insert(csg_nodes_none_action,{
							csg_node = csg_node,
						});
					end
					
				end
			end
		end
	end);
	local render_list = {};
	local function write(node)
		if(node)then
			local vertices,indices,normals,colors = CSGService.toMesh(node);
			table.insert(render_list,{
				world_matrix = world_matrix,
				vertices = vertices,
				indices = indices,
				normals = normals,
				colors = colors,
			});
		end
	end
	-- Write none action's nodes
	local len = #csg_nodes_none_action;
	while(len > 0)do
		local node = csg_nodes_none_action[len].csg_node;
		write(node);
		len = len - 1;
	end
	-- Write action's nodes
	local len = #csg_nodes;
	if(len == 0)then
		return render_list;
	end
	local pre_node = csg_nodes[len-1];
	local cur_node = csg_nodes[len];
	local cur_csg_node = cur_node["csg_node"];
	-- if it is only one node,we do nothing
	if(not pre_node)then
		write(cur_csg_node);
	else
		len = len - 1;
		while(pre_node) do
			local csg_action = pre_node["csg_action"];
			local pre_csg_node = pre_node["csg_node"];

			cur_csg_node = CSGService.operateTwoNodes(pre_csg_node,cur_csg_node,csg_action);
			len = len - 1;
			pre_node = csg_nodes[len];
		end
	end
	write(cur_csg_node);
	return render_list;
end
function CSGService.getRenderList2(scene)
	if(not scene)then
		return
	end
	local render_list = {};
	scene:visit(function(node)
		if(node)then
			local csg_action = node:getTag("csg_action");
			local drawable = node:getDrawable();
			if(drawable and drawable.getCSGNode)then
				local csg_node = drawable:getCSGNode();
				if(csg_node)then
					local color = CSGService.findTagValue(node,"color");
					if(color)then
						if(not CSGService.equalsColor(color,CSGService.default_color))then
							drawable:setColor(color);
						end
					end
					local world_matrix = node:getWorldMatrix();
					drawable:applyMatrix(world_matrix);
					local vertices,indices,normals,colors = drawable:toMesh();
					
					table.insert(render_list,{
						vertices = vertices,
						indices = indices,
						normals = normals,
						colors = colors,
					});
				end
			end
		end
	end);
	return render_list;
end
--[[
	return {
		successful = successful,
		csg_node_values = csg_node_values,
		compile_error = compile_error,
	}
--]]
function CSGService.buildPageContent(code)
	if(not code or code == "") then
		return;
	end
	local output = {}
	local code_func, errormsg = loadstring(code);
	if(code_func) then
		local env = NplCadEnvironment:new();
		setfenv(code_func, env);
		local ok, result = pcall(code_func);
		if(ok) then
			if(type(env.main) == "function") then
				setfenv(env.main, env);
				ok, result = pcall(env.main);
			end
		end
		local render_list = CSGService.getRenderList(env.scene)
		output.successful = ok;
		output.csg_node_values = render_list;
		output.compile_error = result;
	else
		output.successful = false;
		output.compile_error =  errormsg;
	end
	return output;
end