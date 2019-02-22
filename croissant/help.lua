local colors = require "term.colors"

local code    = colors.yellow local id      = colors.blue local keyword = colors.magenta

-- luacheck: ignore 631

return {     
["quit"] = {
         title = "quit ()",         body = "Leave Croissant."     },     
["assert"] = {
         title = "assert  (v [, message])",
    body = [[ Calls ]] .. id "error" .. [[ if the value of its argument ]] .. id "v" .. [[ is false (i.e., ]] .. code "nil" .. [[ or ]] .. code "false" .. [[); otherwise, returns all its arguments. In case of error, ]] .. id "message" .. [[ is the error object; when absent, it defaults to ]] .. code "assertion failed!" .. [[ ]]     },     
["collectgarbage"] = {
         title = "collectgarbage  ([opt [, arg]])",
    body = [[This function is a generic interface to the garbage collector. It performs different functions according to its first argument, ]] .. id "opt" .. [[:

]] .. code "collect" .. [[| performs a full garbage-collection cycle. This is the default option.

]] .. code "stop" .. [[| stops automatic execution of the garbage collector. The collector will run only when explicitly invoked, until a call to restart it.

]] .. code "restart" .. [[| restarts automatic execution of the garbage collector.

]] .. code "count" .. [[| returns the total memory in use by Lua in Kbytes. The value has a fractional part, so that it multiplied by 1024 gives the exact number of bytes in use by Lua (except for overflows).

]] .. code "step" .. [[| performs a garbage-collection step. The step size is controlled by ]] .. id "arg" .. [[. With a zero value, the collector will perform one basic (indivisible) step. For non-zero values, the collector will perform as if that amount of memory (in KBytes) had been allocated by Lua. Returns ]] .. code "true" .. [[ if the step finished a collection cycle.

]] .. code "setpause" .. [[| sets ]] .. id "arg" .. [[ as the new value for the pause of the collector ]] .. id "GC" .. [[. Returns the previous value for pause.

]] .. code "incremental" .. [[| Change the collector mode to incremental. This option can be followed by three numbers: the garbage-collector pause, the step multiplier, and the step size.

]] .. code "generational" .. [[| Change the collector mode to generational. This option can be followed by two numbers: the garbage-collector minor multiplier and the major multiplier.

]] .. code "isrunning" .. [[| returns a boolean that tells whether the collector is running (i.e., not stopped). }

} ]]     },     
["dofile"] = {
         title = "dofile  ([filename])",
    body = [[ Opens the named file and executes its contents as a Lua chunk. When called without arguments, ]] .. id "dofile" .. [[ executes the contents of the standard input (]] .. id "stdin" .. [[). Returns all values returned by the chunk. In case of errors, ]] .. id "dofile" .. [[ propagates the error to its caller (that is, ]] .. id "dofile" .. [[ does not run in protected mode). ]]     },     
["error"] = {
         title = "error  (message [, level])",
    body = [[ Terminates the last protected function called and returns ]] .. id "message" .. [[ as the error object. Function ]] .. id "error" .. [[ never returns.

Usually, ]] .. id "error" .. [[ adds some information about the error position at the beginning of the message, if the message is a string. The ]] .. id "level" .. [[ argument specifies how to get the error position. With level 1 (the default), the error position is where the ]] .. id "error" .. [[ function was called. Level 2 points the error to where the function that called ]] .. id "error" .. [[ was called; and so on. Passing a level 0 avoids the addition of error position information to the message. ]]     },     
["_G"] = {
         title = "_G",
    body = [[A global variable  (not a function) that holds the global environment ]] .. id "globalenv" .. [[. Lua itself does not use this variable; changing its value does not affect any environment, nor vice versa.]]

    },

    
["getmetatable"] = {
         title = "getmetatable (object)",
    body = [[If ]] .. id "object" .. [[ does not have a metatable, returns ]] .. code "nil" .. [[. Otherwise, if the object's metatable has a ]] .. id "__metatable" .. [[ field, returns the associated value. Otherwise, returns the metatable of the given object. ]]     },     
["ipairs"] = {
         title = "ipairs  (t)",
    body = [[Returns three values (an iterator function, the table ]] .. id "t" .. [[, and 0) so that the construction ]] .. code " for i,v in ipairs(t) do @rep{body" .. [[ end }
will iterate over the key@En{}value pairs (]] .. code "1,t[1]" .. [[), (]] .. code "2,t[2]" .. [[), .., up to the first absent index. ]]     },     
["load"] = {
         title = "load  (chunk [, chunkname [, mode [, env]]])",
    body = [[Loads a chunk.

If ]] .. id "chunk" .. [[ is a string, the chunk is this string. If ]] .. id "chunk" .. [[ is a function, ]] .. id "load" .. [[ calls it repeatedly to get the chunk pieces. Each call to ]] .. id "chunk" .. [[ must return a string that concatenates with previous results. A return of an empty string, ]] .. code "nil" .. [[, or no value signals the end of the chunk.

If there are no syntactic errors, returns the compiled chunk as a function; otherwise, returns ]] .. code "nil" .. [[ plus the error message.

When you load a main chunk, the resulting function will always have exactly one upvalue, the ]] .. id "_ENV" .. [[ variable ]] .. id "globalenv" .. [[. However, when you load a binary chunk created from a function ]] .. id "string.dump" .. [[, the resulting function can have an arbitrary number of upvalues, and there is no guarantee that its first upvalue will be the ]] .. id "_ENV" .. [[ variable. (A non-main function may not even have an ]] .. id "_ENV" .. [[ upvalue.)

Regardless, if the resulting function has any upvalues, its first upvalue is set to the value of ]] .. id "env" .. [[, if that parameter is given, or to the value of the global environment. Other upvalues are initialized with ]] .. code "nil" .. [[. All upvalues are fresh, that is, they are not shared with any other function.

]] .. id "chunkname" .. [[ is used as the name of the chunk for error messages and debug information ]] .. id "debugI" .. [[. When absent, it defaults to ]] .. id "chunk" .. [[, if ]] .. id "chunk" .. [[ is a string, or to ]] .. code "=(load)" .. [[ otherwise.

The string ]] .. id "mode" .. [[ controls whether the chunk can be text or binary (that is, a precompiled chunk). It may be the string ]] .. code "b" .. [[ (only binary chunks), ]] .. code "t" .. [[ (only text chunks), or ]] .. code "bt" .. [[ (both binary and text). The default is ]] .. code "bt" .. [[.

Lua does not check the consistency of binary chunks. Maliciously crafted binary chunks can crash the interpreter. ]]     },     
["loadfile"] = {
         title = "loadfile  ([filename [, mode [, env]]])",
    body = [[Similar to ]] .. id "load" .. [[, but gets the chunk from file ]] .. id "filename" .. [[ or from the standard input, if no file name is given. ]]     },     
["next"] = {
         title = "next  (table [, index])",
    body = [[Allows a program to traverse all fields of a table. Its first argument is a table and its second argument is an index in this table. ]] .. id "next" .. [[ returns the next index of the table and its associated value. When called with ]] .. code "nil" .. [[ as its second argument, ]] .. id "next" .. [[ returns an initial index and its associated value. When called with the last index, or with ]] .. code "nil" .. [[ in an empty table, ]] .. id "next" .. [[ returns ]] .. code "nil" .. [[. If the second argument is absent, then it is interpreted as ]] .. code "nil" .. [[. In particular, you can use ]] .. code "next(t)" .. [[ to check whether a table is empty.

The order in which the indices are enumerated is not specified, even for numeric indices. (To traverse a table in numerical order, use a numerical ]] .. keyword "for" .. [[.)

The behavior of ]] .. id "next" .. [[ is undefined if, during the traversal, you assign any value to a non-existent field in the table. You may however modify existing fields. In particular, you may set existing fields to nil. ]]     },     
["pairs"] = {
         title = "pairs  (t)",
    body = [[If ]] .. id "t" .. [[ has a metamethod ]] .. id "__pairs" .. [[, calls it with ]] .. id "t" .. [[ as argument and returns the first three results from the call.

Otherwise, returns three values: the ]] .. id "next" .. [[ function, the table ]] .. id "t" .. [[, and ]] .. code "nil" .. [[, so that the construction ]] .. code " for k,v in pairs(t) do @rep{body" .. [[ end }
will iterate over all key@En{}value pairs of table ]] .. id "t" .. [[.

See function ]] .. id "next" .. [[ for the caveats of modifying the table during its traversal. ]]     },     
["pcall"] = {
         title = "pcall  (f [, arg1, ...])",
    body = [[Calls function ]] .. id "f" .. [[ with the given arguments in protected mode. This means that any error inside ]] .. code "f" .. [[ is not propagated; instead, ]] .. id "pcall" .. [[ catches the error and returns a status code. Its first result is the status code (a boolean), which is true if the call succeeds without errors. In such case, ]] .. id "pcall" .. [[ also returns all results from the call, after this first result. In case of any error, ]] .. id "pcall" .. [[ returns ]] .. code "false" .. [[ plus the error message. ]]     },     
["print"] = {
         title = "print  (...)",
    body = [[ Receives any number of arguments and prints their values to ]] .. id "stdout" .. [[, using the ]] .. id "tostring" .. [[ function to convert each argument to a string. ]] .. id "print" .. [[ is not intended for formatted output, but only as a quick way to show a value, for instance for debugging. For complete control over the output, use ]] .. id "string.format" .. [[ and ]] .. id "io.write" .. [[. ]]     },     
["rawequal"] = {
         title = "rawequal  (v1, v2)",
    body = [[ Checks whether ]] .. id "v1" .. [[ is equal to ]] .. id "v2" .. [[, without invoking the ]] .. id "__eq" .. [[ metamethod. Returns a boolean. ]]     },     
["rawget"] = {
         title = "rawget  (table, index)",
    body = [[ Gets the real value of ]] .. code "table[index]" .. [[, without invoking the ]] .. id "__index" .. [[ metamethod. ]] .. id "table" .. [[ must be a table; ]] .. id "index" .. [[ may be any value. ]]     },     
["rawlen"] = {
         title = "rawlen  (v)",
    body = [[ Returns the length of the object ]] .. id "v" .. [[, which must be a table or a string, without invoking the ]] .. id "__len" .. [[ metamethod. Returns an integer. ]]     },     
["rawset"] = {
         title = "rawset  (table, index, value)",
    body = [[ Sets the real value of ]] .. code "table[index]" .. [[ to ]] .. id "value" .. [[, without invoking the ]] .. id "__newindex" .. [[ metamethod. ]] .. id "table" .. [[ must be a table, ]] .. id "index" .. [[ any value different from ]] .. code "nil" .. [[ and NaN, and ]] .. id "value" .. [[ any Lua value.

This function returns ]] .. id "table" .. [[. ]]     },     
["select"] = {
         title = "select  (index, ...)",
    body = [[If ]] .. id "index" .. [[ is a number, returns all arguments after argument number ]] .. id "index" .. [[; a negative number indexes from the end (]] .. code "-1" .. [[ is the last argument). Otherwise, ]] .. id "index" .. [[ must be the string ]] .. code "\"#\"" .. [[, and ]] .. id "select" .. [[ returns the total number of extra arguments it received. ]]     },     
["setmetatable"] = {
         title = "setmetatable  (table, metatable)",
    body = [[Sets the metatable for the given table. (To change the metatable of other types from Lua code, you must use the @link{debuglib|debug library}.) If ]] .. id "metatable" .. [[ is ]] .. code "nil" .. [[, removes the metatable of the given table. If the original metatable has a ]] .. id "__metatable" .. [[ field, raises an error.

This function returns ]] .. id "table" .. [[. ]]     },     
["tonumber"] = {
         title = "tonumber  (e [, base])",
    body = [[When called with no ]] .. id "base" .. [[, ]] .. id "tonumber" .. [[ tries to convert its argument to a number. If the argument is already a number or a string convertible to a number, then ]] .. id "tonumber" .. [[ returns this number; otherwise, it returns ]] .. code "nil" .. [[.

The conversion of strings can result in integers or floats, according to the lexical conventions of Lua ]] .. id "lexical" .. [[. (The string may have leading and trailing spaces and a sign.)

When called with ]] .. id "base" .. [[, then ]] .. id "e" .. [[ must be a string to be interpreted as an integer numeral in that base. The base may be any integer between 2 and 36, inclusive. In bases above 10, the letter ]] .. code "A" .. [[ (in either upper or lower case) represents 10, ]] .. code "B" .. [[ represents 11, and so forth, with ]] .. code "Z" .. [[ representing 35. If the string ]] .. id "e" .. [[ is not a valid numeral in the given base, the function returns ]] .. code "nil" .. [[. ]]     },     
["tostring"] = {
         title = "tostring  (v)",
    body = [[ Receives a value of any type and converts it to a string in a human-readable format. (For complete control of how numbers are converted, use ]] .. id "string.format" .. [[.)

If the metatable of ]] .. id "v" .. [[ has a ]] .. id "__tostring" .. [[ field, then ]] .. id "tostring" .. [[ calls the corresponding value with ]] .. id "v" .. [[ as argument, and uses the result of the call as its result. ]]     },     
["type"] = {
         title = "type  (v)",
    body = [[ Returns the type of its only argument, coded as a string. The possible results of this function are ]] .. code "nil" .. [[ (a string, not the value ]] .. code "nil" .. [[), ]] .. code "number" .. [[, ]] .. code "string" .. [[, ]] .. code "boolean" .. [[, ]] .. code "table" .. [[, ]] .. code "function" .. [[, ]] .. code "thread" .. [[, and ]] .. code "userdata" .. [[. ]]     },     
["_VERSION"] = {
         title = "_VERSION",
    body = [[ A global variable  (not a function) that holds a string containing the running Lua version. The current value of this variable is ]] .. code "Lua 5.4" .. [[. ]]     },

    
["warn"] = {
         title = "warn (message)",
    body = [[ Emits a warning with the given message. Note that messages not ending with an end-of-line are assumed to be continued by the message in the next call. ]]     },     
["xpcall"] = {
         title = "xpcall  (f, msgh [, arg1, ...])",
    body = [[This function is similar to ]] .. id "pcall" .. [[, except that it sets a new message handler ]] .. id "msgh" .. [[.

} ]]     },     
["coroutine.create"] = {
         title = "coroutine.create  (f)",
    body = [[Creates a new coroutine, with body ]] .. id "f" .. [[. ]] .. id "f" .. [[ must be a function. Returns this new coroutine, an object with type ]] .. code "\"thread\"" .. [[. ]]     },     
