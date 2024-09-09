# GoldenZ-Executor
This is a new roblox executor that's has a powerful execute, and a backdoor scanner!
- NOTE: GoldenZ executor injects his own library on the global environment on Roblox!

# get the library:
```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/noob-scripts/GoldenZ-Executor/master/GoldenZ_Library.luau.lua", true), "goldenz")()
```

# Documentation
- "goldenz": this is the library of the Executor.
- the goldenz library is similar to Synapse X Library (syn)
- aliases: goldenz_backup (syn_backup)

```lua
getgenv().goldenz = {
    crypt = {
        base64 = {}
    }
} -- creates the library!
```
after that, the library is added to the global environment (getgenv() or getfenv(0))

## goldenz.request

```lua
local MyRequest = goldenz.request({
    Url = "https://httpbin.org/post", -- the Url is for make the request in that url.
    Method = "POST", -- set the method you want in it.
    Headers = {
        ["Content-Type"] = "application/json" -- sets the Content-Type you want to make your request.
    } -- Can be a table.
    Body = game:GetService("HttpService"):JSONEncode({GoldenZ = "Executor"}) -- you can put anything in Body, being string, table and more...
})
```
## GoldenZ Headers:
- User-Agent: "goldenz/beta"
- GoldenZ-Fingerprint: returns your player HWID
- GoldenZ-User-Identifier: "<???>" the reason why it's "<???>" instead of a User Identifier, it's because I don't have any idea of how can i make that.

## goldenz.protect_gui

```lua
local MyGui = Instance.new("ScreenGui")
MyGui.Name = "MyGui"
if goldenz then
    goldenz.protect_gui(MyGui) -- It needs to be a Instance and his ClassName needs to be a ScreenGui.
end
MyGui.Parent = cloneref(game:GetService("CoreGui"))
```
## purpose:
- protects a gui to prevent being detected by: Name, Parent, and etc...
- protect all instances inside of a gui too.

## goldenz.unprotect_gui

```lua
-- this just unprotect the gui, doing the opposite of what goldenz.protect_gui does.
if goldenz then
    goldenz.unprotect_gui(MyGui)
end
```

## goldenz.is_beta

```lua
-- goldenz.is_beta will return true if it is
print(goldenz.is_beta()) -- this should print true.
```

## goldenz.queue_on_teleport

```lua
-- this function queues a script on teleport.
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(S)
    if S == Enum.TeleportState.Started then
        goldenz.queue_on_teleport("print('hello world!')")
    end
end)
```

## goldenz.secure_call
- aliases: goldenz.emulate_call

```lua
-- goldenz.secure_call(func, env, ...)
-- runs a function into a script environment, here's a example
-- goldenz.secure_call(function, script, arguments of 'function')
-- Valid ClassNames: LocalScript or ModuleScript.
-- the environment uses getsenv to get the Script environment

local AnyModule = require(game:GetService("ReplicatedStorage").AnyModule)
local Environment = script -- runs a function into a executor environment (the LocalScript that's scripts runs in execute.)
goldenz.secure_call(AnyModule.DoSomething --[[function]], Environment --[[A LocalScript]], "hello world!")
```

## goldenz.save_instance

```lua
goldenz.save_instance() -- save the game
```

## crypt/base64 section

## goldenz.crypt.base64.encode
- encode a string into a base64 encoded string

## goldenz.crypt.base64.decode
- decode a base64 encoded string into a readable string again.

## goldenz.crypt.generate_bytes
- generate bytes, returning using goldenz.crypt.base64.encode.

## goldenz_ section
- another GoldenZ library for get environments

## goldenz_getgenv
- returns the global environment.
```lua
goldenz_getgenv().SomeValue = true -- now SomeValue will be added to the global environment.
```

## goldenz_getreg
- returns Roblox Lua Registry

```lua
for i, v in next, goldenz_getreg() do
    print(tostring(i) .. " = " .. tostring(v))
end
```

## goldenz_getsenv
- returns a script environment (only for LocalScripts or ModuleScripts)

```lua
local Script = game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule -- get the environment of a ModuleScript for example.
print(goldenz_getsenv(Script))
```

## goldenz_getmenv
- returns a ModuleScript environment (it's getsenv but only for Modules)

```lua
local Script = game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule -- get the environment of a ModuleScript for example.
print(goldenz_getmenv(Script))
```

## goldenz_getgc
- returns a copy of the garbage collector

```lua
-- arguments: 1 (include tables)
-- if include tables is set to true, the copy of the Garbage collector will return tables too.
for i, v in pairs(goldenz_getgc(true))
    print(i, v)
end
```

## goldenz_getrenv
- return the Roblox Environment.

```lua
for i, v in pairs(goldenz_getrenv()) do
    print(i, v)
end
```
