local function yo()
	print "third level"
end

local function sayHello(name)
    print("Hello " .. name)

    require "croissant.debugger"()

    yo()
end

local function sayIt()
	print "sayIt"

	sayHello("joe")

	return true
end

sayIt()
