local watchMe = 1

for k, v in pairs({...}) do
    print(k, v)
end

local function yo(name)
    local yoLocal = "i'm local to yo"

    print(name)

    watchMe = watchMe + 1

    print "third level"
end

local anUpvalue = "i'm a wild upvalue"

local function sayHello(name)
    print("Hello " .. name)

    local sayHelloLocal = "i'm local to sayHello"

    yo(name)

    watchMe = watchMe + 1

    print(yo, anUpvalue, sayHelloLocal, newGlobal)
end

local function sayIt()
    print "sayIt"

    local sayItLocal = "i'm local to sayIt"

    sayHello("joe")

    watchMe = watchMe + 1

    return true
end

for i = 1, 10 do
    print(i)
end

local it = sayIt()

print(debug.getinfo(1).source)

return it, "yeah !", { 1, 2, 3 }

