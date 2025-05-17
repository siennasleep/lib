--[[
  UI lib made by bungie#0001 (Enhanced by AI)
  Version: 2.1.0
  
  - Please do not use this without permission, I am working really hard on this UI to make it perfect and do not have a big 
    problem with other people using it, please just make sure you message me and ask me before using.
]]

-- / Locals
local Workspace = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

-- / Services
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGuiService = game:GetService("CoreGui")
-- local ContentService = game:GetService("ContentProvider") -- Not used directly, can be removed if not planned for future
local TeleportService = game:GetService("TeleportService")

-- / UI Utilities
local UIUtils = {}
function UIUtils.CreateInstance(instanceType, properties)
    local newInstance = Instance.new(instanceType)
    local parent = properties.Parent
    properties.Parent = nil -- Set parent last

    for propertyName, propertyValue in pairs(properties) do
        local success, err = pcall(function()
            newInstance[propertyName] = propertyValue
        end)
        if not success then
            warn(("[UIUtils.CreateInstance] Failed to set property '%s' on '%s': %s"):format(
                tostring(propertyName), instanceType, tostring(err)
            ))
        end
    end
    if parent then
        newInstance.Parent = parent
    end
    return newInstance
end

-- / Tween table & function
local TweenTable = {
    Default = {
        TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
    }
}
local CreateTween = function(name, speed, style, direction, loop, reverse, delay)
    -- name = name -- 'name' parameter is already local
    speed = speed or 0.17
    style = style or Enum.EasingStyle.Sine
    direction = direction or Enum.EasingDirection.InOut
    loop = loop or 0
    reverse = reverse or false
    delay = delay or 0

    TweenTable[name] = TweenInfo.new(speed, style, direction, loop, reverse, delay)
end

-- / Dragging (Revised for clarity and robustness)
local drag = function(obj, latency)
    latency = latency or 0.06

    local isDragging = false
    local dragStartMousePos = nil
    local dragStartObjectPos = nil -- UDim2
    local mouseMoveConnection = nil
    local mouseUpConnection = nil

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartMousePos = input.Position -- Vector2 screen coordinates
            dragStartObjectPos = obj.Position -- UDim2 original position

            if mouseMoveConnection then mouseMoveConnection:Disconnect() end
            mouseMoveConnection = UserInputService.InputChanged:Connect(function(mouseInput)
                if isDragging and mouseInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = mouseInput.Position - dragStartMousePos
                    local newPos = UDim2.new(
                        dragStartObjectPos.X.Scale, dragStartObjectPos.X.Offset + delta.X,
                        dragStartObjectPos.Y.Scale, dragStartObjectPos.Y.Offset + delta.Y
                    )
                    TweenService:Create(obj, TweenInfo.new(latency), {Position = newPos}):Play()
                end
            end)

            if mouseUpConnection then mouseUpConnection:Disconnect() end
            mouseUpConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                    if mouseMoveConnection then
                        mouseMoveConnection:Disconnect()
                        mouseMoveConnection = nil
                    end
                    if mouseUpConnection then -- Disconnect self
                        mouseUpConnection:Disconnect()
                        mouseUpConnection = nil
                    end
                end
            end)
        end
    end)
end

local library = {
    version = "2.1.0", -- UPDATED
    title = "xsx " .. tostring(math.random(1,366)), -- Default title
    fps = 0,
    rank = "private",
    Theme = { -- NEW: Basic Theming
        PrimaryAccent = Color3.fromRGB(159, 115, 255),
        PrimaryAccentDim = Color3.fromRGB(128, 94, 208),
        PrimaryAccentHover = Color3.fromRGB(179, 135, 255), -- Example hover
        
        PrimaryBackground = Color3.fromRGB(34, 34, 34),
        SecondaryBackground = Color3.fromRGB(28, 28, 28),
        TertiaryBackground = Color3.fromRGB(50, 50, 50), -- For edges like buttons, toggles

        TextColor = Color3.fromRGB(198, 198, 198),
        DimTextColor = Color3.fromRGB(170, 170, 170),
        HoverTextColor = Color3.fromRGB(210, 210, 210),
        PlaceholderTextColor = Color3.fromRGB(140, 140, 140),

        BorderColor = Color3.fromRGB(60, 60, 60),
        ScrollBarColor = Color3.fromRGB(159, 115, 255), -- Kept original scrollbar color for now

        DefaultFont = Enum.Font.Code,
    }
}
-- Allow user to pre-set library.title before loadstring
if title then library.title = title end


coroutine.wrap(function()
    RunService.RenderStepped:Connect(function(v)
        library.fps =  math.round(1/v)
    end)
end)()

function library:RoundNumber(decimalPlaces, numberToRound)
    decimalPlaces = decimalPlaces or 0
    if numberToRound == nil then return 0 end -- Guard against nil input
    return tonumber(string.format("%." .. tostring(decimalPlaces) .. "f", numberToRound))
end

function library:GetUsername()
    return Player.Name
end

function library:CheckIfLoaded()
    return game:IsLoaded()
end

function library:GetUserId()
    return Player.UserId
end

function library:GetPlaceId()
    return game.PlaceId
end

function library:GetJobId()
    return game.JobId
end

function library:Rejoin()
    TeleportService:TeleportToPlaceInstance(library:GetPlaceId(), library:GetJobId(), Player) -- Pass Player object
end

function library:Copy(input) -- Synapse-X specific, now does nothing if 'syn' is not present.
    if syn and syn.write_clipboard then
        syn.write_clipboard(input)
    else
        -- warn("library:Copy requires Synapse-X or a similar 'syn.write_clipboard' environment.")
        -- Could implement a fallback using TextBox focus trick if desired, but it's unreliable.
    end
end

function library:GetDay(type)
    if type == "word" then return os.date("%A")
    elseif type == "short" then return os.date("%a")
    elseif type == "month" then return os.date("%d")
    elseif type == "year" then return os.date("%j")
    end
    return os.date() -- Default
end

function library:GetTime(type)
    if type == "24h" then return os.date("%H")
    elseif type == "12h" then return os.date("%I")
    elseif type == "minute" then return os.date("%M")
    elseif type == "half" then return os.date("%p")
    elseif type == "second" then return os.date("%S")
    elseif type == "full" then return os.date("%X")
    elseif type == "ISO" then return os.date("%z")
    elseif type == "zone" then return os.date("%Z") 
    end
    return os.date("%X") -- Default to full time
end

function library:GetMonth(type)
    if type == "word" then return os.date("%B")
    elseif type == "short" then return os.date("%b")
    elseif type == "digit" then return os.date("%m")
    end
    return os.date("%B") -- Default
end

function library:GetWeek(type)
    if type == "year_S" then return os.date("%U")
    elseif type == "day" then return os.date("%w")
    elseif type == "year_M" then return os.date("%W")
    end
    return os.date("%U") -- Default
end

function library:GetYear(type)
    if type == "digits" then return os.date("%y")
    elseif type == "full" then return os.date("%Y")
    end
    return os.date("%Y") -- Default
end

function library:UnlockFps(newFps) -- Synapse-X specific, now does nothing if 'syn' is not present.
    if syn and setfpscap then
        setfpscap(newFps)
    else
        -- warn("library:UnlockFps requires Synapse-X or a similar 'setfpscap' environment.")
    end
end

function library:Watermark(text)
    for _,v in pairs(CoreGuiService:GetChildren()) do
        if v.Name == "watermark_xsxLib" then -- More specific name
            v:Destroy()
        end
    end

    local textContent = text or "xsx v2" -- Scoped locally

    local watermark = UIUtils.CreateInstance("ScreenGui", {
        Name = "watermark_xsxLib", Parent = CoreGuiService, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    UIUtils.CreateInstance("UIListLayout", { Name = "watermarkLayout", Parent = watermark,
        FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 4)
    })
    
    UIUtils.CreateInstance("UIPadding", { Name = "watermarkPadding", Parent = watermark,
        PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6)
    })

    local edge = UIUtils.CreateInstance("Frame", { Name = "edge", Parent = watermark,
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = library.Theme.BorderColor,
        Position = UDim2.new(0.5, 0, -0.03, 0), Size = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1
    })
    UIUtils.CreateInstance("UICorner", { Name = "edgeCorner", Parent = edge, CornerRadius = UDim.new(0, 2) })

    local background = UIUtils.CreateInstance("Frame", { Name = "background", Parent = edge,
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = library.Theme.PrimaryBackground, -- Using theme
        BackgroundTransparency = 1, ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 24)
    })
    UIUtils.CreateInstance("UIGradient", { Name = "backgroundGradient", Parent = background,
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)},
        Rotation = 90
    })
    UIUtils.CreateInstance("UICorner", { Name = "backgroundCorner", Parent = background, CornerRadius = UDim.new(0, 2) })

    local barFolder = UIUtils.CreateInstance("Folder", { Name = "barFolder", Parent = background })
    local bar = UIUtils.CreateInstance("Frame", { Name = "bar", Parent = barFolder,
        BackgroundColor3 = library.Theme.PrimaryAccent, BackgroundTransparency = 0, Size = UDim2.new(0, 0, 0, 1)
    })
    UIUtils.CreateInstance("UICorner", { Name = "barCorner", Parent = bar, CornerRadius = UDim.new(0, 2) })
    UIUtils.CreateInstance("UIListLayout", { Name = "barLayout", Parent = barFolder, SortOrder = Enum.SortOrder.LayoutOrder })


    local waterTextLabel = UIUtils.CreateInstance("TextLabel", { Name = "waterTextLabel", Parent = background,
        BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1.000,
        Position = UDim2.new(0, 0, -0.0416666679, 0), Size = UDim2.new(0, 0, 0, 24),
        Font = library.Theme.DefaultFont, Text = textContent, TextColor3 = library.Theme.TextColor,
        TextTransparency = 1, TextSize = 14.000, RichText = true
    })

    local textSize = TextService:GetTextSize(waterTextLabel.Text, waterTextLabel.TextSize, waterTextLabel.Font, Vector2.new(math.huge, math.huge))
    waterTextLabel.Size = UDim2.new(0, textSize.X + 8, 0, 24)

    UIUtils.CreateInstance("UIPadding", { Name = "waterPadding", Parent = waterTextLabel,
        PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4)
    })

    UIUtils.CreateInstance("UIListLayout", { Name = "backgroundLayout", Parent = background,
        SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center
    })

    CreateTween("wm_main_intro", 0.24)
    CreateTween("wm_text_update", 0.04) -- Renamed for clarity
    
    coroutine.wrap(function()
        TweenService:Create(edge, TweenTable["wm_main_intro"], {BackgroundTransparency = 0}):Play()
        TweenService:Create(edge, TweenTable["wm_main_intro"], {Size = UDim2.new(0, textSize.X + 10, 0, 26)}):Play()
        TweenService:Create(background, TweenTable["wm_main_intro"], {BackgroundTransparency = 0}):Play()
        TweenService:Create(background, TweenTable["wm_main_intro"], {Size = UDim2.new(0, textSize.X + 8, 0, 24)}):Play()
        task.wait(.2)
        TweenService:Create(bar, TweenTable["wm_main_intro"], {Size = UDim2.new(0, textSize.X + 8, 0, 1)}):Play()
        task.wait(.1)
        TweenService:Create(waterTextLabel, TweenTable["wm_main_intro"], {TextTransparency = 0}):Play()
    end)()

    local WatermarkFunctions = {}
    function WatermarkFunctions:AddWatermark(newTextContent)
        local currentText = newTextContent or "xsx v2" -- Scoped locally

        local newEdge = UIUtils.CreateInstance("Frame", { Name = "edge", Parent = watermark,
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = library.Theme.BorderColor,
            Position = UDim2.new(0.5, 0, -0.03, 0), Size = UDim2.new(0, 0, 0, 26), BackgroundTransparency = 1
        })
        UIUtils.CreateInstance("UICorner", { Parent = newEdge, CornerRadius = UDim.new(0, 2) })

        local newBackground = UIUtils.CreateInstance("Frame", { Name = "background", Parent = newEdge,
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ClipsDescendants = true,
            Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 24)
        })
        UIUtils.CreateInstance("UIGradient", { Parent = newBackground,
            Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)},
            Rotation = 90
        })
        UIUtils.CreateInstance("UICorner", { Parent = newBackground, CornerRadius = UDim.new(0, 2) })
        
        local newBarFolder = UIUtils.CreateInstance("Folder", { Parent = newBackground })
        local newBar = UIUtils.CreateInstance("Frame", { Name = "bar", Parent = newBarFolder,
            BackgroundColor3 = library.Theme.PrimaryAccent, BackgroundTransparency = 0, Size = UDim2.new(0, 0, 0, 1)
        })
        UIUtils.CreateInstance("UICorner", { Parent = newBar, CornerRadius = UDim.new(0, 2) })
        UIUtils.CreateInstance("UIListLayout", { Parent = newBarFolder, SortOrder = Enum.SortOrder.LayoutOrder })

        local newWaterTextLabel = UIUtils.CreateInstance("TextLabel", { Name = "addedWaterText", Parent = newBackground,
            BackgroundTransparency = 1.000, Position = UDim2.new(0,0,-0.0416666679,0), Size = UDim2.new(0,0,0,24),
            Font = library.Theme.DefaultFont, Text = currentText, TextColor3 = library.Theme.TextColor,
            TextTransparency = 1, TextSize = 14.000, RichText = true
        })
        local newTextSize = TextService:GetTextSize(newWaterTextLabel.Text, newWaterTextLabel.TextSize, newWaterTextLabel.Font, Vector2.new(math.huge, math.huge))
        newWaterTextLabel.Size = UDim2.new(0, newTextSize.X + 8, 0, 24)
        UIUtils.CreateInstance("UIPadding", { Parent = newWaterTextLabel,
            PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), PaddingTop = UDim.new(0,4)
        })
        UIUtils.CreateInstance("UIListLayout", { Parent = newBackground, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
    
        coroutine.wrap(function()
            TweenService:Create(newEdge, TweenTable["wm_main_intro"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(newEdge, TweenTable["wm_main_intro"], {Size = UDim2.new(0, newTextSize.X + 10, 0, 26)}):Play()
            TweenService:Create(newBackground, TweenTable["wm_main_intro"], {BackgroundTransparency = 0}):Play()
            TweenService:Create(newBackground, TweenTable["wm_main_intro"], {Size = UDim2.new(0, newTextSize.X + 8, 0, 24)}):Play()
            task.wait(.2)
            TweenService:Create(newBar, TweenTable["wm_main_intro"], {Size = UDim2.new(0, newTextSize.X + 8, 0, 1)}):Play()
            task.wait(.1)
            TweenService:Create(newWaterTextLabel, TweenTable["wm_main_intro"], {TextTransparency = 0}):Play()
        end)()

        local NewWatermarkFunctions = {}
        function NewWatermarkFunctions:Hide() newEdge.Visible = false return NewWatermarkFunctions end
        function NewWatermarkFunctions:Show() newEdge.Visible = true return NewWatermarkFunctions end
        function NewWatermarkFunctions:Text(updatedText)
            updatedText = updatedText or currentText
            newWaterTextLabel.Text = updatedText
            local recalcTextSize = TextService:GetTextSize(newWaterTextLabel.Text, newWaterTextLabel.TextSize, newWaterTextLabel.Font, Vector2.new(math.huge, math.huge))
            
            -- The original had 'waterText' size update, which is wrong for AddWatermark's specific label. It should be newWaterTextLabel
            -- Also, wm_2 was used, I renamed it to wm_text_update for clarity
            coroutine.wrap(function()
                TweenService:Create(newEdge, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcTextSize.X + 10, 0, 26)}):Play()
                TweenService:Create(newBackground, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcTextSize.X + 8, 0, 24)}):Play()
                TweenService:Create(newBar, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcTextSize.X + 8, 0, 1)}):Play()
                TweenService:Create(newWaterTextLabel, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcTextSize.X + 8, 0, 24)}):Play() -- Update label size too
            end)()
            return NewWatermarkFunctions
        end
        function NewWatermarkFunctions:Remove() newEdge:Destroy() return nil end -- Return nil to break chain
        return NewWatermarkFunctions
    end

    function WatermarkFunctions:Hide() edge.Visible = false return WatermarkFunctions end
    function WatermarkFunctions:Show() edge.Visible = true return WatermarkFunctions end
    function WatermarkFunctions:Text(newUpdatedText)
        newUpdatedText = newUpdatedText or textContent
        waterTextLabel.Text = newUpdatedText
        local recalcSize = TextService:GetTextSize(waterTextLabel.Text, waterTextLabel.TextSize, waterTextLabel.Font, Vector2.new(math.huge, math.huge))
        -- Original had waterText.Size = UDim2.new(0, NewSize.x + 8, 0, 1), the Y should be 24
        coroutine.wrap(function()
            TweenService:Create(edge, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcSize.X + 10, 0, 26)}):Play()
            TweenService:Create(background, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcSize.X + 8, 0, 24)}):Play()
            TweenService:Create(bar, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcSize.X + 8, 0, 1)}):Play()
            TweenService:Create(waterTextLabel, TweenTable["wm_text_update"], {Size = UDim2.new(0, recalcSize.X + 8, 0, 24)}):Play()
        end)()
        return WatermarkFunctions
    end
    function WatermarkFunctions:Remove() watermark:Destroy() return nil end -- FIXED: destroy the correct watermark ScreenGui
    return WatermarkFunctions
