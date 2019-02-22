local colors = require "term.colors"

local function code(str)
    return colors.yellow .. str .. colors.white
end

-- luacheck: ignore 631
return {
    ["quit"] = {
        title = "quit ()",
        body = "Leave Croissant."
    },
    ["table.concat"] = {
        title = "table.concat (list [, sep [, i [, j]]])",
        body  = "Given a list where all elements are strings or numbers, returns the "
        .. code "string list[i]..sep..list[i+1] ··· sep..list[j]"
        .. ". The default value for " .. code "sep" .. " is the empty string, the default for "
        .. code "i" .. " is " .. code "1"
        ..", and the default for " .. code "j" .. " is " .. code "#list"
        .. ". If i is greater than " .. code "j" .. ", returns the empty string."
    }
}
