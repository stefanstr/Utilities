#!/usr/local/bin/lua

-- playing with graphs --

Node = {}
Node.__index = Node

function Node:connect (node_id)
	if not self.nodes[node_id] then
		self.connections = self.connections + 1
	end
	self.nodes[node_id] = true
	return (graph.hash[node_id])
end

function Node:disconnect (node_id)
	self.nodes[node_id] = nil
	self.connections = self.connections - 1
end

function Node:hasConnections()
	if self.connections > 0 then
		return true
	else
		return false
	end
end

function Node:printNode()
	io.write(self.id, "-->")
	for k, _ in pairs(self.nodes) do
		io.write(" ", k, ";")
	end
	io.write("\n")
end

function Node:addPath(path)
	local prev = self
	for _, v in ipairs(path) do
		prev = prev:connect(v)
	end
end

function Node:newNode (graph)
	local tmp = {}
	tmp.nodes = {}
	tmp.connections = 0
	tmp.graph = graph
	tmp.id = #graph.hash + 1
	setmetatable (tmp, Node)
	graph.hash[tmp.id] = tmp
	return tmp
end

Graph = {}
Graph.__index = Graph

function Graph:__call (num)
	return self.hash[num]
end

function Graph:printGraph()
	print("Graph of 100 elements with the following connections:")
	for _, v in pairs(self.hash) do
		if v:hasConnections() then
			v:printNode()
		end
	end
end
			

function Graph:newGraph(size, immutable)
	self.hash = {}
	for i=1, size do
		Node:newNode(self)
	end
	if immutable then
		setmetatable(self.hash, {__newindex=function() error("You tried to add new nodes to an immutable graph.", 3) end})
	end
	return setmetatable(self, Graph)
end

return Graph, Node