["coroutine.isyieldable"] = {
         title = "coroutine.isyieldable  ()",
    body = [[Returns true when the running coroutine can yield.

A running coroutine is yieldable if it is not the main thread and it is not inside a non-yieldable C function. ]]     },     
["coroutine.kill"] = {
         title = "coroutine.kill (co)",
    body = [[Kills coroutine ]] .. id "co" .. [[, closing all its pending to-be-closed variables and putting the coroutine in a dead state. In case of error closing some variable, returns ]] .. code "false" .. [[ plus the error object; otherwise returns ]] .. code "true" .. [[. ]]     },     
["coroutine.resume"] = {
         title = "coroutine.resume  (co [, val1, ...])",
    body = [[Starts or continues the execution of coroutine ]] .. id "co" .. [[. The first time you resume a coroutine, it starts running its body. The values ]] .. id "val1" .. [[, .. are passed as the arguments to the body function. If the coroutine has yielded, ]] .. id "resume" .. [[ restarts it; the values ]] .. id "val1" .. [[, .. are passed as the results from the yield.

If the coroutine runs without any errors, ]] .. id "resume" .. [[ returns ]] .. code "true" .. [[ plus any values passed to ]] .. id "yield" .. [[ (when the coroutine yields) or any values returned by the body function (when the coroutine terminates). If there is any error, ]] .. id "resume" .. [[ returns ]] .. code "false" .. [[ plus the error message. ]]     },     
["coroutine.running"] = {
         title = "coroutine.running  ()",
    body = [[Returns the running coroutine plus a boolean, true when the running coroutine is the main one. ]]     },     
["coroutine.status"] = {
         title = "coroutine.status  (co)",
    body = [[Returns the status of coroutine ]] .. id "co" .. [[, as a string: ]] .. code "\"running\"" .. [[, if the coroutine is running (that is, it called ]] .. id "status" .. [[); ]] .. code "\"suspended\"" .. [[, if the coroutine is suspended in a call to ]] .. id "yield" .. [[, or if it has not started running yet; ]] .. code "\"normal\"" .. [[ if the coroutine is active but not running (that is, it has resumed another coroutine); and ]] .. code "\"dead\"" .. [[ if the coroutine has finished its body function, or if it has stopped with an error. ]]     },     
["coroutine.wrap"] = {
         title = "coroutine.wrap  (f)",
    body = [[Creates a new coroutine, with body ]] .. id "f" .. [[. ]] .. id "f" .. [[ must be a function. Returns a function that resumes the coroutine each time it is called. Any arguments passed to the function behave as the extra arguments to ]] .. id "resume" .. [[. Returns the same values returned by ]] .. id "resume" .. [[, except the first boolean. In case of error, propagates the error. ]]     },     
["coroutine.yield"] = {
         title = "coroutine.yield  (...)",
    body = [[Suspends the execution of the calling coroutine. Any arguments to ]] .. id "yield" .. [[ are passed as extra results to ]] .. id "resume" .. [[.

} ]]     },     
["require"] = {
         title = "require  (modname)",
    body = [[Loads the given module. The function starts by looking into the ]] .. id "package.loaded" .. [[ table to determine whether ]] .. id "modname" .. [[ is already loaded. If it is, then ]] .. id "require" .. [[ returns the value stored at ]] .. code "package.loaded[modname]" .. [[. Otherwise, it tries to find a loader for the module.

To find a loader, ]] .. id "require" .. [[ is guided by the ]] .. id "package.searchers" .. [[ sequence. By changing this sequence, we can change how ]] .. id "require" .. [[ looks for a module. The following explanation is based on the default configuration for ]] .. id "package.searchers" .. [[.

First ]] .. id "require" .. [[ queries ]] .. code "package.preload[modname]" .. [[. If it has a value, this value (which must be a function) is the loader. Otherwise ]] .. id "require" .. [[ searches for a Lua loader using the path stored in ]] .. id "package.path" .. [[. If that also fails, it searches for a C loader using the path stored in ]] .. id "package.cpath" .. [[. If that also fails, it tries an all-in-one loader ]] .. id "package.searchers" .. [[.

Once a loader is found, ]] .. id "require" .. [[ calls the loader with two arguments: ]] .. id "modname" .. [[ and an extra value dependent on how it got the loader. (If the loader came from a file, this extra value is the file name.) If the loader returns any non-nil value, ]] .. id "require" .. [[ assigns the returned value to ]] .. code "package.loaded[modname]" .. [[. If the loader does not return a non-nil value and has not assigned any value to ]] .. code "package.loaded[modname]" .. [[, then ]] .. id "require" .. [[ assigns ]] .. keyword "true" .. [[ to this entry. In any case, ]] .. id "require" .. [[ returns the final value of ]] .. code "package.loaded[modname]" .. [[.

If there is any error loading or running the module, or if it cannot find any loader for the module, then ]] .. id "require" .. [[ raises an error. ]]     },     
["package.config"] = {
         title = "package.config",
    body = [[A string describing some compile-time configurations for packages. This string is a sequence of lines: 

・ The first line is the directory separator string. Default is ]] .. code "\\" .. [[ for Windows and ]] .. code "/" .. [[ for all other systems.}

・ The second line is the character that separates templates in a path. Default is ]] .. code ";" .. [[.}

・ The third line is the string that marks the substitution points in a template. Default is ]] .. code "?" .. [[.}

・ The fourth line is a string that, in a path in Windows, is replaced by the executable's directory. Default is ]] .. code "!" .. [[.}

・ The fifth line is a mark to ignore all text after it when building the ]] .. id "luaopen_" .. [[ function name. Default is ]] .. code "-" .. [[.}]]

    },

    
