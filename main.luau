-- SimpleMenuLib: A lightweight and easy-to-script menu library for Roblox Lua
-- Inspired by Orion Lib, but simplified for ease of use.
-- Updated: Detects and destroys existing menus, more modern UI with rounded corners and gradients, draggable window.
-- Usage: local Menu = require(script.SimpleMenuLib)
-- local window = Menu:CreateWindow("My Menu")
-- local section = window:CreateSection("Example Section")
-- section:CreateToggle("Example Toggle", false, function(state) print("Toggle state:", state) end)
-- section:CreateButton("Example Button", function() print("Button clicked!") end)
-- section:CreateSlider("Example Slider", 0, 100, 50, function(value) print("Slider value:", value) end)

local SimpleMenuLib = {}

-- Helper function to create UI elements
local function createInstance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

-- Create the main window
function SimpleMenuLib:CreateWindow(title)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Detect and destroy existing menus
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name == "SimpleMenuGui" then
            gui:Destroy()
        end
    end
    
    local screenGui = createInstance("ScreenGui", {
        Parent = playerGui,
        Name = "SimpleMenuGui",
        ResetOnSpawn = false
    })
    
    local mainFrame = createInstance("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Add rounded corners
    local uiCorner = createInstance("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Add subtle shadow (using UIStroke with transparency)
    local uiStroke = createInstance("UIStroke", {
        Parent = mainFrame,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.5,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    
    -- Title bar with gradient
    local titleFrame = createInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0
    })
    
    local titleGradient = createInstance("UIGradient", {
        Parent = titleFrame,
        Color = ColorSequence.new(Color3.fromRGB(50, 50, 50), Color3.fromRGB(30, 30, 30)),
        Rotation = 90
    })
    
    local titleCorner = createInstance("UICorner", {
        Parent = titleFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    local titleLabel = createInstance("TextLabel", {
        Parent = titleFrame,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Make the window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    titleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local sectionContainer = createInstance("ScrollingFrame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
        BorderSizePixel = 0
    })
    
    local uiListLayout = createInstance("UIListLayout", {
        Parent = sectionContainer,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local window = {}
    local currentY = 0
    
    -- Create a section in the window
    function window:CreateSection(name)
        local sectionFrame = createInstance("Frame", {
            Parent = sectionContainer,
            Size = UDim2.new(1, -10, 0, 0),  -- Height will be auto-adjusted
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            LayoutOrder = currentY
        })
        
        local sectionCorner = createInstance("UICorner", {
            Parent = sectionFrame,
            CornerRadius = UDim.new(0, 6)
        })
        
        local sectionTitle = createInstance("TextLabel", {
            Parent = sectionFrame,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 10, 0, 5)
        })
        
        local elementContainer = createInstance("Frame", {
            Parent = sectionFrame,
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 0, 0),  -- Auto-height
            BackgroundTransparency = 1
        })
        
        local elementListLayout = createInstance("UIListLayout", {
            Parent = elementContainer,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local section = {}
        local sectionHeight = 35  -- Starting with title height + padding
        
        -- Helper to update section height
        local function updateSectionHeight()
            sectionFrame.Size = UDim2.new(1, -10, 0, sectionHeight + 10)
            elementContainer.Size = UDim2.new(1, 0, 0, sectionHeight - 30)
            currentY = currentY + 1
            sectionContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
        end
        
        -- Create a toggle in the section
        function section:CreateToggle(text, default, callback)
            local toggleFrame = createInstance("Frame", {
                Parent = elementContainer,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            })
            
            local toggleLabel = createInstance("TextLabel", {
                Parent = toggleFrame,
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local toggleButton = createInstance("Frame", {
                Parent = toggleFrame,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            
            local toggleCorner = createInstance("UICorner", {
                Parent = toggleButton,
                CornerRadius = UDim.new(0, 10)
            })
            
            local toggleKnob = createInstance("Frame", {
                Parent = toggleButton,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(default and 0.5 or 0, 0, 0, 0),
                BackgroundColor3 = default and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            })
            
            local knobCorner = createInstance("UICorner", {
                Parent = toggleKnob,
                CornerRadius = UDim.new(0, 10)
            })
            
            local state = default
            toggleButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    toggleKnob.Position = UDim2.new(state and 0.5 or 0, 0, 0, 0)
                    toggleKnob.BackgroundColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                    if callback then callback(state) end
                end
            end)
            
            sectionHeight = sectionHeight + 38
            updateSectionHeight()
        end
        
        -- Create a button in the section
        function section:CreateButton(text, callback)
            local buttonFrame = createInstance("Frame", {
                Parent = elementContainer,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1
            })
            
            local button = createInstance("TextButton", {
                Parent = buttonFrame,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14
            })
            
            local buttonCorner = createInstance("UICorner", {
                Parent = button,
                CornerRadius = UDim.new(0, 6)
            })
            
            local buttonGradient = createInstance("UIGradient", {
                Parent = button,
                Color = ColorSequence.new(Color3.fromRGB(60, 60, 60), Color3.fromRGB(40, 40, 40)),
                Rotation = 90
            })
            
            button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            sectionHeight = sectionHeight + 43
            updateSectionHeight()
        end
        
        -- Create a slider in the section
        function section:CreateSlider(text, min, max, default, callback)
            local sliderFrame = createInstance("Frame", {
                Parent = elementContainer,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1
            })
            
            local sliderLabel = createInstance("TextLabel", {
                Parent = sliderFrame,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text .. ": " .. default,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderBar = createInstance("Frame", {
                Parent = sliderFrame,
                Size = UDim2.new(1, -20, 0, 8),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            
            local barCorner = createInstance("UICorner", {
                Parent = sliderBar,
                CornerRadius = UDim.new(0, 4)
            })
            
            local sliderFill = createInstance("Frame", {
                Parent = sliderBar,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            })
            
            local fillCorner = createInstance("UICorner", {
                Parent = sliderFill,
                CornerRadius = UDim.new(0, 4)
            })
            
            local sliderButton = createInstance("Frame", {
                Parent = sliderBar,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new((default - min) / (max - min), -8, 0, -4),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            })
            
            local buttonCorner = createInstance("UICorner", {
                Parent = sliderButton,
                CornerRadius = UDim.new(0.5, 0)
            })
            
            local dragging = false
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("RunService").RenderStepped:Connect(function()
                if dragging then
                    local mouse = game.Players.LocalPlayer:GetMouse()
                    local barPos = sliderBar.AbsolutePosition.X
                    local barSize = sliderBar.AbsoluteSize.X
                    local relative = math.clamp((mouse.X - barPos) / barSize, 0, 1)
                    local value = math.floor(min + relative * (max - min))
                    sliderFill.Size = UDim2.new(relative, 0, 1, 0)
                    sliderButton.Position = UDim2.new(relative, -8, 0, -4)
                    sliderLabel.Text = text .. ": " .. value
                    if callback then callback(value) end
                end
            end)
            
            sectionHeight = sectionHeight + 58
            updateSectionHeight()
        end
        
        return section
    end
    
    return window
end

return SimpleMenuLib
