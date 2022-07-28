-- Predefined functions
local function WaitForChildOfClass(Object, Class)
	local Found = Object:FindFirstChildOfClass(Class)
	if not Found then
		repeat
			task.wait()
			Found = Object:FindFirstChildOfClass(Class)
		until Found
	end

	return Found
end
local function ApplyUICorner(UIObject, Radius)
	local UICorner = Instance.new('UICorner')
	UICorner.CornerRadius = Radius
	UICorner.Parent = UIObject
end


-- Globals
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer


-- Module
local SliderLibrary = {}


-- :Window()
local Sliders = {}
local WindowIdx = 0
function SliderLibrary:Window(WindowName)
	assert(type(WindowName) == 'string', 'invalid argument #1 to \'Window\' (string expected, got ' .. type(WindowName) .. ')')

	WindowIdx += 1
	local CurrentWindowIdx = WindowIdx
	
	local UIParent = game:GetService('CoreGui')
	if not pcall(function() return UIParent.Name end) then
		UIParent = WaitForChildOfClass(LocalPlayer, 'PlayerGui')
	end

	local UI = Instance.new('ScreenGui')
		local Main = Instance.new('Frame')	
			local Divider = Instance.new('Frame')
			local Name = Instance.new('TextLabel')

	UI.Name = 'Window' .. CurrentWindowIdx
	UI.IgnoreGuiInset = true
	UI.ResetOnSpawn = false
	UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		Main.Name = 'Main'
		Main.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
		Main.Position = UDim2.fromOffset((CurrentWindowIdx * 175) - 125, 50)
		Main.Size = UDim2.fromOffset(150, 125)
		Main.Parent = UI
		ApplyUICorner(Main, UDim.new(0, 5))
			Divider.Name = 'Divider'
			Divider.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
			Divider.BorderSizePixel = 0
			Divider.Position = UDim2.fromOffset(0, 30)
			Divider.Size = UDim2.new(1, 0, 0, 1)
			Divider.Parent = Main
			Name.Name = 'Name'
			Name.BackgroundTransparency = 1
			Name.AnchorPoint = Vector2.new(.5, 0)
			Name.Position = UDim2.new(.5, 0, 0, 5)
			Name.Size = UDim2.fromOffset(140, 20)
			Name.Font = Enum.Font.ArialBold
			Name.TextColor3 = Color3.new(1, 1, 1)
			Name.TextSize = 14
			Name.Text = WindowName
			Name.Parent = Main

	UI.Parent = UIParent


	local SliderWindow = {}

	-- :Slider()
	local SliderIdx = 0
	function SliderWindow:Slider(SliderName, SliderMin, SliderValue, SliderMax, SliderCallback)
		assert(type(SliderName) == 'string', 'invalid argument #1 to \'Slider\' (string expected, got ' .. type(SliderName) .. ')')
		assert(type(SliderMin) == 'number', 'invalid argument #2 to \'Slider\' (number expected, got ' .. type(SliderMin) .. ')')
		assert(type(SliderValue) == 'number', 'invalid argument #3 to \'Slider\' (number expected, got ' .. type(SliderValue) .. ')')
		assert(type(SliderMax) == 'number', 'invalid argument #4 to \'Slider\' (number expected, got ' .. type(SliderMax) .. ')')
		assert(SliderCallback and type(SliderCallback) or not SliderCallback == 'function', 'invalid argument #5 to \'Slider\' (function expected, got ' .. type(SliderCallback) .. ')')

		SliderIdx += 1
		local CurrentSliderIdx = SliderIdx

		Main.Size = UDim2.fromOffset(150, math.max((CurrentSliderIdx + 1) * 40, 125))

		local SliderBase = Instance.new('Frame')
			local CircleShadow = Instance.new('Frame')
				local Circle = Instance.new('Frame')
			local Slider = Instance.new('Frame')
			local Min = Instance.new('TextLabel')
			local Name = Instance.new('TextLabel')
			local Max = Instance.new('TextLabel')
		
		SliderBase.Name = 'Slider' .. CurrentSliderIdx
		SliderBase.BackgroundTransparency = 1
		SliderBase.AnchorPoint = Vector2.new(.5, 0)
		SliderBase.Position = UDim2.new(.5, 0, 0, (CurrentSliderIdx * 40) - 3)
		SliderBase.Size = UDim2.fromOffset(135, 27)
			CircleShadow.Name = 'CircleShadow'
			CircleShadow.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			CircleShadow.BackgroundTransparency = .75
			CircleShadow.Position = UDim2.new(.2, 0, 0, 16)
			CircleShadow.Size = UDim2.fromOffset(9, 9)
			CircleShadow.ZIndex = 2
			CircleShadow.Parent = SliderBase
			ApplyUICorner(CircleShadow, UDim.new(1, 0))
				Circle.Name = 'Circle'
				Circle.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
				Circle.AnchorPoint = Vector2.new(.5, .5)
				Circle.Position = UDim2.fromScale(.5, .5)
				Circle.Size = UDim2.fromOffset(8, 8)
				Circle.Parent = CircleShadow
				ApplyUICorner(Circle, UDim.new(1, 0))
			Slider.Name = 'Slider'
			Slider.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			Slider.Position = UDim2.new(.2, 0, 0, 20)
			Slider.Size = UDim2.new(.6, 0, 0, 2)
			Slider.Parent = SliderBase
			ApplyUICorner(Slider, UDim.new(1, 0))
			Name.Name = 'Name'
			Name.BackgroundTransparency = 1
			Name.AnchorPoint = Vector2.new(.5, 0)
			Name.Position = UDim2.fromScale(.5, 0)
			Name.Size = UDim2.fromOffset(70, 10)
			Name.Font = Enum.Font.GothamMedium
			Name.TextColor3 = Color3.new(1, 1, 1)
			Name.TextSize = 14
			Name.Text = SliderName
			Name.Parent = SliderBase
			Min.Name = 'Min'
			Min.BackgroundTransparency = 1
			Min.Position = UDim2.new(0, 0, 0, 15)
			Min.Size = UDim2.fromOffset(30, 10)
			Min.Font = Enum.Font.SourceSans
			Min.TextColor3 = Color3.new(1, 1, 1)
			Min.TextSize = 12
			Min.Text = SliderMin
			Min.Parent = SliderBase
			Max.Name = 'Max'
			Max.BackgroundTransparency = 1
			Max.AnchorPoint = Vector2.new(1, 0)
			Max.Position = UDim2.new(1, 0, 0, 15)
			Max.Size = UDim2.fromOffset(30, 10)
			Max.Font = Enum.Font.SourceSans
			Max.TextColor3 = Color3.new(1, 1, 1)
			Max.TextSize = 12
			Max.Text = SliderMax
			Max.Parent = SliderBase

		SliderBase.Parent = Main


		local function SliderUpdateCallback(Number, NoLog)
			local NewX = (Number - SliderMin) / (SliderMax - SliderMin)
			NewX = (NewX * .6) + .2
			CircleShadow.Position = UDim2.new(NewX, -CircleShadow.Size.X.Offset / 2, 0, 16)

			if not NoLog and SliderCallback then
				SliderCallback(Number)
			end
		end
		SliderUpdateCallback(SliderValue, true)

		table.insert(Sliders, {
			Circle = CircleShadow,
			Slider = Slider,
			Min = SliderMin,
			Max = SliderMax,
			Callback = SliderUpdateCallback
		})
	end

	return SliderWindow