["package.cpath"] = {
         title = "package.cpath",
    body = [[The path used by ]] .. id "require" .. [[ to search for a C loader.

Lua initializes the C path ]] .. id "package.cpath" .. [[ in the same way it initializes the Lua path ]] .. id "package.path" .. [[, using the environment variable ]] .. id "LUA_CPATH_5_4" .. [[, or the environment variable ]] .. id "LUA_CPATH" .. [[, or a default path defined in ]] .. id "luaconf.h" .. [[.]]

    },

    
["package.loaded"] = {
         title = "package.loaded",
    body = [[A table used by ]] .. id "require" .. [[ to control which modules are already loaded. When you require a module ]] .. id "modname" .. [[ and ]] .. code "package.loaded[modname]" .. [[ is not false, ]] .. id "require" .. [[ simply returns the value stored there.

This variable is only a reference to the real table; assignments to this variable do not change the table used by ]] .. id "require" .. [[.]]

    },

    
["package.loadlib"] = {
         title = "package.loadlib (libname, funcname)",
    body = [[ Dynamically links the host program with the C library ]] .. id "libname" .. [[.

If ]] .. id "funcname" .. [[ is ]] .. code "*" .. [[, then it only links with the library, making the symbols exported by the library available to other dynamically linked libraries. Otherwise, it looks for a function ]] .. id "funcname" .. [[ inside the library and returns this function as a C function. So, ]] .. id "funcname" .. [[ must follow the ]] .. id "lua_CFunction" .. [[ prototype lua_CFunction.

This is a low-level function. It completely bypasses the package and module system. Unlike ]] .. id "require" .. [[, it does not perform any path searching and does not automatically adds extensions. ]] .. id "libname" .. [[ must be the complete file name of the C library, including if necessary a path and an extension. ]] .. id "funcname" .. [[ must be the exact name exported by the C library (which may depend on the C compiler and linker used).

This function is not supported by Standard C. As such, it is only available on some platforms (Windows, Linux, Mac OS X, Solaris, BSD, plus other Unix systems that support the ]] .. id "dlfcn" .. [[ standard). ]]     },

    
["package.path"] = {
         title = "package.path",
    body = [[The path used by ]] .. id "require" .. [[ to search for a Lua loader.

At start-up, Lua initializes this variable with the value of the environment variable ]] .. id "LUA_PATH_5_4" .. [[ or the environment variable ]] .. id "LUA_PATH" .. [[ or with a default path defined in ]] .. id "luaconf.h" .. [[, if those environment variables are not defined. Any ]] .. code ";;" .. [[ in the value of the environment variable is replaced by the default path.]]     },

    
["package.preload"] = {
         title = "package.preload",
    body = [[A table to store loaders for specific modules ]] .. id "require" .. [[.

This variable is only a reference to the real table; assignments to this variable do not change the table used by ]] .. id "require" .. [[.]]

    },

    
["package.searchers"] = {
         title = "package.searchers",
    body = [[A table used by ]] .. id "require" .. [[ to control how to load modules.

Each entry in this table is a searcher function. When looking for a module, ]] .. id "require" .. [[ calls each of these searchers in ascending order, with the module name  (the argument given to ]] .. id "require" .. [[) as its sole argument. The function can return another function (the module loader) plus an extra value that will be passed to that loader, or a string explaining why it did not find that module (or ]] .. code "nil" .. [[ if it has nothing to say).

Lua initializes this table with four searcher functions.

The first searcher simply looks for a loader in the ]] .. id "package.preload" .. [[ table.

The second searcher looks for a loader as a Lua library, using the path stored at ]] .. id "package.path" .. [[. The search is done as described in function ]] .. id "package.searchpath" .. [[.

The third searcher looks for a loader as a C library, using the path given by the variable ]] .. id "package.cpath" .. [[. Again, the search is done as described in function ]] .. id "package.searchpath" .. [[. For instance, if the C path is the string ]] .. code " \"./?.so;./?.dll;/usr/local/?/init.so\" " .. [[
the searcher for module ]] .. id "foo" .. [[ will try to open the files ]] .. code "./foo.so" .. [[, ]] .. code "./foo.dll" .. [[, and ]] .. code "/usr/local/foo/init.so" .. [[, in that order. Once it finds a C library, this searcher first uses a dynamic link facility to link the application with the library. Then it tries to find a C function inside the library to be used as the loader. The name of this C function is the string ]] .. code "luaopen_" .. [[ concatenated with a copy of the module name where each dot is replaced by an underscore. Moreover, if the module name has a hyphen, its suffix after (and including) the first hyphen is removed. For instance, if the module name is ]] .. id "a.b.c-v2.1" .. [[, the function name will be ]] .. id "luaopen_a_b_c" .. [[.

The fourth searcher tries an all-in-one loader. It searches the C path for a library for the root name of the given module. For instance, when requiring ]] .. id "a.b.c" .. [[, it will search for a C library for ]] .. id "a" .. [[. If found, it looks into it for an open function for the submodule; in our example, that would be ]] .. id "luaopen_a_b_c" .. [[. With this facility, a package can pack several C submodules into one single library, with each submodule keeping its original open function.

All searchers except the first one (preload) return as the extra value the file name where the module was found, as returned by ]] .. id "package.searchpath" .. [[. The first searcher returns no extra value.]]

    },

    
