--!native
--!nocheck
--!optimize 2

type Array = {
	index: () -> { number },
	append: (value: any) -> (),
	find: (value: any) -> number,
	remove: (number) -> (),
}

local LemonSignal = require(script.Packages.LemonSignal)
local Promise = require(script.Packages.PromiseType)

local pyScript = {}

pyScript.classes = {}
pyScript.classAdded = LemonSignal.new()

function pyScript.range(min: number, max: number): { number }
	assert(typeof(min) == "number" and typeof(max) == "number", "min and max needs to be number type!")

	local t = {}

	for num = min, max do
		table.insert(t, num - 1) -- Starting from 0
	end

	return t
end

function pyScript.array(self: { any }): { any } & Array
	local methods = {}
	local arr = setmetatable({}, {
		__index = methods,
		__newindex = function(_, key, value)
			if methods[key] then
				error(`Failed to replace {key} method with {value}.`)
			end

			-- returns the value after it changes!
			return value
		end,
	})

	for index, value in self do
		if typeof(index) ~= "number" then
			warn(`Index must be an number, not a {typeof(index)}.`)
			continue
		end

		table.insert(arr, value)
	end

	function methods.index()
		local keysTable = {}

		for key, _ in arr do
			if table.find(keysTable, key) then
				continue
			end
			table.insert(keysTable, key)
		end

		return keysTable
	end

	function methods.append(value)
		table.insert(arr, value)
	end

	function methods.find(value)
		for i, v in arr do
			if v ~= value then
				continue
			end

			return i
		end

		return 1
	end

	function methods.remove(index)
		if not arr[index] then
			warn("The dictionary index doesn't exist!")
			return
		end

		table.remove(arr, index)
	end

	return arr
end

function pyScript:new(name: string?, functions)
	assert(name, "Name must be an string!")
	assert(not self.classes[name], `Name must be unique string, Seems like {name} is already taken.`)
	assert(functions.__init__, "__init__ function must be included in the class")

	local classWrapper = setmetatable({}, {
		__index = functions,
		__call = function(_, ...)
			functions.__init__(...)
			return functions
		end,
	})

	for index, func in functions do
		functions[index] = function(...)
			return func(classWrapper, ...) -- call function with self and arguments
		end
	end

	self.classes[name] = classWrapper
	self.classAdded:Fire(self.classes[name])
end

function pyScript:import(className: string, ...)
	local arguments = table.pack(...)

	return Promise.try(function()
		return self.classes[className]
	end)
		:andThen(function(Class)
			if Class then
				return Class
			end
			return Promise.fromEvent(self.classAdded)
		end)
		:andThen(function(Class)
			return Class(table.unpack(arguments))
		end)
		:catch(warn)
		:expect()
end

return pyScript
