getgenv().goldenz = {
    crypt = {
        base64 = {}
    }
}
getgenv().funcs_storage = {}
getgenv().goldenz_backup = goldenz -- aliase
getgenv().goldenz_hwid = "goldenz-" .. tostring((function()
    return #game.Players.LocalPlayer.Name:reverse() .. game.Players.LocalPlayer.UserId:reverse() .. "==" .. game.Players.LocalPlayer.CharacterAppearanceId:reverse() .. "==^@@" .. game.Players.LocalPlayer.Name .. "@@^==" .. #game.Players.LocalPlayer.DisplayName:reverse()
end)() .. "<\@>")

goldenz.request = function(Options)
    assert(type(Options) == "table", 'Invalid argument #1 to "goldenz.request" (string expected, got ' .. typeof(Options) .. ')')
    local HttpService = game:GetService("HttpService")
    if type(Options) ~= "table" then
        error('invalid argument #1 (table expected, got ' .. typeof(Options) .. ')')
    end

    local Timeout, Done, Time = 5, false, 0
    local Return = {
        Success = false,
        StatusCode = 200,
        StatusMessage = 'Request Timeout',
        Headers = {},
        Body = ''
    }
    local function Callback(Success, Response)
        Done = true
        Return.Success = Success
        Return.StatusCode = Response.StatusCode
        Return.StatusMessage = Response.StatusMessage
        Return.Headers = Response.Headers
        Return.Body = Response.Body
    end
    
    HttpService:RequestInternal(Options):Start(Callback)
        
    while not Done and Time < Timeout do
        Time = Time + .1
        task.wait(.1)
    end

    table.insert(Return.Headers, {
        ["User-Agent"] = "goldenz/beta",
        ["GoldenZ-User-Identifier"] = goldenz_hwid,
        ["GoldenZ-Fingerprint"] = "<???>"
    })
    
    return Return
end

goldenz.protect_gui = function(a)
    assert(a.ClassName == "ScreenGui", "bad argument #1 (ScreenGui expected, got " .. a.ClassName .. ")")

    table.insert(protected_guis, a)
    for _, v in next, a:GetDescendants() do
        table.insert(protected_guis, v)
    end
    local c; c = a.DescendantAdded:Connect(function(d)
        if table.find(protected_guis, a) then
            table.insert(protected_guis, d)
        else
            c:Disconnect()
        end
    end)
end

goldenz.unprotect_gui = function(a)
    assert(a.ClassName == "ScreenGui", "bad argument #1 (ScreenGui expected, got " .. a.ClassName .. ")")
    assert(table.find(protected_guis, a), "bad argument #1 to 'unprotect_gui' (" .. a.Name .. " is not protected.")")

    table.remove(protected_guis, table.find(protected_guis, a))
        for _, v in next, a:GetDescendants() do
            if table.find(protected_guis, v) then
                table.remove(protected_guis, table.find(protected_guis, v))
            end
        end
    end
end

goldenz.is_beta = function() return true end

goldenz.queue_on_teleport = function(Script)
    assert(type(Script) == "string", "Invalid argument #1 (string expected, got " .. typeof(Script) .. ")")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")

    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == Players.LocalPlayer then
            warn("Teleport failed: " .. teleportResult.Name .. " - " .. errorMessage)
        end
    end)
    
    TeleportService.TeleportStateChanged:Connect(function(player, teleportState)
        if player == Players.LocalPlayer and teleportState == Enum.TeleportState.Started then
           TeleportService:SetTeleportData({GoldenZ_Script_Queue = Script})
        end
    end)
end

goldenz.secure_call = function(func, env, ...)
    assert(typeof(func) == "function", "bad argument to #1 to 'goldenz.secure_call' (function expected, got "..typeof(func)..")")
    assert(typeof(env) == "Instance", "bad argument to #2 to 'goldenz.secure_call' (Instance expected, got "..typeof(env)..")")
    assert(env.ClassName == "LocalScript" or env.ClassName == "ModuleScript", "bad argument to #2 to 'goldenz.secure_call' (LocalScript or ModuleScript expected, got "..env.ClassName..")")
    local _, fenv = xpcall(function()
		return getsenv(env)
	end, function()
		return getfenv(func)
	end)
    return coroutine.wrap(function(...)
        setfenv(0, getsenv(env))
        setfenv(1, getsenv(env))
        return func(...)
    end)(...)
end

goldenz.emulate_call = goldenz.secure_call

