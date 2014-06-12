#!/usr/local/bin/lua
--[[
Various random map generators
]]--

-- A SPECIAL MAP TYPE --

local newMap = function (width, height, default_value, allowed_values)
	-- This function generates a new 2D map with the given width and height.
	-- Every field gets populated with the default value.
	-- allowed_values can be a type name ("string", "number" and so on), a table with the
	-- list of accepted values (e.g., {" ", "#", "*"} or a function which accepts an argument
	-- and either returns it or raises an error.
	
	local map = {} -- the object to be returned at the end
	
	if width%1 ~= 0 or height%1 ~= 0 then
		error ("The map's width and height need to be natural numbers.", 2)
	end
	
	local verify_value -- this is an internal function that checks the validity of a value

	-- Set up the internal function verify_value according to the argument allowed_values
	if getmetatable(allowed_values) and getmetatable(allowed_values).__call 
	   or (type(allowed_values) == "function") then 
		verify_value = allowed_values
	else
		verify_value = function (value)
			if allowed_values then
				if type(allowed_values) == "string" then
					if type(value) ~= allowed_values then
						error("Only values of type " .. allowed_values .. " are allowed.", 2)
					end
				elseif type(allowed_values) == "table" then
					local ok = false
					for _, v in pairs(allowed_values) do
						if value == v then
							ok = true
						end
					end
					if not ok then
						error("Unallowed value passed to the map.", 2)
					end
				end
			end
			return value
		end
	end
	
	-- The metatable --
	local map_meta = {} -- the metatable for the map
	map_meta.__tostring = function ()
		return "a " .. width .. " x " .. height .. " map"
	end
	
	map_meta.__index = function (table, column_key)

	end
	
	map_meta.__newindex = function (table, column_key, value)
		
	end
	
	local values = {} -- this stores the map's values (necessary to enable value-checking).
	for w=1, width do
		table.insert(values, setmetatable(row, row_metatable)
	end
	if default_value then
		--initialize table
	end
				

	
	return setmetatable(map, map_meta)
end


-- TESTS --
map = newMap(200, 200, nil, "number")