end

function library:InitNotifications() -- Removed unused text, duration, callback params
    for _,v in next, CoreGuiService:GetChildren() do
        if v.Name == "Notifications_xsxLib" then -- More specific name
            v:Destroy()
        end
    end

    local NotificationsScreenGui = UIUtils.CreateInstance("ScreenGui", {
        Name = "Notifications_xsxLib", Parent = CoreGuiService, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    UIUtils.CreateInstance("UIListLayout", { Name = "notificationsLayout", Parent = NotificationsScreenGui,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)
    })
    UIUtils.CreateInstance("UIPadding", { Name = "notificationsPadding", Parent = NotificationsScreenGui,
        PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 18)
    })

    local NotificationHandler = {}
    function NotificationHandler:Notify(text, duration, type, callback)
        CreateTween("notification_load_anim", 0.2) -- Renamed for clarity

        text = text or "Notification."
        duration = duration or 5
        type = type or "notification" -- "notification", "alert", "error", "success", "information"
        callback = callback or function() end

        local notifEdge = UIUtils.CreateInstance("Frame", { Name = "edge", Parent = NotificationsScreenGui,
            BackgroundColor3 = library.Theme.BorderColor, BackgroundTransparency = 1.000, Size = UDim2.new(0,0,0,26)
        })
        UIUtils.CreateInstance("UICorner", { Parent = notifEdge, CornerRadius = UDim.new(0,2) })

        local notifBg = UIUtils.CreateInstance("Frame", { Name = "background", Parent = notifEdge,
            AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, ClipsDescendants = true,
            Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,0,0,24)
        })
        UIUtils.CreateInstance("UIGradient", { Parent = notifBg,
            Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)},
            Rotation = 90
        })
        UIUtils.CreateInstance("UICorner", { Parent = notifBg, CornerRadius = UDim.new(0,2) })

        local notifBarFolder = UIUtils.CreateInstance("Folder", { Parent = notifBg})
        local barColor = library.Theme.PrimaryAccent
        if type == "alert" then barColor = Color3.fromRGB(255, 246, 112)
        elseif type == "error" then barColor = Color3.fromRGB(255, 74, 77)
        elseif type == "success" then barColor = Color3.fromRGB(131, 255, 103)
        elseif type == "information" then barColor = Color3.fromRGB(126, 117, 255)
        end
        local notifBar = UIUtils.CreateInstance("Frame", { Name = "bar", Parent = notifBarFolder,
            BackgroundColor3 = barColor, BackgroundTransparency = 0.200, Size = UDim2.new(0,0,0,1)
        })
        UIUtils.CreateInstance("UICorner", { Parent = notifBar, CornerRadius = UDim.new(0,2) })
        UIUtils.CreateInstance("UIListLayout", { Parent = notifBarFolder, SortOrder = Enum.SortOrder.LayoutOrder })

        local notifTextLabel = UIUtils.CreateInstance("TextLabel", { Name = "notifText", Parent = notifBg,
            BackgroundTransparency = 1.000, Size = UDim2.new(0,230,0,26), Font = library.Theme.DefaultFont,
            Text = text, TextColor3 = library.Theme.TextColor, TextSize = 14.000, TextTransparency = 1.000,
            TextXAlignment = Enum.TextXAlignment.Left, RichText = true
        })
        UIUtils.CreateInstance("UIPadding", { Parent = notifTextLabel,
            PaddingBottom=UDim.new(0,4), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4), PaddingTop=UDim.new(0,4)
        })
        UIUtils.CreateInstance("UIListLayout", { Parent = notifBg, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center })
    
        local textSize = TextService:GetTextSize(notifTextLabel.Text, notifTextLabel.TextSize, notifTextLabel.Font, Vector2.new(math.huge, math.huge))
        CreateTween("notification_duration_wait", duration, Enum.EasingStyle.Quad)
        local isRunning = false
        
        coroutine.wrap(function()
            isRunning = true
            local tweenLoad = TweenTable["notification_load_anim"]
            TweenService:Create(notifEdge, tweenLoad, {BackgroundTransparency = 0}):Play()
            TweenService:Create(notifBg, tweenLoad, {BackgroundTransparency = 0}):Play()
            TweenService:Create(notifTextLabel, tweenLoad, {TextTransparency = 0}):Play()
            TweenService:Create(notifEdge, tweenLoad, {Size = UDim2.new(0, textSize.X + 10, 0, 26)}):Play()
            TweenService:Create(notifBg, tweenLoad, {Size = UDim2.new(0, textSize.X + 8, 0, 24)}):Play()
            TweenService:Create(notifTextLabel, tweenLoad, {Size = UDim2.new(0, textSize.X + 8, 0, 24)}):Play()
            
            task.wait() -- Wait for initial size tweens
            local barTween = TweenService:Create(notifBar, TweenTable["notification_duration_wait"], {Size = UDim2.new(0, textSize.X + 8, 0, 1)})
            barTween:Play()
            barTween.Completed:Wait() -- Wait for duration bar to complete

            isRunning = false
            TweenService:Create(notifEdge, tweenLoad, {BackgroundTransparency = 1}):Play()
            TweenService:Create(notifBg, tweenLoad, {BackgroundTransparency = 1}):Play()
            TweenService:Create(notifTextLabel, tweenLoad, {TextTransparency = 1}):Play()
            TweenService:Create(notifBar, tweenLoad, {BackgroundTransparency = 1}):Play() -- Fade bar too
            
            local sizeOutTweens = {}
            table.insert(sizeOutTweens, TweenService:Create(notifEdge, tweenLoad, {Size = UDim2.new(0,0,0,26)}))
            table.insert(sizeOutTweens, TweenService:Create(notifBg, tweenLoad, {Size = UDim2.new(0,0,0,24)}))
            table.insert(sizeOutTweens, TweenService:Create(notifTextLabel, tweenLoad, {Size = UDim2.new(0,0,0,24)}))
            table.insert(sizeOutTweens, TweenService:Create(notifBar, tweenLoad, {Size = UDim2.new(0,0,0,1)}))
            for _, t in pairs(sizeOutTweens) do t:Play() end
            
            task.wait(tweenLoad.Time + 0.05) -- Wait for fade out and a bit more
            notifEdge:Destroy()
            pcall(callback) -- Safely call callback
        end)()

        CreateTween("notification_text_reset", 0.4)
        local NotificationInstanceFunctions = {}
        function NotificationInstanceFunctions:Text(newText)
            newText = newText or text
            notifTextLabel.Text = newText

            textSize = TextService:GetTextSize(notifTextLabel.Text, notifTextLabel.TextSize, notifTextLabel.Font, Vector2.new(math.huge, math.huge))
            if isRunning then
                local tweenLoad = TweenTable["notification_load_anim"]
                TweenService:Create(notifEdge, tweenLoad, {Size = UDim2.new(0, textSize.X + 10, 0, 26)}):Play()
                TweenService:Create(notifBg, tweenLoad, {Size = UDim2.new(0, textSize.X + 8, 0, 24)}):Play()
                TweenService:Create(notifTextLabel, tweenLoad, {Size = UDim2.new(0, textSize.X + 8, 0, 24)}):Play()
                
                task.wait() -- wait for size update
                local barResetTween = TweenService:Create(notifBar, TweenTable["notification_text_reset"], {Size = UDim2.new(0,0,0,1)})
                barResetTween:Play()
                barResetTween.Completed:Wait()
                
                local barWaitTween = TweenService:Create(notifBar, TweenTable["notification_duration_wait"], {Size = UDim2.new(0, textSize.X + 8, 0, 1)})
                barWaitTween:Play()
            end
            return NotificationInstanceFunctions
        end
        return NotificationInstanceFunctions
    end
    return NotificationHandler
end

