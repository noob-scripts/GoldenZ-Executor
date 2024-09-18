getgenv().goldenz = {
    crypt = {
        base64 = {},
        lz4 = {},
        hex = {}
    }
}
local protected_guis = {}
local oldnc; oldnc = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    if not checkcaller() and args[1] == game and getnamecallmethod() == "FindFirstChild" and args[3] == true then
	for _,v in next, protected_guis do
	    if v.Name == args[2] then
		return nil
	    end
        end
    end
    return oldnc(...)
end)

getgenv().goldenz_backup = goldenz -- aliase
getgenv().goldenz_hwid = "goldenz-" .. tostring((function()
    return #game.Players.LocalPlayer.Name:reverse() .. game.Players.LocalPlayer.UserId:reverse() .. "==" .. game.Players.LocalPlayer.CharacterAppearanceId:reverse() .. "==^@@" .. game.Players.LocalPlayer.Name .. "@@^==" .. #game.Players.LocalPlayer.DisplayName:reverse()
end)())

goldenz.request = function(Options: table)
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
        Cookies = {},
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

goldenz.protect_gui = function(a: ScreenGui)
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

goldenz.unprotect_gui = function(a: ScreenGui)
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

goldenz.queue_on_teleport = function(Script: string)
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

goldenz.secure_call = function(func: function, env: (LocalScript | ModuleScript), ...)
    assert(typeof(func) == "function", "bad argument to #1 to 'goldenz.secure_call' (function expected, got "..typeof(func)..")")
    assert(typeof(env) == "Instance", "bad argument to #2 to 'goldenz.secure_call' (Instance expected, got "..typeof(env)..")")
    assert(env.ClassName == "LocalScript" or env.ClassName == "ModuleScript", "bad argument to #2 to 'goldenz.secure_call' (LocalScript or ModuleScript expected, got "..env.ClassName..")")
    local senv, fenv = xpcall(function()
        return goldenz_getsenv(env)
    end, function()
        return getfenv(func)
    end)
    return coroutine.wrap(function(...)
        setfenv(0, senv)
        setfenv(1, senv)
        local c = clonefunction(func)
        setfenv(c, fenv)
        
        return c(...)
    end)(...)
end

goldenz.emulate_call = goldenz.secure_call

goldenz.trampoline_call = function(target_func: function, call_stack: table, thread_options: table, ...)
    local current_call_stack = {}
    for i, entry in ipairs(call_stack) do
        current_call_stack[i] = {
            currentline = entry.currentline or 0,
            env = entry.env or getfenv(target_func),
            source = entry.source or "unknown",
            name = entry.name or "anonymous",
            numparams = entry.numparams or debug.getinfo(target_func, "u").nparams,
            is_vararg = entry.is_vararg or debug.getinfo(target_func, "u").isvararg,
            func = entry.func or target_func
        }
    end

    local script = thread_options.script or nil
    local identity = thread_options.identity or nil
    local env = thread_options.env or getfenv(target_func)
    local parent_thread = thread_options.thread or nil

    if env then
        setfenv(target_func, env)
    end

    local A, B = clonefunction(target_func)(...)
    
    if not A then
        return nil
    end

    return B
end

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
goldenz.crypt.base64.encode = function(data: string)
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

goldenz.crypt.base64.decode = function(data: string)
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

goldenz.crypt.generate_bytes = function(len: string)
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

getgenv().goldenz_getgc = function(include_tables: boolean)
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

getgenv().goldenz_getsenv = function(instance: (LocalScript | ModuleScript))
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

getgenv().goldenz_getmenv = function(instance: ModuleScript)
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

-- made by metatablecat 2022
-- NOT MADE BY ME
-- source: https://gist.github.com/metatablecat/92345df2fd6d450da288c28272555faf

