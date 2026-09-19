-- // 磊脚本启动器 //
-- 一键加载，方便快捷

local url = "https://raw.githubusercontent.com/Deadeye78/Lei-script/main/FlyScript.lua"

game:GetService("Players").LocalPlayer.PlayerGui:SetTopbarTransparency(0.5)

local success, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)

if not success then
    warn("[磊脚本] 加载失败: " .. tostring(err))
    warn("请检查网络连接或链接是否正确")
end