["package.searchpath"] = {
         title = "package.searchpath (name, path [, sep [, rep]])",
    body = [[ Searches for the given ]] .. id "name" .. [[ in the given ]] .. id "path" .. [[.

A path is a string containing a sequence of templates separated by semicolons. For each template, the function replaces each interrogation mark (if any) in the template with a copy of ]] .. id "name" .. [[ wherein all occurrences of ]] .. id "sep" .. [[ (a dot, by default) were replaced by ]] .. id "rep" .. [[ (the system's directory separator, by default), and then tries to open the resulting file name.

For instance, if the path is the string ]] .. code " \"./?.lua;./?.lc;/usr/local/?/init.lua\" " .. [[
the search for the name ]] .. id "foo.a" .. [[ will try to open the files ]] .. code "./foo/a.lua" .. [[, ]] .. code "./foo/a.lc" .. [[, and ]] .. code "/usr/local/foo/a/init.lua" .. [[, in that order.

Returns the resulting name of the first file that it can open in read mode (after closing the file), or ]] .. code "nil" .. [[ plus an error message if none succeeds. (This error message lists all file names it tried to open.) ]]     },

    
["string.byte"] = {
         title = "string.byte  (s [, i [, j]])",
    body = [[ Returns the internal numeric codes of the characters ]] .. code "s[i]" .. [[, ]] .. code "s[i+1]" .. [[, .., ]] .. code "s[j]" .. [[. The default value for ]] .. id "i" .. [[ is 1; the default value for ]] .. id "j" .. [[ is ]] .. id "i" .. [[. These indices are corrected following the same rules of function ]] .. id "string.sub" .. [[.

Numeric codes are not necessarily portable across platforms. ]]     },     
["string.char"] = {
         title = "string.char  (...)",
    body = [[ Receives zero or more integers. Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.

Numeric codes are not necessarily portable across platforms. ]]     },     
["string.dump"] = {
         title = "string.dump  (function [, strip])",
    body = [[Returns a string containing a binary representation (a binary chunk) of the given function, so that a later ]] .. id "load" .. [[ on this string returns a copy of the function (but with new upvalues). If ]] .. id "strip" .. [[ is a true value, the binary representation may not include all debug information about the function, to save space.

Functions with upvalues have only their number of upvalues saved. When (re)loaded, those upvalues receive fresh instances containing ]] .. code "nil" .. [[. (You can use the debug library to serialize and reload the upvalues of a function in a way adequate to your needs.) ]]     },     
["string.find"] = {
         title = "string.find  (s, pattern [, init [, plain]])",
    body = [[Looks for the first match of ]] .. id "pattern" .. [[ ]] .. id "pm" .. [[ in the string ]] .. id "s" .. [[. If it finds a match, then ]] .. id "find" .. [[ returns the indices of ]] .. code "s" .. [[ where this occurrence starts and ends; otherwise, it returns ]] .. code "nil" .. [[. A third, optional numeric argument ]] .. id "init" .. [[ specifies where to start the search; its default value is 1 and can be negative. A value of ]] .. code "true" .. [[ as a fourth, optional argument ]] .. id "plain" .. [[ turns off the pattern matching facilities, so the function does a plain find substring operation, with no characters in ]] .. id "pattern" .. [[ being considered magic. Note that if ]] .. id "plain" .. [[ is given, then ]] .. id "init" .. [[ must be given as well.

If the pattern has captures, then in a successful match the captured values are also returned, after the two indices. ]]     },     
["string.format"] = {
         title = "string.format  (formatstring, ...)",
    body = [[Returns a formatted version of its variable number of arguments following the description given in its first argument (which must be a string). The format string follows the same rules as the ]] .. id "sprintf" .. [[. The only differences are that the options/modifiers ]] .. code "*" .. [[, ]] .. id "h" .. [[, ]] .. id "L" .. [[, ]] .. id "l" .. [[, ]] .. id "n" .. [[, and ]] .. id "p" .. [[ are not supported and that there is an extra option, ]] .. id "q" .. [[.

The ]] .. id "q" .. [[ option formats booleans, nil, numbers, and strings in a way that the result is a valid constant in Lua source code. Booleans and nil are written in the obvious way (]] .. id "true" .. [[, ]] .. id "false" .. [[, ]] .. id "nil" .. [[). Floats are written in hexadecimal, to preserve full precision. A string is written between double quotes, using escape sequences when necessary to ensure that it can safely be read back by the Lua interpreter. For instance, the call ]] .. code " string.format('%q', 'a string with \"quotes\" and \n new line') " .. [[
may produce the string: ]] .. code " \"a string with \"quotes\" and \\  new line\" " .. [[

Options ]] .. id "A" .. [[, ]] .. id "a" .. [[, ]] .. id "E" .. [[, ]] .. id "e" .. [[, ]] .. id "f" .. [[, ]] .. id "G" .. [[, and ]] .. id "g" .. [[ all expect a number as argument. Options ]] .. id "c" .. [[, ]] .. id "d" .. [[, ]] .. id "i" .. [[, ]] .. id "o" .. [[, ]] .. id "u" .. [[, ]] .. id "X" .. [[, and ]] .. id "x" .. [[ expect an integer. When Lua is compiled with a C89 compiler, options ]] .. id "A" .. [[ and ]] .. id "a" .. [[ (hexadecimal floats) do not support any modifier (flags, width, length).

Option ]] .. id "s" .. [[ expects a string; if its argument is not a string, it is converted to one following the same rules of ]] .. id "tostring" .. [[. If the option has any modifier (flags, width, length), the string argument should not contain embedded zeros. ]]     },     
["string.gmatch"] = {
         title = "string.gmatch  (s, pattern [, init])",
    body = [[ Returns an iterator function that, each time it is called, returns the next captures from ]] .. id "pattern" .. [[ ]] .. id "pm" .. [[ over the string ]] .. id "s" .. [[. If ]] .. id "pattern" .. [[ specifies no captures, then the whole match is produced in each call. A third, optional numeric argument ]] .. id "init" .. [[ specifies where to start the search; its default value is 1 and can be negative.

As an example, the following loop will iterate over all the words from string ]] .. id "s" .. [[, printing one per line: ]] .. code " s = \"hello world from Lua\" for w in string.gmatch(s, \"%a+\") do   print(w) end " .. [[
The next example collects all pairs ]] .. code "key=value" .. [[ from the given string into a table: ]] .. code " t = {" .. [[ s = "from=world, to=Lua" for k, v in string.gmatch(s, "(%w+)=(%w+)") do   t[k] = v end }

For this function, a caret ]] .. code "^" .. [[ at the start of a pattern does not work as an anchor, as this would prevent the iteration. ]]     },     
["string.gsub"] = {
         title = "string.gsub  (s, pattern, repl [, n])",
    body = [[ Returns a copy of ]] .. id "s" .. [[ in which all (or the first ]] .. id "n" .. [[, if given) occurrences of the ]] .. id "pattern" .. [[ ]] .. id "pm" .. [[ have been replaced by a replacement string specified by ]] .. id "repl" .. [[, which can be a string, a table, or a function. ]] .. id "gsub" .. [[ also returns, as its second value, the total number of matches that occurred. The name ]] .. id "gsub" .. [[ comes from Global SUBstitution.

If ]] .. id "repl" .. [[ is a string, then its value is used for replacement. The character ]] .. code "%" .. [[ works as an escape character: any sequence in ]] .. id "repl" .. [[ of the form ]] .. code "%@rep{d" .. [[}, with @rep{d} between 1 and 9, stands for the value of the @rep{d}-th captured substring. The sequence ]] .. code "%0" .. [[ stands for the whole match. The sequence ]] .. code "%%" .. [[ stands for a single ]] .. code "%" .. [[.

If ]] .. id "repl" .. [[ is a table, then the table is queried for every match, using the first capture as the key.

If ]] .. id "repl" .. [[ is a function, then this function is called every time a match occurs, with all captured substrings passed as arguments, in order.

In any case, if the pattern specifies no captures, then it behaves as if the whole pattern was inside a capture.

If the value returned by the table query or by the function call is a string or a number, then it is used as the replacement string; otherwise, if it is ]] .. keyword "false" .. [[ or ]] .. code "nil" .. [[, then there is no replacement (that is, the original match is kept in the string).

Here are some examples: ]] .. code [[ x = string.gsub("hello world", "(%w+)", "%1 %1") --> x="hello hello world world"

x = string.gsub("hello world", "%w+", "%0 %0", 1) --> x="hello hello world"

x = string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2 %1") --> x="world hello Lua from"

x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv) --> x="home = /home/roberto, user = roberto"

x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)       return load(s)()     end) --> x="4+5 = 9"

local t = {name="lua", version="5.4" x = string.gsub("$name-$version.tar.gz", "%$(%w+)", t) --> x="lua-5.4.tar.gz" }]]     },     
["string.len"] = {
         title = "string.len  (s)",
    body = [[ Receives a string and returns its length. The empty string ]] .. code "\"\"" .. [[ has length 0. Embedded zeros are counted, so ]] .. code "\"a\000bc\000\"" .. [[ has length 5. ]]     },     
["string.lower"] = {
         title = "string.lower  (s)",
    body = [[ Receives a string and returns a copy of this string with all uppercase letters changed to lowercase. All other characters are left unchanged. The definition of what an uppercase letter is depends on the current locale. ]]     },     
["string.match"] = {
         title = "string.match  (s, pattern [, init])",
    body = [[ Looks for the first match of ]] .. id "pattern" .. [[ ]] .. id "pm" .. [[ in the string ]] .. id "s" .. [[. If it finds one, then ]] .. id "match" .. [[ returns the captures from the pattern; otherwise it returns ]] .. code "nil" .. [[. If ]] .. id "pattern" .. [[ specifies no captures, then the whole match is returned. A third, optional numeric argument ]] .. id "init" .. [[ specifies where to start the search; its default value is 1 and can be negative. ]]     },     
["string.pack"] = {
         title = "string.pack  (fmt, v1, v2, ...)",
    body = [[Returns a binary string containing the values ]] .. id "v1" .. [[, ]] .. id "v2" .. [[, etc. packed (that is, serialized in binary form) according to the format string ]] .. id "fmt" .. [[ ]] .. id "pack" .. [[. ]]     },     
["string.packsize"] = {
         title = "string.packsize  (fmt)",
    body = [[Returns the size of a string resulting from ]] .. id "string.pack" .. [[ with the given format. The format string cannot have the variable-length options ]] .. code "s" .. [[ or ]] .. code "z" .. [[ ]] .. id "pack" .. [[. ]]     },     
["string.rep"] = {
         title = "string.rep  (s, n [, sep])",
    body = [[ Returns a string that is the concatenation of ]] .. id "n" .. [[ copies of the string ]] .. id "s" .. [[ separated by the string ]] .. id "sep" .. [[. The default value for ]] .. id "sep" .. [[ is the empty string (that is, no separator). Returns the empty string if ]] .. id "n" .. [[ is not positive.

(Note that it is very easy to exhaust the memory of your machine with a single call to this function.) ]]     },     
["string.reverse"] = {
         title = "string.reverse  (s)",
    body = [[ Returns a string that is the string ]] .. id "s" .. [[ reversed. ]]     },     
["string.sub"] = {
         title = "string.sub  (s, i [, j])",
    body = [[ Returns the substring of ]] .. id "s" .. [[ that starts at ]] .. id "i" .. [[  and continues until ]] .. id "j" .. [[; ]] .. id "i" .. [[ and ]] .. id "j" .. [[ can be negative. If ]] .. id "j" .. [[ is absent, then it is assumed to be equal to ]] .. code "-1" .. [[ (which is the same as the string length). In particular, the call ]] .. code "string.sub(s,1,j)" .. [[ returns a prefix of ]] .. id "s" .. [[ with length ]] .. id "j" .. [[, and ]] .. code "string.sub(s, -i)" .. [[ (for a positive ]] .. id "i" .. [[) returns a suffix of ]] .. id "s" .. [[ with length ]] .. id "i" .. [[.

If, after the translation of negative indices, ]] .. id "i" .. [[ is less than 1, it is corrected to 1. If ]] .. id "j" .. [[ is greater than the string length, it is corrected to that length. If, after these corrections, ]] .. id "i" .. [[ is greater than ]] .. id "j" .. [[, the function returns the empty string. ]]     },     
["string.unpack"] = {
         title = "string.unpack  (fmt, s [, pos])",
    body = [[Returns the values packed in string ]] .. id "s" .. [[ ]] .. id "string.pack" .. [[ according to the format string ]] .. id "fmt" .. [[ ]] .. id "pack" .. [[. An optional ]] .. id "pos" .. [[ marks where to start reading in ]] .. id "s" .. [[ (default is 1). After the read values, this function also returns the index of the first unread byte in ]] .. id "s" .. [[. ]]     },     
["string.upper"] = {
         title = "string.upper  (s)",
    body = [[ Receives a string and returns a copy of this string with all lowercase letters changed to uppercase. All other characters are left unchanged. The definition of what a lowercase letter is depends on the current locale. ]]     },     
["utf8.char"] = {
         title = "utf8.char  (...)",
    body = [[ Receives zero or more integers, converts each one to its corresponding UTF-8 byte sequence and returns a string with the concatenation of all these sequences. ]]     },     