end


-- Slider handler
local BoundPadding = 5
local function GetBoundSlider(MouseLocation)
	for _, SliderData in pairs(Sliders) do
		local CirclePosition = SliderData.Circle.AbsolutePosition
		local CircleSize = SliderData.Circle.AbsoluteSize
		if math.sqrt((CirclePosition.X - MouseLocation.X)^2 + (CirclePosition.Y - MouseLocation.Y)^2) <= math.sqrt(CircleSize.X^2 + CircleSize.Y^2) then
			return SliderData
		end

		local SliderPosition = SliderData.Slider.AbsolutePosition
		local SliderSize = SliderData.Slider.AbsoluteSize
		if MouseLocation.X >= SliderPosition.X - BoundPadding and MouseLocation.X <= SliderPosition.X + SliderSize.X + BoundPadding and MouseLocation.Y >= SliderPosition.Y - BoundPadding and MouseLocation.Y <= SliderPosition.Y + SliderSize.Y + BoundPadding then
			return SliderData
		end
	end
end

local Holding = false
local CurrentSlider
UserInputService.InputBegan:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		local MouseLocation = UserInputService:GetMouseLocation() - ({ GuiService:GetGuiInset() })[1]
		local BoundSlider = GetBoundSlider(MouseLocation)

		if BoundSlider then
			CurrentSlider = BoundSlider
			Holding = true
		end
	end
end)
UserInputService.InputEnded:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		Holding = false
	end
end)
UserInputService.InputChanged:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseMovement and Holding then
		local MouseLocation = UserInputService:GetMouseLocation()
		local Circle, Slider, Min, Max = CurrentSlider.Circle, CurrentSlider.Slider, CurrentSlider.Min, CurrentSlider.Max
		
		local Ratio = (MouseLocation.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X
		local Value = math.clamp(Ratio * (Max - Min) + Min, Min, Max)

		CurrentSlider.Callback(math.round(Value))
	end
end)


return SliderLibrary
