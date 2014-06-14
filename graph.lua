#!/usr/local/bin/lua

--[[TO DO
- "2D graph"
	- vertices
	- multiple connections? -> integrate delaunay/gabriel and Voronoi in 1 graph?
		-> also to allow for delaunay and gabriel in the same graph
]]--

-- playing with graphs --

local Node = {}
Node.__index = Node

function Node:connect (node_id) -- public
	if not self.nodes[node_id] then
		self.connections = self.connections + 1
	end
	self.nodes[node_id] = true
	return (graph.hash[node_id])
end

function Node:disconnect (node_id) -- public
	self.nodes[node_id] = nil
	self.connections = self.connections - 1
end

function Node:hasConnections() -- public
	if self.connections > 0 then
		return true
	else
		return false
	end
end

function Node:clearConnections()
	for k, v in pairs(self.nodes) do
		self:disconnect(k)
	end
end

function Node:printNode() -- public
	io.write(self.id, "-->")
	for k, _ in pairs(self.nodes) do
		io.write(" ", k, ";")
	end
	io.write("\n")
end

function Node:addPath(path) -- public
	local prev = self
	for _, v in ipairs(path) do
		prev = prev:connect(v)
	end
end

function Node:getConnections() -- public
	return self.nodes
end

local Graph = {}
Graph.__index = Graph

function Graph:newNode ()
	local tmp = {}
	tmp.nodes = {}
	tmp.connections = 0
	tmp.graph = self
	tmp.id = #self.hash + 1
	setmetatable (tmp, Node)
	self.hash[tmp.id] = tmp
	self.size = self.size + 1
	return tmp.id
end

function Graph:removeNode(node)
	self.hash[node] = nil
	self.size = self.size - 1
end

function Graph:clearGraph()
	for k, _ in pairs(self.hash) do
		self:removeNode(k)
	end
end

function Graph:__call (num)
	return self.hash[num]
end

function Graph:getSize()
	return self.size
end

function Graph:printGraph()
	print("Graph of 100 elements with the following connections:")
	for _, v in pairs(self.hash) do
		if v:hasConnections() then
			v:printNode()
		end
	end
end		

function Graph:clearConnections()
	for _, v in pairs(self.hash) do
		if v:hasConnections() then
			v:clearConnections()
		end
	end
end	


function Graph:newGraph(size, immutable)
	self = {}
	self.hash = {}
	self.size = 0
	if size and (size > 0) then
		for i=1, size do
			Node:newNode(self)
		end
	end
	if immutable then
		setmetatable(self.hash, {__newindex=function() error("You tried to add new nodes to an immutable graph.", 3) end})
	end
	return setmetatable(self, Graph)
end

graph = {Graph=Graph, Node=Node}

return graph