["utf8.charpattern"] = {
         title = "utf8.charpattern",
    body = [[The pattern  (a string, not a function) ]] .. code "[\0-\x7F\xC2-\xF4][\x80-\xBF]*" .. [[ ]] .. id "pm" .. [[, which matches exactly one UTF-8 byte sequence, assuming that the subject is a valid UTF-8 string.]]     },

    
["utf8.codes"] = {
         title = "utf8.codes (s)",
    body = [[ Returns values so that the construction ]] .. code " for p, c in utf8.codes(s) do @rep{body" .. [[ end }
will iterate over all characters in string ]] .. id "s" .. [[, with ]] .. id "p" .. [[ being the position (in bytes) and ]] .. id "c" .. [[ the code point of each character. It raises an error if it meets any invalid byte sequence. ]]     },     
["utf8.codepoint"] = {
         title = "utf8.codepoint  (s [, i [, j]])",
    body = [[ Returns the codepoints (as integers) from all characters in ]] .. id "s" .. [[ that start between byte position ]] .. id "i" .. [[ and ]] .. id "j" .. [[ (both included). The default for ]] .. id "i" .. [[ is 1 and for ]] .. id "j" .. [[ is ]] .. id "i" .. [[. It raises an error if it meets any invalid byte sequence. ]]     },     
["utf8.len"] = {
         title = "utf8.len  (s [, i [, j]])",
    body = [[ Returns the number of UTF-8 characters in string ]] .. id "s" .. [[ that start between positions ]] .. id "i" .. [[ and ]] .. id "j" .. [[ (both inclusive). The default for ]] .. id "i" .. [[ is ]] .. code "1" .. [[ and for ]] .. id "j" .. [[ is ]] .. code "-1" .. [[. If it finds any invalid byte sequence, returns a false value plus the position of the first invalid byte. ]]     },     
["utf8.offset"] = {
         title = "utf8.offset  (s, n [, i])",
    body = [[ Returns the position (in bytes) where the encoding of the ]] .. id "n" .. [[-th character of ]] .. id "s" .. [[ (counting from position ]] .. id "i" .. [[) starts. A negative ]] .. id "n" .. [[ gets characters before position ]] .. id "i" .. [[. The default for ]] .. id "i" .. [[ is 1 when ]] .. id "n" .. [[ is non-negative and ]] .. code "#s + 1" .. [[ otherwise, so that ]] .. code "utf8.offset(s, -n)" .. [[ gets the offset of the ]] .. id "n" .. [[-th character from the end of the string. If the specified character is neither in the subject nor right after its end, the function returns ]] .. code "nil" .. [[.

As a special case, when ]] .. id "n" .. [[ is 0 the function returns the start of the encoding of the character that contains the ]] .. id "i" .. [[-th byte of ]] .. id "s" .. [[.

This function assumes that ]] .. id "s" .. [[ is a valid UTF-8 string.

} ]]     },     
["table.concat"] = {
         title = "table.concat  (list [, sep [, i [, j]]])",
    body = [[Given a list where all elements are strings or numbers, returns the string ]] .. code "list[i]..sep..list[i+1] ... sep..list[j]" .. [[. The default value for ]] .. id "sep" .. [[ is the empty string, the default for ]] .. id "i" .. [[ is 1, and the default for ]] .. id "j" .. [[ is ]] .. code "#list" .. [[. If ]] .. id "i" .. [[ is greater than ]] .. id "j" .. [[, returns the empty string. ]]     },     
["table.insert"] = {
         title = "table.insert  (list, [pos,] value)",
    body = [[Inserts element ]] .. id "value" .. [[ at position ]] .. id "pos" .. [[ in ]] .. id "list" .. [[, shifting up the elements ]] .. code "list[pos], list[pos+1], ..., list[#list]" .. [[. The default value for ]] .. id "pos" .. [[ is ]] .. code "#list+1" .. [[, so that a call ]] .. code "table.insert(t,x)" .. [[ inserts ]] .. id "x" .. [[ at the end of list ]] .. id "t" .. [[. ]]     },     
["table.move"] = {
         title = "table.move  (a1, f, e, t [,a2])",
    body = [[Moves elements from table ]] .. id "a1" .. [[ to table ]] .. id "a2" .. [[, performing the equivalent to the following multiple assignment: ]] .. code "a2[t],... = a1[f],...,a1[e]" .. [[. The default for ]] .. id "a2" .. [[ is ]] .. id "a1" .. [[. The destination range can overlap with the source range. The number of elements to be moved must fit in a Lua integer.

Returns the destination table ]] .. id "a2" .. [[. ]]     },     
["table.pack"] = {
         title = "table.pack  (...)",
    body = [[Returns a new table with all arguments stored into keys 1, 2, etc. and with a field ]] .. code "n" .. [[ with the total number of arguments. Note that the resulting table may not be a sequence, if some arguments are ]] .. code "nil" .. [[. ]]     },     
["table.remove"] = {
         title = "table.remove  (list [, pos])",
    body = [[Removes from ]] .. id "list" .. [[ the element at position ]] .. id "pos" .. [[, returning the value of the removed element. When ]] .. id "pos" .. [[ is an integer between 1 and ]] .. code "#list" .. [[, it shifts down the elements ]] .. code "list[pos+1], list[pos+2], ..., list[#list]" .. [[ and erases element ]] .. code "list[#list]" .. [[; The index ]] .. id "pos" .. [[ can also be 0 when ]] .. code "#list" .. [[ is 0, or ]] .. code "#list + 1" .. [[.

The default value for ]] .. id "pos" .. [[ is ]] .. code "#list" .. [[, so that a call ]] .. code "table.remove(l)" .. [[ removes the last element of list ]] .. id "l" .. [[. ]]     },     
["table.sort"] = {
         title = "table.sort  (list [, comp])",
    body = [[Sorts list elements in a given order, in-place, from ]] .. code "list[1]" .. [[ to ]] .. code "list[#list]" .. [[. If ]] .. id "comp" .. [[ is given, then it must be a function that receives two list elements and returns true when the first element must come before the second in the final order (so that, after the sort, ]] .. code "i < j" .. [[ implies ]] .. code "not comp(list[j],list[i])" .. [[). If ]] .. id "comp" .. [[ is not given, then the standard Lua operator ]] .. code "<" .. [[ is used instead.

Note that the ]] .. id "comp" .. [[ function must define a strict partial order over the elements in the list; that is, it must be asymmetric and transitive. Otherwise, no valid sort may be possible.

The sort algorithm is not stable: elements considered equal by the given order may have their relative positions changed by the sort. ]]     },     
["table.unpack"] = {
         title = "table.unpack  (list [, i [, j]])",
    body = [[Returns the elements from the given list. This function is equivalent to ]] .. code " return list[i], list[i+1], ..., list[j] " .. [[
By default, ]] .. id "i" .. [[ is 1 and ]] .. id "j" .. [[ is ]] .. code "#list" .. [[.

} ]]     },     
["math.abs"] = {
         title = "math.abs  (x)",
    body = [[Returns the absolute value of ]] .. id "x" .. [[. (integer/float) ]]     },     
["math.acos"] = {
         title = "math.acos  (x)",
    body = [[Returns the arc cosine of ]] .. id "x" .. [[ (in radians). ]]     },     
["math.asin"] = {
         title = "math.asin  (x)",
    body = [[Returns the arc sine of ]] .. id "x" .. [[ (in radians). ]]     },     
["math.atan"] = {
         title = "math.atan  (y [, x])",
    body = [[@index{atan2} Returns the arc tangent of ]] .. code "y/x" .. [[ (in radians), but uses the signs of both arguments to find the quadrant of the result. (It also handles correctly the case of ]] .. id "x" .. [[ being zero.)

The default value for ]] .. id "x" .. [[ is 1, so that the call ]] .. code "math.atan(y)" .. [[ returns the arc tangent of ]] .. id "y" .. [[. ]]     },     
["math.ceil"] = {
         title = "math.ceil  (x)",
    body = [[Returns the smallest integral value larger than or equal to ]] .. id "x" .. [[. ]]     },     
["math.cos"] = {
         title = "math.cos  (x)",
    body = [[Returns the cosine of ]] .. id "x" .. [[ (assumed to be in radians). ]]     },     
["math.deg"] = {
         title = "math.deg  (x)",
    body = [[Converts the angle ]] .. id "x" .. [[ from radians to degrees. ]]     },     
["math.exp"] = {
         title = "math.exp  (x)",
    body = [[Returns the value esp{x} (where ]] .. id "e" .. [[ is the base of natural logarithms). ]]     },     
["math.floor"] = {
         title = "math.floor  (x)",
    body = [[Returns the largest integral value smaller than or equal to ]] .. id "x" .. [[. ]]     },     
["math.fmod"] = {
         title = "math.fmod  (x, y)",
    body = [[Returns the remainder of the division of ]] .. id "x" .. [[ by ]] .. id "y" .. [[ that rounds the quotient towards zero. (integer/float) ]]     },     
["math.huge"] = {
         title = "math.huge",
    body = [[The float value ]] .. id "HUGE_VAL" .. [[, a value larger than any other numeric value.]]     },

    
["math.log"] = {
         title = "math.log  (x [, base])",
    body = [[ Returns the logarithm of ]] .. id "x" .. [[ in the given base. The default for ]] .. id "base" .. [[ is e (so that the function returns the natural logarithm of ]] .. id "x" .. [[). ]]     },     
["math.max"] = {
         title = "math.max  (x, ...)",
    body = [[Returns the argument with the maximum value, according to the Lua operator ]] .. code "<" .. [[. (integer/float) ]]     },     
