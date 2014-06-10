--[[The array class.

The goal: an n-dimensional array that can be dynamically initialized with the
following properties:
- fixed size or dynamic
- ideally fields should be in nil status if not initialized
- n-dimensional
- default value for fields should be possible
- it should be possible to delimit valid values of fields
- not possible to add properties outside of fields
- addition and subtraction of arrays
- concatenation of arrays
- the constructor should specify the allowed type to be stored in a cell (number,
string, a table with a specific metatable...)

There will be a separate structure for 1-dimensional array. Once this is working, I will
figure out how to do secure multidimensional arrays.
]]--



newArrayType = function (name, cell_prototype, length)
-- Creates a new type of array with the given name, cell_prototype and length.
-- name is the name for the metatable, cell_prototype tells us what
-- values the array should be able to store (numbers, strings, specific tables).
-- if length is not given, it means the array can have variable length
-- This function returns a callable metatable that is at the same time used as the 
-- metatable for all arrays of that type and is used as their constructor.
	
	local array_type = {} --this will be returned as the metatable
	local hidden = {} --this holds values the array should be able to access but not the user
	if not (type(name) == "string") then
		error("The name of a new array type must be a string.", 2)
	end
	hidden.name = name -- the name of the array type
	
	-- Functions used for healthchecks. --
	hidden.check_length = function (length)
		if not (type(length) == "number" or length == nil) then
			error("The length parameter needs to be a number, if given.", 3)
		end
	end
	
	hidden.check_prototype = function (value)
		if not (type(cell_prototype) == "number" or type(cell_prototype) == "string"
				or getmetatable(value)) then
			error("The cell_prototype must be a number, a string or an object (i.e., a table with a metatable).", 3)
		end
	end
	
	hidden.check_value_type = function (value)
		if type(hidden.cell_prototype) ~= type(value) then
			error("Incorrect value assignment. The correct value type for array " .. hidden.name .. " is " .. type(hidden.cell_prototype), 3)
		end
	end
	
	hidden.check_table_and_key = function (table, key)
		if getmetatable(table) ~= array_type.__metatable then
			error("This error should never happen: somehow, a table of the wrong type has been tied to " .. array_type.__metatable, 2)
		end
		if type(key) ~= "number" then
			error("Array keys can only be numbers.", 3)
		elseif hidden.length and key > hidden.length or key < 1 then
			error("Assignment out of array length (1.." .. hidden.length .. ")", 3)
		elseif key%1 ~= 0 then
			error("Array keys have to be integers.", 3)
		end
	end
	-- End of healthcheck functions --
	
	-- Saving arguments as hidden parameters.
	hidden.check_length(length)
	hidden.length = length
	hidden.check_prototype(cell_prototype)
	hidden.cell_prototype = cell_prototype
		
	array_meta = {} -- metatable for the array type
	-- A separate meta-metatable is necessary, because the actual type is created within
	--the below __call event.
	
	array_meta.__call = function (...)
		-- The actual array constructor. length is the number of fields. 
		-- initvalue is the value with which the array should be initialized
		-- for fixed length arrays, the arguments go ([initvalue])
		-- for variable length arrays, the arguments go ([initvalue], [length])
		local _, initvalue, length = ...
		-- _ is needed to catch "self" - the first arg
		length = hidden.length or length
		hidden.check_length(length)
		
		local array_temp = {}
		
		-- The below hidden table is a necessary step if we want to control the allowed
		-- value types. This is because direct assignment doesn't fire __index or __newindex
		-- events.
		local array_values = {} 
		if initvalue then 
			hidden.check_value_type (initvalue)
			if length then -- initialize with values
				for i=1, length do
					array_values[i] = initvalue
				end
			else -- otherwise create a default value: without it, the default value is nil
				array_values.default = initvalue
			end	
		end
		
		-- Populating the metatable for the type.
		-- These events have to be inside the constructor because they need access to
		-- array_values.
		array_type.__metatable = "ArrayType:[" .. hidden.name .. "]"
		
		array_type.__index = function (table, key)
			hidden.check_table_and_key(table, key)
			return array_values[key] or array_values.default
		end
		
		array_type.__newindex = function (table, key, value)
			hidden.check_table_and_key(table, key)
			hidden.check_value_type (value)
			array_values[key] = value
		end

		setmetatable(array_temp, array_type)
		return array_temp
	end -- end of array constructor: it returns the ready-baked array
	
	setmetatable(array_type, array_meta)
	return array_type
end -- end of array *type* constructor. It returns the type/metatable.



-- TESTS --
numberType = newArrayType ("numberType", 0, 10)
numbers = numberType(0)
matrixType = newArrayType ("matrixType", numbers, 10)
matrix = matrixType(numbers)
for i=1, 10 do 
	for j=1, 10 do
		print (matrix[i][j]) 
end end


--byteType = newArrayType ("byte", 0, 8)
--wordType = newArrayType ("word", byteType(), 8) --> making this work is the next step
--word1 = wordType(1)
--for i=1, 8 do
--	for j=1, 8 do
--		word1[i][j] = math.random(1,5)
--	end
--end
--print(word1[3][3], word1[1][1])