type Streamer = {
	Offset: number,
	Source: string,
	Length: number,
	IsFinished: boolean,
	LastUnreadBytes: number,

	read: (Streamer, len: number?, shiftOffset: boolean?) -> string,
	seek: (Streamer, len: number) -> (),
	append: (Streamer, newData: string) -> (),
	toEnd: (Streamer) -> ()
}

type BlockData = {
	[number]: {
		Literal: string,
		LiteralLength: number,
		MatchOffset: number?,
		MatchLength: number?
	}
}

local function plainFind(str, pat)
	return string.find(str, pat, 0, true)
end

local function streamer(str): Streamer
	local Stream = {}
	Stream.Offset = 0
	Stream.Source = str
	Stream.Length = string.len(str)
	Stream.IsFinished = false	
	Stream.LastUnreadBytes = 0

	function Stream.read(self: Streamer, len: number?, shift: boolean?): string
		local len = len or 1
		local shift = if shift ~= nil then shift else true
		local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)

		local dataLength = string.len(dat)
		local unreadBytes = len - dataLength

		if shift then
			self:seek(len)
		end

		self.LastUnreadBytes = unreadBytes
		return dat
	end

	function Stream.seek(self: Streamer, len: number)
		local len = len or 1

		self.Offset = math.clamp(self.Offset + len, 0, self.Length)
		self.IsFinished = self.Offset >= self.Length
	end

	function Stream.append(self: Streamer, newData: string)
		-- adds new data to the end of a stream
		self.Source ..= newData
		self.Length = string.len(self.Source)
		self:seek(0) --hacky but forces a recalculation of the isFinished flag
	end

	function Stream.toEnd(self: Streamer)
		self:seek(self.Length)
	end

	return Stream
end

goldenz.crypt.lz4.compress = function(str: string): string
	local blocks: BlockData = {}
	local iostream = streamer(str)

	if iostream.Length > 12 then
		local firstFour = iostream:read(4)

		local processed = firstFour
		local lit = firstFour
		local match = ""
		local LiteralPushValue = ""
		local pushToLiteral = true

		repeat
			pushToLiteral = true
			local nextByte = iostream:read()

			if plainFind(processed, nextByte) then
				local next3 = iostream:read(3, false)

				if string.len(next3) < 3 then
					--push bytes to literal block then break
					LiteralPushValue = nextByte .. next3
					iostream:seek(3)
				else
					match = nextByte .. next3

					local matchPos = plainFind(processed, match)
					if matchPos then
						iostream:seek(3)
						repeat
							local nextMatchByte = iostream:read(1, false)
							local newResult = match .. nextMatchByte

							local repos = plainFind(processed, newResult) 
							if repos then
								match = newResult
								matchPos = repos
								iostream:seek(1)
							end
						until not plainFind(processed, newResult) or iostream.IsFinished

						local matchLen = string.len(match)
						local pushMatch = true

						if iostream.Length - iostream.Offset <= 5 then
							LiteralPushValue = match
							pushMatch = false
							--better safe here, dont bother pushing to match ever
						end

						if pushMatch then
							pushToLiteral = false

							-- gets the position from the end of processed, then slaps it onto processed
							local realPosition = string.len(processed) - matchPos
							processed = processed .. match

							table.insert(blocks, {
								Literal = lit,
								LiteralLength = string.len(lit),
								MatchOffset = realPosition + 1,
								MatchLength = matchLen,
							})
							lit = ""
						end
					else
						LiteralPushValue = nextByte
					end
				end
			else
				LiteralPushValue = nextByte
			end

			if pushToLiteral then
				lit = lit .. LiteralPushValue
				processed = processed .. nextByte
			end
		until iostream.IsFinished
		table.insert(blocks, {
			Literal = lit,
			LiteralLength = string.len(lit)
		})
	else
		local str = iostream.Source
		blocks[1] = {
			Literal = str,
			LiteralLength = string.len(str)
		}
	end

	-- generate the output chunk
	-- %s is for adding header
	local output = string.rep("\x00", 4)
	local function write(char)
		output = output .. char
	end
	-- begin working through chunks
	for chunkNum, chunk in blocks do
		local litLen = chunk.LiteralLength
		local matLen = (chunk.MatchLength or 4) - 4

		-- create token
		local tokenLit = math.clamp(litLen, 0, 15)
		local tokenMat = math.clamp(matLen, 0, 15)

		local token = bit32.lshift(tokenLit, 4) + tokenMat
		write(string.pack("<I1", token))

		if litLen >= 15 then
			litLen = litLen - 15
			--begin packing extra bytes
			repeat
				local nextToken = math.clamp(litLen, 0, 0xFF)
				write(string.pack("<I1", nextToken))
				if nextToken == 0xFF then
					litLen = litLen - 255
				end
			until nextToken < 0xFF
		end

		-- push raw lit data
		write(chunk.Literal)

		if chunkNum ~= #blocks then
			-- push offset as u16
			write(string.pack("<I2", chunk.MatchOffset))

			-- pack extra match bytes
			if matLen >= 15 then
				matLen = matLen - 15

				repeat
					local nextToken = math.clamp(matLen, 0, 0xFF)
					write(string.pack("<I1", nextToken))
					if nextToken == 0xFF then
						matLen = matLen - 255
					end
				until nextToken < 0xFF
			end
		end
	end
	--append chunks
	local compLen = string.len(output) - 4
	local decompLen = iostream.Length

	return string.pack("<I4", compLen) .. string.pack("<I4", decompLen) .. output