["math.maxinteger"] = {
         title = "math.maxinteger",         body = "An integer with the maximum value for an integer."     },

    
["math.min"] = {
         title = "math.min  (x, ...)",
    body = [[ Returns the argument with the minimum value, according to the Lua operator ]] .. code "<" .. [[. (integer/float) ]]     },

    
["math.mininteger"] = {
         title = "math.mininteger",
    body = [[An integer with the minimum value for an integer.]]     },

    
["math.modf"] = {
         title = "math.modf  (x)",
    body = [[ Returns the integral part of ]] .. id "x" .. [[ and the fractional part of ]] .. id "x" .. [[. Its second result is always a float. ]]     },

    
["math.pi"] = {
title = "math.pi",
    body = [[The value of @pi.]]},

    
["math.rad"] = {
         title = "math.rad  (x)",
    body = [[ Converts the angle ]] .. id "x" .. [[ from degrees to radians. ]]     },     
["math.random"] = {
         title = "math.random  ([m [, n]])",
    body = [[When called without arguments, returns a pseudo-random float with uniform distribution in the range ]] .. code "(" .. [[ [0,1).  ]] .. code "]" .. [[ When called with two integers ]] .. id "m" .. [[ and ]] .. id "n" .. [[, ]] .. id "math.random" .. [[ returns a pseudo-random integer with uniform distribution in the range [m, n]. The call ]] .. code "math.random(n)" .. [[, for a positive ]] .. id "n" .. [[, is equivalent to ]] .. code "math.random(1,n)" .. [[. The call ]] .. code "math.random(0)" .. [[ produces an integer with all bits (pseudo)random.

Lua initializes its pseudo-random generator with a weak attempt for ``randomness'', so that ]] .. id "math.random" .. [[ should generate different sequences of results each time the program runs. To ensure a required level of randomness to the initial state (or contrarily, to have a deterministic sequence, for instance when debugging a program), you should call ]] .. id "math.randomseed" .. [[ explicitly.

The results from this function have good statistical qualities, but they are not cryptographically secure. (For instance, there are no guarantees that it is hard to predict future results based on the observation of some number of previous results.) ]]     },     
["math.randomseed"] = {
         title = "math.randomseed  (x [, y])",
    body = [[The integer parameters ]] .. id "x" .. [[ and ]] .. id "y" .. [[ are concatenated into a 128-bit seed that is used to reinitialize the pseudo-random generator; equal seeds produce equal sequences of numbers. The default for ]] .. id "y" .. [[ is zero. ]]     },     
["math.sin"] = {
         title = "math.sin  (x)",
    body = [[Returns the sine of ]] .. id "x" .. [[ (assumed to be in radians). ]]     },     
["math.sqrt"] = {
         title = "math.sqrt  (x)",
    body = [[Returns the square root of ]] .. id "x" .. [[. (You can also use the expression ]] .. code "x^0.5" .. [[ to compute this value.) ]]     },     
["math.tan"] = {
         title = "math.tan  (x)",
    body = [[Returns the tangent of ]] .. id "x" .. [[ (assumed to be in radians). ]]     },     
["math.tointeger"] = {
         title = "math.tointeger  (x)",
    body = [[If the value ]] .. id "x" .. [[ is convertible to an integer, returns that integer. Otherwise, returns ]] .. code "nil" .. [[. ]]     },     
["math.type"] = {
         title = "math.type  (x)",
    body = [[Returns ]] .. code "integer" .. [[ if ]] .. id "x" .. [[ is an integer, ]] .. code "float" .. [[ if it is a float, or ]] .. code "nil" .. [[ if ]] .. id "x" .. [[ is not a number. ]]     },     
["math.ult"] = {
         title = "math.ult  (m, n)",
    body = [[Returns a boolean, true if and only if integer ]] .. id "m" .. [[ is below integer ]] .. id "n" .. [[ when they are compared as unsigned integers.

} ]]     },     
["io.close"] = {
         title = "io.close  ([file])",
    body = [[Equivalent to ]] .. code "file:close()" .. [[. Without a ]] .. id "file" .. [[, closes the default output file. ]]     },     
["io.flush"] = {
         title = "io.flush  ()",
    body = [[Equivalent to ]] .. code "io.output():flush()" .. [[. ]]     },     
["io.input"] = {
         title = "io.input  ([file])",
    body = [[When called with a file name, it opens the named file (in text mode), and sets its handle as the default input file. When called with a file handle, it simply sets this file handle as the default input file. When called without arguments, it returns the current default input file.

In case of errors this function raises the error, instead of returning an error code. ]]     },     
["io.lines"] = {
         title = "io.lines  ([filename, ...])",
    body = [[Opens the given file name in read mode and returns an iterator function that works like ]] .. code "file:lines(...)" .. [[ over the opened file. When the iterator function detects the end of file, it returns no values (to finish the loop) and automatically closes the file. Besides the iterator function, ]] .. id "io.lines" .. [[ returns three other values: two ]] .. code "nil" .. [[ values as placeholders, plus the created file handle. Therefore, when used in a generic ]] .. keyword "for" .. [[ loop, the file is closed also if the loop is interrupted by an error or a ]] .. keyword "break" .. [[.

The call ]] .. code "io.lines()" .. [[ (with no file name) is equivalent to ]] .. code "io.input():lines(\"l\")" .. [[; that is, it iterates over the lines of the default input file. In this case, the iterator does not close the file when the loop ends.

In case of errors this function raises the error, instead of returning an error code. ]]     },     
["io.open"] = {
         title = "io.open  (filename [, mode])",
    body = [[This function opens a file, in the mode specified in the string ]] .. id "mode" .. [[. In case of success, it returns a new file handle.

The ]] .. id "mode" .. [[ string can be any of the following:

・ ]] .. code "r" .. [[| read mode (the default);} ・ ]] .. code "w" .. [[| write mode;} ・ ]] .. code "a" .. [[| append mode;} ・ ]] .. code "r+" .. [[| update mode, all previous data is preserved;} ・ ]] .. code "w+" .. [[| update mode, all previous data is erased;} ・ ]] .. code "a+" .. [[| append update mode, previous data is preserved,   writing is only allowed at the end of file.} }
The ]] .. id "mode" .. [[ string can also have a ]] .. code "b" .. [[ at the end, which is needed in some systems to open the file in binary mode. ]]     },     
["io.output"] = {
         title = "io.output  ([file])",
    body = [[Similar to ]] .. id "io.input" .. [[, but operates over the default output file. ]]     },     
["io.popen"] = {
         title = "io.popen  (prog [, mode])",
    body = [[This function is system dependent and is not available on all platforms.

Starts program ]] .. id "prog" .. [[ in a separated process and returns a file handle that you can use to read data from this program (if ]] .. id "mode" .. [[ is ]] .. code "\"r\"" .. [[, the default) or to write data to this program (if ]] .. id "mode" .. [[ is ]] .. code "\"w\"" .. [[). ]]     },     
["io.read"] = {
         title = "io.read  (...)",
    body = [[Equivalent to ]] .. code "io.input():read(...)" .. [[. ]]     },     
["io.tmpfile"] = {
         title = "io.tmpfile  ()",
    body = [[In case of success, returns a handle for a temporary file. This file is opened in update mode and it is automatically removed when the program ends. ]]     },     
["io.type"] = {
         title = "io.type  (obj)",
    body = [[Checks whether ]] .. id "obj" .. [[ is a valid file handle. Returns the string ]] .. code "\"file\"" .. [[ if ]] .. id "obj" .. [[ is an open file handle, ]] .. code "\"closed file\"" .. [[ if ]] .. id "obj" .. [[ is a closed file handle, or ]] .. code "nil" .. [[ if ]] .. id "obj" .. [[ is not a file handle. ]]     },     
["io.write"] = {
         title = "io.write  (...)",
    body = [[Equivalent to ]] .. code "io.output():write(...)" .. [[.

]]     },     
["file:close"] = {
         title = "file:close  ()",
    body = [[Closes ]] .. id "file" .. [[. Note that files are automatically closed when their handles are garbage collected, but that takes an unpredictable amount of time to happen.

When closing a file handle created with ]] .. id "io.popen" .. [[, ]] .. id "file:close" .. [[ returns the same values returned by ]] .. id "os.execute" .. [[. ]]     },     
["file:flush"] = {
         title = "file:flush  ()",
    body = [[Saves any written data to ]] .. id "file" .. [[. ]]     },     