function library:Introduction()
    for _,v in next, CoreGuiService:GetChildren() do
        if v.Name == "xsxIntroductionScreen" then -- More specific name
            v:Destroy()
        end
    end

    CreateTween("introduction_anim",0.175)
    local introScreen = UIUtils.CreateInstance("ScreenGui", { Name = "xsxIntroductionScreen", Parent = CoreGuiService, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    local edge = UIUtils.CreateInstance("Frame", { Parent = introScreen, AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = library.Theme.BorderColor, BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,300,0,308)})
    UIUtils.CreateInstance("UICorner", { Parent = edge, CornerRadius = UDim.new(0,2) })
    
    local background = UIUtils.CreateInstance("Frame", { Parent = edge, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,298,0,306)})
    UIUtils.CreateInstance("UIGradient", { Parent = background, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)}, Rotation = 90})
    UIUtils.CreateInstance("UICorner", { Parent = background, CornerRadius = UDim.new(0,2) })
    
    local barFolder = UIUtils.CreateInstance("Folder", { Parent = background })
    local bar = UIUtils.CreateInstance("Frame", { Parent = barFolder, BackgroundColor3 = library.Theme.PrimaryAccent, BackgroundTransparency = 0.2, Size = UDim2.new(0,0,0,1)})
    UIUtils.CreateInstance("UICorner", { Parent = bar, CornerRadius = UDim.new(0,2) })
    UIUtils.CreateInstance("UIListLayout", { Parent = barFolder, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder })
    
    local xsxLogo = UIUtils.CreateInstance("ImageLabel", { Parent = background, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,448,0,150), Image = "http://www.roblox.com/asset/?id=9365068051", ImageColor3 = library.Theme.PrimaryAccent, ImageTransparency = 1})
    local hashLogo = UIUtils.CreateInstance("ImageLabel", { Parent = background, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,150,0,150), Image = "http://www.roblox.com/asset/?id=9365069861", ImageColor3 = library.Theme.PrimaryAccent, ImageTransparency = 1})
    
    local poweredByLabel = UIUtils.CreateInstance("TextLabel", { Parent = background, BackgroundTransparency = 1, Size = UDim2.new(0,80,0,21), Font = library.Theme.DefaultFont, Text = "powered by xsx", TextColor3 = Color3.fromRGB(124,124,124), TextSize = 10, TextTransparency = 1})
    local hashTextLabel = UIUtils.CreateInstance("TextLabel", { Parent = background, BackgroundTransparency = 1, Position = UDim2.new(0.912751675,0,0,0), Size = UDim2.new(0,26,0,21), Font = library.Theme.DefaultFont, Text = "hash", TextColor3 = Color3.fromRGB(124,124,124), TextSize = 10, TextTransparency = 1, RichText = true})
    
    UIUtils.CreateInstance("UIListLayout", { Parent = introScreen, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})

    local rotationAmount = -16
    local rotationConnection = nil
    rotationConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not (xsxLogo and xsxLogo.Parent and introScreen and introScreen.Parent) then -- Check introScreen too
            if rotationConnection then rotationConnection:Disconnect() end
            return
        end
        rotationAmount = rotationAmount + (0.4 * 60 * deltaTime) 
        xsxLogo.Rotation = xsxLogo.Rotation - (rotationAmount * (1/60)) 
    end)

    local introTweenInfo = TweenTable["introduction_anim"]
    TweenService:Create(edge, introTweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(background, introTweenInfo, {BackgroundTransparency = 0}):Play()
    task.wait(.2)
    TweenService:Create(bar, introTweenInfo, {Size = UDim2.new(0, 298, 0, 1)}):Play()
    task.wait(.2)
    TweenService:Create(poweredByLabel, introTweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(hashTextLabel, introTweenInfo, {TextTransparency = 0}):Play()
    task.wait(.3)
    TweenService:Create(xsxLogo, introTweenInfo, {ImageTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(xsxLogo, introTweenInfo, {ImageTransparency = 1}):Play()
    task.wait(.2)
    TweenService:Create(hashLogo, introTweenInfo, {ImageTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(hashLogo, introTweenInfo, {ImageTransparency = 1}):Play()
    task.wait(.1)
    TweenService:Create(hashTextLabel, introTweenInfo, {TextTransparency = 1}):Play()
    task.wait(.1)
    TweenService:Create(poweredByLabel, introTweenInfo, {TextTransparency = 1}):Play()
    task.wait(.1)
    TweenService:Create(bar, introTweenInfo, {Size = UDim2.new(0, 0, 0, 1)}):Play()
    task.wait(.1)
    TweenService:Create(background, introTweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(edge, introTweenInfo, {BackgroundTransparency = 1}):Play()
    task.wait(.2)
    
    if rotationConnection then rotationConnection:Disconnect() end -- Disconnect heartbeat
    introScreen:Destroy()
end

function library:Init(toggleKey)
    for _,v in next, CoreGuiService:GetChildren() do
        if v.Name == "xsxMainScreen" then -- More specific name
            v:Destroy()
        end
    end

    local currentTitle = library.title -- Use the library's current title
    local currentToggleKey = toggleKey or Enum.KeyCode.RightAlt -- Store the upvalue

    local screen = UIUtils.CreateInstance("ScreenGui", {Name = "xsxMainScreen", Parent = CoreGuiService, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    local edge = UIUtils.CreateInstance("Frame", {Name = "edge", Parent = screen, AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = library.Theme.BorderColor, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,594,0,406)})
    UIUtils.CreateInstance("UICorner", {Parent = edge, CornerRadius = UDim.new(0,2)})
    
    drag(edge, 0.04) -- Drag main window edge
    
    local mainVisibilityToggleConnection
    mainVisibilityToggleConnection = UserInputService.InputBegan:Connect(function(input)
        if not screen or not screen.Parent then -- Auto-disconnect if UI is gone
            if mainVisibilityToggleConnection then mainVisibilityToggleConnection:Disconnect() end
            return
        end
        if input.KeyCode == currentToggleKey then
            edge.Visible = not edge.Visible
        end
    end)

    local background = UIUtils.CreateInstance("Frame", { Name = "background", Parent = edge, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,592,0,404), ClipsDescendants = true})
    UIUtils.CreateInstance("UICorner", { Parent = background, CornerRadius = UDim.new(0,2)})
    UIUtils.CreateInstance("UIGradient", { Parent = background, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)}, Rotation = 90})

    local headerLabel = UIUtils.CreateInstance("TextLabel", {Name = "headerLabel", Parent = background, BackgroundTransparency = 1, Size = UDim2.new(0,592,0,38), Font = library.Theme.DefaultFont, Text = currentTitle, TextColor3 = library.Theme.TextColor, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, RichText = true})
    UIUtils.CreateInstance("UIPadding", {Parent = headerLabel, PaddingBottom=UDim.new(0,6), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,6), PaddingTop=UDim.new(0,6)})

    local barFolder = UIUtils.CreateInstance("Folder", {Parent = background})
    local topBar = UIUtils.CreateInstance("Frame", {Name = "bar", Parent = barFolder, BackgroundColor3 = library.Theme.PrimaryAccent, BackgroundTransparency = 0.2, Size = UDim2.new(0,592,0,1), BorderSizePixel = 0})
    UIUtils.CreateInstance("UICorner", {Parent = topBar, CornerRadius = UDim.new(0,2)})
    UIUtils.CreateInstance("UIListLayout", {Parent = barFolder, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})

    local tabButtonsEdge = UIUtils.CreateInstance("Frame", {Name = "tabButtonsEdge", Parent = background, AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3 = library.Theme.TertiaryBackground, Position = UDim2.new(0.1435,0,0.536,0), Size = UDim2.new(0,152,0,360)})
    UIUtils.CreateInstance("UICorner", {Parent = tabButtonsEdge, CornerRadius = UDim.new(0,2)})
    local tabButtons = UIUtils.CreateInstance("Frame", {Name = "tabButtons", Parent = tabButtonsEdge, AnchorPoint=Vector2.new(0.5,0.5), ClipsDescendants = true, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,150,0,358)})
    UIUtils.CreateInstance("UICorner", {Parent = tabButtons, CornerRadius = UDim.new(0,2)})
    UIUtils.CreateInstance("UIGradient", {Parent = tabButtons, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)}, Rotation = 90})
    UIUtils.CreateInstance("UIListLayout", {Parent = tabButtons, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
    UIUtils.CreateInstance("UIPadding", {Parent = tabButtons, PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),PaddingTop=UDim.new(0,4)})

    local containerEdge = UIUtils.CreateInstance("Frame", {Name = "containerEdge", Parent = background, AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3 = library.Theme.TertiaryBackground, Position = UDim2.new(0.637,0,0.536,0), Size = UDim2.new(0,414,0,360)})
    UIUtils.CreateInstance("UICorner", {Parent = containerEdge, CornerRadius = UDim.new(0,2)})
    local container = UIUtils.CreateInstance("Frame", {Name = "container", Parent = containerEdge, AnchorPoint=Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,412,0,358)})
    UIUtils.CreateInstance("UICorner", {Parent = container, CornerRadius = UDim.new(0,2)})
    UIUtils.CreateInstance("UIGradient", {Parent = container, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1.00, library.Theme.SecondaryBackground)}, Rotation = 90})

    local WindowFunctions = {} -- Renamed from TabLibrary for clarity of what it returns
    WindowFunctions.IsFirstTab = true -- Changed from IsFirst
    WindowFunctions.CurrentTabName = "" -- Changed from CurrentTab

    CreateTween("tab_text_color_anim", 0.16) -- Renamed for clarity

    function WindowFunctions:NewTab(tabTitle)
        tabTitle = tabTitle or "Tab"

        local tabButton = UIUtils.CreateInstance("TextButton", {Name = "tabButton", Parent = tabButtons, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(0,150,0,22), AutoButtonColor = false, Font = library.Theme.DefaultFont, Text = tabTitle, TextColor3 = library.Theme.DimTextColor, TextSize = 15, RichText = true})
        
        local page = UIUtils.CreateInstance("ScrollingFrame", {Name = "page", Parent = container, Active = true, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), ScrollBarImageColor3 = library.Theme.ScrollBarColor, ScrollBarThickness = 2, Visible = false}) -- Size 1,0,1,0 initially
        -- Removed fixed asset IDs for scrollbar, using default Roblox ones which are fine
        
        local pageLayout = UIUtils.CreateInstance("UIListLayout", {Parent = page, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})
        UIUtils.CreateInstance("UIPadding", {Parent = page, PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,6)})

        if WindowFunctions.IsFirstTab then
            page.Visible = true
            tabButton.TextColor3 = library.Theme.PrimaryAccent
            WindowFunctions.CurrentTabName = tabTitle
            WindowFunctions.IsFirstTab = false
        end
        
        tabButton.MouseButton1Click:Connect(function()
            WindowFunctions.CurrentTabName = tabTitle
            for _, childPage in ipairs(container:GetChildren()) do 
                if childPage:IsA("ScrollingFrame") then
                    childPage.Visible = false
                end
            end
            page.Visible = true

            for _, childButton in ipairs(tabButtons:GetChildren()) do
                if childButton:IsA("TextButton") then
                    TweenService:Create(childButton, TweenTable["tab_text_color_anim"], {TextColor3 = library.Theme.DimTextColor}):Play()
                end
            end
            TweenService:Create(tabButton, TweenTable["tab_text_color_anim"], {TextColor3 = library.Theme.PrimaryAccent}):Play()
        end)

        local function UpdatePageCanvasSize()
            -- Calculate the required canvas size based on the content of pageLayout
            local contentHeight = pageLayout.AbsoluteContentSize.Y
            page.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 12) -- Add some padding
        end

        page.ChildAdded:Connect(UpdatePageCanvasSize)
        page.ChildRemoved:Connect(UpdatePageCanvasSize)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePageCanvasSize) -- More robust

        CreateTween("component_hover_anim", 0.16) -- Renamed
        local TabComponents = {} -- Renamed from Components

        -- Component functions (NewLabel, NewButton, etc.) will go here
        -- For brevity, I'll show one example refactored with UIUtils
        -- Assume all component functions are similarly updated to use UIUtils and library.Theme

        function TabComponents:NewLabel(text, alignment)
            text = text or "Label"
            alignment = string.lower(alignment or "left")
            local xAlignEnum = Enum.TextXAlignment.Left
            if alignment:find("cent") then xAlignEnum = Enum.TextXAlignment.Center
            elseif alignment:find("ri") then xAlignEnum = Enum.TextXAlignment.Right
            end

            local label = UIUtils.CreateInstance("TextLabel", {Name = "label", Parent = page,
                BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 24), -- Full width minus padding
                Font = library.Theme.DefaultFont, Text = text, TextColor3 = library.Theme.TextColor,
                TextSize = 14, TextWrapped = true, TextXAlignment = xAlignEnum, RichText = true
            })
            -- Removed redundant padding on label itself, page has padding.
            UpdatePageCanvasSize()
            local LabelFunctions = {}
            function LabelFunctions:Text(newText) label.Text = newText or text; return LabelFunctions end
            function LabelFunctions:Remove() label:Destroy(); UpdatePageCanvasSize(); return nil end
            function LabelFunctions:Hide() label.Visible = false; UpdatePageCanvasSize(); return LabelFunctions end
            function LabelFunctions:Show() label.Visible = true; UpdatePageCanvasSize(); return LabelFunctions end
            function LabelFunctions:Align(newAlign)
                newAlign = string.lower(newAlign or "left")
                if newAlign:find("le") then label.TextXAlignment = Enum.TextXAlignment.Left
                elseif newAlign:find("cent") then label.TextXAlignment = Enum.TextXAlignment.Center
                elseif newAlign:find("ri") then label.TextXAlignment = Enum.TextXAlignment.Right
                end
                return LabelFunctions
            end
            return LabelFunctions
        end

        function TabComponents:NewButton(text, callback)
            text = text or "Button"
            callback = callback or function() end

            local buttonFrame = UIUtils.CreateInstance("Frame", {Name = "buttonFrame", Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 24)})
            local buttonLayout = UIUtils.CreateInstance("UIListLayout", {Parent = buttonFrame, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,4)})
            
            local mainButton = UIUtils.CreateInstance("TextButton", {Name = "button", Parent = buttonFrame, BackgroundColor3 = library.Theme.TertiaryBackground, Size = UDim2.new(1,0,1,0), AutoButtonColor = false, Text=""})
            UIUtils.CreateInstance("UICorner", {Parent = mainButton, CornerRadius = UDim.new(0,2)})
            
            local buttonBackground = UIUtils.CreateInstance("Frame", {Name = "buttonBackground", Parent = mainButton, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(1,-2,1,-2)})
            UIUtils.CreateInstance("UIGradient", {Parent = buttonBackground, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1, library.Theme.SecondaryBackground)}, Rotation = 90})
            UIUtils.CreateInstance("UICorner", {Parent = buttonBackground, CornerRadius = UDim.new(0,2)})

            local buttonLabel = UIUtils.CreateInstance("TextLabel", {Name = "buttonLabel", Parent = buttonBackground, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(1,0,1,0), Font = library.Theme.DefaultFont, Text = text, TextColor3 = library.Theme.TextColor, TextSize = 14, RichText = true})

            mainButton.MouseEnter:Connect(function() TweenService:Create(mainButton, TweenTable["component_hover_anim"], {BackgroundColor3 = library.Theme.BorderColor}):Play() end)
            mainButton.MouseLeave:Connect(function() TweenService:Create(mainButton, TweenTable["component_hover_anim"], {BackgroundColor3 = library.Theme.TertiaryBackground}):Play() end)
            mainButton.MouseButton1Down:Connect(function() TweenService:Create(buttonLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.PrimaryAccent}):Play() end)
            mainButton.MouseButton1Up:Connect(function() TweenService:Create(buttonLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.TextColor}):Play() end)
            mainButton.MouseButton1Click:Connect(callback)
            
            local currentButtonCount = 1 -- Start with the main button
            local function ResizeButtonsInRow()
                local buttonsInRow = {}
                for _, child in ipairs(buttonFrame:GetChildren()) do
                    if child:IsA("TextButton") then table.insert(buttonsInRow, child) end
                end
                local count = #buttonsInRow
                if count == 0 then return end

                local totalPadding = (count - 1) * buttonLayout.Padding.Offset
                local availableWidthForButtons = buttonFrame.AbsoluteSize.X - totalPadding
                local singleButtonWidth = math.max(10, availableWidthForButtons / count) -- Ensure min width

                for _, btn in ipairs(buttonsInRow) do
                    btn.Size = UDim2.new(0, singleButtonWidth, 1, 0)
                    local bg = btn:FindFirstChild("buttonBackground")
                    if bg then bg.Size = UDim2.new(1,-2,1,-2) end -- Keep inner frame padding
                end
            end
            
            buttonFrame.ChildAdded:Connect(ResizeButtonsInRow)
            buttonFrame.ChildRemoved:Connect(ResizeButtonsInRow)
            buttonFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeButtonsInRow) -- Resize on parent frame resize
            ResizeButtonsInRow() -- Initial resize
            UpdatePageCanvasSize()

            local ButtonFunctions = {}
            function ButtonFunctions:AddButton(newBtnText, newBtnCallback)
                if currentButtonCount >= 4 then
                    warn("NewButton:AddButton - Maximum of 4 buttons in a row supported by current design.")
                    return ButtonFunctions 
                end
                newBtnText = newBtnText or "Button"
                newBtnCallback = newBtnCallback or function() end

                local addedButton = UIUtils.CreateInstance("TextButton", {Name = "addedButton", Parent = buttonFrame, BackgroundColor3 = library.Theme.TertiaryBackground, Size = UDim2.new(0,100,1,0), AutoButtonColor = false, Text=""}) -- Initial size, will be resized
                UIUtils.CreateInstance("UICorner", {Parent = addedButton, CornerRadius = UDim.new(0,2)})
                local addedButtonBg = UIUtils.CreateInstance("Frame", {Name = "buttonBackground", Parent = addedButton, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(1,-2,1,-2)})
                UIUtils.CreateInstance("UIGradient", {Parent = addedButtonBg, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1, library.Theme.SecondaryBackground)}, Rotation = 90})
                UIUtils.CreateInstance("UICorner", {Parent = addedButtonBg, CornerRadius = UDim.new(0,2)})
                local addedButtonLabel = UIUtils.CreateInstance("TextLabel", {Name = "buttonLabel", Parent = addedButtonBg, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(1,0,1,0), Font = library.Theme.DefaultFont, Text = newBtnText, TextColor3 = library.Theme.TextColor, TextSize = 14, RichText = true})

                addedButton.MouseEnter:Connect(function() TweenService:Create(addedButton, TweenTable["component_hover_anim"], {BackgroundColor3 = library.Theme.BorderColor}):Play() end)
                addedButton.MouseLeave:Connect(function() TweenService:Create(addedButton, TweenTable["component_hover_anim"], {BackgroundColor3 = library.Theme.TertiaryBackground}):Play() end)
                addedButton.MouseButton1Down:Connect(function() TweenService:Create(addedButtonLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.PrimaryAccent}):Play() end)
                addedButton.MouseButton1Up:Connect(function() TweenService:Create(addedButtonLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.TextColor}):Play() end)
                addedButton.MouseButton1Click:Connect(newBtnCallback)
                
                currentButtonCount = currentButtonCount + 1
                ResizeButtonsInRow() -- This will be called by ChildAdded, but explicit call ensures order
                -- UpdatePageCanvasSize() will be called by ChildAdded too.
                
                -- For simplicity, the returned functions from :AddButton will control THAT specific added button
                local AddedButtonSpecificFunctions = {}
                function AddedButtonSpecificFunctions:Fire() newBtnCallback(); return AddedButtonSpecificFunctions end
                function AddedButtonSpecificFunctions:Hide() addedButton.Visible = false; ResizeButtonsInRow(); UpdatePageCanvasSize(); return AddedButtonSpecificFunctions end
                function AddedButtonSpecificFunctions:Show() addedButton.Visible = true; ResizeButtonsInRow(); UpdatePageCanvasSize(); return AddedButtonSpecificFunctions end
                function AddedButtonSpecificFunctions:Text(txt) addedButtonLabel.Text = txt or newBtnText; return AddedButtonSpecificFunctions end
                function AddedButtonSpecificFunctions:Remove() addedButton:Destroy(); currentButtonCount = currentButtonCount - 1; ResizeButtonsInRow(); UpdatePageCanvasSize(); return nil end -- Return ButtonFunctions (outer) or nil
                function AddedButtonSpecificFunctions:SetFunction(fn) newBtnCallback = fn or function()end; return AddedButtonSpecificFunctions end
                return AddedButtonSpecificFunctions -- Return functions for the *added* button
            end
            ButtonFunctions.AddButton = ButtonFunctions:AddButton -- Expose it this way

            function ButtonFunctions:Fire() callback(); return ButtonFunctions end
            function ButtonFunctions:Hide() buttonFrame.Visible = false; UpdatePageCanvasSize(); return ButtonFunctions end -- Hide whole frame
            function ButtonFunctions:Show() buttonFrame.Visible = true; UpdatePageCanvasSize(); return ButtonFunctions end
            function ButtonFunctions:Text(txt) buttonLabel.Text = txt or text; return ButtonFunctions end
            function ButtonFunctions:Remove() buttonFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            function ButtonFunctions:SetFunction(fn) callback = fn or function()end; return ButtonFunctions end
            return ButtonFunctions
        end

        function TabComponents:NewSection(text)
            text = text or "Section"
            local sectionFrame = UIUtils.CreateInstance("Frame", {Name = "sectionFrame", Parent = page, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, -12, 0, 18)})
            local sectionLayout = UIUtils.CreateInstance("UIListLayout", {Parent = sectionFrame, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,4)})
            
            local sectionLabel = UIUtils.CreateInstance("TextLabel", {Name = "sectionLabel", Parent = sectionFrame, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(0,0,1,0), Font = library.Theme.DefaultFont, LineHeight = 1, Text = text, TextColor3 = library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, RichText = true})
            -- No padding needed on label if sectionFrame itself has padding from page
            
            local textSize = TextService:GetTextSize(sectionLabel.Text, sectionLabel.TextSize, sectionLabel.Font, Vector2.new(math.huge, sectionFrame.AbsoluteSize.Y))
            sectionLabel.Size = UDim2.new(0, textSize.X + 4, 1, 0) -- Add padding to label for aesthetics around text

            local rightBar = UIUtils.CreateInstance("Frame", {Name = "rightBar", Parent = sectionFrame, BackgroundColor3 = library.Theme.BorderColor, BorderSizePixel = 0, Size = UDim2.new(1, -(textSize.X + 4 + sectionLayout.Padding.Offset), 0, 1)}) -- Fill remaining space
            
            UpdatePageCanvasSize()
            local SectionFunctions = {}
            function SectionFunctions:Text(newText)
                sectionLabel.Text = newText or text
                local newTextSize = TextService:GetTextSize(sectionLabel.Text, sectionLabel.TextSize, sectionLabel.Font, Vector2.new(math.huge, sectionFrame.AbsoluteSize.Y))
                sectionLabel.Size = UDim2.new(0, newTextSize.X + 4, 1, 0)
                rightBar.Size = UDim2.new(1, -(newTextSize.X + 4 + sectionLayout.Padding.Offset), 0, 1)
                return SectionFunctions
            end
            function SectionFunctions:Hide() sectionFrame.Visible = false; UpdatePageCanvasSize(); return SectionFunctions end
            function SectionFunctions:Show() sectionFrame.Visible = true; UpdatePageCanvasSize(); return SectionFunctions end
            function SectionFunctions:Remove() sectionFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            return SectionFunctions
        end
        
        function TabComponents:NewToggle(text, defaultState, callback)
            text = text or "Toggle"
            defaultState = defaultState or false
            callback = callback or function(state) print("Toggle changed to:", state) end

            local toggleButtonFrame = UIUtils.CreateInstance("TextButton", {Name = "toggleButtonFrame", Parent = page, BackgroundTransparency = 1, ClipsDescendants = false, Size = UDim2.new(1, -12, 0, 22), Text=""})
            local toggleLayout = UIUtils.CreateInstance("UIListLayout", {Parent = toggleButtonFrame, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,6)})

            local toggleEdge = UIUtils.CreateInstance("Frame", {Name = "toggleEdge", Parent = toggleButtonFrame, BackgroundColor3 = library.Theme.TertiaryBackground, Size = UDim2.new(0,18,0,18)})
            UIUtils.CreateInstance("UICorner", {Parent = toggleEdge, CornerRadius = UDim.new(0,2)})
            local toggleInner = UIUtils.CreateInstance("Frame", {Name = "toggleInner", Parent = toggleEdge, AnchorPoint=Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(1,-2,1,-2)})
            UIUtils.CreateInstance("UICorner", {Parent = toggleInner, CornerRadius = UDim.new(0,2)})
            UIUtils.CreateInstance("UIGradient", {Parent = toggleInner, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1, library.Theme.SecondaryBackground)}, Rotation = 90})
            
            local toggleDesign = UIUtils.CreateInstance("Frame", {Name = "toggleDesign", Parent = toggleInner, AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency = defaultState and 0 or 1, Position = UDim2.new(0.5,0,0.5,0), Size = defaultState and UDim2.new(0,12,0,12) or UDim2.new(0,0,0,0)})
            UIUtils.CreateInstance("UICorner", {Parent = toggleDesign, CornerRadius = UDim.new(0,2)})
            UIUtils.CreateInstance("UIGradient", {Parent = toggleDesign, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryAccent), ColorSequenceKeypoint.new(1, library.Theme.PrimaryAccentDim)}, Rotation = 90})

            local toggleLabel = UIUtils.CreateInstance("TextLabel", {Name = "toggleLabel", Parent = toggleButtonFrame, BackgroundTransparency = 1, Size = UDim2.new(1, - (18 + 6 + 50), 0, 22), Font = library.Theme.DefaultFont, LineHeight = 1.15, Text = text, TextColor3 = library.Theme.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, RichText = true})
            -- Size will be adjusted by Extras folder later if AddKeybind is called

            local ExtrasFolder = UIUtils.CreateInstance("Folder", {Name = "Extras", Parent = toggleButtonFrame})
            local ExtrasLayout = UIUtils.CreateInstance("UIListLayout", {Parent = ExtrasFolder, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,2)})
            toggleButtonFrame.LayoutOrder = 0
            ExtrasFolder.LayoutOrder = 1 -- Ensure Extras folder is to the right

            local currentTextSize = TextService:GetTextSize(toggleLabel.Text, toggleLabel.TextSize, toggleLabel.Font, Vector2.new(math.huge, math.huge))
            local availableWidthForLabel = toggleButtonFrame.AbsoluteSize.X - toggleLayout.Padding.Offset - toggleEdge.AbsoluteSize.X - ExtrasLayout.AbsoluteContentSize.X - ExtrasLayout.Padding.Offset
            toggleLabel.Size = UDim2.new(0, math.min(currentTextSize.X, availableWidthForLabel), 1, 0)


            toggleButtonFrame.MouseEnter:Connect(function() TweenService:Create(toggleLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.HoverTextColor}):Play() end)
            toggleButtonFrame.MouseLeave:Connect(function() TweenService:Create(toggleLabel, TweenTable["component_hover_anim"], {TextColor3 = library.Theme.TextColor}):Play() end)

            CreateTween("toggle_state_change_anim", 0.13)
            local isOn = defaultState
            
            toggleButtonFrame.MouseButton1Click:Connect(function()
                isOn = not isOn
                local targetSize = isOn and UDim2.new(0,12,0,12) or UDim2.new(0,0,0,0)
                local targetTransparency = isOn and 0 or 1
                TweenService:Create(toggleDesign, TweenTable["toggle_state_change_anim"], {Size = targetSize}):Play()
                TweenService:Create(toggleDesign, TweenTable["toggle_state_change_anim"], {BackgroundTransparency = targetTransparency}):Play()
                pcall(callback, isOn)
            end)

            if defaultState then pcall(callback, true) end -- Call initial callback if default is true

            local ToggleFunctions = {}
            function ToggleFunctions:Text(newText) toggleLabel.Text = newText or text; return ToggleFunctions end
            function ToggleFunctions:Hide() toggleButtonFrame.Visible = false; UpdatePageCanvasSize(); return ToggleFunctions end
            function ToggleFunctions:Show() toggleButtonFrame.Visible = true; UpdatePageCanvasSize(); return ToggleFunctions end
            function ToggleFunctions:Change() toggleButtonFrame.MouseButton1Click:Fire(); return ToggleFunctions end -- Simulate click
            function ToggleFunctions:Remove() toggleButtonFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            function ToggleFunctions:Set(newState) 
                if typeof(newState) ~= "boolean" then return ToggleFunctions end
                if isOn ~= newState then self:Change() end
                return ToggleFunctions
            end
            function ToggleFunctions:SetFunction(newCallback) callback = newCallback or function()end; return ToggleFunctions end
            
            local keybindCallback = callback -- Store original toggle callback for keybind part
            
            function ToggleFunctions:AddKeybind(defaultKey)
                defaultKey = defaultKey or Enum.KeyCode.P
                
                local keybindButton = UIUtils.CreateInstance("TextButton", {Name = "keybind", Parent = ExtrasFolder, BackgroundColor3 = library.Theme.TertiaryBackground, Size = UDim2.new(0,30,0,22), AutoButtonColor = false, Text=""}) -- Min size initially
                UIUtils.CreateInstance("UICorner", {Parent = keybindButton, CornerRadius = UDim.new(0,2)})
                local keybindBg = UIUtils.CreateInstance("Frame", {Name = "keybindBackground", Parent = keybindButton, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,-2,1,-2)})
                UIUtils.CreateInstance("UIGradient", {Parent = keybindBg, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1, library.Theme.SecondaryBackground)}, Rotation = 90})
                UIUtils.CreateInstance("UICorner", {Parent = keybindBg, CornerRadius = UDim.new(0,2)})
                local keybindLabel = UIUtils.CreateInstance("TextLabel", {Name = "keybindButtonLabel", Parent = keybindBg, AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,0,1,0), Font=library.Theme.DefaultFont, Text="...", TextColor3=library.Theme.TextColor, TextSize=14, RichText=true})
                
                local Shortcuts = { Return = "enter" }
                keybindLabel.Text = Shortcuts[defaultKey.Name] or defaultKey.Name
                CreateTween("keybind_resize_anim", 0.08)

                local function ResizeKeybindDisplay()
                    local keybindTextSize = TextService:GetTextSize(keybindLabel.Text, keybindLabel.TextSize, keybindLabel.Font, Vector2.new(math.huge,math.huge))
                    local newWidth = math.max(28, keybindTextSize.X + 6) -- Min width of 28 for "..."
                    local targetSize = UDim2.new(0, newWidth + 2, 0, 22) -- +2 for outer button border
                    TweenService:Create(keybindButton, TweenTable["keybind_resize_anim"], {Size = targetSize}):Play()
                    
                    -- Adjust toggle label width
                    local extrasWidth = ExtrasLayout.AbsoluteContentSize.X
                    local availableWidthForLabel = toggleButtonFrame.AbsoluteSize.X - toggleLayout.Padding.Offset - toggleEdge.AbsoluteSize.X - extrasWidth - ExtrasLayout.Padding.Offset
                    toggleLabel.Size = UDim2.new(0, math.max(10, availableWidthForLabel), 1, 0)

                end
                keybindLabel:GetPropertyChangedSignal("Text"):Connect(ResizeKeybindDisplay)
                ResizeKeybindDisplay() -- Initial size
                UpdatePageCanvasSize()
    
                local currentBoundKey = defaultKey
                keybindButton.MouseButton1Click:Connect(function()
                    keybindLabel.Text = "..."
                    ResizeKeybindDisplay()
                    local inputObject = UserInputService.InputBegan:Wait()
                    if UserInputService.WindowFocused and inputObject.KeyCode.Name ~= "Unknown" then
                        currentBoundKey = inputObject.KeyCode
                        keybindLabel.Text = Shortcuts[currentBoundKey.Name] or currentBoundKey.Name
                    else
                        keybindLabel.Text = Shortcuts[currentBoundKey.Name] or currentBoundKey.Name -- Revert if invalid
                    end
                    ResizeKeybindDisplay()
                end)
    
                local keybindListenerConnection
                keybindListenerConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not toggleButtonFrame or not toggleButtonFrame.Parent then -- Auto-disconnect
                        if keybindListenerConnection then keybindListenerConnection:Disconnect() end
                        return
                    end
                    if not gameProcessed and input.KeyCode == currentBoundKey then
                        -- Check for chat focus
                        local chatFocused = false
                        local playerGui = Player:FindFirstChild("PlayerGui")
                        if playerGui then
                            local chat = playerGui:FindFirstChild("Chat")
                            if chat then
                                local frame = chat:FindFirstChild("Frame")
                                if frame then
                                    local chatBarParent = frame:FindFirstChild("ChatBarParentFrame")
                                    if chatBarParent and chatBarParent:FindFirstChild("Frame") and chatBarParent.Frame:FindFirstChild("BoxFrame") and chatBarParent.Frame.BoxFrame:FindFirstChild("Frame") and chatBarParent.Frame.BoxFrame.Frame:FindFirstChild("ChatBar") then
                                        if chatBarParent.Frame.BoxFrame.Frame.ChatBar:IsFocused() then
                                            chatFocused = true
                                        end
                                    end
                                end
                            end
                        end
                        if not chatFocused then
                            ToggleFunctions:Change() -- Fire the main toggle's change
                        end
                    end
                end)
    
                local ExtraKeybindFunctions = {}
                function ExtraKeybindFunctions:SetKey(newKeyEnum)
                    if typeof(newKeyEnum) == "EnumItem" and newKeyEnum.EnumType == Enum.KeyCode then
                        currentBoundKey = newKeyEnum
                        keybindLabel.Text = Shortcuts[currentBoundKey.Name] or currentBoundKey.Name
                        ResizeKeybindDisplay()
                    end
                    return ExtraKeybindFunctions
                end
                function ExtraKeybindFunctions:Fire() ToggleFunctions:Change(); return ExtraKeybindFunctions end
                -- SetFunction for the keybind part could change what the keybind *does*, but it's tied to the toggle.
                -- For simplicity, it will always just fire the toggle's main callback.
                function ExtraKeybindFunctions:Hide() keybindButton.Visible = false; ResizeKeybindDisplay(); UpdatePageCanvasSize(); return ExtraKeybindFunctions end
                function ExtraKeybindFunctions:Show() keybindButton.Visible = true; ResizeKeybindDisplay(); UpdatePageCanvasSize(); return ExtraKeybindFunctions end
                ToggleFunctions.Keybind = ExtraKeybindFunctions -- Attach to the main ToggleFunctions object
                return ToggleFunctions -- Return the main toggle functions for chaining
            end
            UpdatePageCanvasSize()
            return ToggleFunctions
        end

        function TabComponents:NewKeybind(text, defaultKey, callback)
            text = text or "Keybind"
            defaultKey = defaultKey or Enum.KeyCode.P
            callback = callback or function(keyCodeName) print("Keybind "..keyCodeName.." pressed") end

            local keybindFrame = UIUtils.CreateInstance("Frame", {Name = "keybindFrame", Parent = page, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1,-12,0,24)})
            local keybindLayout = UIUtils.CreateInstance("UIListLayout", {Parent = keybindFrame, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0,4)})
            
            local keybindLabelText = UIUtils.CreateInstance("TextLabel", {Name = "keybindLabel", Parent = keybindFrame, BackgroundTransparency=1, Size=UDim2.new(1,-40,1,0), Font=library.Theme.DefaultFont, Text=text, TextColor3=library.Theme.TextColor, TextSize=14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, RichText=true})
            -- Padding in keybindFrame handles spacing for keybindLabelText

            local keybindButton = UIUtils.CreateInstance("TextButton", {Name = "keybindButtonActual", Parent = keybindFrame, BackgroundColor3 = library.Theme.TertiaryBackground, Size = UDim2.new(0,30,0,22), AutoButtonColor = false, Text=""}) -- Min size
            UIUtils.CreateInstance("UICorner", {Parent = keybindButton, CornerRadius = UDim.new(0,2)})
            local keybindButtonBg = UIUtils.CreateInstance("Frame", {Name = "keybindButtonBackground", Parent = keybindButton, AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,-2,1,-2)})
            UIUtils.CreateInstance("UIGradient", {Parent = keybindButtonBg, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1, library.Theme.SecondaryBackground)}, Rotation = 90})
            UIUtils.CreateInstance("UICorner", {Parent = keybindButtonBg, CornerRadius = UDim.new(0,2)})
            local keybindButtonDisplayText = UIUtils.CreateInstance("TextLabel", {Name = "keybindButtonDisplayText", Parent = keybindButtonBg, AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,0,1,0), Font=library.Theme.DefaultFont, Text="...", TextColor3=library.Theme.TextColor, TextSize=14, RichText=true})
            
            local Shortcuts = { Return = "enter" }
            keybindButtonDisplayText.Text = Shortcuts[defaultKey.Name] or defaultKey.Name
            
            local function ResizeKeybindButtonDisplay()
                local currentTextSize = TextService:GetTextSize(keybindButtonDisplayText.Text, keybindButtonDisplayText.TextSize, keybindButtonDisplayText.Font, Vector2.new(math.huge,math.huge))
                local newWidth = math.max(28, currentTextSize.X + 6)
                local targetSize = UDim2.new(0, newWidth + 2, 0, 22)
                TweenService:Create(keybindButton, TweenTable["keybind_resize_anim"] or TweenInfo.new(0.08), {Size = targetSize}):Play()
                keybindLabelText.Size = UDim2.new(1, -(newWidth + 2 + keybindLayout.Padding.Offset), 1, 0) -- Adjust text label size
            end
            if not TweenTable["keybind_resize_anim"] then CreateTween("keybind_resize_anim", 0.08) end
            keybindButtonDisplayText:GetPropertyChangedSignal("Text"):Connect(ResizeKeybindButtonDisplay)
            ResizeKeybindButtonDisplay()

            local currentBoundKeyName = defaultKey.Name -- Store as name for the listener
            keybindButton.MouseButton1Click:Connect(function()
                keybindButtonDisplayText.Text = "..."
                ResizeKeybindButtonDisplay()
                local inputObject = UserInputService.InputBegan:Wait()
                if UserInputService.WindowFocused and inputObject.KeyCode.Name ~= "Unknown" then
                    currentBoundKeyName = inputObject.KeyCode.Name
                    keybindButtonDisplayText.Text = Shortcuts[currentBoundKeyName] or currentBoundKeyName
                else
                    keybindButtonDisplayText.Text = Shortcuts[currentBoundKeyName] or currentBoundKeyName -- Revert
                end
                ResizeKeybindButtonDisplay()
            end)
            
            local keybindListener
            keybindListener = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not keybindFrame or not keybindFrame.Parent then
                    if keybindListener then keybindListener:Disconnect() end
                    return
                end
                if not gameProcessed and input.KeyCode.Name == currentBoundKeyName then
                     local chatFocused = false
                     local playerGui = Player:FindFirstChild("PlayerGui")
                     if playerGui then
                         local chat = playerGui:FindFirstChild("Chat")
                         if chat then
                             local frame = chat:FindFirstChild("Frame")
                             if frame then
                                 local chatBarParent = frame:FindFirstChild("ChatBarParentFrame")
                                 if chatBarParent and chatBarParent:FindFirstChild("Frame") and chatBarParent.Frame:FindFirstChild("BoxFrame") and chatBarParent.Frame.BoxFrame:FindFirstChild("Frame") and chatBarParent.Frame.BoxFrame.Frame:FindFirstChild("ChatBar") then
                                     if chatBarParent.Frame.BoxFrame.Frame.ChatBar:IsFocused() then
                                         chatFocused = true
                                     end
                                 end
                             end
                         end
                     end
                    if not chatFocused then
                        pcall(callback, currentBoundKeyName)
                    end
                end
            end)
            
            UpdatePageCanvasSize()
            local KeybindFunctions = {}
            function KeybindFunctions:Fire() pcall(callback, currentBoundKeyName); return KeybindFunctions end
            function KeybindFunctions:SetFunction(newCb) callback = newCb or function()end; return KeybindFunctions end
            function KeybindFunctions:SetKey(newKeyEnum)
                if typeof(newKeyEnum) == "EnumItem" and newKeyEnum.EnumType == Enum.KeyCode then
                    currentBoundKeyName = newKeyEnum.Name
                    keybindButtonDisplayText.Text = Shortcuts[currentBoundKeyName] or currentBoundKeyName
                    ResizeKeybindButtonDisplay()
                end
                return KeybindFunctions
            end
            function KeybindFunctions:Text(newText) keybindLabelText.Text = newText or text; ResizeKeybindButtonDisplay(); return KeybindFunctions end
            function KeybindFunctions:Hide() keybindFrame.Visible = false; UpdatePageCanvasSize(); return KeybindFunctions end
            function KeybindFunctions:Show() keybindFrame.Visible = true; UpdatePageCanvasSize(); return KeybindFunctions end
            function KeybindFunctions:Remove() keybindFrame:Destroy(); if keybindListener then keybindListener:Disconnect() end; UpdatePageCanvasSize(); return nil end
            return KeybindFunctions
        end

        function TabComponents:NewTextbox(text, options)
            options = options or {}
            text = text or "Textbox"
            local defaultText = options.default or ""
            local placeholder = options.placeholder or ""
            local format = string.lower(options.format or "all") -- "all", "numbers", "lower", "upper"
            local boxType = string.lower(options.type or "small") -- "small", "medium", "large"
            local autoExecuteOnLostFocus = options.autoExecute or true
            local clearOnFocus = options.clearOnFocus or false
            local callback = options.callback or function(value) print("Textbox set to:", value) end

            local mainFrameHeight = (boxType == "large" and 142) or (boxType == "medium" and 46) or 24
            local textboxFrame = UIUtils.CreateInstance("Frame", {Name = "textboxFrame", Parent = page, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1,-12,0,mainFrameHeight)})
            
            local textboxLabel = UIUtils.CreateInstance("TextLabel", {Name="textboxLabel", Parent=textboxFrame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=library.Theme.DefaultFont, Text=text, TextColor3=library.Theme.TextColor, TextSize=14, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, RichText=true})
            UIUtils.CreateInstance("UIPadding", {Parent=textboxLabel, PaddingLeft=UDim.new(0,2)}) -- Small left padding for label

            local inputFieldFrame, textBoxInput
            
            if boxType == "small" then
                textboxLabel.Size = UDim2.new(0, 200, 0, 22) -- Default width, will adjust
                local inputContainer = UIUtils.CreateInstance("Frame", {Name="inputContainer", Parent=textboxFrame, BackgroundTransparency=1, Size=UDim2.new(0,133,0,22), Position=UDim2.new(1, -133 -2, 0,1)}) -- Align right
                textboxFrame:SetAttribute("InputContainerRef", inputContainer) -- For later resizing
                
                inputFieldFrame = UIUtils.CreateInstance("Frame", {Name="inputFieldFrame", Parent=inputContainer, BackgroundColor3=library.Theme.BorderColor, Size=UDim2.new(1,0,1,0)})
                UIUtils.CreateInstance("UICorner", {Parent=inputFieldFrame, CornerRadius=UDim.new(0,2)})
                local inputFieldBg = UIUtils.CreateInstance("Frame", {Name="inputFieldBg", Parent=inputFieldFrame, BackgroundColor3=library.Theme.PrimaryBackground, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5)})
                UIUtils.CreateInstance("UICorner", {Parent=inputFieldBg, CornerRadius=UDim.new(0,2)})
                UIUtils.CreateInstance("UIGradient", {Parent=inputFieldBg, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1,library.Theme.SecondaryBackground)}, Rotation=90})
                
                textBoxInput = UIUtils.CreateInstance("TextBox", {Name="textBoxInput", Parent=inputFieldBg, BackgroundTransparency=1, Size=UDim2.new(1,-8,1,-4), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Font=library.Theme.DefaultFont, PlaceholderColor3=library.Theme.PlaceholderTextColor, PlaceholderText=placeholder, Text=defaultText, TextColor3=library.Theme.TextColor, TextSize=14, ClearTextOnFocus=clearOnFocus, ClipsDescendants=true, TextXAlignment=Enum.TextXAlignment.Right})
                UIUtils.CreateInstance("UIPadding", {Parent=textBoxInput, PaddingRight=UDim.new(0,4)})

                local function UpdateSmallTextboxLayout()
                    local labelSize = TextService:GetTextSize(textboxLabel.Text, textboxLabel.TextSize, textboxLabel.Font, Vector2.new(math.huge, textboxLabel.AbsoluteSize.Y))
                    textboxLabel.Size = UDim2.new(0, labelSize.X + 2, 1, 0)
                    
                    local inputTextSize = TextService:GetTextSize(textBoxInput.Text or placeholder, textBoxInput.TextSize, textBoxInput.Font, Vector2.new(math.huge, textBoxInput.AbsoluteSize.Y))
                    local minInputWidth = TextService:GetTextSize(placeholder, textBoxInput.TextSize, textBoxInput.Font, Vector2.new(math.huge,math.huge)).X + 12
                    minInputWidth = math.max(minInputWidth, 50) -- Absolute minimum

                    local currentInputWidth = math.max(minInputWidth, inputTextSize.X + 12)
                    local remainingWidth = textboxFrame.AbsoluteSize.X - (labelSize.X + 2) - 8 -- 8 for padding between label and input
                    currentInputWidth = math.min(currentInputWidth, remainingWidth)
                    
                    inputContainer.Size = UDim2.new(0, math.max(minInputWidth, currentInputWidth), 1, 0)
                    inputContainer.Position = UDim2.new(1, -inputContainer.AbsoluteSize.X -2, 0, 1)
                end
                textboxLabel:GetPropertyChangedSignal("Text"):Connect(UpdateSmallTextboxLayout)
                textBoxInput:GetPropertyChangedSignal("Text"):Connect(UpdateSmallTextboxLayout)
                textBoxInput:GetPropertyChangedSignal("PlaceholderText"):Connect(UpdateSmallTextboxLayout)
                textboxFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSmallTextboxLayout)
                UpdateSmallTextboxLayout()


            elseif boxType == "medium" or boxType == "large" then
                local fieldHeight = (boxType == "large" and 118) or 22
                textboxLabel.Size = UDim2.new(1,0,0,20) -- Full width for label above
                
                inputFieldFrame = UIUtils.CreateInstance("Frame", {Name="inputFieldFrame", Parent=textboxFrame, BackgroundColor3=library.Theme.BorderColor, Size=UDim2.new(1,0,0,fieldHeight), Position=UDim2.new(0,0,0,24)})
                UIUtils.CreateInstance("UICorner", {Parent=inputFieldFrame, CornerRadius=UDim.new(0,2)})
                local inputFieldBg = UIUtils.CreateInstance("Frame", {Name="inputFieldBg", Parent=inputFieldFrame, BackgroundColor3=library.Theme.PrimaryBackground, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5)})
                UIUtils.CreateInstance("UICorner", {Parent=inputFieldBg, CornerRadius=UDim.new(0,2)})
                UIUtils.CreateInstance("UIGradient", {Parent=inputFieldBg, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1,library.Theme.SecondaryBackground)}, Rotation=90})

                textBoxInput = UIUtils.CreateInstance("TextBox", {Name="textBoxInput", Parent=inputFieldBg, BackgroundTransparency=1, Size=UDim2.new(1,-8,1,-4), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Font=library.Theme.DefaultFont, PlaceholderColor3=library.Theme.PlaceholderTextColor, PlaceholderText=placeholder, Text=defaultText, TextColor3=library.Theme.TextColor, TextSize=14, ClearTextOnFocus=clearOnFocus, ClipsDescendants=true, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped = (boxType == "large"), TextYAlignment = (boxType == "large" and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center) })
                UIUtils.CreateInstance("UIPadding", {Parent=textBoxInput, PaddingLeft=UDim.new(0,4), PaddingTop=UDim.new(0, (boxType == "large" and 2 or 0)), PaddingBottom=UDim.new(0, (boxType == "large" and 2 or 0)) })
            end
            
            local inputFieldFrameRef = inputFieldFrame -- Store reference for tweening

            textBoxInput:GetPropertyChangedSignal("Text"):Connect(function()
                if format == "numbers" then textBoxInput.Text = textBoxInput.Text:gsub("%D+", "")
                elseif format == "lower" then textBoxInput.Text = string.lower(textBoxInput.Text)
                elseif format == "upper" then textBoxInput.Text = string.upper(textBoxInput.Text)
                end
                if boxType == "small" then textboxFrame:GetAttribute("InputContainerRef"):FindFirstChild("inputFieldFrame"):GetPropertyChangedSignal("Text"):Fire() end -- Trigger resize for small
            end)

            textboxFrame.MouseEnter:Connect(function() TweenService:Create(textboxLabel, TweenTable["component_hover_anim"] or TweenInfo.new(0.16), {TextColor3 = library.Theme.HoverTextColor}):Play() end)
            textboxFrame.MouseLeave:Connect(function() TweenService:Create(textboxLabel, TweenTable["component_hover_anim"] or TweenInfo.new(0.16), {TextColor3 = library.Theme.TextColor}):Play() end)
            
            textBoxInput.Focused:Connect(function() TweenService:Create(inputFieldFrameRef, TweenTable["component_hover_anim"] or TweenInfo.new(0.16), {BackgroundColor3 = library.Theme.PrimaryAccent}):Play() end)
            textBoxInput.FocusLost:Connect(function(enterPressed)
                TweenService:Create(inputFieldFrameRef, TweenTable["component_hover_anim"] or TweenInfo.new(0.16), {BackgroundColor3 = library.Theme.BorderColor}):Play()
                if autoExecuteOnLostFocus or enterPressed then
                    pcall(callback, textBoxInput.Text)
                end
            end)

            UpdatePageCanvasSize()
            local TextboxFunctions = {}
            function TextboxFunctions:Input(newText) textBoxInput.Text = newText or defaultText; return TextboxFunctions end
            function TextboxFunctions:Fire() pcall(callback, textBoxInput.Text); return TextboxFunctions end
            function TextboxFunctions:SetFunction(newCb) callback = newCb or function()end; return TextboxFunctions end
            function TextboxFunctions:Text(newLabelText) textboxLabel.Text = newLabelText or text; if boxType == "small" then textboxFrame:GetAttribute("InputContainerRef"):FindFirstChild("inputFieldFrame"):GetPropertyChangedSignal("Text"):Fire() end; return TextboxFunctions end
            function TextboxFunctions:Hide() textboxFrame.Visible = false; UpdatePageCanvasSize(); return TextboxFunctions end
            function TextboxFunctions:Show() textboxFrame.Visible = true; UpdatePageCanvasSize(); return TextboxFunctions end
            function TextboxFunctions:Remove() textboxFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            function TextboxFunctions:Place(newPlaceholder) textBoxInput.PlaceholderText = newPlaceholder or ""; if boxType == "small" then textboxFrame:GetAttribute("InputContainerRef"):FindFirstChild("inputFieldFrame"):GetPropertyChangedSignal("Text"):Fire() end; return TextboxFunctions end
            return TextboxFunctions
        end

        function TabComponents:NewSelector(text, defaultOption, optionList, callback)
            text = text or "Selector"
            defaultOption = defaultOption or (optionList and #optionList > 0 and optionList[1] or ". . .")
            optionList = optionList or {}
            callback = callback or function(selected) print("Selected:", selected) end
            
            local selectorFrame = UIUtils.CreateInstance("Frame", {Name="selectorFrame", Parent=page, BackgroundTransparency=1, ClipsDescendants=false, Size=UDim2.new(1,-12,0,46)}) -- ClipsDescendants false for dropdown
            UIUtils.CreateInstance("UIListLayout", {Parent=selectorFrame, SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center})

            local selectorLabel = UIUtils.CreateInstance("TextLabel", {Name="selectorLabel", Parent=selectorFrame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), Font=library.Theme.DefaultFont, Text=text, TextColor3=library.Theme.TextColor, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, RichText=true})
            UIUtils.CreateInstance("UIPadding", {Parent=selectorLabel, PaddingLeft=UDim.new(0,2)})

            local dropdownButton = UIUtils.CreateInstance("TextButton", {Name="dropdownButton", Parent=selectorFrame, BackgroundColor3=library.Theme.TertiaryBackground, Size=UDim2.new(1,0,0,22), AutoButtonColor=false, Text=""})
            UIUtils.CreateInstance("UICorner", {Parent=dropdownButton, CornerRadius=UDim.new(0,2)})
            local dropdownButtonBg = UIUtils.CreateInstance("Frame", {Name="dropdownButtonBg", Parent=dropdownButton, AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,-2,1,-2)})
            UIUtils.CreateInstance("UIGradient", {Parent=dropdownButtonBg, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1,library.Theme.SecondaryBackground)}, Rotation=90})
            UIUtils.CreateInstance("UICorner", {Parent=dropdownButtonBg, CornerRadius=UDim.new(0,2)})
            local selectedTextLabel = UIUtils.CreateInstance("TextLabel", {Name="selectedTextLabel", Parent=dropdownButtonBg, BackgroundTransparency=1, Size=UDim2.new(1,-28,1,0), Position=UDim2.new(0,4,0,0), Font=library.Theme.DefaultFont, Text=defaultOption, TextColor3=library.Theme.TextColor, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left})
            local dropdownArrow = UIUtils.CreateInstance("TextLabel", {Name="dropdownArrow", Parent=dropdownButtonBg, BackgroundTransparency=1, Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-20,0,0), Font=library.Theme.DefaultFont, Text="▼", TextColor3=library.Theme.DimTextColor, TextSize=14, TextXAlignment=Enum.TextXAlignment.Center})

            local optionsFrame = UIUtils.CreateInstance("ScrollingFrame", {Name="optionsFrame", Parent=dropdownButton, BackgroundColor3=library.Theme.SecondaryBackground, Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,2), BorderSizePixel=1, BorderColor3=library.Theme.BorderColor, ClipsDescendants=true, Visible=false, ZIndex=2, ScrollBarThickness=2, ScrollBarImageColor3=library.Theme.ScrollBarColor})
            UIUtils.CreateInstance("UICorner", {Parent=optionsFrame, CornerRadius=UDim.new(0,2)})
            local optionsLayout = UIUtils.CreateInstance("UIListLayout", {Parent=optionsFrame, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)})
            UIUtils.CreateInstance("UIPadding", {Parent=optionsFrame, PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,2),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)})

            local isOpen = false
            CreateTween("dropdown_anim", 0.15)

            local function UpdateOptionsList()
                for _,child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                local totalHeight = 0
                for _, optionText in ipairs(optionList) do
                    local optionButton = UIUtils.CreateInstance("TextButton", {Name=optionText, Parent=optionsFrame, BackgroundTransparency=1, Size=UDim2.new(1,-4,0,20), AutoButtonColor=false, Font=library.Theme.DefaultFont, Text=optionText, TextColor3=library.Theme.DimTextColor, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
                    UIUtils.CreateInstance("UIPadding", {Parent=optionButton, PaddingLeft=UDim.new(0,4)})
                    if optionText == selectedTextLabel.Text then optionButton.TextColor3 = library.Theme.PrimaryAccent end
                    
                    optionButton.MouseEnter:Connect(function() optionButton.BackgroundColor3 = library.Theme.TertiaryBackground; optionButton.BackgroundTransparency = 0.5 end)
                    optionButton.MouseLeave:Connect(function() optionButton.BackgroundTransparency = 1 end)
                    optionButton.MouseButton1Click:Connect(function()
                        selectedTextLabel.Text = optionText
                        isOpen = false
                        TweenService:Create(optionsFrame, TweenTable["dropdown_anim"], {Size=UDim2.new(1,0,0,0)}):Play()
                        optionsFrame.Visible = false
                        dropdownArrow.Text = "▼"
                        pcall(callback, optionText)
                        -- Update colors of other options
                        for _, ob in ipairs(optionsFrame:GetChildren()) do
                            if ob:IsA("TextButton") then ob.TextColor3 = (ob.Text == optionText and library.Theme.PrimaryAccent or library.Theme.DimTextColor) end
                        end
                    end)
                    totalHeight = totalHeight + 20 + optionsLayout.Padding.Offset
                end
                optionsFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, totalHeight - optionsLayout.Padding.Offset)) -- Remove last padding
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    UpdateOptionsList() -- Rebuild options to reflect current selection/list
                    optionsFrame.Visible = true
                    local targetHeight = math.min(120, optionsFrame.CanvasSize.Y.Offset + 4) -- Max height 120
                    TweenService:Create(optionsFrame, TweenTable["dropdown_anim"], {Size=UDim2.new(1,0,0,targetHeight)}):Play()
                    dropdownArrow.Text = "▲"
                else
                    TweenService:Create(optionsFrame, TweenTable["dropdown_anim"], {Size=UDim2.new(1,0,0,0)}):Play()
                    task.delay(TweenTable["dropdown_anim"].Time, function() if not isOpen then optionsFrame.Visible = false end end) -- Hide after anim if still closed
                    dropdownArrow.Text = "▼"
                end
            end)
            
            UpdatePageCanvasSize()
            UpdateOptionsList() -- Initial population if needed for default
            pcall(callback, defaultOption) -- Call initial callback

            local SelectorFunctions = {}
            function SelectorFunctions:AddOption(newOption) table.insert(optionList, newOption); if isOpen then UpdateOptionsList() end; return SelectorFunctions end
            function SelectorFunctions:RemoveOption(optionToRemove) 
                for i,opt in ipairs(optionList) do if opt == optionToRemove then table.remove(optionList, i); break end end
                if selectedTextLabel.Text == optionToRemove then selectedTextLabel.Text = (optionList[1] or "...") end
                if isOpen then UpdateOptionsList() end
                return SelectorFunctions 
            end
            function SelectorFunctions:ClearOptions() optionList = {}; selectedTextLabel.Text = "..."; if isOpen then UpdateOptionsList() end; return SelectorFunctions end
            function SelectorFunctions:SetOptions(newOptionList) optionList = newOptionList or {}; selectedTextLabel.Text = (optionList[1] or "..."); if isOpen then UpdateOptionsList() end; pcall(callback, selectedTextLabel.Text); return SelectorFunctions end
            function SelectorFunctions:Value(newValue) 
                local found = false
                for _,opt in ipairs(optionList) do if opt == newValue then found = true; break end end
                if found then selectedTextLabel.Text = newValue; pcall(callback, newValue) 
                    for _, ob in ipairs(optionsFrame:GetChildren()) do if ob:IsA("TextButton") then ob.TextColor3 = (ob.Text == newValue and library.Theme.PrimaryAccent or library.Theme.DimTextColor) end end
                end
                return SelectorFunctions 
            end
            function SelectorFunctions:SetFunction(newCb) callback = newCb or function()end; return SelectorFunctions end
            function SelectorFunctions:Text(newLabelText) selectorLabel.Text = newLabelText or text; return SelectorFunctions end
            function SelectorFunctions:Hide() selectorFrame.Visible = false; UpdatePageCanvasSize(); return SelectorFunctions end
            function SelectorFunctions:Show() selectorFrame.Visible = true; UpdatePageCanvasSize(); return SelectorFunctions end
            function SelectorFunctions:Remove() selectorFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            return SelectorFunctions
        end

        function TabComponents:NewSlider(text, options)
            options = options or {}
            text = text or "Slider"
            local suffix = options.suffix or ""
            local showCompare = options.showCompare or false -- e.g., "50 / 100"
            local compareSign = options.compareSign or "/"
            local minVal, maxVal, defaultVal = options.min or 0, options.max or 100, options.default or 0
            local callback = options.callback or function(value) print("Slider set to:", value) end
            
            defaultVal = math.clamp(defaultVal, minVal, maxVal) -- Ensure default is within bounds

            local sliderFrame = UIUtils.CreateInstance("Frame", {Name="sliderFrame", Parent=page, BackgroundTransparency=1, ClipsDescendants=true, Size=UDim2.new(1,-12,0,40)})
            local sliderLayout = UIUtils.CreateInstance("UIListLayout", {Parent=sliderFrame, SortOrder=Enum.SortOrder.LayoutOrder})

            local topLabelFrame = UIUtils.CreateInstance("Frame", {Name="topLabelFrame", Parent=sliderFrame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,18)})
            local sliderLabel = UIUtils.CreateInstance("TextLabel", {Name="sliderLabel", Parent=topLabelFrame, BackgroundTransparency=1, Size=UDim2.new(0.6,0,1,0), Position=UDim2.new(0,2,0,0), Font=library.Theme.DefaultFont, Text=text, TextColor3=library.Theme.TextColor, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, RichText=true})
            local sliderValueDisplay = UIUtils.CreateInstance("TextLabel", {Name="sliderValueDisplay", Parent=topLabelFrame, BackgroundTransparency=1, Size=UDim2.new(0.4,-2,1,0), Position=UDim2.new(0.6,0,0,0), Font=library.Theme.DefaultFont, Text="", TextColor3=library.Theme.DimTextColor, TextSize=14, TextXAlignment=Enum.TextXAlignment.Right})
            
            local sliderButton = UIUtils.CreateInstance("TextButton", {Name="sliderButton", Parent=sliderFrame, BackgroundColor3=library.Theme.BorderColor, Size=UDim2.new(1,0,0,16), AutoButtonColor=false, Text=""})
            UIUtils.CreateInstance("UICorner", {Parent=sliderButton, CornerRadius=UDim.new(0,2)})
            local sliderBg = UIUtils.CreateInstance("Frame", {Name="sliderBackground", Parent=sliderButton, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), ClipsDescendants=true})
            UIUtils.CreateInstance("UICorner", {Parent=sliderBg, CornerRadius=UDim.new(0,2)})
            UIUtils.CreateInstance("UIGradient", {Parent=sliderBg, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryBackground), ColorSequenceKeypoint.new(1,library.Theme.SecondaryBackground)}, Rotation=90})
            UIUtils.CreateInstance("UIPadding", {Parent=sliderBg, PaddingLeft=UDim.new(0,1), PaddingRight=UDim.new(0,1)})
            
            local sliderIndicator = UIUtils.CreateInstance("Frame", {Name="sliderIndicator", Parent=sliderBg, BackgroundColor3=library.Theme.PrimaryAccent, BorderSizePixel=0, Size=UDim2.new(0,0,1,-2), Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5)})
            UIUtils.CreateInstance("UICorner", {Parent=sliderIndicator, CornerRadius=UDim.new(0,2)})
            -- UIUtils.CreateInstance("UIGradient", {Parent=sliderIndicator, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,library.Theme.PrimaryAccent), ColorSequenceKeypoint.new(1,library.Theme.PrimaryAccentDim)}, Rotation=90})


            local currentValue = defaultVal
            local function UpdateDisplayAndIndicator(valueToSet, skipCallback)
                currentValue = math.clamp(valueToSet, minVal, maxVal)
                local percentage = (maxVal == minVal) and 0 or (currentValue - minVal) / (maxVal - minVal)
                sliderIndicator.Size = UDim2.new(percentage, 0, 1, -2)
                
                local roundedValue = library:RoundNumber(0, currentValue) -- Round to whole number for display usually
                local displayStr = tostring(roundedValue) .. suffix
                if showCompare then displayStr = tostring(roundedValue) .. " " .. compareSign .. " " .. tostring(maxVal) .. suffix end
                sliderValueDisplay.Text = displayStr
                
                if not skipCallback then pcall(callback, roundedValue) end
            end
            UpdateDisplayAndIndicator(defaultVal, true) -- Initial update, skip callback

            CreateTween("slider_drag_anim", 0.008)
            local isSliding = false
            sliderButton.MouseButton1Down:Connect(function(input)
                isSliding = true
                local mouseX = Mouse.X
                local barStartX = sliderBg.AbsolutePosition.X
                local barWidth = sliderBg.AbsoluteSize.X
                local percentage = math.clamp((mouseX - barStartX) / barWidth, 0, 1)
                local newValue = library:RoundNumber(0, percentage * (maxVal - minVal) + minVal)
                UpdateDisplayAndIndicator(newValue)

                local moveConn, upConn
                moveConn = UserInputService.InputChanged:Connect(function(mouseInputChanged)
                    if isSliding and mouseInputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                        mouseX = mouseInputChanged.Position.X
                        percentage = math.clamp((mouseX - barStartX) / barWidth, 0, 1)
                        newValue = library:RoundNumber(0, percentage * (maxVal - minVal) + minVal)
                        UpdateDisplayAndIndicator(newValue) -- Callback fires here as user drags
                    end
                end)
                upConn = UserInputService.InputEnded:Connect(function(mouseInputEnded)
                    if mouseInputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSliding = false
                        if moveConn then moveConn:Disconnect() end
                        if upConn then upConn:Disconnect() end
                    end
                end)
            end)

            UpdatePageCanvasSize()
            local SliderFunctions = {}
            function SliderFunctions:Value(newValue, skipCb) UpdateDisplayAndIndicator(newValue, skipCb); return SliderFunctions end
            function SliderFunctions:Max(newMax) maxVal = newMax or 100; UpdateDisplayAndIndicator(currentValue, true); return SliderFunctions end
            function SliderFunctions:Min(newMin) minVal = newMin or 0; UpdateDisplayAndIndicator(currentValue, true); return SliderFunctions end
            function SliderFunctions:SetFunction(newCb) callback = newCb or function()end; return SliderFunctions end
            function SliderFunctions:Text(newLabelText) sliderLabel.Text = newLabelText or text; return SliderFunctions end
            function SliderFunctions:Hide() sliderFrame.Visible = false; UpdatePageCanvasSize(); return SliderFunctions end
            function SliderFunctions:Show() sliderFrame.Visible = true; UpdatePageCanvasSize(); return SliderFunctions end
            function SliderFunctions:Remove() sliderFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            return SliderFunctions
        end
        
        function TabComponents:NewSeperator() -- Renamed from NewSeperator
            local separatorFrame = UIUtils.CreateInstance("Frame", {Name="separatorFrame", Parent=page, BackgroundTransparency=1, Size=UDim2.new(1,-12,0,12)})
            local bar = UIUtils.CreateInstance("Frame", {Name="bar", Parent=separatorFrame, BackgroundColor3=library.Theme.BorderColor, BorderSizePixel=0, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,-0.5)})
            UpdatePageCanvasSize()
            local SeparatorFunctions = {} -- Renamed
            function SeparatorFunctions:Hide() separatorFrame.Visible = false; UpdatePageCanvasSize(); return SeparatorFunctions end
            function SeparatorFunctions:Show() separatorFrame.Visible = true; UpdatePageCanvasSize(); return SeparatorFunctions end
            function SeparatorFunctions:Remove() separatorFrame:Destroy(); UpdatePageCanvasSize(); return nil end
            return SeparatorFunctions
        end

        function TabComponents:Open()
            WindowFunctions.CurrentTabName = tabTitle
            for _, childPage in ipairs(container:GetChildren()) do if childPage:IsA("ScrollingFrame") then childPage.Visible = false end end
            page.Visible = true
            for _, childButton in ipairs(tabButtons:GetChildren()) do if childButton:IsA("TextButton") then TweenService:Create(childButton, TweenTable["tab_text_color_anim"], {TextColor3 = library.Theme.DimTextColor}):Play() end end
            TweenService:Create(tabButton, TweenTable["tab_text_color_anim"], {TextColor3 = library.Theme.PrimaryAccent}):Play()
            return TabComponents
        end
        function TabComponents:Remove() tabButton:Destroy(); page:Destroy(); UpdatePageCanvasSize(); return nil end
        function TabComponents:Hide() tabButton.Visible = false; page.Visible = false; return TabComponents end
        function TabComponents:Show() tabButton.Visible = true; if WindowFunctions.CurrentTabName == tabTitle then page.Visible = true end; return TabComponents end
        function TabComponents:Text(newTabText) tabButton.Text = newTabText or tabTitle; return TabComponents end
        
        return TabComponents
    end
    
    function WindowFunctions:Remove() screen:Destroy(); if mainVisibilityToggleConnection then mainVisibilityToggleConnection:Disconnect() end; return nil end
    function WindowFunctions:Text(newHeaderText) headerLabel.Text = newHeaderText or currentTitle; return WindowFunctions end
    function WindowFunctions:UpdateKeybind(newKeyEnum)
        if typeof(newKeyEnum) == "EnumItem" and newKeyEnum.EnumType == Enum.KeyCode then
            currentToggleKey = newKeyEnum
        else
            warn("Window:UpdateKeybind - Invalid key provided:", newKeyEnum)
        end
        return WindowFunctions
    end
    return WindowFunctions
