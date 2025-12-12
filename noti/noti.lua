-- Dán đoạn này vào cuối script
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    
    -- 1. Phát âm thanh
    local Sound = Instance.new("Sound")
    Sound.Parent = game:GetService("Workspace")
    Sound.SoundId = "rbxassetid://4590657391"
    Sound.Volume = 2
    Sound:Play()
    Debris:AddItem(Sound, 2)

    -- 2. Tạo GUI Tùy Chỉnh (Custom Notification)
    local ScreenGui = Instance.new("ScreenGui")
    -- Ưu tiên dùng CoreGui để không bị reset khi chết, nếu không được thì dùng PlayerGui
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Khung chính (Main Frame)
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu Đen Đậm
    Frame.Size = UDim2.new(0, 300, 0, 70)
    Frame.Position = UDim2.new(1, 20, 0.85, 0) -- Bắt đầu ở ngoài màn hình bên phải
    Frame.BorderSizePixel = 0
    
    -- Bo góc (Rounded Corners)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame
    
    -- Hiệu ứng viền xung quanh (Stroke Effect)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = Frame
    UIStroke.Color = Color3.fromRGB(0, 255, 255) -- Màu viền (Cyan Neon)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0
    
    -- Ảnh Icon (Của bạn)
    local Icon = Instance.new("ImageLabel")
    Icon.Parent = Frame
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 10, 0.5, -25)
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Image = "rbxassetid://122440227529764" -- ID ảnh của bạn
    
    -- Bo góc cho ảnh (để ảnh tròn đẹp hơn)
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0) -- Bo tròn hoàn toàn
    IconCorner.Parent = Icon

    -- Tiêu đề (Title)
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 70, 0, 10)
    Title.Size = UDim2.new(0, 200, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "SYSTEM NOTIFICATION"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Nội dung (Text)
    local Text = Instance.new("TextLabel")
    Text.Parent = Frame
    Text.BackgroundTransparency = 1
    Text.Position = UDim2.new(0, 70, 0, 35)
    Text.Size = UDim2.new(0, 200, 0, 25)
    Text.Font = Enum.Font.Gotham
    Text.Text = "Script Loaded Successfully!"
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left

    -- 3. Hiệu ứng Xuất hiện (Animation)
    -- Trượt từ phải sang trái
    local TargetPosition = UDim2.new(1, -320, 0.85, 0)
    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = TargetPosition}):Play()
    
    -- Hiệu ứng viền nhấp nháy nhẹ (Pulse Effect)
    task.spawn(function()
        while Frame.Parent do
            TweenService:Create(UIStroke, TweenInfo.new(1), {Color = Color3.fromRGB(0, 150, 255)}):Play()
            task.wait(1)
            TweenService:Create(UIStroke, TweenInfo.new(1), {Color = Color3.fromRGB(0, 255, 255)}):Play()
            task.wait(1)
        end
    end)

    -- 4. Tự xóa sau 5 giây
    task.wait(10)
    -- Trượt ra ngoài
    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.85, 0)}):Play()
    task.wait(0.5)
    ScreenGui:Destroy()
end)