["file:lines"] = {
         title = "file:lines  (...)",
    body = [[Returns an iterator function that, each time it is called, reads the file according to the given formats. When no format is given, uses ]] .. code "l" .. [[ as a default. As an example, the construction ]] .. code " for c in file:lines(1) do @rep{body" .. [[ end }
will iterate over all characters of the file, starting at the current position. Unlike ]] .. id "io.lines" .. [[, this function does not close the file when the loop ends.

In case of errors this function raises the error, instead of returning an error code. ]]     },     
["file:read"] = {
         title = "file:read  (...)",
    body = [[Reads the file ]] .. id "file" .. [[, according to the given formats, which specify what to read. For each format, the function returns a string or a number with the characters read, or ]] .. code "nil" .. [[ if it cannot read data with the specified format. (In this latter case, the function does not read subsequent formats.) When called without arguments, it uses a default format that reads the next line (see below).

The available formats are


・ ]] .. code "n" .. [[| reads a numeral and returns it as a float or an integer, following the lexical conventions of Lua. (The numeral may have leading spaces and a sign.) This format always reads the longest input sequence that is a valid prefix for a numeral; if that prefix does not form a valid numeral (e.g., an empty string, ]] .. code "0x" .. [[, or ]] .. code "3.4e-" .. [[), it is discarded and the format returns ]] .. code "nil" .. [[.

]] .. code "a" .. [[| reads the whole file, starting at the current position. On end of file, it returns the empty string.

]] .. code "l" .. [[| reads the next line skipping the end of line, returning ]] .. code "nil" .. [[ on end of file. This is the default format.

]] .. code "L" .. [[| reads the next line keeping the end-of-line character (if present), returning ]] .. code "nil" .. [[ on end of file. }

・ number| reads a string with up to this number of bytes, returning ]] .. code "nil" .. [[ on end of file. If ]] .. id "number" .. [[ is zero, it reads nothing and returns an empty string, or ]] .. code "nil" .. [[ on end of file. }

} The formats ]] .. code "l" .. [[ and ]] .. code "L" .. [[ should be used only for text files. ]]     },     
["file:seek"] = {
         title = "file:seek  ([whence [, offset]])",
    body = [[Sets and gets the file position, measured from the beginning of the file, to the position given by ]] .. id "offset" .. [[ plus a base specified by the string ]] .. id "whence" .. [[, as follows:

・ ]] .. code "set" .. [[| base is position 0 (beginning of the file);} ・ ]] .. code "cur" .. [[| base is current position;} ・ ]] .. code "end" .. [[| base is end of file;} }
In case of success, ]] .. id "seek" .. [[ returns the final file position, measured in bytes from the beginning of the file. If ]] .. id "seek" .. [[ fails, it returns ]] .. code "nil" .. [[, plus a string describing the error.

The default value for ]] .. id "whence" .. [[ is ]] .. code "\"cur\"" .. [[, and for ]] .. id "offset" .. [[ is 0. Therefore, the call ]] .. code "file:seek()" .. [[ returns the current file position, without changing it; the call ]] .. code "file:seek(\"set\")" .. [[ sets the position to the beginning of the file (and returns 0); and the call ]] .. code "file:seek(\"end\")" .. [[ sets the position to the end of the file, and returns its size. ]]     },     
["file:setvbuf"] = {
         title = "file:setvbuf  (mode [, size])",
    body = [[Sets the buffering mode for an output file. There are three available modes:


・ ]] .. code "no" .. [[| no buffering; the result of any output operation appears immediately.

]] .. code "full" .. [[| full buffering; output operation is performed only when the buffer is full or when you explicitly ]] .. code "flush" .. [[ the file ]] .. id "io.flush" .. [[.

]] .. code "line" .. [[| line buffering; output is buffered until a newline is output or there is any input from some special files (such as a terminal device). }

} For the last two cases, ]] .. id "size" .. [[ specifies the size of the buffer, in bytes. The default is an appropriate size. ]]     },     
["file:write"] = {
         title = "file:write  (...)",
    body = [[Writes the value of each of its arguments to ]] .. id "file" .. [[. The arguments must be strings or numbers.

In case of success, this function returns ]] .. id "file" .. [[. Otherwise it returns ]] .. code "nil" .. [[ plus a string describing the error.

} ]]     },     
["os.clock"] = {
         title = "os.clock  ()",
    body = [[Returns an approximation of the amount in seconds of CPU time used by the program. ]]     },     
["os.date"] = {
         title = "os.date  ([format [, time]])",
    body = [[Returns a string or a table containing date and time, formatted according to the given string ]] .. id "format" .. [[.

If the ]] .. id "time" .. [[ argument is present, this is the time to be formatted (see the ]] .. id "os.time" .. [[ function for a description of this value). Otherwise, ]] .. id "date" .. [[ formats the current time.

If ]] .. id "format" .. [[ starts with ]] .. code "!" .. [[, then the date is formatted in Coordinated Universal Time. After this optional character, if ]] .. id "format" .. [[ is the string ]] .. code "*t" .. [[, then ]] .. id "date" .. [[ returns a table with the following fields: ]] .. id "year" .. [[, ]] .. id "month" .. [[ (1@En{}12), ]] .. id "day" .. [[ (1@En{}31), ]] .. id "hour" .. [[ (0@En{}23), ]] .. id "min" .. [[ (0@En{}59), ]] .. id "sec" .. [[ (0@En{}61, due to leap seconds), ]] .. id "wday" .. [[ (weekday, 1@En{}7, Sunday is 1), ]] .. id "yday" .. [[ (day of the year, 1@En{}366), and ]] .. id "isdst" .. [[ (daylight saving flag, a boolean). This last field may be absent if the information is not available.

If ]] .. id "format" .. [[ is not ]] .. code "*t" .. [[, then ]] .. id "date" .. [[ returns the date as a string, formatted according to the same rules as the ]] .. id "strftime" .. [[.

When called without arguments, ]] .. id "date" .. [[ returns a reasonable date and time representation that depends on the host system and on the current locale. (More specifically, ]] .. code "os.date()" .. [[ is equivalent to ]] .. code "os.date(\"%c\")" .. [[.)

On non-POSIX systems, this function may be not thread safe because of its reliance on @CId{gmtime} and @CId{localtime}. ]]     },     
["os.difftime"] = {
         title = "os.difftime  (t2, t1)",
    body = [[Returns the difference, in seconds, from time ]] .. id "t1" .. [[ to time ]] .. id "t2" .. [[ (where the times are values returned by ]] .. id "os.time" .. [[). In POSIX, Windows, and some other systems, this value is exactly ]] .. id "t2" .. [[-]] .. id "t1" .. [[. ]]     },     
["os.execute"] = {
         title = "os.execute  ([command])",
    body = [[This function is equivalent to the ]] .. id "system" .. [[. It passes ]] .. id "command" .. [[ to be executed by an operating system shell. Its first result is ]] .. code "true" .. [[ if the command terminated successfully, or ]] .. code "nil" .. [[ otherwise. After this first result the function returns a string plus a number, as follows:


・ ]] .. code "exit" .. [[| the command terminated normally; the following number is the exit status of the command.

]] .. code "signal" .. [[| the command was terminated by a signal; the following number is the signal that terminated the command. }

}

When called without a ]] .. id "command" .. [[, ]] .. id "os.execute" .. [[ returns a boolean that is true if a shell is available. ]]     },     
["os.exit"] = {
         title = "os.exit  ([code [, close]])",
    body = [[Calls the ]] .. id "exit" .. [[ to terminate the host program. If ]] .. id "code" .. [[ is ]] .. keyword "true" .. [[, the returned status is ]] .. id "EXIT_SUCCESS" .. [[; if ]] .. id "code" .. [[ is ]] .. keyword "false" .. [[, the returned status is ]] .. id "EXIT_FAILURE" .. [[; if ]] .. id "code" .. [[ is a number, the returned status is this number. The default value for ]] .. id "code" .. [[ is ]] .. keyword "true" .. [[.

If the optional second argument ]] .. id "close" .. [[ is true, closes the Lua state before exiting. ]]     },     
["os.getenv"] = {
         title = "os.getenv  (varname)",
    body = [[Returns the value of the process environment variable ]] .. id "varname" .. [[, or ]] .. code "nil" .. [[ if the variable is not defined. ]]     },     
["os.remove"] = {
         title = "os.remove  (filename)",
    body = [[Deletes the file (or empty directory, on POSIX systems) with the given name. If this function fails, it returns ]] .. code "nil" .. [[, plus a string describing the error and the error code. Otherwise, it returns true. ]]     },     
["os.rename"] = {
         title = "os.rename  (oldname, newname)",
    body = [[Renames the file or directory named ]] .. id "oldname" .. [[ to ]] .. id "newname" .. [[. If this function fails, it returns ]] .. code "nil" .. [[, plus a string describing the error and the error code. Otherwise, it returns true. ]]     },     
["os.setlocale"] = {
         title = "os.setlocale  (locale [, category])",
    body = [[Sets the current locale of the program. ]] .. id "locale" .. [[ is a system-dependent string specifying a locale; ]] .. id "category" .. [[ is an optional string describing which category to change: ]] .. code "\"all\"" .. [[, ]] .. code "\"collate\"" .. [[, ]] .. code "\"ctype\"" .. [[, ]] .. code "\"monetary\"" .. [[, ]] .. code "\"numeric\"" .. [[, or ]] .. code "\"time\"" .. [[; the default category is ]] .. code "\"all\"" .. [[. The function returns the name of the new locale, or ]] .. code "nil" .. [[ if the request cannot be honored.

If ]] .. id "locale" .. [[ is the empty string, the current locale is set to an implementation-defined native locale. If ]] .. id "locale" .. [[ is the string ]] .. code "C" .. [[, the current locale is set to the standard C locale.

When called with ]] .. code "nil" .. [[ as the first argument, this function only returns the name of the current locale for the given category.

This function may be not thread safe because of its reliance on @CId{setlocale}. ]]     },     
["os.time"] = {
         title = "os.time  ([table])",
    body = [[Returns the current time when called without arguments, or a time representing the local date and time specified by the given table. This table must have fields ]] .. id "year" .. [[, ]] .. id "month" .. [[, and ]] .. id "day" .. [[, and may have fields ]] .. id "hour" .. [[ (default is 12), ]] .. id "min" .. [[ (default is 0), ]] .. id "sec" .. [[ (default is 0), and ]] .. id "isdst" .. [[ (default is ]] .. code "nil" .. [[). Other fields are ignored. For a description of these fields, see the ]] .. id "os.date" .. [[ function.

When the function is called, the values in these fields do not need to be inside their valid ranges. For instance, if ]] .. id "sec" .. [[ is -10, it means 10 seconds before the time specified by the other fields; if ]] .. id "hour" .. [[ is 1000, it means 1000 hours after the time specified by the other fields.

The returned value is a number, whose meaning depends on your system. In POSIX, Windows, and some other systems, this number counts the number of seconds since some given start time (the epoch). In other systems, the meaning is not specified, and the number returned by ]] .. id "time" .. [[ can be used only as an argument to ]] .. id "os.date" .. [[ and ]] .. id "os.difftime" .. [[.

When called with a table, ]] .. id "os.time" .. [[ also normalizes all the fields documented in the ]] .. id "os.date" .. [[ function, so that they represent the same time as before the call but with values inside their valid ranges. ]]     },     
["os.tmpname"] = {
         title = "os.tmpname  ()",
    body = [[Returns a string with a file name that can be used for a temporary file. The file must be explicitly opened before its use and explicitly removed when no longer needed.

In POSIX systems, this function also creates a file with that name, to avoid security risks. (Someone else might create the file with wrong permissions in the time between getting the name and creating the file.) You still have to open the file to use it and to remove it (even if you do not use it).

When possible, you may prefer to use ]] .. id "io.tmpfile" .. [[, which automatically removes the file when the program ends.

} ]]     },     
["debug.debug"] = {
         title = "debug.debug  ()",
    body = [[Enters an interactive mode with the user, running each string that the user enters. Using simple commands and other debug facilities, the user can inspect global and local variables, change their values, evaluate expressions, and so on. A line containing only the word ]] .. id "cont" .. [[ finishes this function, so that the caller continues its execution.

Note that commands for ]] .. id "debug.debug" .. [[ are not lexically nested within any function and so have no direct access to local variables. ]]     },     
["debug.gethook"] = {
         title = "debug.gethook  ([thread])",
    body = [[Returns the current hook settings of the thread, as three values: the current hook function, the current hook mask, and the current hook count (as set by the ]] .. id "debug.sethook" .. [[ function). ]]     },     