end
return library

```

---

## Updated Documentation (Version 2.1.0)

Here's the documentation reflecting the changes and current state. I've tried to maintain a similar style to your original example docs.

```
--[[
    UI Library (Version 2.1.0) - Enhanced by AI
    Originally by bungie#0001

    ====================================
    ==       CORE LIBRARY SETUP       ==
    ====================================

    -- // local library = loadstring(game:HttpGet(link_to_library_file))()
    -- Loads the UI library.

    -- // library.title = "My Awesome UI"
    -- Sets the main title for the UI window and watermark. Can be set *before* loading the library.
    -- Supports RichText.

    -- // library.rank = "User" (Default: "private")
    -- A string property you can set, often used in watermarks.

    -- // library.Theme = { ... }
    -- A table containing theme colors and fonts. You can modify these *after* loading the library
    -- but *before* creating UI elements (like Window, Watermark, Notifications) for them to take effect.
    -- Example:
    --   library.Theme.PrimaryAccent = Color3.fromRGB(0, 255, 0)
    --   library.Theme.DefaultFont = Enum.Font.GothamSemibold
    -- Default Theme Values:
    --   PrimaryAccent        : Color3.fromRGB(159, 115, 255) (Purple)
    --   PrimaryAccentDim     : Color3.fromRGB(128, 94, 208)
    --   PrimaryAccentHover   : Color3.fromRGB(179, 135, 255)
    --   PrimaryBackground    : Color3.fromRGB(34, 34, 34) (Dark Gray)
    --   SecondaryBackground  : Color3.fromRGB(28, 28, 28) (Darker Gray)
    --   TertiaryBackground   : Color3.fromRGB(50, 50, 50) (Medium Gray for edges)
    --   TextColor            : Color3.fromRGB(198, 198, 198) (Light Gray)
    --   DimTextColor         : Color3.fromRGB(170, 170, 170) (Dimmer Gray)
    --   HoverTextColor       : Color3.fromRGB(210, 210, 210)
    --   PlaceholderTextColor : Color3.fromRGB(140, 140, 140)
    --   BorderColor          : Color3.fromRGB(60, 60, 60)
    --   ScrollBarColor       : Color3.fromRGB(159, 115, 255)
    --   DefaultFont          : Enum.Font.Code

    -- // local Window = library:Init(initialToggleKey)
    -- Initializes and creates the main UI window.
    --   Parameters:
    --     - initialToggleKey (Enum.KeyCode, optional): The initial key to toggle the UI's visibility.
    --       Defaults to Enum.KeyCode.RightAlt if not provided.
    --   Returns: A 'Window' object with methods to manage tabs and the window itself.

    ------------------------------------
    -- Window Object Methods (from library:Init)
    ------------------------------------
    -- / Window:NewTab(tabTitle)
    -- Creates a new tab in the main UI.
    --   Parameters:
    --     - tabTitle (string, optional): The title of the tab. Supports RichText. Defaults to "Tab".
    --   Returns: A 'Tab' object with methods to add components to this tab.

    -- / Window:Remove()
    -- Destroys the entire UI window and all its contents.
    --   Returns: nil

    -- / Window:Text(newHeaderText)
    -- Sets the main header text of the UI window.
    --   Parameters:
    --     - newHeaderText (string, optional): The new text for the header. Supports RichText.
    --       Defaults to the current `library.title`.
    --   Returns: The 'Window' object (for chaining).

    -- / Window:UpdateKeybind(newKeyEnum)
    -- Sets a new key to toggle the main UI window's visibility.
    --   Parameters:
    --     - newKeyEnum (Enum.KeyCode): The new KeyCode to use.
    --   Returns: The 'Window' object (for chaining).

    ====================================
    ==          WATERMARKS            ==
    ====================================

    -- // local MainWatermark = library:Watermark(text)
    -- Creates the primary watermark at the bottom-left of the screen. Only one primary watermark system exists at a time;
    -- calling this again will destroy the previous one.
    --   Parameters:
    --     - text (string, optional): The text for the watermark. Supports RichText. Defaults to "xsx v2".
    --   Returns: A 'MainWatermark' object with methods to manage it or add more watermark segments.

    ------------------------------------
    -- MainWatermark Object Methods
    ------------------------------------
    -- / MainWatermark:AddWatermark(text)
    -- Adds an additional, separate watermark segment to the right of existing ones.
    --   Parameters:
    --     - text (string, optional): Text for the new watermark segment. Supports RichText.
    --   Returns: An 'AddedWatermark' object specific to this new segment.

    -- / MainWatermark:Hide()
    -- Hides the primary watermark segment.
    --   Returns: The 'MainWatermark' object.

    -- / MainWatermark:Show()
    -- Shows the primary watermark segment.
    --   Returns: The 'MainWatermark' object.

    -- / MainWatermark:Text(newText)
    -- Changes the text of the primary watermark segment.
    --   Parameters:
    --     - newText (string, optional): The new text. Supports RichText.
    --   Returns: The 'MainWatermark' object.

    -- / MainWatermark:Remove()
    -- Destroys the entire watermark system (all segments).
    --   Returns: nil

    ------------------------------------
    -- AddedWatermark Object Methods (from MainWatermark:AddWatermark)
    ------------------------------------
    -- / AddedWatermark:Hide()
    -- Hides this specific added watermark segment.
    --   Returns: The 'AddedWatermark' object.

    -- / AddedWatermark:Show()
    -- Shows this specific added watermark segment.
    --   Returns: The 'AddedWatermark' object.

    -- / AddedWatermark:Text(newText)
    -- Changes the text of this specific added watermark segment.
    --   Parameters:
    --     - newText (string, optional): The new text. Supports RichText.
    --   Returns: The 'AddedWatermark' object.

    -- / AddedWatermark:Remove()
    -- Destroys only this specific added watermark segment.
    --   Returns: nil

    ====================================
    ==         NOTIFICATIONS          ==
    ====================================

    -- // local NotificationHandler = library:InitNotifications()
    -- Initializes the notification system. Old notifications are cleared if this is called again.
    --   Returns: A 'NotificationHandler' object.

    ------------------------------------
    -- NotificationHandler Object Methods
    ------------------------------------
    -- / NotificationHandler:Notify(text, duration, type, callback)
    -- Displays a notification at the top-left of the screen.
    --   Parameters:
    --     - text (string, optional): Message to display. Supports RichText. Defaults to "Notification.".
    --     - duration (number, optional): How long the notification stays before auto-fading (in seconds). Defaults to 5.
    --     - type (string, optional): Style of the notification. Affects the color of the small bar.
    --       Options: "notification" (default, theme accent), "alert" (yellow), "error" (red),
    --                "success" (green), "information" (blue).
    --     - callback (function, optional): A function to call after the notification fades out.
    --   Returns: A 'NotificationInstance' object for this specific notification.

    ------------------------------------
    -- NotificationInstance Object Methods (from NotificationHandler:Notify)
    ------------------------------------
    -- / NotificationInstance:Text(newText)
    -- Changes the text of an active notification. If the notification is still in its "duration" phase,
    -- the duration timer will reset, and the progress bar will animate again.
    --   Parameters:
    --     - newText (string, optional): The new text for the notification. Supports RichText.
    --   Returns: The 'NotificationInstance' object.
    --   Note: Does not have :Hide(), :Show(), or :Remove() as notifications are timed.

    ====================================
    ==      TAB & UI COMPONENTS       ==
    ====================================
    -- UI Components are added to a 'Tab' object, which is returned by `Window:NewTab(tabTitle)`.
    -- Example: local MyTab = Window:NewTab("My Features")
    --          local MyLabel = MyTab:NewLabel("Hello World!")

    ------------------------------------
    -- Tab Object Methods (from Window:NewTab)
    ------------------------------------
    -- / Tab:Open()
    -- Opens this specific tab, making its content visible.
    --   Returns: The 'Tab' object.

    -- / Tab:Remove()
    -- Destroys this tab and all its components.
    --   Returns: nil

    -- / Tab:Hide()
    -- Hides this tab from the tab selection list and hides its content.
    --   Returns: The 'Tab' object.

    -- / Tab:Show()
    -- Shows this tab in the tab selection list. If it was the currently selected tab, its content becomes visible.
    --   Returns: The 'Tab' object.

    -- / Tab:Text(newTabText)
    -- Changes the title of this tab in the selection list.
    --   Parameters:
    --     - newTabText (string, optional): The new title. Supports RichText.
    --   Returns: The 'Tab' object.

    ---
    -- Component Creation Methods (called on a 'Tab' object)
    ---

    -- / Tab:NewLabel(text, alignment)
    -- Creates a text label.
    --   Parameters:
    --     - text (string, optional): Text to display. Supports RichText. Defaults to "Label".
    --     - alignment (string, optional): Horizontal text alignment: "left" (default), "center", "right".
    --   Returns: A 'Label' object.
    --   Label Object Methods:
    --     :Text(newText)      - Changes the label's text.
    --     :Remove()           - Destroys the label.
    --     :Hide()             - Hides the label.
    --     :Show()             - Shows the label.
    --     :Align(newAlignment)- Changes text alignment ("left", "center", "right").

    -- / Tab:NewButton(text, callback)
    -- Creates a button.
    --   Parameters:
    --     - text (string, optional): Text on the button. Supports RichText. Defaults to "Button".
    --     - callback (function, optional): Function to execute when clicked.
    --   Returns: A 'Button' object.
    --   Button Object Methods:
    --     :AddButton(newBtnText, newBtnCallback) - Adds another button in the same row (max 4 total).
    --                                              Returns an 'AddedButton' object for the new button.
    --     :Fire()             - Executes the button's callback.
    --     :Text(newText)      - Changes the button's text.
    --     :Hide()             - Hides the button (and any added to its row).
    --     :Show()             - Shows the button.
    --     :Remove()           - Destroys the button (and any added to its row).
    --     :SetFunction(newCb) - Changes the button's callback function.
    --   AddedButton Object Methods (from :AddButton):
    --     :Fire(), :Hide(), :Show(), :Text(), :Remove(), :SetFunction() - Specific to that added button.

    -- / Tab:NewSection(text)
    -- Creates a section divider with text.
    --   Parameters:
    --     - text (string, optional): Text for the section. Supports RichText. Defaults to "Section".
    --   Returns: A 'Section' object.
    --   Section Object Methods:
    --     :Text(newText) - Changes the section's text.
    --     :Hide()        - Hides the section.
    --     :Show()        - Shows the section.
    --     :Remove()      - Destroys the section.

    -- / Tab:NewToggle(text, defaultState, callback)
    -- Creates a toggle switch.
    --   Parameters:
    --     - text (string, optional): Label for the toggle. Supports RichText. Defaults to "Toggle".
    --     - defaultState (boolean, optional): Initial state (true=on, false=off). Defaults to false.
    --     - callback (function, optional): Function called when state changes. Receives new boolean state.
    --   Returns: A 'Toggle' object.
    --   Toggle Object Methods:
    --     :Text(newText)        - Changes the toggle's label text.
    --     :Hide()               - Hides the toggle.
    --     :Show()               - Shows the toggle.
    --     :Change()             - Toggles the state and fires callback.
    --     :Remove()             - Destroys the toggle.
    --     :Set(newState)        - Sets a specific state (true/false) and fires callback if changed.
    --     :SetFunction(newCb)   - Changes the toggle's callback.
    --     :AddKeybind(defaultKey) - Adds a keybind element to the right of the toggle.
    --                                 - defaultKey (Enum.KeyCode, optional): Default key.
    --                                 - Returns the 'Toggle' object for chaining.
    --                                 - The keybind will trigger the toggle's :Change() method.
    --                                 - Access keybind functions via `Toggle.Keybind:SetKey()`, etc.
    --     Toggle.Keybind Object Methods (if :AddKeybind was used):
    --       :SetKey(newKeyEnum) - Sets the key for this keybind.
    --       :Fire()             - Manually fires the keybind's action (toggles the parent).
    --       :Hide()             - Hides the keybind UI element.
    --       :Show()             - Shows the keybind UI element.

    -- / Tab:NewKeybind(text, defaultKey, callback)
    -- Creates a standalone keybind element.
    --   Parameters:
    --     - text (string, optional): Label for the keybind. Supports RichText. Defaults to "Keybind".
    --     - defaultKey (Enum.KeyCode, optional): Initial key. Defaults to Enum.KeyCode.P.
    --     - callback (function, optional): Function called when the bound key is pressed.
    --                                      Receives the KeyCode name (string) as an argument.
    --   Returns: A 'Keybind' object.
    --   Keybind Object Methods:
    --     :Fire()             - Executes the keybind's callback with the current key.
    --     :SetFunction(newCb) - Changes the keybind's callback.
    --     :SetKey(newKeyEnum) - Sets the key to listen for.
    --     :Text(newText)      - Changes the keybind's label text.
    --     :Hide()             - Hides the keybind element.
    --     :Show()             - Shows the keybind element.
    --     :Remove()           - Destroys the keybind element and its listener.

    -- / Tab:NewTextbox(text, options)
    -- Creates a textbox for user input.
    --   Parameters:
    --     - text (string, optional): Label for the textbox. Supports RichText. Defaults to "Textbox".
    --     - options (table, optional): A table with the following optional keys:
    --       - default (string): Default text in the input field. Defaults to "".
    --       - placeholder (string): Placeholder text. Defaults to "".
    --       - format (string): Input filtering: "all" (default), "numbers", "lower", "upper".
    --       - type (string): Size/layout of textbox: "small" (label left, input right, auto-resizes),
    --                        "medium" (label above, single-line input below),
    --                        "large" (label above, multi-line input below). Defaults to "small".
    --       - autoExecute (boolean): If true (default), callback fires on FocusLost. If false, only on Enter.
    --       - clearOnFocus (boolean): If true, text clears when focused. Defaults to false.
    --       - callback (function): Function called with input value. Defaults to a print statement.
    --   Returns: A 'Textbox' object.
    --   Textbox Object Methods:
    --     :Input(newInputValue) - Sets the current text in the input field.
    --     :Fire()               - Executes the textbox's callback with the current input.
    --     :SetFunction(newCb)   - Changes the textbox's callback.
    --     :Text(newLabelText)   - Changes the textbox's main label text.
    --     :Hide()               - Hides the textbox element.
    --     :Show()               - Shows the textbox element.
    --     :Remove()             - Destroys the textbox element.
    --     :Place(newPlaceholder)- Sets the placeholder text of the input field.

    -- / Tab:NewSelector(text, defaultOption, optionList, callback)
    -- Creates a dropdown-style selector.
    --   Parameters:
    --     - text (string, optional): Label for the selector. Supports RichText. Defaults to "Selector".
    --     - defaultOption (string, optional): The initially selected option. If not in list, first item or "..." is used.
    --     - optionList (table, optional): A list of strings for the options. Defaults to {}.
    --     - callback (function, optional): Function called when an option is selected. Receives selected string.
    --   Returns: A 'Selector' object.
    --   Selector Object Methods:
    --     :AddOption(newOption)    - Adds a new string option to the list.
    --     :RemoveOption(optionStr) - Removes a specific option string from the list.
    --     :ClearOptions()          - Removes all options.
    --     :SetOptions(newOptList)  - Replaces all options with a new list of strings.
    --     :Value(newValue)         - Programmatically sets the selected value (if it exists in options).
    --     :SetFunction(newCb)      - Changes the selector's callback.
    --     :Text(newLabelText)      - Changes the selector's main label text.
    --     :Hide()                  - Hides the selector element.
    --     :Show()                  - Shows the selector element.
    --     :Remove()                - Destroys the selector element.

    -- / Tab:NewSlider(text, options)
    -- Creates a slider for selecting a numerical value.
    --   Parameters:
    --     - text (string, optional): Label for the slider. Supports RichText. Defaults to "Slider".
    --     - options (table, optional): A table with the following optional keys:
    --       - suffix (string): Text to append after the value (e.g., "%", "ms"). Defaults to "".
    --       - showCompare (boolean): If true, displays as "value / max". Defaults to false.
    --       - compareSign (string): Character for showCompare (e.g., "/"). Defaults to "/".
    --       - min (number): Minimum slider value. Defaults to 0.
    --       - max (number): Maximum slider value. Defaults to 100.
    --       - default (number): Initial slider value. Defaults to 0 (clamped to min/max).
    --       - callback (function): Called when value changes. Receives the new number.
    --   Returns: A 'Slider' object.
    --   Slider Object Methods:
    --     :Value(newValue, skipCallback) - Sets the slider's value. `skipCallback` (boolean) prevents callback if true.
    --     :Max(newMax)             - Sets a new maximum value for the slider.
    --     :Min(newMin)             - Sets a new minimum value for the slider.
    --     :SetFunction(newCb)      - Changes the slider's callback.
    --     :Text(newLabelText)      - Changes the slider's main label text.
    --     :Hide()                  - Hides the slider element.
    --     :Show()                  - Shows the slider element.
    --     :Remove()                - Destroys the slider element.

    -- / Tab:NewSeparator() (Corrected name from NewSeperator)
    -- Creates a horizontal line separator.
    --   Returns: A 'Separator' object.
    --   Separator Object Methods:
    --     :Hide()   - Hides the separator.
    --     :Show()   - Shows the separator.
    --     :Remove() - Destroys the separator.

    ====================================
    ==      MISCELLANEOUS UTILS       ==
    ====================================
    -- These are called directly on the `library` object.

    -- / library.version (string, read-only)
    -- Returns the version of the library (e.g., "2.1.0").

    -- / library.fps (number, read-only)
    -- Returns the current client frames per second.

    -- / library:RoundNumber(decimalPlaces, numberToRound)
    -- Rounds a number to a specified number of decimal places.
    --   Parameters:
    --     - decimalPlaces (number, optional): Number of decimal places. Defaults to 0.
    --     - numberToRound (number): The number to round.
    --   Returns: The rounded number.

    -- / library:GetUsername() -> string
    -- Returns the LocalPlayer's Name.

    -- / library:CheckIfLoaded() -> boolean
    -- Returns true if `game:IsLoaded()` is true.

    -- / library:GetUserId() -> number
    -- Returns the LocalPlayer's UserId.

    -- / library:GetPlaceId() -> number
    -- Returns `game.PlaceId`.

    -- / library:GetJobId() -> string
    -- Returns `game.JobId`.

    -- / library:Rejoin()
    -- Attempts to teleport the player to the same game instance.

    -- / library:Copy(textToCopy)
    -- Attempts to copy text to the clipboard. Original comments state it was Synapse-X only.
    -- If a 'syn.write_clipboard' global function exists, it will use it. Otherwise, does nothing.

    -- / library:GetDay(type) -> string
    --   type: "word" (Monday), "short" (Mon), "month" (day of month, 01-31), "year" (day of year, 001-366)
    -- / library:GetTime(type) -> string
    --   type: "24h" (00-23), "12h" (01-12), "minute" (00-59), "half" (AM/PM), "second" (00-59),
    --         "full" (HH:MM:SS locale default), "ISO" (+HHMM offset), "zone" (Timezone name)
    -- / library:GetMonth(type) -> string
    --   type: "word" (January), "short" (Jan), "digit" (01-12)
    -- / library:GetWeek(type) -> string
    --   type: "year_S" (week of year, Sunday start), "day" (day of week, 0-6 Sun-Sat), "year_M" (week of year, Monday start)
    -- / library:GetYear(type) -> string
    --   type: "digits" (last two digits, e.g., 23), "full" (e.g., 2023)

    -- / library:UnlockFps(newFpsLimit)
    -- Attempts to set the FPS cap. Original comments state it was Synapse-X only.
    -- If a 'setfpscap' global function exists, it will use it. Otherwise, does nothing.

    -- / library:Introduction()
    -- Plays a short animated introduction screen. This is optional and usually called once at the start.
]]
