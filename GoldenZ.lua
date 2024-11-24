if not game:IsLoaded() then
    error("[GoldenZ Output]: \"Game is not loaded.\" (please wait...)", 2);
    return nil
end

local GoldenZ = {}
GoldenZ.__index = GoldenZ

GoldenZ["CoreGui"] = cloneref(game:GetService("CoreGui"));

GoldenZ["Folder"] = Instance.new("Folder", GoldenZ["CoreGui"]);
GoldenZ["Folder"]["Name"] = string.rep("\0", math.random(1, 10));

GoldenZ["ActorProtector"] = Instance.new("Actor", GoldenZ["Folder"]);
GoldenZ["ActorProtector"]["Name"] = string.rep("\0", math.random(1, 10));

GoldenZ["ScreenGUI"] = Instance.new("ScreenGui", GoldenZ["ActorProtector"]);
GoldenZ["ScreenGUI"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["ScreenGUI"]["ResetOnSpawn"] = false;
if syn then
    syn.protect_gui(GoldenZ["ScreenGUI"])
end;
GoldenZ["ScreenGUI"]["Enabled"] = true;
GoldenZ["ScreenGUI"]["Parent"] = GoldenZ["Folder"];

task.wait(0.1)

GoldenZ["Protector"] = Instance.new("LocalScript", GoldenZ["ScreenGUI"]);
GoldenZ["Protector"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Protector"]["Source"] = [===[
-- \0
local s = script.Parent:Clone()
local oldPar = script.Parent

script.Parent:Destroy()
s.Parent = oldPar]===];
GoldenZ["Protector"]["LinkedSource"] = GoldenZ["Protector"]["Source"];

GoldenZ["Bool"] = Instance.new("BoolValue", GoldenZ["ScreenGUI"]);
GoldenZ["Bool"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Bool"]["Value"] = false

GoldenZ["Main"] = Instance.new("Frame", GoldenZ["ScreenGUI"]);
GoldenZ["Main"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Main"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Main"]["Position"] = UDim2.new(0.5, 1, 0.5, 1);
GoldenZ["Main"]["Size"] = UDim2.new(0, 646, 0, 283);
GoldenZ["Main"]["Active"] = true;
GoldenZ["Main"]["Selectable"] = true;
GoldenZ["Main"]["Draggable"] = true;
GoldenZ["Main"]["BackgroundColor3"] = Color3.new(0.2, 0.2, 0.2);
GoldenZ["Main"]["BorderSizePixel"] = 0;
GoldenZ["Main"]["ZIndex"] = 1;

GoldenZ["Gradient"] = Instance.new("UIGradient", GoldenZ["Main"]);
GoldenZ["Gradient"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Gradient"]["Rotation"] = 90;
GoldenZ["Gradient"]["Color"] = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(51, 51, 51)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(51, 51, 51)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
});

GoldenZ["UiScale"] = Instance.new("UIScale", GoldenZ["Main"])
GoldenZ["UiScale"]["Name"] = string.rep("\0", math.random(1, 10))
GoldenZ["UiScale"]["Scale"] = 0

GoldenZ["Draggable-Frame"] = Instance.new("LocalScript", GoldenZ["Main"]);
GoldenZ["Draggable-Frame"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Draggable-Frame"]["Source"] = [===[
-- \0
local UserInputService = game:GetService("UserInputService")
local frame = script.Parent
local dragging
local dragInput
local dragStart
local startPos

frame.Selectable = true
frame.Active = true
frame.Draggable = true
local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
end)
frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
end)]===];
GoldenZ["Draggable-Frame"]["LinkedSource"] = GoldenZ["Draggable-Frame"]["Source"];