goldenz.save_instance = function()
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
        SSI = "saveinstance",
    }
    local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
    local SaveOptions = {
	    ReadMe = true,
        IsolatePlayers = true,
        FilePath = string.format("%d", tick())
    }
    synsaveinstance(SaveOptions)
end

-- crypt section
goldenz.crypt.base64.encode = function(data)
    local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2^i - b % 2^(i - 1) > 0 and '1' or '0')
        end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2^(6 - i) or 0)
        end
        return letters:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

goldenz.crypt.base64.decode = function(data)
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    data = string.gsub(data, '[^' .. b .. '=]', '')

    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)        
    if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
        end
        return string.char(c)
    end))
end

goldenz.crypt.generate_bytes = function(len)
	assert(type(len) == "number", "invalid argument #1 'goldenz.generate_bytes' (must be a number, got " .. typeof(len) .. ")")
	local key = ''
	local Valid = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    for _ = 1, len do
        local n = math.random(1, #Valid)
        key = key .. string.sub(Valid, n, n)
    end
	return goldenz.crypt.base64.encode(key)
end

getgenv().goldenz_getgenv = function()
    return getfenv(0), _G, shared
end

getgenv().goldenz_getreg = function()
    return debug.getregistry()
end

getgenv().goldenz_getgc = function(include_tables)
    local gc_list_copy = {}
    local function addObject(obj)
        if include_tables or type(obj) ~= "table" then
            table.insert(gc_list_copy, obj)
        end
    end

    for i = 1, math.huge do
        local obj = debug.getupvalue(debug.getinfo(1).func, i)
        if obj == nil then break end
        addObject(obj)
    end

    return gc_list_copy
end

getgenv().goldenz_getsenv = function(instance)
    assert(typeof(instance) == "instance", "Invalid argument #1 (instance expected, got " .. typeof(instance) .. ")")
    assert(instance.ClassName == "LocalScript" or instance.ClassName == "ModuleScript", "Invalid Argument #1 (LocalScript or ModuleScript Expected, got " .. instance.ClassName .. ")")
 
    for _, v in next, goldenz_getreg() do
        if type(v) == "function" then
            if getfenv(v).script == instance then
                return getfenv(v)
            end
        end
    end
end

getgenv().goldenz_getmenv = function(instance)
    assert(typeof(instance) == "Instance", "Invalid argument #1 (Instance expected, got " .. typeof(instance) .. ")")
    assert(instance.ClassName == "ModuleScript", "Invalid Argument #1 (ModuleScript expected, got " .. instance.ClassName .. ")")

    for _, v in next, goldenz_getreg() do
        if type(v) == "function" then
            if getfenv(v).script == instance then
                return env
            end
        end
    end
end

getgenv().goldenz_getrenv = function()
    return {
        print, warn, error, assert, collectgarbage, load, require, select, tonumber, tostring, type, xpcall, pairs, next, ipairs,
        newproxy, rawequal, rawget, rawset, rawlen, setmetatable, PluginManager,
        coroutine.create, coroutine.resume, coroutine.running, coroutine.status, coroutine.wrap, coroutine.yield,
        bit32.arshift, bit32.band, bit32.bnot, bit32.bor, bit32.btest, bit32.extract, bit32.lshift, bit32.replace, bit32.rshift, bit32.xor,
        math.abs, math.acos, math.asin, math.atan, math.atan2, math.ceil, math.cos, math.cosh, math.deg, math.exp, math.floor, math.fmod, math.frexp, math.ldexp, math.log, math.log10, math.max, math.min, math.modf, math.pow, math.rad, math.random, math.randomseed, math.sin, math.sinh, math.sqrt, math.tan, math.tanh,
        string.byte, string.char, string.find, string.format, 
        string.gmatch, string.gsub, string.len, string.lower, 
        string.match, string.pack, string.packsize, string.rep, 
        string.reverse, string.sub, string.unpack, string.upper,
        table.concat, table.insert, table.pack, table.remove, table.sort, table.unpack,
        utf8.char, utf8.charpattern, utf8.codepoint, utf8.codes, utf8.len, utf8.nfdnormalize, utf8.nfcnormalize,
        os.clock, os.date, os.difftime, os.time,
        delay, elapsedTime, require, spawn, tick, time, typeof, 
        UserSettings, version, wait,
        task.defer, task.delay, task.spawn, task.wait,
        debug.traceback, debug.profilebegin, debug.profileend
    }
end

setreadonly(goldenz, true)

return goldenz