["debug.getinfo"] = {
         title = "debug.getinfo  ([thread,] f [, what])",
    body = [[Returns a table with information about a function. You can give the function directly or you can give a number as the value of ]] .. id "f" .. [[, which means the function running at level ]] .. id "f" .. [[ of the call stack of the given thread: level 0 is the current function (]] .. id "getinfo" .. [[ itself); level 1 is the function that called ]] .. id "getinfo" .. [[ (except for tail calls, which do not count on the stack); and so on. If ]] .. id "f" .. [[ is a number larger than the number of active functions, then ]] .. id "getinfo" .. [[ returns ]] .. code "nil" .. [[.

The returned table can contain all the fields returned by ]] .. id "lua_getinfo" .. [[, with the string ]] .. id "what" .. [[ describing which fields to fill in. The default for ]] .. id "what" .. [[ is to get all information available, except the table of valid lines. If present, the option ]] .. code "f" .. [[ adds a field named ]] .. id "func" .. [[ with the function itself. If present, the option ]] .. code "L" .. [[ adds a field named ]] .. id "activelines" .. [[ with the table of valid lines.

For instance, the expression ]] .. code "debug.getinfo(1,\"n\").name" .. [[ returns a name for the current function, if a reasonable name can be found, and the expression ]] .. code "debug.getinfo(print)" .. [[ returns a table with all available information about the ]] .. id "print" .. [[ function. ]]     },     
["debug.getlocal"] = {
         title = "debug.getlocal  ([thread,] f, local)",
    body = [[This function returns the name and the value of the local variable with index ]] .. id "local" .. [[ of the function at level ]] .. id "f" .. [[ of the stack. This function accesses not only explicit local variables, but also parameters, temporaries, etc.

The first parameter or local variable has index 1, and so on, following the order that they are declared in the code, counting only the variables that are active in the current scope of the function. Negative indices refer to vararg arguments; ]] .. code "-1" .. [[ is the first vararg argument. The function returns ]] .. code "nil" .. [[ if there is no variable with the given index, and raises an error when called with a level out of range. (You can call ]] .. id "debug.getinfo" .. [[ to check whether the level is valid.)

Variable names starting with ]] .. code "(" .. [[ (open parenthesis) ]] .. code ")" .. [[ represent variables with no known names (internal variables such as loop control variables, and variables from chunks saved without debug information).

The parameter ]] .. id "f" .. [[ may also be a function. In that case, ]] .. id "getlocal" .. [[ returns only the name of function parameters. ]]     },     
["debug.getmetatable"] = {
         title = "debug.getmetatable  (value)",
    body = [[Returns the metatable of the given ]] .. id "value" .. [[ or ]] .. code "nil" .. [[ if it does not have a metatable. ]]     },     
["debug.getregistry"] = {
         title = "debug.getregistry  ()",
    body = [[Returns the registry table ]] .. id "registry" .. [[. ]]     },     
["debug.getupvalue"] = {
         title = "debug.getupvalue  (f, up)",
    body = [[This function returns the name and the value of the upvalue with index ]] .. id "up" .. [[ of the function ]] .. id "f" .. [[. The function returns ]] .. code "nil" .. [[ if there is no upvalue with the given index.

Variable names starting with ]] .. code "(" .. [[ (open parenthesis) ]] .. code ")" .. [[ represent variables with no known names (variables from chunks saved without debug information). ]]     },     
["debug.getuservalue"] = {
         title = "debug.getuservalue  (u, n)",
    body = [[Returns the ]] .. id "n" .. [[-th user value associated to the userdata ]] .. id "u" .. [[ plus a boolean, ]] .. code "false" .. [[ if the userdata does not have that value. ]]     },     
["debug.sethook"] = {
         title = "debug.sethook  ([thread,] hook, mask [, count])",
    body = [[Sets the given function as a hook. The string ]] .. id "mask" .. [[ and the number ]] .. id "count" .. [[ describe when the hook will be called. The string mask may have any combination of the following characters, with the given meaning:

・ ]] .. code "c" .. [[| the hook is called every time Lua calls a function;} ・ ]] .. code "r" .. [[| the hook is called every time Lua returns from a function;} ・ ]] .. code "l" .. [[| the hook is called every time Lua enters a new line of code.} }
Moreover, with a ]] .. id "count" .. [[ different from zero, the hook is called also after every ]] .. id "count" .. [[ instructions.

When called without arguments, ]] .. id "debug.sethook" .. [[ turns off the hook.

When the hook is called, its first parameter is a string describing the event that has triggered its call: ]] .. code "\"call\"" .. [[ (or ]] .. code "\"tail call\"" .. [[), ]] .. code "\"return\"" .. [[, ]] .. code "\"line\"" .. [[, and ]] .. code "\"count\"" .. [[. For line events, the hook also gets the new line number as its second parameter. Inside a hook, you can call ]] .. id "getinfo" .. [[ with level 2 to get more information about the running function (level 0 is the ]] .. id "getinfo" .. [[ function, and level 1 is the hook function). ]]     },     
["debug.setlocal"] = {
         title = "debug.setlocal  ([thread,] level, local, value)",
    body = [[This function assigns the value ]] .. id "value" .. [[ to the local variable with index ]] .. id "local" .. [[ of the function at level ]] .. id "level" .. [[ of the stack. The function returns ]] .. code "nil" .. [[ if there is no local variable with the given index, and raises an error when called with a ]] .. id "level" .. [[ out of range. (You can call ]] .. id "getinfo" .. [[ to check whether the level is valid.) Otherwise, it returns the name of the local variable.

See ]] .. id "debug.getlocal" .. [[ for more information about variable indices and names. ]]     },     
["debug.setmetatable"] = {
         title = "debug.setmetatable  (value, table)",
    body = [[Sets the metatable for the given ]] .. id "value" .. [[ to the given ]] .. id "table" .. [[ (which can be ]] .. code "nil" .. [[). Returns ]] .. id "value" .. [[. ]]     },     

["debug.setupvalue"] = {

         title = "debug.setupvalue  (f, up, value)",
    body = [[This function assigns the value ]] .. id "value" .. [[ to the upvalue with index ]] .. id "up" .. [[ of the function ]] .. id "f" .. [[. The function returns ]] .. code "nil" .. [[ if there is no upvalue with the given index. Otherwise, it returns the name of the upvalue. ]]     },     
["debug.setuservalue"] = {
         title = "debug.setuservalue  (udata, value, n)",
    body = [[Sets the given ]] .. id "value" .. [[ as the ]] .. id "n" .. [[-th user value associated to the given ]] .. id "udata" .. [[. ]] .. id "udata" .. [[ must be a full userdata.

Returns ]] .. id "udata" .. [[, or ]] .. code "nil" .. [[ if the userdata does not have that value. ]]     },     
["debug.traceback"] = {
         title = "debug.traceback  ([thread,] [message [, level]])",
    body = [[If ]] .. id "message" .. [[ is present but is neither a string nor ]] .. code "nil" .. [[, this function returns ]] .. id "message" .. [[ without further processing. Otherwise, it returns a string with a traceback of the call stack. The optional ]] .. id "message" .. [[ string is appended at the beginning of the traceback. An optional ]] .. id "level" .. [[ number tells at which level to start the traceback (default is 1, the function calling ]] .. id "traceback" .. [[). ]]     },     
["debug.upvalueid"] = {
         title = "debug.upvalueid  (f, n)",
    body = [[Returns a unique identifier (as a light userdata) for the upvalue numbered ]] .. id "n" .. [[ from the given function.

These unique identifiers allow a program to check whether different closures share upvalues. Lua closures that share an upvalue (that is, that access a same external local variable) will return identical ids for those upvalue indices. ]]     },     
["debug.upvaluejoin"] = {
         title = "debug.upvaluejoin  (f1, n1, f2, n2)",
    body = [[ Make the ]] .. id "n1" .. [[-th upvalue of the Lua closure ]] .. id "f1" .. [[ refer to the ]] .. id "n2" .. [[-th upvalue of the Lua closure ]] .. id "f2" .. [[.]]     }

}
