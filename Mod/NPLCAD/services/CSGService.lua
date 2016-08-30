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
	local bResult = false;
	if(pre_csg_node and cur_csg_node)then
		if(csg_action == "union")then
			cur_csg_node = pre_csg_node:union(cur_csg_node);
			bResult = true;
		elseif(csg_action == "difference")then
			cur_csg_node = pre_csg_node:subtract(cur_csg_node);
			bResult = true;
		elseif(csg_action == "intersection")then
			cur_csg_node = pre_csg_node:intersect(cur_csg_node);
			bResult = true;
		else
			-- Default action is "union".
			--cur_csg_node = pre_csg_node:union(cur_csg_node);
		end
	end
	return cur_csg_node,bResult;
end
function CSGService.findTagValue(node,name)
	if(not node)then
		return
	end
	local p = node;
	while(p) do
		local v = p:getTag(name);
		if(v)then
			return v,p;
		end
		p = p:getParent();
	end
end
function CSGService.equalsColor(color_1,color_2)
	if(color_1 and color_2)then
		return (color_1[1] == color_2[1] and color_1[2] == color_2[2] and color_1[3] == color_2[3]);
	end
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
	code = CSGService.appendLoadXmlFunction(code)
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
		CSGService.scene = env.scene;
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
function CSGService.appendLoadXmlFunction(code)
	if(code)then
		local first_line;
		for line in string.gmatch(code,"[^\r\n]+") do
			first_line = line;
			break;
		end
		if(first_line)then
			if(string.find(first_line,"nplcad"))then
				code = string.format("loadXml([[%s]])",code);
				return code;
			end
		end
		return code;
	end
end

function CSGService.getRenderList(scene)
	if(not scene)then
		return
	end
	local render_list = {};
	local nodes_map = {};
	local nodes_list = {};
	scene:visit(function(node)
		if(node)then
			local csg_node = CSGService.cloneCsgNode(node);
			
			nodes_map[node] = {
				csg_node = csg_node,
			};
			table.insert(nodes_list,node);
		end
	end);
	local input_params = {
		nodes_map = nodes_map,
		result = {};
	};
	local len = #nodes_list;
	while(len > 0) do
		CSGService.visitNode(nodes_list[len],input_params)
		len = len - 1;
	end

	local function write(csg_node)
		if(csg_node)then
			local vertices,indices,normals,colors = CSGService.toMesh(csg_node);
			table.insert(render_list,{
				vertices = vertices,
				indices = indices,
				normals = normals,
				colors = colors,
			});
		end
	end
	for k,v in pairs(nodes_map) do
		local csg_node = v["csg_node"];
		write(csg_node);
	end
	local result = input_params.result;
	local len = #result;
	for k =1,len do
		local csg_node = result[k]["csg_node"];
		write(csg_node);
	end
	return render_list;
end
function CSGService.doOperator(csg_nodes,csg_action)
	local len = #csg_nodes;
	if(len == 0)then
		return;
	end
	local pre_node = csg_nodes[len-1];
	local cur_node = csg_nodes[len];
	local cur_csg_node = cur_node["csg_node"];

	-- if it is only one node,we do nothing
	if(not pre_node)then
		return cur_csg_node;
	else
		len = len - 1;
		while(pre_node) do
			local pre_csg_node = pre_node["csg_node"];

			cur_csg_node = CSGService.operateTwoNodes(pre_csg_node,cur_csg_node,csg_action);
			len = len - 1;
			pre_node = csg_nodes[len];
		end
	end
	return cur_csg_node;
end
function CSGService.findCsgNode(node)
		if(not node)then return end
		local drawable = node:getDrawable();
		if(drawable and drawable.getCSGNode)then
			local cur_csg_node = drawable:getCSGNode();
			return cur_csg_node;
		end
end
function CSGService.visitNode(node,input_params)
	if(not node)then return end
	local nodes_map = input_params.nodes_map;
	if(nodes_map[node]["csg_node"])then
		return
	end
	local child = node:getFirstChild();
	local top_csg_action = CSGService.findTagValue(node,"csg_action");
	local temp_list = {};
	while(child) do
		local csg_node = nodes_map[child]["csg_node"];
		if(csg_node)then
			if(top_csg_action)then
				table.insert(temp_list,{
					csg_node = csg_node,
				});	
			else
				table.insert(input_params.result,{
					csg_node = csg_node,
				});	
			end
			
		end
		nodes_map[child]["csg_node"] = nil;
		child = child:getNextSibling();
	end	
	local csg_node = CSGService.doOperator(temp_list,top_csg_action);
	nodes_map[node]["csg_node"] = csg_node;
end
function CSGService.cloneCsgNode(child)
	local csg_node = CSGService.findCsgNode(child);
	if(csg_node)then
		csg_node = csg_node:clone();-- clone a new node for operation. 
		local color = CSGService.findTagValue(child,"color");
		if(color)then
			if(not CSGService.equalsColor(color,CSGService.default_color))then
				CSGService.setColor(csg_node,color);
			end
		end
		local world_matrix = child:getWorldMatrix();
		CSGService.applyMatrix(csg_node,world_matrix);
		return csg_node;
	end
end