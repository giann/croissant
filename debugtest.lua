local function yo(name)
    local yoLocal = "i'm local to yo"

    print(name)

	print "third level"
end

local anUpvalue = "i'm a wild upvalue"

local function sayHello(name)
    print("Hello " .. name)

    local sayHelloLocal = "i'm local to sayHello"

    print(yo, anUpvalue, sayHelloLocal, newGlobal)

    yo(name)
end

local function sayIt()
	print "sayIt"

    local sayItLocal = "i'm local to sayIt"

	sayHello("joe")

	return true
end

local it = sayIt()

print(debug.getinfo(1).source)

return it, "yeah !", { 1, 2, 3 }