GoldenZ["ScrollingFrame"] = Instance.new("ScrollingFrame", GoldenZ["Main"]);
GoldenZ["ScrollingFrame"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["ScrollingFrame"]["ScrollingEnabled"] = true;
GoldenZ["ScrollingFrame"]["Size"] = UDim2.new(0, 486, 0, 194);
GoldenZ["ScrollingFrame"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["ScrollingFrame"]["Position"] = UDim2.new(0, 260, 0.4, 0); -- reference: {0, 260}, {0, 0}
GoldenZ["ScrollingFrame"]["ScrollingDirection"] = Enum.ScrollingDirection.XY;
GoldenZ["ScrollingFrame"]["ScrollBarThickness"] = 0;
GoldenZ["ScrollingFrame"]["BackgroundColor3"] = Color3.new(0.25, 0.25, 0.25);
GoldenZ["ScrollingFrame"]["BorderSizePixel"] = 0;
GoldenZ["ScrollingFrame"]["CanvasSize"] = UDim2.new(0, 0, 0, 500);

GoldenZ["BetterScroll"] = Instance.new("LocalScript", GoldenZ["ScrollingFrame"]);
GoldenZ["BetterScroll"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["BetterScroll"]["Source"] = [===[
-- \0
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local scrollingFrame = script.Parent

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local startPosition = input.Position
        local initialPosition = scrollingFrame.Position

        local function onInputChanged(newInput)
            local delta = newInput.Position - startPosition
            scrollingFrame.Position = UDim2.new(initialPosition.X.Scale, initialPosition.X.Offset + delta.X, initialPosition.Y.Scale, initialPosition.Y.Offset + delta.Y)
        end

        local function onInputEnded()
            UserInputService.InputChanged:Disconnect(onInputChanged)
            UserInputService.InputEnded:Disconnect(onInputEnded)
        end

        UserInputService.InputChanged:Connect(onInputChanged)
        UserInputService.InputEnded:Connect(onInputEnded)
    end
end

scrollingFrame.InputBegan:Connect(onInputBegan)
]===]
GoldenZ["BetterScroll"]["LinkedSource"] = GoldenZ["BetterScroll"]["Source"]

GoldenZ["TextBox"] = Instance.new("TextBox", GoldenZ["ScrollingFrame"]);
GoldenZ["TextBox"]["ZIndex"] = 4;
GoldenZ["TextBox"]["BorderSizePixel"] = 0;
GoldenZ["TextBox"]["TextSize"] = 14;
GoldenZ["TextBox"]["TextXAlignment"] = Enum.TextXAlignment.Left;
GoldenZ["TextBox"]["TextYAlignment"] = Enum.TextYAlignment.Top;
GoldenZ["TextBox"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
GoldenZ["TextBox"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["TextBox"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
GoldenZ["TextBox"]["MultiLine"] = true;
GoldenZ["TextBox"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["TextBox"]["Size"] = UDim2.new(0, 486, 0, 194);
GoldenZ["TextBox"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["TextBox"]["Text"] = [[print("GoldenZ Executor"); -- GoldenZ Executor]];
GoldenZ["TextBox"]["Position"] = UDim2.new(0, 260, 0.2, 0);
GoldenZ["TextBox"]["AutomaticSize"] = Enum.AutomaticSize.Y;
GoldenZ["TextBox"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["TextBox"]["ClearTextOnFocus"] = false;

GoldenZ["ScriptHub"] = Instance.new("ScrollingFrame", GoldenZ["Main"]);
GoldenZ["ScriptHub"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["ScriptHub"]["Size"] = UDim2.new(0, 123, 0, 190); -- reference: {0, 123}, {0, 190}
GoldenZ["ScriptHub"]["Position"] = UDim2.new(0, 575, 0, 110); -- reference: {0, 575}, {0, 110}
GoldenZ["ScriptHub"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["ScriptHub"]["ScrollingDirection"] = Enum.ScrollingDirection.Y;
GoldenZ["ScriptHub"]["CanvasSize"] = UDim2.new(0, 0, 0, 500);

game:GetService("RunService").Heartbeat:Connect(function()
    GoldenZ["ScriptHub"]["CanvasPosition"] = Vector2.new(0, 0);
end);

GoldenZ["ScriptHub"]["ScrollBarThickness"] = 0;
GoldenZ["ScriptHub"]["BorderSizePixel"] = 0;
GoldenZ["ScriptHub"]["BackgroundColor3"] = Color3.new(0.25, 0.25, 0.25);

GoldenZ["Troll"] = Instance.new("TextLabel", GoldenZ["Main"]);
GoldenZ["Troll"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Troll"]["Text"] = [[No scripthub?]];
GoldenZ["Troll"]["Rotation"] = 90;
GoldenZ["Troll"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
GoldenZ["Troll"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Troll"]["Position"] = UDim2.new(0, 575, 0, 110);
GoldenZ["Troll"]["TextSize"] = 20;
GoldenZ["Troll"]["TextColor3"] = Color3.fromRGB(255, 255, 255);

GoldenZ["Exec"] = Instance.new("TextButton", GoldenZ["Main"]);
GoldenZ["Exec"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Exec"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Exec"]["Size"] = UDim2.new(0, 100, 0, 37); -- reference: {0, 100}, {0, 37}
GoldenZ["Exec"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
GoldenZ["Exec"]["BorderSizePixel"] = 0;
GoldenZ["Exec"]["Position"] = UDim2.new(0, 80, 0.88, 0); -- reference: {0, 80}, {0.88, 0}
GoldenZ["Exec"]["Text"] = [[execute]];
GoldenZ["Exec"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["Exec"]["TextSize"] = 9;

GoldenZ["ExecC"] = Instance.new("TextButton", GoldenZ["Main"]);
GoldenZ["ExecC"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["ExecC"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["ExecC"]["Size"] = UDim2.new(0, 100, 0, 37); -- reference: {0, 100}, {0, 37}
GoldenZ["ExecC"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
GoldenZ["ExecC"]["BorderSizePixel"] = 0;
GoldenZ["ExecC"]["Position"] = UDim2.new(0, 195, 0.88, 0); -- reference: {0, 80}, {0.88, 0}
GoldenZ["ExecC"]["Text"] = [[exec clipboard]];
GoldenZ["ExecC"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["ExecC"]["TextSize"] = 9;

GoldenZ["Copy"] = Instance.new("TextButton", GoldenZ["Main"]);
GoldenZ["Copy"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Copy"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Copy"]["Size"] = UDim2.new(0, 100, 0, 37); -- reference: {0, 100}, {0, 37}
GoldenZ["Copy"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
GoldenZ["Copy"]["BorderSizePixel"] = 0;
GoldenZ["Copy"]["Position"] = UDim2.new(0, 310, 0.88, 0); -- reference: {0, 310}, {0, 0}
GoldenZ["Copy"]["Text"] = [[copy]];
GoldenZ["Copy"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["Copy"]["TextSize"] = 9;

GoldenZ["Clear"] = Instance.new("TextButton", GoldenZ["Main"]);
GoldenZ["Clear"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Clear"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Clear"]["Size"] = UDim2.new(0, 100, 0, 37); -- reference: {0, 100}, {0, 37}
GoldenZ["Clear"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
GoldenZ["Clear"]["BorderSizePixel"] = 0;
GoldenZ["Clear"]["Position"] = UDim2.new(0, 423, 0.88, 0); -- reference: {0, 423}, {0, 0}
GoldenZ["Clear"]["Text"] = [[clear]];
GoldenZ["Clear"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["Clear"]["TextSize"] = 9;

GoldenZ["Console"] = Instance.new("TextButton", GoldenZ["Main"]);
GoldenZ["Console"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["Console"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["Console"]["Size"] = UDim2.new(0, 100, 0, 37); -- reference: {0, 100}, {0, 37}
GoldenZ["Console"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
GoldenZ["Console"]["BorderSizePixel"] = 0;
GoldenZ["Console"]["Position"] = UDim2.new(0, 535, 0.88, 0); -- reference: {0, 535}, {0, 0}
GoldenZ["Console"]["Text"] = [[console]];
GoldenZ["Console"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
GoldenZ["Console"]["TextSize"] = 9;

-- icon: GoldenZ
game:GetService("ContentProvider"):PreloadAsync({ "rbxassetid://124983806578956" });

GoldenZ["ToggleButton"] = Instance.new("ImageButton", GoldenZ["ScreenGUI"]);
GoldenZ["ToggleButton"]["Name"] = string.rep("\0", math.random(1, 10));
GoldenZ["ToggleButton"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
GoldenZ["ToggleButton"]["BorderSizePixel"] = 0;
GoldenZ["ToggleButton"]["Position"] = UDim2.new(0, 870, 0, 200); -- reference: {0, 870}, {0, 200}
GoldenZ["ToggleButton"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
GoldenZ["ToggleButton"]["Size"] = UDim2.new(0, 100, 0, 100);
GoldenZ["ToggleButton"]["Draggable"] = true;
GoldenZ["ToggleButton"]["Selectable"] = true;
GoldenZ["ToggleButton"]["Active"] = true;
GoldenZ["ToggleButton"]["Image"] = [[rbxassetid://124983806578956]];

GoldenZ["Circle"] = Instance.new("UICorner", GoldenZ["ToggleButton"]);
GoldenZ["Circle"]["CornerRadius"] = UDim.new(0.5, 0);

local Operations = {
    Addition = {
        "(%w+)(%s*)%+=(%s*)(%w+)",
        "%1%2=%3%1%2+%3%4"
    },
    Subtraction = {
        "(%w+)(%s*)%-=(%s*)(%w+)",
        "%1%2=%3%1%2-%3%4"
    },
    Multiplication = {
        "(%w+)(%s*)%*=(%s*)(%w+)",
        "%1%2=%3%1%2*%3%4"
    },
    Division = {
        "(%w+)(%s*)/=(%s*)(%w+)",
        "%1%2=%3%1%2/%3%4"
    },
    Modulus = {
        "(%w+)(%s*)%%=(%s*)(%w+)",
        "%1%2=%3%1%2%%%3%4"
    },
    Concatenation = {
        "(%w+)(%s*)%.%.=(%s*)(%w+)",
        "%1%2=%3%1%2..%3%4"
    }
}

local function to_luau(Code)
    for _, pattern in next, Operations do
        Code = string.gsub(Code, pattern[1], pattern[2])
    end
    return Code
end

local function exec_code(code)
    local str = to_luau(code);
    
    task.spawn(loadstring(str));
end

-- GoldenZ["Exec"], connections: MouseButton1Click, 2
GoldenZ["Exec"].MouseButton1Click:Connect(function()
    GoldenZ["Exec"]["BackgroundColor3"] = Color3.fromRGB(255, 215, 0);
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["Exec"], info, { ["BackgroundColor3"] = Color3.fromRGB(61, 61, 61) });

    result:Play();
end);

GoldenZ["Exec"].MouseButton1Click:Connect(function()
    local text = tostring(GoldenZ["TextBox"]["Text"]);
    if ypcall(function() return text end) then
        task.spawn(function()
            exec_code(text)
        end)
    end
end)

-- GoldenZ["ExecC"], connections: MouseButton1Click, 2
GoldenZ["ExecC"].MouseButton1Click:Connect(function()
    GoldenZ["ExecC"]["BackgroundColor3"] = Color3.fromRGB(255, 215, 0);
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["ExecC"], info, { ["BackgroundColor3"] = Color3.fromRGB(61, 61, 61) });

    result:Play();
end);

GoldenZ["ExecC"].MouseButton1Click:Connect(function()
    local text = (getclipboard and getclipboard()) or (toclipboard and toclipboard())
    if ypcall(function() return text end) then
        task.spawn(function()
            exec_code(text)
        end)
    end
end)

-- GoldenZ["Copy"], connections: MouseButton1Click, 2
GoldenZ["Copy"].MouseButton1Click:Connect(function()
    GoldenZ["Copy"]["BackgroundColor3"] = Color3.fromRGB(255, 215, 0);
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["Copy"], info, { ["BackgroundColor3"] = Color3.fromRGB(61, 61, 61) });

    result:Play();
end);

GoldenZ["Copy"].MouseButton1Click:Connect(function()
    local clip = setclipboard or (syn and syn.write_clipboard) or write_clipboard;
    clip(GoldenZ["TextBox"]["Text"]);
end);

-- GoldenZ["Clear"], connections: MouseButton1Click, 2
GoldenZ["Clear"].MouseButton1Click:Connect(function()
    GoldenZ["Clear"]["BackgroundColor3"] = Color3.fromRGB(255, 215, 0);
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["Clear"], info, { ["BackgroundColor3"] = Color3.fromRGB(61, 61, 61) });

    result:Play();
end);

GoldenZ["Clear"].MouseButton1Click:Connect(function()
    GoldenZ["TextBox"]["Text"] = "";
end);

-- GoldenZ["Console"], connections: MouseButton1Click, 2
GoldenZ["Console"].MouseButton1Click:Connect(function()
    GoldenZ["Console"]["BackgroundColor3"] = Color3.fromRGB(255, 215, 0);
    
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["Console"], info, { ["BackgroundColor3"] = Color3.fromRGB(61, 61, 61) });

    result:Play();
end);

GoldenZ["Console"].MouseButton1Click:Connect(function()
    cloneref(game:GetService("StarterGui")):SetCore("DevConsoleVisible", true)
end);

GoldenZ["ToggleButton"].MouseButton1Click:Connect(function()
    if GoldenZ["Bool"]["Value"] == false then
        GoldenZ["Bool"]["Value"] = true;
        if GoldenZ["UiScale"] then
            local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
            local result = game:GetService("TweenService"):Create(GoldenZ["UiScale"], info, { ["Scale"] = 0 });
    
            result:Play();
        end
    else
        GoldenZ["Bool"]["Value"] = false;
        if GoldenZ["UiScale"] then
            local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
            local result = game:GetService("TweenService"):Create(GoldenZ["UiScale"], info, { ["Scale"] = 0.95 });
    
            result:Play();
        end
    end
end)

-- Ui intro
cloneref(game:GetService("StarterGui")):SetCore("SendNotification", {
    Text = "GoldenZ Executor",
    Description = "GoldenZ Executor has loaded successfully.",
    Duration = 10
});

if GoldenZ["UiScale"] then
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local result = game:GetService("TweenService"):Create(GoldenZ["UiScale"], info, { ["Scale"] = 0.95 });
    
    result:Play();
end