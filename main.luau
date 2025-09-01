-- SimpleMenuLib: A lightweight and easy-to-script menu library for Roblox Lua
-- Inspired by Orion Lib, but simplified for ease of use.
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
    local screenGui = createInstance("ScreenGui", {
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        Name = "SimpleMenuGui",
        ResetOnSpawn = false
    })
    
    local mainFrame = createInstance("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    })
    
    local titleLabel = createInstance("TextLabel", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 18
    })
    
    local sectionContainer = createInstance("ScrollingFrame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5
    })
    
    local uiListLayout = createInstance("UIListLayout", {
        Parent = sectionContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local window = {}
    local currentY = 0
    
    -- Create a section in the window
    function window:CreateSection(name)
        local sectionFrame = createInstance("Frame", {
            Parent = sectionContainer,
            Size = UDim2.new(1, -10, 0, 0),  -- Height will be auto-adjusted
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            LayoutOrder = currentY
        })
        
        local sectionTitle = createInstance("TextLabel", {
            Parent = sectionFrame,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.SourceSans,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 10, 0, 0)
        })
        
        local elementContainer = createInstance("Frame", {
            Parent = sectionFrame,
            Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(1, 0, 0, 0),  -- Auto-height
            BackgroundTransparency = 1
        })
        
        local elementListLayout = createInstance("UIListLayout", {
            Parent = elementContainer,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local section = {}
        local sectionHeight = 25
        
        -- Helper to update section height
        local function updateSectionHeight()
            sectionFrame.Size = UDim2.new(1, -10, 0, sectionHeight + 10)
            elementContainer.Size = UDim2.new(1, 0, 0, sectionHeight - 25)
            currentY = currentY + 1
            sectionContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
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
                Size = UDim2.new(0.8, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local toggleButton = createInstance("TextButton", {
                Parent = toggleFrame,
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -40, 0.5, -10),
                BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
                Text = ""
            })
            
            local state = default
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                if callback then callback(state) end
            end)
            
            sectionHeight = sectionHeight + 35
            updateSectionHeight()
        end
        
        -- Create a button in the section
        function section:CreateButton(text, callback)
            local buttonFrame = createInstance("Frame", {
                Parent = elementContainer,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            })
            
            local button = createInstance("TextButton", {
                Parent = buttonFrame,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.SourceSans,
                TextSize = 14
            })
            
            button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            sectionHeight = sectionHeight + 35
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
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderBar = createInstance("Frame", {
                Parent = sliderFrame,
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            
            local sliderFill = createInstance("Frame", {
                Parent = sliderBar,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            })
            
            local sliderButton = createInstance("TextButton", {
                Parent = sliderBar,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new((default - min) / (max - min), -10, 0, -5),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                Text = ""
            })
            
            local dragging = false
            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("RunService").RenderStepped:Connect(function()
                if dragging then
                    local mouseX = game.Players.LocalPlayer:GetMouse().X
                    local barX = sliderBar.AbsolutePosition.X
                    local barWidth = sliderBar.AbsoluteSize.X
                    local relative = math.clamp((mouseX - barX) / barWidth, 0, 1)
                    local value = math.floor(min + relative * (max - min))
                    sliderFill.Size = UDim2.new(relative, 0, 1, 0)
                    sliderButton.Position = UDim2.new(relative, -10, 0, -5)
                    sliderLabel.Text = text .. ": " .. value
                    if callback then callback(value) end
                end
            end)
            
            sectionHeight = sectionHeight + 55
            updateSectionHeight()
        end
        
        return section
    end
    
    return window
end

return SimpleMenuLib