end

goldenz.crypt.lz4.decompress = function(lz4data: string): string
	local inputStream = streamer(lz4data)

	local compressedLen = string.unpack("<I4", inputStream:read(4))
	local decompressedLen = string.unpack("<I4", inputStream:read(4))
	local reserved = string.unpack("<I4", inputStream:read(4))

	if compressedLen == 0 then
		return inputStream:read(decompressedLen)
	end

	local outputStream = streamer("")

	repeat
		local token = string.byte(inputStream:read())
		local litLen = bit32.rshift(token, 4)
		local matLen = bit32.band(token, 15) + 4

		if litLen >= 15 then
			repeat
				local nextByte = string.byte(inputStream:read())
				litLen += nextByte
			until nextByte ~= 0xFF
		end

		local literal = inputStream:read(litLen)
		outputStream:append(literal)
		outputStream:toEnd()
		if outputStream.Length < decompressedLen then
			--match
			local offset = string.unpack("<I2", inputStream:read(2))
			if matLen >= 19 then
				repeat
					local nextByte = string.byte(inputStream:read())
					matLen += nextByte
				until nextByte ~= 0xFF
			end

			outputStream:seek(-offset)
			local pos = outputStream.Offset
			local match = outputStream:read(matLen)
			local unreadBytes = outputStream.LastUnreadBytes
			local extra
			if unreadBytes then
				repeat
					outputStream.Offset = pos
					extra = outputStream:read(unreadBytes)
					unreadBytes = outputStream.LastUnreadBytes
					match ..= extra
				until unreadBytes <= 0
			end

			outputStream:append(match)
			outputStream:toEnd()
		end

	until outputStream.Length >= decompressedLen

	return outputStream.Source
end

goldenz.crypt.hex.encode = function(input: string)
    return (input:gsub(".", function(m)
        return string.format("%02X", string.byte(m))
    end))
end

goldenz.crypt.hex.decode = function(input: string)
    return (input:gsub("..", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

getgenv().is_goldenz_function = function(f: function)
    for i, v in pairs(goldenz) do
        if (v == f) then
            return true
        elseif type(v) == "table" then
            for i, v in pairs(v) do
                if (v == f) then
                    return true
                end
            end
        elseif debug.getinfo(f).name:find("goldenz") then
            return true
        end
    end

    return false
end

setreadonly(goldenz, true)
