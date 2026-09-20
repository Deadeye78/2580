--[[ 磊脚本 - 全局错误防护 + 工具库 ]]
local function safeCall(fn,...)
 local args={...} local ok,err=pcall(function() fn(unpack(args)) end)
 if not ok then warn("[磊脚本错误]",err) end
 return ok,err
end
local function safeSpawn(fn,...)
 local args={...}
 task.spawn(function()
  local ok,err=pcall(function() fn(unpack(args)) end)
  if not ok then warn("[磊脚本错误]",err) end
 end)
end
-- 通用工具函数
local Util={}
function Util:SafeGet(parent,name,class)
 local ok,res=pcall(function() return parent and parent:FindFirstChild(name) end)
 if ok and res and (not class or res:IsA(class)) then return res end
 return nil
end
function Util:SafeHRP(player)
 if not player then return nil end
 local ok,res=pcall(function()
  local c=player.Character if not c then return nil end
  local r=c:FindFirstChild("HumanoidRootPart") return r
 end)
 return ok and res or nil
end
function Util:SafeHum(player)
 if not player then return nil end
 local ok,res=pcall(function()
  local c=player.Character if not c then return nil end
  local h=c:FindFirstChild("Humanoid") return h
 end)
 return ok and res or nil
end
function Util:CreateUI(class,props)
 local ok,res=pcall(function()
  local obj=Instance.new(class)
  for k,v in pairs(props) do obj[k]=v end
  return obj
 end)
 return ok and res or nil
end
function Util:Tween(obj,info,props,callback)
 if not obj then return end
 local t=TS:Create(obj,info,props)
 if callback then t.Completed:Connect(function() pcall(callback) end) end
 t:Play()
 return t
end
-- 游戏通用功能库
local GameLib={}
function GameLib:NoClip(character,enabled)
 if not character then return end
 for _,d in ipairs(character:GetDescendants()) do
  if d:IsA("BasePart") then
   pcall(function() d.CanCollide=not enabled end)
  end
 end
end
function GameLib:SetSpeed(character,speed)
 if not character then return end
 local hum=character:FindFirstChild("Humanoid")
 if hum then pcall(function() hum.WalkSpeed=speed end) end
end
function GameLib:SetJump(character,jp)
 if not character then return end
 local hum=character:FindFirstChild("Humanoid")
 if hum then pcall(function() hum.JumpPower=jp end) end
end
function GameLib:GodMode(character,enabled)
 if not character then return end
 local hum=character:FindFirstChild("Humanoid")
 if hum and enabled then
  pcall(function() hum.Health=hum.MaxHealth end)
 end
end
function GameLib:MakeUI(title,color,sizeX,sizeY)
 local SG=Instance.new("ScreenGui") SG.Parent=CG SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local f=Instance.new("Frame")
 f.BackgroundColor3=Color3.fromRGB(15,15,20)
 f.Position=UDim2.new(0,10,0,10)
 f.Size=UDim2.new(0,sizeX or 200,0,sizeY or 200)
 f.BackgroundTransparency=0.1
 f.Parent=SG
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
 local st=Instance.new("UIStroke")
 st.Color=color or Color3.fromRGB(100,200,255)
 st.Thickness=2
 st.Parent=f
 local t=Instance.new("TextLabel")
 t.BackgroundTransparency=1
 t.Size=UDim2.new(1,0,0,30)
 t.Position=UDim2.new(0,0,0,6)
 t.Font=Enum.Font.GothamBold
 t.Text=title or "脚本UI"
 t.TextColor3=color or Color3.fromRGB(120,220,255)
 t.TextSize=15
 t.Parent=f
 return SG,f,st,t
end
function GameLib:MakeBtn(parent,y,txt,color,sizeY,cb)
 local b=Instance.new("TextButton")
 b.BackgroundColor3=color or Color3.fromRGB(40,45,60)
 b.Size=UDim2.new(0,170,0,sizeY or 32)
 b.Position=UDim2.new(0.5,-85,0,y)
 b.Font=Enum.Font.GothamSemibold
 b.Text=txt
 b.TextColor3=Color3.fromRGB(230,235,250)
 b.TextSize=12
 b.Parent=parent
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
 if cb then b.MouseButton1Click:Connect(function() safeCall(cb) end) end
 return b
end
function GameLib:MakeCloseBtn(parent,y,cb)
 return GameLib:MakeBtn(parent,y,"✕ 关闭",Color3.fromRGB(70,30,30),32,cb)
end
local TS=game:GetService("TweenService") local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService") local Plrs=game:GetService("Players")
local LP=Plrs.LocalPlayer local CG=game:GetService("CoreGui")
local cam=workspace.CurrentCamera
local Settings={Accent=Color3.fromRGB(100,200,255),BGImg="",BGT=0.3,FX={Rainbow=false,Meteor=false}}
local LG=Instance.new("ScreenGui") LG.Name="LS_Load" LG.Parent=CG LG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
-- 朦胧背景层
local LB=Instance.new("Frame") LB.Parent=LG LB.BackgroundColor3=Color3.fromRGB(5,5,12) LB.Size=UDim2.new(1,0,1,0) LB.ZIndex=1 LB.BackgroundTransparency=1
local Vignette=Instance.new("Frame") Vignette.Parent=LB Vignette.BackgroundColor3=Color3.fromRGB(0,0,0) Vignette.Size=UDim2.new(1,0,1,0) Vignette.ZIndex=2 Vignette.BackgroundTransparency=1
local VG=Instance.new("UIGradient") VG.Parent=Vignette VG.Rotation=0 VG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.7),NumberSequenceKeypoint.new(0.5,0.95),NumberSequenceKeypoint.new(1,0.7)}
-- 星星层
local Stars=Instance.new("Frame") Stars.Parent=LB Stars.BackgroundTransparency=1 Stars.Size=UDim2.new(1,0,1,0) Stars.ZIndex=3
local starData={}
for i=1,50 do
 local s=Instance.new("Frame") s.Parent=Stars s.BackgroundColor3=Color3.fromRGB(255,255,255)
 s.Size=UDim2.new(0,math.random(1,3),0,math.random(1,3)) s.Position=UDim2.new(math.random(),0,math.random(),0)
 s.BackgroundTransparency=math.random(50,90)/100 s.ZIndex=3 Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
 table.insert(starData,{Obj=s,BaseT=math.random()*10,Spd=0.5+math.random()*1.5})
end
-- 流星雨层
local Meteors=Instance.new("Frame") Meteors.Parent=LB Meteors.BackgroundTransparency=1 Meteors.Size=UDim2.new(1,0,1,0) Meteors.ZIndex=4 Meteors.ClipsDescendants=false
local meteorData={}
for i=1,8 do
 local m=Instance.new("Frame") m.Parent=Meteors m.BackgroundColor3=Color3.fromRGB(200,230,255)
 m.Size=UDim2.new(0,2,0,80) m.ZIndex=4 m.BackgroundTransparency=0.5 m.Visible=false
 Instance.new("UICorner",m).CornerRadius=UDim.new(0,1)
 local MG=Instance.new("UIGradient") MG.Parent=m MG.Rotation=45 MG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}
 table.insert(meteorData,{Obj=m,Delay=math.random()*4,Spd=0.8+math.random()*1.2,Len=60+math.random(60),Rot=35+math.random(20)})
end
-- 光晕层
local Halo=Instance.new("Frame") Halo.Parent=LB Halo.BackgroundColor3=Color3.fromRGB(100,200,255) Halo.BackgroundTransparency=0.85
Halo.Size=UDim2.new(0,520,0,520) Halo.Position=UDim2.new(0.5,-260,0.5,-260) Halo.ZIndex=5
Instance.new("UICorner",Halo).CornerRadius=UDim.new(260,0)
local HG=Instance.new("UIGradient") HG.Parent=Halo HG.Rotation=0
HG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.6,0.5),NumberSequenceKeypoint.new(1,1)}
-- 主面板
local LF=Instance.new("Frame") LF.Parent=LG LF.BackgroundColor3=Color3.fromRGB(12,12,18) LF.Position=UDim2.new(0.5,-210,0.5,-130) LF.Size=UDim2.new(0,420,0,260) LF.ZIndex=6 LF.BackgroundTransparency=1
Instance.new("UICorner",LF).CornerRadius=UDim.new(0,18)
local UIStroke=Instance.new("UIStroke") UIStroke.Parent=LF UIStroke.Thickness=1.5 UIStroke.Transparency=0.65 UIStroke.Color=Color3.fromRGB(100,200,255) UIStroke.LineJoinMode=Enum.LineJoinMode.Round
-- 朦胧玻璃效果
local Glass=Instance.new("Frame") Glass.Parent=LF Glass.BackgroundColor3=Color3.fromRGB(30,40,60) Glass.Size=UDim2.new(1,0,1,0) Glass.BackgroundTransparency=0.85 Glass.ZIndex=1
Instance.new("UICorner",Glass).CornerRadius=UDim.new(0,18)
-- 标题
local TL=Instance.new("TextLabel") TL.Parent=LF TL.BackgroundTransparency=1 TL.Position=UDim2.new(0,0,0,45) TL.Size=UDim2.new(1,0,0,52)
TL.Font=Enum.Font.GothamBold TL.Text="磊脚本" TL.TextColor3=Color3.fromRGB(255,255,255) TL.TextSize=44 TL.ZIndex=7 TL.TextTransparency=1
local TS2=Instance.new("UIStroke") TS2.Parent=TL TS2.Thickness=2.5 TS2.Transparency=0.8 TS2.Color=Color3.fromRGB(100,200,255)
local SL=Instance.new("TextLabel") SL.Parent=LF SL.BackgroundTransparency=1 SL.Position=UDim2.new(0,0,0,100) SL.Size=UDim2.new(1,0,0,24)
SL.Font=Enum.Font.Gotham SL.Text="✨ LEI SCRIPT PREMIUM ✨" SL.TextColor3=Color3.fromRGB(160,190,230) SL.TextSize=13 SL.ZIndex=7 SL.TextTransparency=1
-- 进度条
local PBg=Instance.new("Frame") PBg.Parent=LF PBg.BackgroundColor3=Color3.fromRGB(20,20,30) PBg.Position=UDim2.new(0.5,-150,0,150) PBg.Size=UDim2.new(0,300,0,10) PBg.ZIndex=7 PBg.BackgroundTransparency=1
Instance.new("UICorner",PBg).CornerRadius=UDim.new(0,5)
local PB=Instance.new("Frame") PB.Parent=PBg PB.BackgroundColor3=Color3.fromRGB(100,200,255) PB.Size=UDim2.new(0,0,1,0) PB.ZIndex=8
Instance.new("UICorner",PB).CornerRadius=UDim.new(0,5)
local PG=Instance.new("UIGradient") PG.Parent=PB PG.Rotation=0 PG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.2)}
local Shine=Instance.new("Frame") Shine.Parent=PB Shine.BackgroundColor3=Color3.fromRGB(255,255,255) Shine.BackgroundTransparency=0.4 Shine.Size=UDim2.new(0,40,1,0) Shine.Position=UDim2.new(-0.2,0,0,0) Shine.ZIndex=9
Instance.new("UICorner",Shine).CornerRadius=UDim.new(0,3)
-- 百分比和状态
local PT=Instance.new("TextLabel") PT.Parent=LF PT.BackgroundTransparency=1 PT.Position=UDim2.new(0,0,0,178) PT.Size=UDim2.new(1,0,0,22)
PT.Font=Enum.Font.GothamBold PT.Text="0%" PT.TextColor3=Color3.fromRGB(210,230,255) PT.TextSize=15 PT.ZIndex=7 PT.TextTransparency=1
local ST=Instance.new("TextLabel") ST.Parent=LF ST.BackgroundTransparency=1 ST.Position=UDim2.new(0,0,0,208) ST.Size=UDim2.new(1,0,0,20)
ST.Font=Enum.Font.Gotham ST.Text="正在初始化..." ST.TextColor3=Color3.fromRGB(150,170,210) ST.TextSize=12 ST.ZIndex=7 ST.TextTransparency=1
local NT=Instance.new("TextLabel") NT.Parent=LF NT.BackgroundTransparency=1 NT.Position=UDim2.new(0,0,1,-34) NT.Size=UDim2.new(1,0,0,24)
NT.Font=Enum.Font.GothamSemibold NT.Text="🌟 此脚本由 TRAE 制造 · 完全免费 · 请勿付费 🌟" NT.TextColor3=Color3.fromRGB(255,225,110) NT.TextSize=11 NT.ZIndex=7 NT.TextTransparency=1
-- 动画循环
local t0=os.clock()
local function hsv(h,s,v) return Color3.fromHSV(h,s,v) end
RS.RenderStepped:Connect(function()
 if not LG.Parent then return end
 local t=os.clock()-t0
 local hue=(t*0.06)%1 local c=hsv(hue,0.65,1)
 local c2=hsv((hue+0.08)%1,0.5,1)
 -- 主面板浮动
 LF.Position=UDim2.new(0.5,-210,0.5,-130+math.sin(t*1.2)*5)
 -- 彩虹边框+标题发光
 UIStroke.Color=c TS2.Color=c PB.BackgroundColor=c
 PG.Color=ColorSequence.new{c2,c,c2}
 Halo.BackgroundColor3=c
 -- 流光
 Shine.Position=UDim2.new((t*0.4)%1.4-0.2,0,0,0)
 -- 星星闪烁
 for _,sd in ipairs(starData) do
  local tw=0.7+0.3*math.sin(t*sd.Spd+sd.BaseT)
  sd.Obj.BackgroundTransparency=1-tw*0.5
  sd.Obj.BackgroundColor3=c
 end
 -- 流星雨
 for _,md in ipairs(meteorData) do
  local phase=(t+md.Delay)%5
  if phase<2.5 then
   md.Obj.Visible=true
   local prog=phase/2.5
   local sx=0.3+prog*0.8 local sy=-0.1+prog*1.3
   local rad=math.rad(md.Rot)
   md.Obj.Position=UDim2.new(sx,0,sy,0)
   md.Obj.Rotation=md.Rot
   md.Obj.Size=UDim2.new(0,2,0,md.Len)
   md.Obj.BackgroundTransparency=prog<0.1 and 1-prog/0.1 or (prog>0.8 and (1-prog)/0.2 or 0.3)
   md.Obj.BackgroundColor3=c
  else
   md.Obj.Visible=false
  end
 end
end)
local buildUI=nil
local function setPct(p,s)
 if p<0 then p=0 end if p>100 then p=100 end
 TS:Create(PB,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Size=UDim2.new(p/100,0,1,0)}):Play()
 PT.Text=math.floor(p).."%" if s then ST.Text=s end
end
-- 加载动画 + UI构建（快速丝滑版）
task.spawn(function()
 -- 加载动画（丝滑快速版）
 TS:Create(LB,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{BackgroundTransparency=0.7}):Play()
 TS:Create(Vignette,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{BackgroundTransparency=0}):Play()
 task.wait(0.15)
 TS:Create(LF,TweenInfo.new(0.4,Enum.EasingStyle.Back),{BackgroundTransparency=0}):Play()
 task.wait(0.15)
 TS:Create(TL,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
 task.wait(0.08)
 TS:Create(SL,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
 task.wait(0.08)
 TS:Create(PBg,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{BackgroundTransparency=0}):Play()
 TS:Create(PT,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
 TS:Create(ST,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
 TS:Create(NT,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
 -- 快速进度条
 local sp={{10,"初始化..."},{25,"加载UI引擎..."},{42,"渲染特效..."},{60,"加载功能..."},{78,"加载资源..."},{95,"收尾中..."},{100,"完成！"}}
 for _,s in ipairs(sp) do setPct(s[1],s[2]) task.wait(0.15+math.random()*0.1) end
 task.wait(0.2)
 -- 等待UI构建完成
 while not buildUI do task.wait() end
 local ok,err=pcall(buildUI)
 if not ok then
  warn("[磊脚本] 加载失败:",err)
  local EG=Instance.new("ScreenGui") EG.Parent=CG EG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
  local EF=Instance.new("Frame") EF.Parent=EG EF.BackgroundColor3=Color3.fromRGB(25,15,20) EF.Position=UDim2.new(0.5,-180,0.5,-80) EF.Size=UDim2.new(0,360,0,160) EF.ZIndex=1
  Instance.new("UICorner",EF).CornerRadius=UDim.new(0,12)
  local ES=Instance.new("UIStroke") ES.Parent=EF ES.Thickness=1 ES.Transparency=0.6 ES.Color=Color3.fromRGB(255,80,80)
  local ET=Instance.new("TextLabel") ET.Parent=EF ET.BackgroundTransparency=1 ET.Position=UDim2.new(0,0,0,15) ET.Size=UDim2.new(1,0,0,30)
  ET.Font=Enum.Font.GothamBold ET.Text="❌ 加载失败" ET.TextColor3=Color3.fromRGB(255,80,80) ET.TextSize=20 ET.ZIndex=2
  local EM=Instance.new("TextLabel") EM.Parent=EF EM.BackgroundTransparency=1 EM.Position=UDim2.new(0,20,0,55) EM.Size=UDim2.new(1,-40,0,70)
  EM.Font=Enum.Font.Gotham EM.Text=tostring(err) EM.TextColor3=Color3.fromRGB(220,220,220) EM.TextSize=12 EM.ZIndex=2 EM.TextWrapped=true EM.TextXAlignment=Enum.TextXAlignment.Left
  local EB=Instance.new("TextButton") EB.Parent=EF EB.BackgroundColor3=Color3.fromRGB(80,40,40) EB.Position=UDim2.new(0.5,-50,1,-40) EB.Size=UDim2.new(0,100,0,28) EB.AutoButtonColor=false EB.ZIndex=2
  EB.Font=Enum.Font.GothamSemibold EB.Text="知道了" EB.TextColor3=Color3.fromRGB(255,255,255) EB.TextSize=12 EB.ZIndex=3
  Instance.new("UICorner",EB).CornerRadius=UDim.new(0,6)
  EB.MouseButton1Click:Connect(function() EG:Destroy() end)
  EB.MouseEnter:Connect(function() EB.BackgroundColor3=Color3.fromRGB(100,50,50) end)
  EB.MouseLeave:Connect(function() EB.BackgroundColor3=Color3.fromRGB(80,40,40) end)
  return
 end
 -- 丝滑退出动画
 TS:Create(LF,TweenInfo.new(0.4,Enum.EasingStyle.Quad),{BackgroundTransparency=1,Position=UDim2.new(0.5,-200,0.45,-120)}):Play()
 TS:Create(TL,TweenInfo.new(0.3),{TextTransparency=1}):Play()
 TS:Create(SL,TweenInfo.new(0.25),{TextTransparency=1}):Play()
 TS:Create(PBg,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
 TS:Create(PT,TweenInfo.new(0.25),{TextTransparency=1}):Play()
 TS:Create(ST,TweenInfo.new(0.25),{TextTransparency=1}):Play()
 TS:Create(NT,TweenInfo.new(0.25),{TextTransparency=1}):Play()
 TS:Create(LB,TweenInfo.new(0.45,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
 task.wait(0.45) LG:Destroy()
end)
local Lib={}
local function drag(gui,handle)
 local dg,di,ds,sp=false,nil,nil,nil
 handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   dg=true ds=i.Position sp=gui.Position
   i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
  end
 end)
 handle.InputChanged:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then di=i end
 end)
 UIS.InputChanged:Connect(function(i)
  if i==di and dg then
   local d=i.Position-ds
   gui.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
  end
 end)
end
function Lib:CreateWindow(title)
 local SG=Instance.new("ScreenGui") SG.Name="LS_Main" SG.Parent=CG SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling SG.ResetOnSpawn=false SG.Enabled=false
 local BGL=Instance.new("Frame") BGL.Parent=SG BGL.BackgroundColor3=Color3.fromRGB(15,15,20) BGL.BackgroundTransparency=1 BGL.Size=UDim2.new(1,0,1,0) BGL.ZIndex=0
 local BGG=Instance.new("UIGradient") BGG.Parent=BGL BGG.Rotation=90 BGG.Enabled=false BGG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,0.15)}
 -- 暗角效果层（增加高级感）
 local Vignette=Instance.new("Frame") Vignette.Parent=SG Vignette.BackgroundTransparency=1 Vignette.Size=UDim2.new(1,0,1,0) Vignette.ZIndex=0
 local VG=Instance.new("UIGradient") VG.Parent=Vignette VG.Rotation=0 VG.Enabled=false
 VG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
 VG.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.7),NumberSequenceKeypoint.new(0.5,0.95),NumberSequenceKeypoint.new(1,0.7)}
 local MF=Instance.new("Frame") MF.Parent=SG MF.BackgroundColor3=Color3.fromRGB(15,15,20) MF.Position=UDim2.new(0.5,-290,0.5,-190) MF.Size=UDim2.new(0,580,0,380) MF.ClipsDescendants=true MF.Active=true MF.ZIndex=1
 Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
 local MS=Instance.new("UIStroke") MS.Parent=MF MS.Thickness=1.5 MS.Transparency=0.6 MS.Color=Settings.Accent MS.LineJoinMode=Enum.LineJoinMode.Round
 local TB=Instance.new("Frame") TB.Parent=MF TB.BackgroundColor3=Color3.fromRGB(20,20,26) TB.Size=UDim2.new(1,0,0,48) TB.ZIndex=2
 Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
 local TBS=Instance.new("UIStroke") TBS.Parent=TB TBS.Thickness=0.8 TBS.Transparency=0.8 TBS.Color=Settings.Accent
 local TL2=Instance.new("TextLabel") TL2.Parent=TB TL2.BackgroundTransparency=1 TL2.Position=UDim2.new(0,50,0,6) TL2.Size=UDim2.new(0,180,0,24)
 TL2.Font=Enum.Font.GothamBold TL2.Text=title TL2.TextColor3=Settings.Accent TL2.TextSize=16 TL2.TextXAlignment=Enum.TextXAlignment.Left TL2.ZIndex=3
 local TLS=Instance.new("UIStroke") TLS.Parent=TL2 TLS.Thickness=1.5 TLS.Transparency=0.85 TLS.Color=Settings.Accent
 local ST2=Instance.new("TextLabel") ST2.Parent=TB ST2.BackgroundTransparency=1 ST2.Position=UDim2.new(0,50,0,28) ST2.Size=UDim2.new(0,200,0,16)
 ST2.Font=Enum.Font.Gotham ST2.Text="PREMIUM · 尊享版" ST2.TextColor3=Color3.fromRGB(150,150,180) ST2.TextSize=11 ST2.TextXAlignment=Enum.TextXAlignment.Left ST2.ZIndex=3
 local VT=Instance.new("TextLabel") VT.Parent=TB VT.BackgroundColor3=Color3.fromRGB(30,30,40) VT.Position=UDim2.new(0,210,0,13) VT.Size=UDim2.new(0,60,0,22) VT.Font=Enum.Font.GothamSemibold VT.Text="v4.0" VT.TextColor3=Settings.Accent VT.TextSize=11 VT.ZIndex=3
 Instance.new("UICorner",VT).CornerRadius=UDim.new(0,6)
 local VTS=Instance.new("UIStroke") VTS.Parent=VT VTS.Thickness=0.8 VTS.Transparency=0.7 VTS.Color=Settings.Accent
 local X=Instance.new("TextButton") X.Parent=TB X.BackgroundTransparency=1 X.Position=UDim2.new(1,-35,0,12) X.Size=UDim2.new(0,24,0,24)
 X.Font=Enum.Font.GothamBold X.Text="✕" X.TextColor3=Color3.fromRGB(180,180,200) X.TextSize=14 X.AutoButtonColor=false X.ZIndex=5
 X.MouseEnter:Connect(function() TS:Create(X,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(255,80,80)}):Play() end)
 X.MouseLeave:Connect(function() TS:Create(X,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(180,180,200)}):Play() end)
 X.MouseButton1Click:Connect(function() SG:Destroy() end)
 local Min=Instance.new("TextButton") Min.Parent=TB Min.BackgroundTransparency=1 Min.Position=UDim2.new(1,-65,0,12) Min.Size=UDim2.new(0,24,0,24)
 Min.Font=Enum.Font.GothamBold Min.Text="—" Min.TextColor3=Color3.fromRGB(180,180,200) Min.TextSize=14 Min.AutoButtonColor=false Min.ZIndex=5
 local mini=false
 Min.MouseEnter:Connect(function() TS:Create(Min,TweenInfo.new(0.15),{TextColor3=Settings.Accent}):Play() end)
 Min.MouseLeave:Connect(function() TS:Create(Min,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(180,180,200)}):Play() end)
 Min.MouseButton1Click:Connect(function()
  mini=not mini
  TS:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=mini and UDim2.new(0,580,0,48) or UDim2.new(0,580,0,380)}):Play()
 end)
 local SB=Instance.new("ScrollingFrame") SB.Parent=MF SB.BackgroundColor3=Color3.fromRGB(18,18,24) SB.Position=UDim2.new(0,0,0,48) SB.Size=UDim2.new(0,175,1,-48) SB.ClipsDescendants=true SB.ZIndex=2 SB.ScrollBarThickness=3 SB.ScrollBarImageColor3=Settings.Accent SB.CanvasSize=UDim2.new(0,0,0,0) SB.AutomaticCanvasSize=Enum.AutomaticSize.Y
 local SBC=Instance.new("Frame") SBC.Parent=SB SBC.BackgroundTransparency=1 SBC.Size=UDim2.new(1,0,1,0) SBC.AutomaticSize=Enum.AutomaticSize.Y
 local SBL=Instance.new("UIListLayout") SBL.Parent=SBC SBL.Padding=UDim.new(0,3) SBL.HorizontalAlignment=Enum.HorizontalAlignment.Center SBL.VerticalAlignment=Enum.VerticalAlignment.Top
 local SBP=Instance.new("UIPadding") SBP.Parent=SBC SBP.PaddingTop=UDim.new(0,10)
 local CC=Instance.new("Frame") CC.Parent=MF CC.BackgroundColor3=Color3.fromRGB(15,15,20) CC.Position=UDim2.new(0,175,0,48) CC.Size=UDim2.new(1,-175,1,-48) CC.ClipsDescendants=true CC.ZIndex=2
 local PC=Instance.new("ScrollingFrame") PC.Parent=CC PC.BackgroundTransparency=1 PC.Size=UDim2.new(1,0,1,0) PC.ScrollBarThickness=3 PC.ScrollBarImageColor3=Settings.Accent PC.CanvasSize=UDim2.new(0,0,0,0) PC.ZIndex=2
 drag(MF,TB)
 local pages={} local cur=nil
 -- UI特效层（放在MF外面，避免被裁剪）
 local FXLayer=Instance.new("Frame") FXLayer.Parent=SG FXLayer.BackgroundTransparency=1 FXLayer.Size=UDim2.new(1,0,1,0) FXLayer.ZIndex=100
 -- 流星环绕
 local MeteorLayer=Instance.new("Frame") MeteorLayer.Parent=FXLayer MeteorLayer.BackgroundTransparency=1 MeteorLayer.Size=UDim2.new(1,0,1,0) MeteorLayer.ZIndex=100
 local fxMeteors={}
 for i=1,12 do
  local m=Instance.new("Frame") m.Parent=MeteorLayer m.BackgroundColor3=Settings.Accent m.Visible=false
  m.Size=UDim2.new(0,4,0,60) m.ZIndex=100 m.BackgroundTransparency=0
  Instance.new("UICorner",m).CornerRadius=UDim.new(0,2)
  -- 渐变：头部亮白→中间主题色→尾部透明消失
  local mg=Instance.new("UIGradient") mg.Parent=m
  mg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.3,Settings.Accent),ColorSequenceKeypoint.new(1,Settings.Accent)}
  mg.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.2,0),NumberSequenceKeypoint.new(0.7,0.5),NumberSequenceKeypoint.new(1,1)}
  -- 发光效果
  local gs=Instance.new("UIStroke") gs.Parent=m gs.Thickness=2 gs.Transparency=0.6 gs.Color=Settings.Accent gs.LineJoinMode=Enum.LineJoinMode.Round
  table.insert(fxMeteors,{Obj=m,Delay=i*0.25,Spd=1+math.random()*0.6,Len=55+math.random(40),Grad=mg,Stroke=gs})
 end
 -- 特效状态
 local fxState={Rainbow=false,Meteor=false,RainbowConn=nil,MeteorConn=nil,AccentBase=Settings.Accent}
 local function fxTick()
  if not SG.Parent then return end
  local t=os.clock()
  -- 彩虹边框
  if fxState.Rainbow then
   local hue=(t*0.15)%1 local c=Color3.fromHSV(hue,0.7,1)
   MS.Color=c TBS.Color=c TLS.Color=c VTS.Color=c
   TL2.TextColor3=c VT.TextColor3=c PC.ScrollBarImageColor3=c
   for _,p in ipairs(pages) do
    if p.Pg==cur then p.Btn.BackgroundColor3=Color3.fromRGB(c.R*40,c.G*40,c.B*40) p.Btn.TextColor3=c end
   end
  end
  -- 流星环绕
  if fxState.Meteor then
   local mfx=MF.AbsolutePosition.X local mfy=MF.AbsolutePosition.Y
   local w=MF.AbsoluteSize.X local h=MF.AbsoluteSize.Y
   local perimeter=2*(w+h)
   for i,md in ipairs(fxMeteors) do
    local pos=((t*md.Spd*100+md.Delay*80)%perimeter)/perimeter
    md.Obj.Visible=true
    -- 计算流星位置（屏幕绝对坐标），流星头朝前
    local px,py,rot
    if pos<0.25 then -- 上边 左→右
     local pf=pos/0.25 px=mfx+pf*w py=mfy-2 rot=90
    elseif pos<0.5 then -- 右边 上→下
     local pf=(pos-0.25)/0.25 px=mfx+w+2 py=mfy+pf*h rot=180
    elseif pos<0.75 then -- 下边 右→左
     local pf=(pos-0.5)/0.25 px=mfx+w-pf*w py=mfy+h+2 rot=270
    else -- 左边 下→上
     local pf=(pos-0.75)/0.25 px=mfx-2 py=mfy+h-pf*h rot=0
    end
    md.Obj.Position=UDim2.new(0,px,0,py)
    md.Obj.Rotation=rot
    md.Obj.Size=UDim2.new(0,4,0,md.Len)
    local c
    if fxState.Rainbow then
     local hue2=((t*0.15)+i*0.05)%1 c=Color3.fromHSV(hue2,0.7,1)
     md.Obj.BackgroundColor3=c
     md.Grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.3,c),ColorSequenceKeypoint.new(1,c)}
     md.Stroke.Color=c
    else
     c=fxState.AccentBase md.Obj.BackgroundColor3=c
     md.Grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.3,c),ColorSequenceKeypoint.new(1,c)}
     md.Stroke.Color=c
    end
   end
  else
   for _,md in ipairs(fxMeteors) do md.Obj.Visible=false end
  end
 end
 local function applyAccent(color)
  Settings.Accent=color fxState.AccentBase=color
  if not fxState.Rainbow then
   MS.Color=color TBS.Color=color TLS.Color=color VTS.Color=color
   TL2.TextColor3=color VT.TextColor3=color PC.ScrollBarImageColor3=color
   for _,p in ipairs(pages) do
    if p.Pg==cur then p.Btn.BackgroundColor3=Color3.fromRGB(color.R*40,color.G*40,color.B*40) p.Btn.TextColor3=color end
   end
  end
 end
 local function applyBG(imgid,color,trans,gradient,rot)
  if gradient then
   -- 渐变背景 + 暗角效果
   BGG.Enabled=true
   BGG.Color=ColorSequence.new(gradient)
   BGG.Rotation=rot or 90
   BGL.BackgroundTransparency=0
   BGL.BackgroundColor3=gradient[1]
   VG.Enabled=true
   Vignette.BackgroundTransparency=0
  elseif color then
   -- 纯色背景
   BGG.Enabled=false
   BGL.BackgroundColor3=color BGL.BackgroundTransparency=trans or 0.5
   VG.Enabled=false
   Vignette.BackgroundTransparency=1
  else
   -- 无背景
   BGG.Enabled=false
   BGL.BackgroundTransparency=1
   VG.Enabled=false
   Vignette.BackgroundTransparency=1
  end
 end
 local function toggleRainbow(enable)
  fxState.Rainbow=enable
  if enable then
   if not fxState.RainbowConn then
    fxState.RainbowConn=RS.RenderStepped:Connect(fxTick)
   end
  else
   if fxState.RainbowConn and not fxState.Meteor then
    fxState.RainbowConn:Disconnect() fxState.RainbowConn=nil
   end
   applyAccent(fxState.AccentBase)
  end
 end
 local function toggleMeteor(enable)
  fxState.Meteor=enable
  if enable then
   if not fxState.MeteorConn then
    fxState.MeteorConn=RS.RenderStepped:Connect(fxTick)
   end
  else
   if fxState.MeteorConn and not fxState.Rainbow then
    fxState.MeteorConn:Disconnect() fxState.MeteorConn=nil
   end
   for _,md in ipairs(fxMeteors) do md.Obj.Visible=false end
  end
 end
 local W={ApplyAccent=applyAccent,ApplyBG=applyBG,ToggleRainbow=toggleRainbow,ToggleMeteor=toggleMeteor}
 function W:AddTab(name,icon)
  local btn=Instance.new("TextButton") btn.Parent=SBC btn.BackgroundColor3=Color3.fromRGB(24,24,30) btn.Size=UDim2.new(0,155,0,36)
  btn.Font=Enum.Font.GothamSemibold btn.Text=(icon and icon.."  " or "")..name btn.TextColor3=Color3.fromRGB(190,190,210) btn.TextSize=13 btn.TextXAlignment=Enum.TextXAlignment.Left btn.AutoButtonColor=false btn.ZIndex=3
  Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
  local BP=Instance.new("UIPadding") BP.Parent=btn BP.PaddingLeft=UDim.new(0,12)
  local pg=Instance.new("Frame") pg.Parent=PC pg.BackgroundTransparency=1 pg.Size=UDim2.new(1,0,1,0) pg.Visible=false pg.ZIndex=2
  local PL=Instance.new("UIListLayout") PL.Parent=pg PL.Padding=UDim.new(0,8) PL.HorizontalAlignment=Enum.HorizontalAlignment.Center PL.VerticalAlignment=Enum.VerticalAlignment.Top
  local PP=Instance.new("UIPadding") PP.Parent=pg PP.PaddingTop=UDim.new(0,12) PP.PaddingBottom=UDim.new(0,12) PP.PaddingLeft=UDim.new(0,12) PP.PaddingRight=UDim.new(0,12)
  if #pages==0 then btn.BackgroundColor3=Color3.fromRGB(Settings.Accent.R*40,Settings.Accent.G*40,Settings.Accent.B*40) btn.TextColor3=Settings.Accent pg.Visible=true cur=pg end
  btn.MouseEnter:Connect(function() if cur~=pg then TS:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(34,34,42)}):Play() end end)
  btn.MouseLeave:Connect(function() if cur~=pg then TS:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(24,24,30)}):Play() end end)
  btn.MouseButton1Click:Connect(function()
   if cur==pg then return end
   -- 丝滑页面切换动画
   local oldPg=cur
   for _,p in ipairs(pages) do p.Btn.BackgroundColor3=Color3.fromRGB(24,24,30) p.Btn.TextColor3=Color3.fromRGB(190,190,210) end
   btn.BackgroundColor3=Color3.fromRGB(Settings.Accent.R*40,Settings.Accent.G*40,Settings.Accent.B*40) btn.TextColor3=Settings.Accent
   -- 新页面从右侧滑入+淡入
   pg.Visible=true
   pg.Position=UDim2.new(1,10,0,0)
   pg.BackgroundTransparency=1
   TS:Create(pg,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Position=UDim2.new(0,0,0,0),BackgroundTransparency=1}):Play()
   -- 旧页面淡出
   if oldPg and oldPg~=pg then
    TS:Create(oldPg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Position=UDim2.new(-0.05,0,0,0)}):Play()
    task.delay(0.2,function() oldPg.Visible=false oldPg.Position=UDim2.new(0,0,0,0) end)
   end
   cur=pg
   task.delay(0.26,function() PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end)
  end)
  local T={Btn=btn,Pg=pg,PL=PL,PC=PC}
  function T:AddButton(txt,cb)
   local bf=Instance.new("Frame") bf.Parent=pg bf.BackgroundColor3=Color3.fromRGB(24,24,30) bf.Size=UDim2.new(1,0,0,42) bf.ZIndex=3
   Instance.new("UICorner",bf).CornerRadius=UDim.new(0,6)
   local b=Instance.new("TextButton") b.Parent=bf b.BackgroundTransparency=1 b.Size=UDim2.new(1,0,1,0)
   b.Font=Enum.Font.GothamSemibold b.Text=txt b.TextColor3=Color3.fromRGB(220,220,240) b.TextSize=13 b.AutoButtonColor=false b.ZIndex=5
   b.MouseEnter:Connect(function() TS:Create(bf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end)
   b.MouseLeave:Connect(function() TS:Create(bf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(24,24,30)}):Play() end)
   b.MouseButton1Click:Connect(function() cb() end)
   if cur==pg then PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end
   return b
  end
  function T:AddSection(sname,collapsed)
   local sec=Instance.new("Frame") sec.Parent=pg sec.BackgroundColor3=Color3.fromRGB(24,24,30) sec.Size=UDim2.new(1,0,0,38) sec.ClipsDescendants=true sec.ZIndex=3
   Instance.new("UICorner",sec).CornerRadius=UDim.new(0,6)
   local stb=Instance.new("TextButton") stb.Parent=sec stb.BackgroundTransparency=1 stb.Position=UDim2.new(0,0,0,0) stb.Size=UDim2.new(1,0,0,38)
   stb.Font=Enum.Font.GothamBold stb.Text=(collapsed and "  ▶ " or "  🔻 ")..sname stb.TextColor3=Color3.fromRGB(220,220,240) stb.TextSize=13 stb.TextXAlignment=Enum.TextXAlignment.Left stb.AutoButtonColor=false stb.ZIndex=6
   local sp2=Instance.new("UIPadding") sp2.Parent=stb sp2.PaddingLeft=UDim.new(0,12)
   local sc=Instance.new("Frame") sc.Parent=sec sc.BackgroundTransparency=1 sc.Position=UDim2.new(0,0,0,38) sc.Size=UDim2.new(1,0,0,0) sc.AutomaticSize=Enum.AutomaticSize.Y sc.ZIndex=4
   local SCL=Instance.new("UIListLayout") SCL.Parent=sc SCL.Padding=UDim.new(0,6) SCL.HorizontalAlignment=Enum.HorizontalAlignment.Center SCL.VerticalAlignment=Enum.VerticalAlignment.Top
   local SCP=Instance.new("UIPadding") SCP.Parent=sc SCP.PaddingLeft=UDim.new(0,12) SCP.PaddingRight=UDim.new(0,12) SCP.PaddingBottom=UDim.new(0,10)
   local exp=not collapsed
   stb.MouseEnter:Connect(function() stb.TextColor3=Color3.fromRGB(255,255,255) end)
   stb.MouseLeave:Connect(function() stb.TextColor3=Color3.fromRGB(220,220,240) end)
   stb.MouseButton1Click:Connect(function()
    exp=not exp
    if exp then stb.Text="  🔻 "..sname TS:Create(sec,TweenInfo.new(0.2),{Size=UDim2.new(1,0,0,38+sc.AbsoluteSize.Y+10)}):Play()
    else stb.Text="  ▶ "..sname TS:Create(sec,TweenInfo.new(0.2),{Size=UDim2.new(1,0,0,38)}):Play() end
    task.delay(0.22,function() if cur==pg then PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end end)
   end)
   local S={}
   function S:AddButton(txt,cb)
    local bf=Instance.new("Frame") bf.Parent=sc bf.BackgroundColor3=Color3.fromRGB(30,30,38) bf.Size=UDim2.new(1,0,0,36) bf.ZIndex=5
    Instance.new("UICorner",bf).CornerRadius=UDim.new(0,5)
    local b=Instance.new("TextButton") b.Parent=bf b.BackgroundTransparency=1 b.Size=UDim2.new(1,0,1,0)
    b.Font=Enum.Font.GothamSemibold b.Text=txt b.TextColor3=Color3.fromRGB(210,210,230) b.TextSize=12 b.AutoButtonColor=false b.ZIndex=6
    b.MouseEnter:Connect(function() TS:Create(bf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(42,42,55)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(bf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,38)}):Play() end)
    b.MouseButton1Click:Connect(function() cb() end)
    task.defer(function() if exp then sec.Size=UDim2.new(1,0,0,38+sc.AbsoluteSize.Y+10) end if cur==pg then PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end end)
    return b
   end
   function S:AddSlider(name,minv,maxv,def,cb)
    local sf=Instance.new("Frame") sf.Parent=sc sf.BackgroundColor3=Color3.fromRGB(30,30,38) sf.Size=UDim2.new(1,0,0,64) sf.ZIndex=5
    Instance.new("UICorner",sf).CornerRadius=UDim.new(0,5)
    -- 悬浮发光效果
    local glow=Instance.new("UIStroke") glow.Parent=sf glow.Thickness=0 glow.Transparency=1 glow.Color=Settings.Accent glow.LineJoinMode=Enum.LineJoinMode.Round
    local sl=Instance.new("TextLabel") sl.Parent=sf sl.BackgroundTransparency=1 sl.Position=UDim2.new(0,12,0,4) sl.Size=UDim2.new(1,-80,0,20)
    sl.Font=Enum.Font.GothamSemibold sl.Text=name.."  "..tostring(def) sl.TextColor3=Color3.fromRGB(210,210,230) sl.TextSize=12 sl.TextXAlignment=Enum.TextXAlignment.Left sl.ZIndex=6
    local sP=Instance.new("UIPadding") sP.Parent=sl sP.PaddingLeft=UDim.new(0,12)
    -- 数值输入框
    local ib=Instance.new("TextBox") ib.Parent=sf ib.BackgroundColor3=Color3.fromRGB(45,45,60) ib.Position=UDim2.new(1,-68,0,4) ib.Size=UDim2.new(0,56,0,22) ib.ZIndex=7 ib.Font=Enum.Font.GothamBold ib.Text=tostring(def) ib.TextColor3=Settings.Accent ib.TextSize=11 ib.TextXAlignment=Enum.TextXAlignment.Center
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,4)
    local ibs=Instance.new("UIStroke") ibs.Parent=ib ibs.Thickness=1 ibs.Transparency=0.7 ibs.Color=Settings.Accent
    local track=Instance.new("Frame") track.Parent=sf track.BackgroundColor3=Color3.fromRGB(50,50,65) track.Position=UDim2.new(0,12,0,42) track.Size=UDim2.new(1,-24,0,6) track.ZIndex=6
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)
    local fill=Instance.new("Frame") fill.Parent=track fill.BackgroundColor3=Settings.Accent fill.Size=UDim2.new((def-minv)/(maxv-minv),0,1,0) fill.ZIndex=7
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local fg=Instance.new("UIGradient") fg.Parent=fill fg.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,0)}
    local knob=Instance.new("Frame") knob.Parent=track knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new((def-minv)/(maxv-minv),-5,0,0) knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(8,0)
    local ks=Instance.new("UIStroke") ks.Parent=knob ks.Thickness=2 ks.Color=Settings.Accent
    -- 大触控区域（透明按钮，覆盖整个轨道范围，方便移动端点击拖动）
    local hitBtn=Instance.new("TextButton") hitBtn.Parent=sf hitBtn.BackgroundTransparency=1 hitBtn.Text="" hitBtn.Position=UDim2.new(0,12,0,36) hitBtn.Size=UDim2.new(1,-24,0,20) hitBtn.ZIndex=20 hitBtn.AutoButtonColor=false
    local dragging=false local val=def
    local function getPct(input)
     return (input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X
    end
    local function upd(pct)
     if pct<0 then pct=0 elseif pct>1 then pct=1 end
     val=math.floor(minv+pct*(maxv-minv)+0.5)
     fill.Size=UDim2.new(pct,0,1,0)
     knob.Position=UDim2.new(pct,-5,0,0)
     sl.Text=name.."  "..tostring(val)
     ib.Text=tostring(val)
     cb(val)
    end
    local function setVal(v)
     v=tonumber(v) if not v then return end
     if v<minv then v=minv elseif v>maxv then v=maxv end
     upd((v-minv)/(maxv-minv))
    end
    local function startDrag(input)
     dragging=true
     upd(getPct(input))
     -- 拖动时发光效果
     TS:Create(glow,TweenInfo.new(0.2),{Thickness=1.5,Transparency=0.3}):Play()
    end
    hitBtn.InputBegan:Connect(function(input)
     if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
      startDrag(input)
     end
    end)
    knob.InputBegan:Connect(function(input)
     if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
      startDrag(input)
     end
    end)
    track.InputBegan:Connect(function(input)
     if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
      startDrag(input)
     end
    end)
    UIS.InputChanged:Connect(function(input)
     if not dragging then return end
     if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
      upd(getPct(input))
     end
    end)
    UIS.InputEnded:Connect(function(input)
     if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
      dragging=false
      TS:Create(glow,TweenInfo.new(0.2),{Thickness=0,Transparency=1}):Play()
     end
    end)
    -- 输入框回车确认
    ib.FocusLost:Connect(function(enterPressed)
     if enterPressed then
      setVal(ib.Text)
     end
    end)
    -- 悬浮效果
    sf.MouseEnter:Connect(function() TS:Create(sf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(38,38,50)}):Play() TS:Create(glow,TweenInfo.new(0.15),{Thickness=1,Transparency=0.5}):Play() end)
    sf.MouseLeave:Connect(function() if not dragging then TS:Create(sf,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,38)}):Play() TS:Create(glow,TweenInfo.new(0.15),{Thickness=0,Transparency=1}):Play() end end)
    task.defer(function() if exp then sec.Size=UDim2.new(1,0,0,38+sc.AbsoluteSize.Y+10) end if cur==pg then PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end end)
    return {Set=function(v) setVal(v) end,Get=function() return val end}
   end
   task.defer(function() if exp then sec.Size=UDim2.new(1,0,0,38+sc.AbsoluteSize.Y+10) end if cur==pg then PC.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+24) end end)
   return S
  end
  table.insert(pages,T)
  return T
 end
 function W:Show()
  MF.BackgroundTransparency=1
  MF.Size=UDim2.new(0,500,0,320)
  MF.Position=UDim2.new(0.5,-250,0.5,-160)
  SG.Enabled=true
  -- 丝滑弹出动画：放大+淡入
  TS:Create(MF,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,620,0,400),BackgroundTransparency=0}):Play()
  TS:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-310,0.5,-200)}):Play()
 end
 return W
end
local NC={E=false,S=50,C=nil,D=nil,OC={},BV=nil,OG=nil}
function NC:Enable()
 if self.E then return end self.E=true
 local ch=LP.Character if not ch then self.E=false print("[NC] no char") return end
 local hrp=ch:FindFirstChild("HumanoidRootPart") local hum=ch:FindFirstChild("Humanoid")
 if not hrp or not hum then self.E=false print("[NC] no hrp") return end
 self.OWS=hum.WalkSpeed self.OJP=hum.JumpPower self.OJH=hum.JumpHeight
 hum.WalkSpeed=self.S hum.JumpPower=0 hum.JumpHeight=0
 self.OC={}
 for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then self.OC[p]=p.CanCollide p.CanCollide=false end end
 self.D=ch.DescendantAdded:Connect(function(d) if d:IsA("BasePart") then self.OC[d]=d.CanCollide d.CanCollide=false end end)
 self.C=RS.Stepped:Connect(function()
  if not self.E then return end
  ch=LP.Character if not ch then return end
  hrp=ch:FindFirstChild("HumanoidRootPart") hum=ch:FindFirstChild("Humanoid")
  if not hrp or not hum then return end
  local mv=hum.MoveDirection
  if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
  if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
  if mv.Magnitude>0.1 then
   hrp.Velocity=mv.Unit*self.S
  else
   hrp.Velocity=Vector3.new(hrp.Velocity.X*0.9,0,hrp.Velocity.Z*0.9)
  end
 end)
 print("[穿墙] 已开启 (方向键移动,空格上升,Ctrl下降)")
end
function NC:Disable()
 if not self.E then return end self.E=false
 if self.C then self.C:Disconnect() self.C=nil end
 if self.D then self.D:Disconnect() self.D=nil end
 local ch=LP.Character
 if ch and self.OC then for p,o in pairs(self.OC) do if p and p.Parent then p.CanCollide=o end end end
 if ch then
  local h=ch:FindFirstChild("Humanoid")
  if h then h.WalkSpeed=self.OWS or 16 h.JumpPower=self.OJP or 50 h.JumpHeight=self.OJH or 7.2 end
 end
 self.OC={} print("[穿墙] 已关闭")
end
local ESP={E=false,SN=true,SD=true,SH=true,SB=true,TC=false,HL=false,D={},C=nil}
local function nd(t) local d=Drawing.new(t) d.Visible=false return d end
local function cESP(plr)
 if plr==LP then return end
 ESP.D[plr]={Box=nd("Square"),Name=nd("Text"),Dist=nd("Text"),HP=nd("Square"),HPB=nd("Square"),HL=nil}
 local e=ESP.D[plr]
 e.Box.Thickness=1 e.Box.Filled=false e.Box.Transparency=1
 e.Name.Center=true e.Name.Outline=true e.Name.Color=Color3.fromRGB(255,255,255) e.Name.Size=13 e.Name.Font=2
 e.Dist.Center=true e.Dist.Outline=true e.Dist.Color=Color3.fromRGB(200,200,200) e.Dist.Size=12 e.Dist.Font=2
 e.HPB.Color=Color3.fromRGB(0,0,0) e.HPB.Filled=true e.HPB.Thickness=1 e.HPB.Transparency=0.7
 e.HP.Filled=true e.HP.Thickness=1 e.HP.Transparency=1 e.HP.Color=Color3.fromRGB(0,255,0)
end
local function updateHL(plr,e)
 local ch=plr.Character local hum=ch and ch:FindFirstChild("Humanoid")
 if not ch or not hum or hum.Health<=0 then
  if e.HL then e.HL.Enabled=false end
  return
 end
 if not e.HL then
  local hl=Instance.new("Highlight") hl.Parent=ch hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
  hl.FillColor=Color3.fromRGB(255,50,50) hl.OutlineColor=Color3.fromRGB(255,255,255)
  hl.FillTransparency=0.7 hl.OutlineTransparency=0.2 hl.Enabled=false
  e.HL=hl
 end
 e.HL.Enabled=ESP.HL
 if ESP.TC and plr.Team==LP.Team then e.HL.Enabled=false end
end
local function uESP()
 if not ESP.E then return end
 for plr,e in pairs(ESP.D) do
  local ch=plr.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart") local hum=ch and ch:FindFirstChild("Humanoid")
  pcall(function() updateHL(plr,e) end)
  local function hi() e.Box.Visible=false e.Name.Visible=false e.Dist.Visible=false e.HP.Visible=false e.HPB.Visible=false end
  if not ch or not hrp or not hum or hum.Health<=0 then hi()
  elseif ESP.TC and plr.Team==LP.Team then hi()
  else
   local rp,on=cam:WorldToViewportPoint(hrp.Position)
   local head=ch:FindFirstChild("Head")
   local hp2=cam:WorldToViewportPoint(head and head.Position or hrp.Position)
   local lp=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
   if not on then hi()
   else
    local h=math.abs(hp2.Y-lp.Y) local w=h*0.6 local bx=rp.X-w/2 local by=hp2.Y
    if ESP.SB then e.Box.Visible=true e.Box.Size=Vector2.new(w,h) e.Box.Position=Vector2.new(bx,by)
     e.Box.Color=plr.Team and plr.TeamColor.Color or Color3.fromRGB(255,0,0)
    else e.Box.Visible=false end
    if ESP.SN then e.Name.Visible=true e.Name.Text=plr.Name e.Name.Position=Vector2.new(rp.X,by-18) else e.Name.Visible=false end
    if ESP.SD then
     local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
     if mr then e.Dist.Visible=true e.Dist.Text=math.floor((hrp.Position-mr.Position).Magnitude).." studs" e.Dist.Position=Vector2.new(rp.X,by+h+2)
     else e.Dist.Visible=false end
    else e.Dist.Visible=false end
    if ESP.SH then
     local pct=hum.Health/hum.MaxHealth local bw=4
     e.HPB.Visible=true e.HPB.Size=Vector2.new(bw,h) e.HPB.Position=Vector2.new(bx-bw-3,by)
     e.HP.Visible=true e.HP.Size=Vector2.new(bw,h*pct) e.HP.Position=Vector2.new(bx-bw-3,by+(h-h*pct))
     e.HP.Color=pct>0.7 and Color3.fromRGB(0,255,0) or pct>0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
    else e.HP.Visible=false e.HPB.Visible=false end
   end
  end
 end
end
function ESP:Enable()
 if self.E then return end self.E=true
 for _,p in ipairs(Plrs:GetPlayers()) do if p~=LP then cESP(p) end end
 self.PA=Plrs.PlayerAdded:Connect(function(p) if p~=LP then p.CharacterAdded:Wait() cESP(p) end end)
 self.PR=Plrs.PlayerRemoving:Connect(function(p)
  if self.D[p] then
   for _,d in pairs(self.D[p]) do
    if type(d)=="userdata" and pcall(function() return d.Remove end) then pcall(function() d:Remove() end)
    elseif typeof(d)=="Instance" then pcall(function() d:Destroy() end) end
   end
   self.D[p]=nil
  end
 end)
 self.C=RS.RenderStepped:Connect(function() cam=workspace.CurrentCamera or cam uESP() end)
 print("[ESP] 已开启")
end
function ESP:Disable()
 if not self.E then return end self.E=false
 if self.C then self.C:Disconnect() self.C=nil end
 if self.PA then self.PA:Disconnect() self.PA=nil end
 if self.PR then self.PR:Disconnect() self.PR=nil end
 for plr,e in pairs(self.D) do
  for _,d in pairs(e) do
   if type(d)=="userdata" and pcall(function() return d.Remove end) then pcall(function() d:Remove() end)
   elseif typeof(d)=="Instance" then pcall(function() d:Destroy() end) end
  end
 end
 self.D={} print("[ESP] 已关闭")
end
local function runLS(name,url)
 print("["..name.."] 正在加载...")
 local ok,err=pcall(function() loadstring(game:HttpGet(url))() end)
 if ok then print("["..name.."] 加载成功！") else warn("["..name.."] 失败:",err) end
end
local function runLST(name,url)
 print("["..name.."] 正在加载...")
 local ok,err=pcall(function() loadstring(game:HttpGet(url,true))() end)
 if ok then print("["..name.."] 加载成功！") else warn("["..name.."] 失败:",err) end
end
local function runLSA(name,url)
 print("["..name.."] 正在加载...")
 local ok,err=pcall(function() loadstring(game:HttpGetAsync(url))() end)
 if ok then print("["..name.."] 加载成功！") else warn("["..name.."] 失败:",err) end
end
buildUI=function()
 local W=Lib:CreateWindow("磊脚本")
 local MT=W:AddTab("主页","🏠")
 local NS=MT:AddSection("📢 重要公告")
 NS:AddButton("此脚本由 TRAE 制造",function() end)
 NS:AddButton("完全免费，请勿付费购买",function() end)
 NS:AddButton("如已付费请向买家退款",function() end)
 local SpS=MT:AddSection("⚡  通用调整")
 SpS:AddSlider("🏃  移动速度",1,10000,16,function(v)
  local ch=LP.Character local hum=ch and ch:FindFirstChild("Humanoid")
  if hum then hum.WalkSpeed=v print("[速度] WalkSpeed="..v) end
 end)
 SpS:AddSlider("🦘  跳跃力",1,10000,50,function(v)
  local ch=LP.Character local hum=ch and ch:FindFirstChild("Humanoid")
  if hum then hum.JumpPower=v print("[跳跃] JumpPower="..v) end
 end)
 SpS:AddButton("🔄  恢复默认",function()
  local ch=LP.Character local hum=ch and ch:FindFirstChild("Humanoid")
  if hum then hum.WalkSpeed=16 hum.JumpPower=50 print("[调整] 已恢复默认") end
 end)
 local FS=MT:AddSection("✈  飞行功能")
 FS:AddButton("✈  开启飞行",function() runLS("飞行","https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua") end)
 local AWS={E=false,C=nil,BV=nil,BP=nil,OWS=16,OJP=50,OG=196.2,TargetY=0,Jumping=false,LastSpace=false,CharConn=nil}
function AWS:Enable()
 if self.E then return end self.E=true
 local ch=LP.Character local hum=ch and ch:FindFirstChild("Humanoid") local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hum or not hrp then print("[踏空] 找不到角色") self.E=false return end
 self.OWS=hum.WalkSpeed self.OJP=hum.JumpPower
 self.OG=workspace.Gravity
 self.TargetY=hrp.Position.Y
 hum.WalkSpeed=16 hum.JumpPower=0
 -- 关闭重力
 workspace.Gravity=0
 -- BodyVelocity 控制水平移动
 local bv=Instance.new("BodyVelocity") bv.Name="AirWalkBV"
 bv.Velocity=Vector3.new(0,0,0) bv.MaxForce=Vector3.new(10000,math.huge,10000)
 bv.P=5000 bv.Parent=hrp
 self.BV=bv
 -- BodyPosition 锁定Y轴高度
 local bp=Instance.new("BodyPosition") bp.Name="AirWalkBP"
 bp.Position=Vector3.new(0,self.TargetY,0) bp.MaxForce=Vector3.new(0,99999,0)
 bp.P=10000 bp.D=800 bp.Parent=hrp
 self.BP=bp
 -- 角色重生自动恢复
 self.CharConn=LP.CharacterAdded:Connect(function(c)
  if not self.E then return end
  task.wait(1.5)
  if not self.E then return end
  local h=c:FindFirstChild("Humanoid") local r=c:FindFirstChild("HumanoidRootPart")
  if h and r then
   h.WalkSpeed=16 h.JumpPower=0
   local bv2=Instance.new("BodyVelocity") bv2.Name="AirWalkBV"
   bv2.Velocity=Vector3.new(0,0,0) bv2.MaxForce=Vector3.new(10000,math.huge,10000) bv2.P=5000 bv2.Parent=r
   self.BV=bv2
   local bp3=Instance.new("BodyPosition") bp3.Name="AirWalkBP"
   bp3.Position=Vector3.new(0,r.Position.Y,0) bp3.MaxForce=Vector3.new(0,99999,0) bp3.P=10000 bp3.D=800 bp3.Parent=r
   self.BP=bp3 self.TargetY=r.Position.Y
   print("[踏空] 重生后自动恢复")
  end
 end)
 -- 主循环
 self.C=RS.Stepped:Connect(function()
  local c=LP.Character local h=c and c:FindFirstChild("Humanoid") local r=c and c:FindFirstChild("HumanoidRootPart")
  if not h or not r then return end
  -- 确保 BodyVelocity 存在
  local b=r:FindFirstChild("AirWalkBV")
  if not b then
   b=Instance.new("BodyVelocity") b.Name="AirWalkBV"
   b.MaxForce=Vector3.new(10000,math.huge,10000) b.P=5000 b.Parent=r
   self.BV=b
  end
  -- 确保 BodyPosition 存在
  local bp2=r:FindFirstChild("AirWalkBP")
  if not bp2 then
   bp2=Instance.new("BodyPosition") bp2.Name="AirWalkBP"
   bp2.MaxForce=Vector3.new(0,99999,0) bp2.P=10000 bp2.D=800 bp2.Parent=r
   bp2.Position=Vector3.new(0,self.TargetY,0) self.BP=bp2
  end
  -- 水平移动控制（平滑插值）
  local md=h.MoveDirection
  local curVel=b.Velocity
  local targetX=0 local targetZ=0
  if md.Magnitude>0.1 then
   targetX=md.X*h.WalkSpeed targetZ=md.Z*h.WalkSpeed
  end
  b.Velocity=Vector3.new(
   curVel.X+(targetX-curVel.X)*0.3,
   curVel.Y,
   curVel.Z+(targetZ-curVel.Z)*0.3
  )
  -- 跳跃控制
  local spaceDown=UIS:IsKeyDown(Enum.KeyCode.Space)
  local shiftDown=UIS:IsKeyDown(Enum.KeyCode.LeftShift)
  if spaceDown and not self.LastSpace then
   self.Jumping=true
   bp2.MaxForce=Vector3.new(0,0,0)
   b.Velocity=Vector3.new(curVel.X,55,curVel.Z)
  elseif not spaceDown and self.LastSpace and self.Jumping then
   self.Jumping=false
   self.TargetY=r.Position.Y
   bp2.MaxForce=Vector3.new(0,99999,0)
   bp2.Position=Vector3.new(0,self.TargetY,0)
   b.Velocity=Vector3.new(curVel.X,0,curVel.Z)
  elseif shiftDown then
   self.Jumping=false
   self.TargetY=self.TargetY-0.8
   bp2.MaxForce=Vector3.new(0,99999,0)
   bp2.Position=Vector3.new(0,self.TargetY,0)
  end
  self.LastSpace=spaceDown
  -- 跳跃顶点自动锁定
  if self.Jumping then
   if r.Velocity.Y<=0.2 then
    self.Jumping=false
    self.TargetY=r.Position.Y
    bp2.MaxForce=Vector3.new(0,99999,0)
    bp2.Position=Vector3.new(0,self.TargetY,0)
    b.Velocity=Vector3.new(curVel.X,0,curVel.Z)
   end
  end
 end)
 print("[踏空] 已开启 (空格跳跃/Shift下降/重生自动恢复)")
end
function AWS:Disable()
 if not self.E then return end self.E=false
 if self.C then self.C:Disconnect() self.C=nil end
 if self.CharConn then self.CharConn:Disconnect() self.CharConn=nil end
 local ch=LP.Character local hum=ch and ch:FindFirstChild("Humanoid") local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if hum then pcall(function() hum.WalkSpeed=self.OWS hum.JumpPower=self.OJP end) end
 if hrp then
  local b=hrp:FindFirstChild("AirWalkBV") if b then pcall(function() b:Destroy() end) end
  local bp2=hrp:FindFirstChild("AirWalkBP") if bp2 then pcall(function() bp2:Destroy() end) end
 end
 workspace.Gravity=self.OG
 print("[踏空] 已关闭")
end
local AWSs=MT:AddSection("踏空行走")
 AWSs:AddButton("●  开启踏空",function() AWS:Enable() end)
 AWSs:AddButton("○  关闭踏空",function() AWS:Disable() end)
 local NT=W:AddTab("穿墙","🧱")
 local NM=NT:AddSection("穿墙开关")
 NM:AddButton("●  开启穿墙",function() NC:Enable() end)
 NM:AddButton("○  关闭穿墙",function() NC:Disable() end)
 local NSet=NT:AddSection("速度设置")
 local sb={}
 local function updSel(s) for n,data in pairs(sb) do data.Button.Text=data.Base..(n==s and "  ✓" or "") end end
 local s1=NSet:AddButton("🐢  慢速",function() NC.S=20 updSel("s1") end) sb.s1={Button=s1,Base="🐢  慢速"}
 local s2=NSet:AddButton("🚶  中速",function() NC.S=50 updSel("s2") end) sb.s2={Button=s2,Base="🚶  中速"}
 local s3=NSet:AddButton("🏃  快速",function() NC.S=100 updSel("s3") end) sb.s3={Button=s3,Base="🏃  快速"}
 local s4=NSet:AddButton("🚀  极速",function() NC.S=200 updSel("s4") end) sb.s4={Button=s4,Base="🚀  极速"}
 updSel("s2")
 local ET=W:AddTab("透视","👁")
 local EM=ET:AddSection("透视开关")
 EM:AddButton("●  开启透视",function() ESP:Enable() end)
 EM:AddButton("○  关闭透视",function() ESP:Disable() end)
 local ES=ET:AddSection("显示设置")
 ES:AddButton("👤  显示名字: 开",function() ESP.SN=not ESP.SN end)
 ES:AddButton("📏  显示距离: 开",function() ESP.SD=not ESP.SD end)
 ES:AddButton("❤️  显示血条: 开",function() ESP.SH=not ESP.SH end)
 ES:AddButton("📦  显示框线: 开",function() ESP.SB=not ESP.SB end)
 ES:AddButton("✨  人物高亮: 关",function() ESP.HL=not ESP.HL print("[ESP] 人物高亮:"..(ESP.HL and "开" or "关")) end)
 ES:AddButton("👥  队伍检查: 关",function() ESP.TC=not ESP.TC end)
 -- NPC透视
 local NPC_ESP={E=false,E_Hostile=false,E_Friendly=false,D={},C=nil,Conn=nil}
 -- 敌方NPC关键词（会攻击的）
 local hostileKeys={"zombie","Zombie","monster","Monster","enemy","Enemy","boss","Boss","guard","Guard","soldier","Soldier","killer","Killer","demon","Demon","ghost","Ghost","skeleton","Skeleton","bandit","Bandit","pirate","Pirate","warrior","Warrior","knight","Knight","archer","Archer","mage","Mage","wizard","Wizard","villain","Villain","evil","Evil","dark","Dark","undead","Undead","vampire","Vampire","werewolf","Werewolf","dragon","Dragon","spider","Spider","wolf","Wolf","bear","Bear","shark","Shark","crocodile","Crocodile","alien","Alien","robot","Robot","android","Android","security","Security","police","Police","swat","SWAT","hostile","Hostile","aggressive","Aggressive"}
 -- 友善NPC关键词（不会攻击的）
 local friendlyKeys={"npc","NPC","shop","Shop","merchant","Merchant","vendor","Vendor","seller","Seller","buyer","Buyer","citizen","Citizen","civilian","Civilian","villager","Villager","farmer","Farmer","worker","Worker","doctor","Doctor","nurse","Nurse","teacher","Teacher","student","Student","kid","Kid","child","Child","baby","Baby","friend","Friend","ally","Ally","friendly","Friendly","peaceful","Peaceful","helper","Helper","guide","Guide","quest","Quest","questgiver","QuestGiver","pet","Pet","cat","Cat","dog","Dog","bunny","Bunny","rabbit","Rabbit"}
 local function isHostileNPC(model)
  local name=model.Name:lower()
  for _,k in ipairs(hostileKeys) do
   if name:find(k:lower(),1,true) then return true end
  end
  -- 检查是否有武器/攻击工具
  if model:FindFirstChildOfClass("Tool") then return true end
  if model:FindFirstChild("Sword",true) or model:FindFirstChild("Gun",true) or model:FindFirstChild("Knife",true) then return true end
  -- 检查是否有攻击脚本
  for _,d in ipairs(model:GetDescendants()) do
   if d:IsA("Script") or d:IsA("LocalScript") then
    local dn=d.Name:lower()
    if dn:find("attack") or dn:find("damage") or dn:find("kill") or dn:find("fight") then
     return true
    end
   end
  end
  return false
 end
 local function isFriendlyNPC(model)
  local name=model.Name:lower()
  for _,k in ipairs(friendlyKeys) do
   if name:find(k:lower(),1,true) then return true end
  end
  return false
 end
 local function classifyNPC(model)
  if isHostileNPC(model) then return "hostile" end
  if isFriendlyNPC(model) then return "friendly" end
  -- 默认根据是否有武器判断
  if model:FindFirstChildOfClass("Tool") then return "hostile" end
  return "friendly"
 end
 local function addNPCHighlight(model,kind)
  if not model or not model:IsA("Model") then return end
  if NPC_ESP.D[model] then return end
  local hl=Instance.new("Highlight")
  hl.Parent=model
  hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
  hl.FillTransparency=0.6
  hl.OutlineTransparency=0.3
  hl.OutlineColor=Color3.fromRGB(255,255,255)
  if kind=="hostile" then
   hl.FillColor=Color3.fromRGB(255,40,40)
   hl.OutlineColor=Color3.fromRGB(255,100,100)
  else
   hl.FillColor=Color3.fromRGB(40,255,80)
   hl.OutlineColor=Color3.fromRGB(100,255,130)
  end
  hl.Enabled=false
  NPC_ESP.D[model]={HL=hl,Kind=kind}
  -- 监听移除
  model.AncestryChanged:Connect(function()
   if not model.Parent then
    if NPC_ESP.D[model] then NPC_ESP.D[model]=nil end
   end
  end)
 end
 local function updateNPC_ESP()
  if not NPC_ESP.E then return end
  -- 扫描工作区内的NPC（有Humanoid的模型）
  for _,desc in ipairs(workspace:GetDescendants()) do
   if desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") then
    local model=desc.Parent
    -- 排除玩家
    local isPlayer=false
    for _,p in ipairs(Plrs:GetPlayers()) do
     if p.Character==model then isPlayer=true break end
    end
    if not isPlayer and not NPC_ESP.D[model] then
     local kind=classifyNPC(model)
     addNPCHighlight(model,kind)
    end
   end
  end
  -- 更新显示状态
  for model,data in pairs(NPC_ESP.D) do
   if not model or not model.Parent then
    NPC_ESP.D[model]=nil
   else
    local hum=model:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health>0 then
     if data.Kind=="hostile" then
      data.HL.Enabled=NPC_ESP.E_Hostile
     else
      data.HL.Enabled=NPC_ESP.E_Friendly
     end
    else
     data.HL.Enabled=false
    end
   end
  end
 end
 local NES=ET:AddSection("👹  NPC透视")
 NES:AddButton("●  开启NPC透视",function()
  if NPC_ESP.E then print("[NPC透视] 已经开启了") return end
  NPC_ESP.E=true NPC_ESP.E_Hostile=true NPC_ESP.E_Friendly=true
  NPC_ESP.C=RS.Heartbeat:Connect(updateNPC_ESP)
  -- 初始扫描
  task.spawn(updateNPC_ESP)
  print("[NPC透视] 已开启 (敌方红/友善绿)")
 end)
 NES:AddButton("○  关闭NPC透视",function()
  NPC_ESP.E=false NPC_ESP.E_Hostile=false NPC_ESP.E_Friendly=false
  if NPC_ESP.C then NPC_ESP.C:Disconnect() NPC_ESP.C=nil end
  for model,data in pairs(NPC_ESP.D) do
   if data.HL then pcall(function() data.HL:Destroy() end) end
  end
  NPC_ESP.D={}
  print("[NPC透视] 已关闭")
 end)
 NES:AddButton("🔴  敌方(红色): 开",function()
  NPC_ESP.E_Hostile=not NPC_ESP.E_Hostile
  print("[NPC透视] 敌方显示: "..(NPC_ESP.E_Hostile and "开" or "关"))
 end)
 NES:AddButton("🟢  友善(绿色): 开",function()
  NPC_ESP.E_Friendly=not NPC_ESP.E_Friendly
  print("[NPC透视] 友善显示: "..(NPC_ESP.E_Friendly and "开" or "关"))
 end)
 NES:AddButton("🔍  重新扫描NPC",function()
  task.spawn(updateNPC_ESP)
  print("[NPC透视] 正在重新扫描...")
 end)
 local FT=W:AddTab("甩飞炸服","💥")
 local ExS=FT:AddSection("炸服")
 ExS:AddButton("💣  启动炸服",function()
  print("[炸服] 正在启动...")
  pcall(function()
   if LP.Character and LP.Character:FindFirstChild("Humanoid") then
    local isR6=LP.Character.Humanoid.RigType==Enum.HumanoidRigType.R6
    task.spawn(function()
     local Anim=Instance.new("Animation")
     Anim.AnimationId=isR6 and "rbxassetid://27432686" or "rbxassetid://507776043"
     local bruh=LP.Character.Humanoid:LoadAnimation(Anim)
     bruh:Play() bruh:AdjustSpeed(0)
     LP.Character.Animate.Disabled=true
     local hi=Instance.new("Sound") hi.Name="Sound" hi.SoundId="rbxassetid://8114290584"
     hi.Volume=2 hi.Looped=false hi.Archivable=false hi.Parent=workspace hi:Play()
     task.wait(1.5)
     local Spin=Instance.new("BodyAngularVelocity") Spin.Name="Spinning"
     Spin.Parent=LP.Character.HumanoidRootPart
     Spin.MaxTorque=Vector3.new(0,math.huge,0) Spin.AngularVelocity=Vector3.new(0,40,0)
     task.wait(3.5)
     while LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health>0 do
      task.wait(0.1)
      if LP.Character and LP.Character:FindFirstChild("Humanoid") then
       LP.Character.Humanoid.HipHeight=LP.Character.Humanoid.HipHeight+1
      end
     end
    end)
   end
  end)
  print("[炸服] 已启动！")
 end)
 local SlS=FT:AddSection("甩飞 (优化版)")
 SlS:AddButton("👋  脉冲甩飞",function()
  pcall(function()
   local mc=LP.Character if not mc then return end
   local mh=mc:FindFirstChild("HumanoidRootPart") if not mh then return end
   local count=0
   local conn
   conn=RS.Stepped:Connect(function()
    count=count+1
    if count>10 then conn:Disconnect() return end
    for _,p in ipairs(Plrs:GetPlayers()) do
     if p~=LP and p.Character then
      local hrp=p.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
       local dir=(hrp.Position-mh.Position).Unit
       hrp.Velocity=dir*150+Vector3.new(0,80+count*5,0)
      end
     end
    end
   end)
  end)
  print("[甩飞] 脉冲甩飞执行！(10次连续推力)")
 end)
 SlS:AddButton("🌪  龙卷风甩飞",function()
  pcall(function()
   local mc=LP.Character if not mc then return end
   local mh=mc:FindFirstChild("HumanoidRootPart") if not mh then return end
   local t=0
   local conn
   conn=RS.Stepped:Connect(function()
    t=t+0.15
    if t>3 then conn:Disconnect() return end
    for _,p in ipairs(Plrs:GetPlayers()) do
     if p~=LP and p.Character then
      local hrp=p.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
       local dx=hrp.Position.X-mh.Position.X
       local dz=hrp.Position.Z-mh.Position.Z
       local angle=math.atan2(dz,dx)+t
       local dist=math.sqrt(dx*dx+dz*dz)
       local newX=mh.Position.X+math.cos(angle)*dist
       local newZ=mh.Position.Z+math.sin(angle)*dist
       hrp.Velocity=Vector3.new((newX-hrp.Position.X)*5,60,(newZ-hrp.Position.Z)*5)
      end
     end
    end
   end)
  end)
  print("[甩飞] 龙卷风甩飞执行！(3秒旋转)")
 end)
 SlS:AddButton("🚀  宇宙弹射",function()
  pcall(function()
   for _,p in ipairs(Plrs:GetPlayers()) do
    if p~=LP and p.Character then
     local hrp=p.Character:FindFirstChild("HumanoidRootPart")
     local hum=p.Character:FindFirstChild("Humanoid")
     if hrp and hum and hum.Health>0 then
      -- 先拉到高空再垂直射出去
      hrp.Position=hrp.Position+Vector3.new(0,50,0)
      task.wait(0.1)
      hrp.Velocity=Vector3.new(0,200,0)
      -- 多次助推
      task.delay(0.3,function() if hrp and hrp.Parent then hrp.Velocity=Vector3.new(0,250,0) end end)
      task.delay(0.6,function() if hrp and hrp.Parent then hrp.Velocity=Vector3.new(0,300,0) end end)
     end
    end
   end
  end)
  print("[甩飞] 宇宙弹射执行！(超高弹射)")
 end)
 SlS:AddButton("💥  全服爆炸",function()
  pcall(function()
   local mc=LP.Character if not mc then return end
   local mh=mc:FindFirstChild("HumanoidRootPart") if not mh then return end
   for _,p in ipairs(Plrs:GetPlayers()) do
    if p~=LP and p.Character then
     local hrp=p.Character:FindFirstChild("HumanoidRootPart")
     if hrp then
      local dist=(hrp.Position-mh.Position).Magnitude
      if dist<50 then
       local dir=(hrp.Position-mh.Position).Unit
       -- 爆炸式：距离越近威力越大
       local power=math.max(200,500-dist*8)
       hrp.Velocity=dir*power+Vector3.new(0,power*0.6,0)
      end
     end
    end
   end
  end)
  print("[甩飞] 全服爆炸执行！(距离越近威力越大)")
 end)
 SlS:AddButton("🌀  原地升天",function()
  pcall(function()
   for _,p in ipairs(Plrs:GetPlayers()) do
    if p~=LP and p.Character then
     local hrp=p.Character:FindFirstChild("HumanoidRootPart")
     if hrp then
      -- 用BodyVelocity稳定向上推
      local bv=Instance.new("BodyVelocity")
      bv.Velocity=Vector3.new(0,150,0)
      bv.MaxForce=Vector3.new(0,math.huge,0)
      bv.P=10000
      bv.Parent=hrp
      game:GetService("Debris"):AddItem(bv,2)
     end
    end
   end
  end)
  print("[甩飞] 原地升天执行！(2秒持续推力)")
 end)
 local OT=W:AddTab("脚本","📦")
 local CS=OT:AddSection("通用脚本")
 CS:AddButton("🌐  翻译脚本",function() runLSA("翻译脚本","https://raw.githubusercontent.com/dream6-e/rbx/refs/heads/main/%E7%BF%BB%E8%AF%91%E8%84%9A%E6%9C%AC.lua") end)
 CS:AddButton("🚂  火车头",function() runLS("火车头","https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua") end)
 CS:AddButton("🦸  无敌少侠飞行",function() runLS("无敌少侠飞行","https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414") end)
 local BS=OT:AddSection("黑脚本")
 BS:AddButton("⚫  运行黑脚本",function() runLS("黑脚本","https://raw.githubusercontent.com/hgvuyguyg/HEIJIAOBEN/main/aaa") end)
 local DBS=OT:AddSection("DB脚本")
 DBS:AddButton("🔵  运行 DB 脚本",function() runLS("DB脚本","https://raw.githubusercontent.com/dish-rr/DB-scriptnb/main/DB-script101.lua") end)
 local CeS=OT:AddSection("脚本中心")
 CeS:AddButton("🏠  运行脚本中心",function()
  print("[脚本中心] 正在加载...")
  local ok,err=pcall(function()
   loadstring(utf8.char(table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})))()
  end)
  if ok then print("[脚本中心] 加载成功！") else warn("[脚本中心] 失败:",err) end
 end)
 local DYS=OT:AddSection("地岩脚本")
 DYS:AddButton("🪨  运行地岩脚本",function()
  print("[地岩脚本] 正在加载...")
  local ok,err=pcall(function() loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,98,98,97,109,120,98,98,97,109,120,98,98,97,109,120,47,99,111,100,101,115,112,97,99,101,115,45,98,108,97,110,107,47,109,97,105,110,47,37,69,55,37,57,57,37,66,68,34,41,41,40,41")() end)
  if ok then print("[地岩脚本] 加载成功！") else warn("[地岩脚本] 失败:",err) end
 end)
 local GS=OT:AddSection("绿脚本")
 GS:AddButton("🟢  运行绿脚本",function() runLS("绿脚本","https://pastebin.com/raw/Esw6YQKR") end)
 local GaS=OT:AddSection("甘脚本")
 GaS:AddButton("💚  运行甘脚本",function() runLST("甘脚本","https://raw.githubusercontent.com/CN1919810/de2/main/77_0M1VK6VF%20(1).lua") end)
 local QS=OT:AddSection("空情脚本")
 QS:AddButton("💙  运行空情脚本",function() runLS("空情脚本","https://ayangwp.cn/api/v3/file/get/8628/%E9%9D%99?sign=uxlt7ravTFmP3TZLNgN7zImLHxJWhH93SEbKgFA_PRc%3D%3A0") end)
 local XAS=OT:AddSection("XA 枢纽")
 XAS:AddButton("🌀  运行 XA 枢纽",function() runLS("XA枢纽","https://raw.gitcode.com/Xingtaiduan/Scripts/raw/main/Loader.lua") end)
    local ZMScripts = {}

    ZMScripts['XK脚本'] = [=[
--群聊:915207093--云端更新，请复制下面链接
loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\66\73\78\106\105\97\111\98\122\120\54\47\66\73\78\106\105\97\111\47\109\97\105\110\47\88\75\46\84\88\84\34\41\41\40\41\10")()
]=]

    ZMScripts['云脚本最新'] = [=[
_G.CloudScript = "云脚本主群号526684389"
loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/LOL/main/%E4%BA%91%E8%84%9A%E6%9C%ACCloud%20script.lua", true))()
]=]

    ZMScripts['剑客脚本'] = [=[
loadstring(game:HttpGet("https://raw.githubusercontent.com/lyyanai/Crack/main/JiankeCrack"))()
]=]

    ZMScripts['小魔脚本'] = [=[
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaomoNB666/xiaomoNB666/main/%E6%9E%81.lua"))()
]=]

    ZMScripts['小黑子脚本'] = [=[
--#region Setup
if getgenv then
    if getgenv().DGEM_LOADED==true then
        repeat task.wait() until true==false
    end
    getgenv().DGEM_LOADED=true
end
local entities={
    AllEntities={"全部","Ambush","Eyes","Glitch","Grundge","Halt","Hide","没有","随机","Rush","Screech","Seek","Shadow","Smiler","Timothy","Trashbag","Trollface"},
    DeveloperEntities={"Trollface", "没有"},
    CustomEntities={"Grundge","Smiler","Trashbag", "None"},
    RegularEntities={"全部", "Ambush", "Eyes", "Glitch", "Halt", "Hide", "随机","没有","Rush","Screech","Seek","Shadow","Timothy"}
}
for _, tb in pairs(entities) do table.sort(tb) end

--#endregion

--#region Window
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
	Name = "小黑子 | 使用的执行器："..(identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"),
	加载中Title = "正在加载",
	加载中Subtitle = "作者夜（黑子)【源码Sponguss+Zepssy】",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "L.N.K v1" -- ZEPSYY I TOLD YOU ITS NOT GONNA BE NAMED LINK  
    },
    false,
    KeySettings = {
        Title = "DX的密钥系统",
        Subtitle = "密钥系统",
        Note = "QQ群(731361929)",
        Key = "DXuwu.lol"
    }
})
	
--#endregion
--#region Connections & Variables

workspace.ChildAdded:Connect(function(c)
    if c:FindFirstChild("RushNew") and not c.Parent:GetAttribute("IsCustomEntity") and (c.Parent.Name=="RushMoving" or c.Parent.Name=="AmbushMoving")  then
        Rayfield:Notify({
            Title = "真正的【伺服器】 "..c.Parent.Name=="RushMoving" and "Rush" or "Ambush".." 已生成...",
            Content = "Notification Content",
            Duration = 6.5,

            Image = 4483362458,
            Actions = {
                Ignore = {
                    Name = "好的!",
                    Callback = function() end
                },
                Hide = {
                    Name="Hide!",
                    Callback=function() 
                        for _, wardrobe in pairs(workspace.CurrentRooms:GetDescendants()) do
                            if wardrobe.Name=="Wardrobe" and wardrobe.HiddenPlayer.Value==nil then
                                game.Players.LocalPlayer.Character:PivotTo(wardrobe.Main.CFrame)
                                task.wait(.1)
                                if wardrobe.HiddenPlayer.Value~=nil then continue end
                                fireproximityprompt(wardrobe.HidePrompt)
                                return
                            end
                        end
                    end
                }
            },
        })
    end
end)

--//MAIN VARIABLES\\--
local Debris = game:GetService("Debris")


local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")

local allLimbs = {}

for i,v in pairs(Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(allLimbs, v)
    end
end

--//MAIN USABLE FUNCTIONS\\--

function removeDebris(obj, Duration)
    Debris:AddItem(obj, Duration)
end

-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
}
local Connections = {}

-- Functions

local function playSound(soundId, source, properties)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://".. soundId
    sound.PlayOnRemove = true
    
    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" and i ~= "PlayOnRemove" then
            sound[i] = v
        end
    end

    sound.Parent = source
    sound:Destroy()
end

local function drag(model, dest, speed)
    local reached = false

    Connections.Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local seekPos = model.PrimaryPart.Position
            local newDest = Vector3.new(dest.X, seekPos.Y, dest.Z)
            local diff = newDest - seekPos
    
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.lookAt(seekPos + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05), newDest))
            else
                Connections.Drag:Disconnect()
                reached = true
            end
        else
            Connections.Drag:Disconnect()
        end
    end)

    repeat task.wait() until reached
end

local function jumpscareSeek()
    Hum.Health = 0
    workspace.Ambience_Seek:Stop()

    local func = getconnections(ReSt.Bricks.Jumpscare.OnClientEvent)[1].Function
    debug.setupvalue(func, 1, false)
    func("Seek")
end

local function connectSeek(room)
    local seekMoving = workspace.SeekMoving
    local seekRig = seekMoving.SeekRig

    -- Intro
    
    seekMoving:SetPrimaryPartCFrame(room.RoomStart.CFrame * CFrame.new(0, 0, -15))
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRaise):Play()

    task.spawn(function()
        task.wait(7)
        workspace.Footsteps_Seek:Play()
    end)

    workspace.Ambience_Seek:Play()
    ModuleScripts.SeekIntro(ModuleScripts.MainGame)
    seekRig.AnimationController:LoadAnimation(seekRig.AnimRun):Play()
    Char:SetPrimaryPartCFrame(room.RoomEnd.CFrame * CFrame.new(0, 0, 20))
    ModuleScripts.MainGame.chase = true
    Hum.WalkSpeed = 22
    
    -- Movement

    task.spawn(function()
        local nodes = {}

        for _, v in next, workspace.CurrentRooms:GetChildren() do
            for i2, v2 in next, v:GetAttributes() do
                if string.find(i2, "Seek") and v2 then
                    nodes[#nodes + 1] = v.RoomEnd
                end
            end
        end

        for _, v in next, nodes do
            if seekMoving.Parent and not seekMoving:GetAttribute("IsDead") then
                drag(seekMoving, v.Position, 15)
            end
        end
    end)

    -- Killing

    task.spawn(function()
        while seekMoving.Parent do
            if (Root.Position - seekMoving.PrimaryPart.Position).Magnitude <= 30 and Hum.Health > 0 and not seekMoving.GetAttribute(seekMoving, "IsDead") then
                Connections.Drag:Disconnect()
                workspace.Footsteps_Seek:Stop()
                ModuleScripts.MainGame.chase = false
                Hum.WalkSpeed = 15
                
                -- Crucifix / death

                if not Char.FindFirstChild(Char, "Crucifix") then
                    jumpscareSeek()
                else
                    seekMoving.Figure.Repent:Play()
                    seekMoving:SetAttribute("IsDead", true)
                    workspace.Ambience_Seek.TimePosition = 92.6

                    task.spawn(function()
                        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
                        task.wait(0.5)
                        ModuleScripts.MainGame.camShaker:ShakeOnce(5, 25, 4, 4)
                    end)

                    -- Crucifix float

                    local model = Instance.new("Model")
                    model.Name = "Crucifix"
                    local hl = Instance.new("Highlight")
                    local crucifix = Char.Crucifix
                    local fakeCross = crucifix.Handle:Clone()
        
                    fakeCross:FindFirstChild("EffectLight").Enabled = true
        
                    ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
        
                    model.Parent = workspace
                    -- hl.Parent = model
                    -- hl.FillTransparency = 1
                    -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
                    fakeCross.Anchored = true
                    fakeCross.Parent = model
        
                    crucifix:Destroy()
        
                    for i, v in pairs(fakeCross:GetChildren()) do
                        if v.Name == "E" and v:IsA("BasePart") then
                            v.Transparency = 0
                            v.CanCollide = false
                        end
                        if v:IsA("Motor6D") then
                            v.Name = "Motor6D"
                        end
                    end
        


                    -- Seek death

                    task.wait(4)
                    seekMoving.Figure.Scream:Play()
                    playSound(11464351694, workspace, { Volume = 3 })
                    game.TweenService:Create(seekMoving.PrimaryPart, TweenInfo.new(4), {CFrame = seekMoving.PrimaryPart.CFrame - Vector3.new(0, 10, 0)}):Play()
                    task.wait(4)

                    seekMoving:Destroy()
                    fakeCross.Anchored = false
                    fakeCross.CanCollide = true
                    task.wait(0.5)
                    model:Remove()
                end

                break
            end

            task.wait()
        end
    end)
end

-- Setup

local newIdx; newIdx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if k == "WalkSpeed" and not checkcaller() then
        if ModuleScripts.MainGame.chase then
            v = ModuleScripts.MainGame.crouching and 17 or 22
        else
            v = ModuleScripts.MainGame.crouching and 10 or 15
        end
    end
    
    return newIdx(t, k, v)
end))

-- Scripts
 
local roomConnection; roomConnection = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    local trigger = room:WaitForChild("TriggerEventCollision", 1)

    if trigger then
        roomConnection:Disconnect()

        local collision = trigger.Collision:Clone()
        collision.Parent = room
        trigger:Destroy()

        local touchedConnection; touchedConnection = collision.Touched:Connect(function(p)
            if p:IsDescendantOf(Char) then
                touchedConnection:Disconnect()

                connectSeek(room)
            end
        end)
    end
end)
--#endregion
--#region Tabs
local MainTab=Window:CreateTab("怪物生成", 4370345144)
local DoorsMods=Window:CreateTab("Doors游戏修改", 10722835155)
local ConfigEntities = Window:CreateTab("修改怪物", 8285095937)
local publicServers = Window:CreateTab("特殊伺服器", 9692125126)
local Tools=Window:CreateTab("物品", 29402763) 
local CharacterMods=Window:CreateTab("人物", 483040244)
local global=Window:CreateTab("公共", 1588352259)
local info= Window:CreateTab("资讯", 4483345998)
--#endregion
    
--region info
info:CreateParagraph({Title = "如何联系作者", Content = "快手号dxuwulol|QQ群731361929"})
info:CreateParagraph({Title = "更新", Content = "Seek十字架,万圣节十字架,MC房间,手电筒"})
info:CreateParagraph({Title = "11.12.2022", Content = "Rayfield UI!!!"})
info:CreateParagraph({Title = "Bugs", Content = "1. 骷髅钥匙无效 "})
info:CreateParagraph({Title = "Notes", Content = "哈哈哈"})

--end region

--#region Special Servers
publicServers:CreateSection("伺服器识别器")
publicServers:CreateLabel("目前的伺服器识别码: "..game.JobId)
publicServers:CreateButton({
    Name="复制目前伺服器识别码",
    Callback=function()
        (syn and syn.write_clipboard or setclipboard)(game.JobId)
    end
})
publicServers:CreateSection("特色")
publicServers:CreateButton({
    Name="进入无人特殊伺服器",
    Callback=function()
        game.Players.LocalPlayer:Kick("\nJoining Special Server... Please Wait")
		wait()
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
publicServers:CreateButton({
    Name="免费复活",
    Callback=function()
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})
publicServers:CreateLabel("注意: 你必须在一个特殊伺服器里面才有效")
publicServers:CreateSection("转换伺服器")
publicServers:CreateButton({
    Name="进入一个随机的特殊伺服器",
	Callback = function()
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tb.data[math.random(1,#tb.data)].id, game.Players.LocalPlayer)
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
    end,
})
publicServers:CreateInput({
    Name="进入指定玩家的伺服器",
    PlaceholderText = game.Players.LocalPlayer.Name,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local tb=game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))))
        for _, server in pairs(tb.data) do
            for _, player in pairs(server.players) do
                if player.name==Text or player.UserId==Text then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                    queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
                end
            end
        end
    end,
})
publicServers:CreateInput({
    Name="进入特殊伺服器",
    PlaceholderText = "请填写伺服器识别码",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Text, game.Players.LocalPlayer)
        queue_on_teleport("loadstring(game:HttpGet\"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/source.lua\")()")
    end,
})
--#endregion
--#region Entity Configuration
local EntitiesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

_G.ScreechConfig = false
_G.TimothyConfig = false
_G.HaltConfig = false
_G.GlitchConfig = false

_G.HaltModel = 0
_G.TimothyModel = 0
_G.ScreechModel = 0
_G.GlitchModel = 0

local function connectEntity(entitytype, id, entityname)
    if entitytype == "3d" then
        game:GetService("Debris"):AddItem(game:GetService("ReplicatedStorage"):WaitForChild("Entities"):FindFirstChild(entityname), 0)

        local customentity = game:GetObjects("rbxassetid://"..id)[1]
        customentity.Name = entityname
        customentity.Parent = game:GetService("ReplicatedStorage"):FindFirstChild("Entities")

        local isCustom = Instance.new("StringValue")
        isCustom.Name = "isCustom"
        isCustom.Parent = customentity

        
    elseif entitytype == string.lower("2d") then
        error("怪物不可被修改因为它是2D.")
    end
end

ConfigEntities:CreateSection("3D 怪物")

ConfigEntities:CreateParagraph({Title="注意", Content="此设定只能由开发人员使用，除非你有DOORS的怪物源模型."})

ConfigEntities:CreateToggle({
    Name = "Screech 修订",
	CurrentValue = false,
	Flag = "AddScreechConfig",
	Callback = function(Value)
        _G.ScreechConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.ScreechModel, "Screech")
            else
                connectEntity("3d", "11599277464", "Screech")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Screech 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.ScreechModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Glitch 修订",
	CurrentValue = false,
	Flag = "AddGlitchConfig",
	Callback = function(Value)
        _G.GlitchConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.GlitchModel, "Glitch")
            else
                connectEntity("3d", "11689725604", "Glitch")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Glitch Model",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.GlitchModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Timothy 修订",
	CurrentValue = false,
	Flag = "AddTimothyConfig",
	Callback = function(Value)
        _G.TimothyConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.TimothyModel, "Spider")
            else
                connectEntity("3d", "11689711982", "Spider")
            end
        end)
	end,
})


ConfigEntities:CreateInput({
	Name = "设置 Timothy 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.TimothyModel = Text
	end,
})

ConfigEntities:CreateToggle({
    Name = "Halt 修订",
	CurrentValue = false,
	Flag = "AddHaltConfig",
	Callback = function(Value)
        _G.HaltConfig = Value
        game:GetService("RunService").RenderStepped:Connect(function()
            if Value then
                connectEntity("3d", _G.HaltModel, "Shade")
            else
                connectEntity("3d", "11689715035", "Shade")
            end
        end)
	end,
})

ConfigEntities:CreateInput({
	Name = "设置 Halt 模型",
	PlaceholderText = "ex: 123456789",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        _G.HaltModel = Text
	end,
})

ConfigEntities:CreateSection("2D 怪物")
--#endregion
--#region Doors Modifications
--#region UI Mods
DoorsMods:CreateSection("游戏UI修改")

DoorsMods:CreateInput({
	Name = "设置金币数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Knobs.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Knobs:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置复活数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Revives.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Revives:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置加成数量",
	PlaceholderText = game.Players.LocalPlayer.PlayerGui.PermUI.Topbar.Boosts.Text,
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        require(game.ReplicatedStorage.ReplicaDataModule).event.Boosts:Fire(tonumber(Text))
	end,
})

DoorsMods:CreateInput({
	Name = "设置底下文字",
	PlaceholderText = "就是你的打火机没燃料了什么什么那里...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, Text)
	end,
})


DoorsMods:CreateButton({
	Name = "心跳小游戏",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.ClutchHeartbeat.OnClientEvent)
	end,
})

DoorsMods:CreateButton({
	Name = "全成就",
	Callback = function()
        for i,v in pairs(require(game.ReplicatedStorage.Achievements)) do
            spawn(function()
                require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock)(nil, i)
            end)
        end
	end,
})
--#endregion
--#region Modify Rooms
DoorsMods:CreateSection("房间修订")

DoorsMods:CreateColorPicker({
    Name="设置房间颜色",
    Color=Color3.fromRGB(89,69,72),
    Flag="RoomColor",
    Callback=function(color)
        local room=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]

        if color==Color3.fromRGB(89,69,72) then
            room.LightBase.SurfaceLight.Enabled=true
            room.LightBase.SurfaceLight.Color=Color3.fromRGB(89,69,72)
            for _, thing in pairs(room.Assets:GetDescendants()) do
                if thing:FindFirstChild"LightFixture" then
                    thing.LightFixture.Neon.Color=Color3.fromRGB(195, 161, 141)
                    for _, light in pairs(thing.LightFixture:GetChildren()) do
                        if light:IsA("SpotLight") or light:IsA("PointLight") then
                            light.Color=Color3.fromRGB(235, 167, 98)
                        end
                    end
                end
            end
            return
        end

        room.LightBase.SurfaceLight.Enabled=true
        room.LightBase.SurfaceLight.Color=color
        for _, thing in pairs(room.Assets:GetDescendants()) do
            if thing:FindFirstChild"LightFixture" then
                thing.LightFixture.Neon.Color=color
                for _, light in pairs(thing.LightFixture:GetChildren()) do
                    if light:IsA("SpotLight") or light:IsA("PointLight") then
                        light.Color=color
                    end
                end
            end
        end
    end
})

DoorsMods:CreateParagraph({Title="注意", Content="如果你想重置房间颜色, 填写 89,69,72"})

DoorsMods:CreateButton({
	Name = "生成红房",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "tryp", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 9e307)
        -- Imagine someone actually waits 90000000000000000... seconds for the red room to run out, would be crazy 
	end,
})

DoorsMods:CreateButton({
	Name = "破坏灯",
	Callback = function()
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "breakLights", workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 0.416, 60) 
	end,
})

DoorsMods:CreateInput({
	Name = "灯闪烁",
	PlaceholderText = "事件【秒】...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "flickerLights", game.Players.LocalPlayer:GetAttribute("CurrentRoom"), tonumber(Text)) 
	end,
})

DoorsMods:CreateInput({
	Name = "设置门的文字",
	PlaceholderText = "你干嘛嘿嘿哟",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local r=workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")]
        r.Door.Sign.Stinker.Text=Text
        r.Door.Sign.Stinker.Highlight.Text=Text
        r.Door.Sign.Stinker.Shadow.Text=Text
	end,    
})
--#endregion
--#region Modify Entities
DoorsMods:CreateSection("怪物修订")

local EnabledEntities={
    EnabledScreech=false,
    EnabledHalt=false,
    EnabledGlitch=false,
}

DoorsMods:CreateToggle({
    Name = "无视 Screech",
	CurrentValue = false,
	Flag = "IgnoreScreech",
	Callback = function(Value)
        EnabledEntities.EnabledScreech = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "无视 Glitch",
	CurrentValue = false,
	Flag = "IgnoreGlitch",
	Callback = function(Value)
        EnabledEntities.EnabledGlitch = Value
	end,
})

DoorsMods:CreateToggle({
    Name = "无视 Halt",
	CurrentValue = false,
	Flag = "IgnoreHalt",
	Callback = function(Value)
        EnabledEntities.EnabledHalt = Value
	end,
})

workspace.Camera.ChildAdded:Connect(function(c)
    if c.Name == "Screech" then
        wait(0.1)
        if EnabledEntities.EnabledScreech then
            removeDebris(c, 0)
        end
    end

    if c.Name == "Shade" then
        wait(.1)
        if EnabledEntities.EnabledHalt then
            removeDebris(c, 0)
        end
    end
end)

workspace.CurrentRooms.ChildAdded:Connect(function()
    if EnabledEntities.EnabledGlitch then
        local currentRoom=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
        local roomAmt=#workspace.CurrentRooms:GetChildren()
        local lastRoom=game.ReplicatedStorage.GameData.LatestRoom.Value
    
        if roomAmt>=4 and currentRoom<lastRoom-3 then
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(lastRoom.RoomStart.Position))
        end    
    end
end)
--#endregion
--#region Global Doors Mods

DoorsMods:CreateSection("公共doors修订")

local thanksgivingEnabled=false
DoorsMods:CreateToggle({
	Name = "感恩节模式",
	Callback = function()
        if thanksgivingEnabled then
            return Rayfield:Notify({
                Title = "Error",
                Content = "You have already ran this",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
        thanksgivingEnabled=true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSthanksgiving"))()
	end,
})

DoorsMods:CreateButton({
    Name = "MC房间",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/y2WmccLk"))()
    end,
})


--#endregion
--#endregion
--#region Character Mods
local con
local con2
local isJumping=false
CharacterMods:CreateInput({
    Name="设置 Guiding Light",
    PlaceholderText = "文字 1~文字 2",
	RemoveTextAfterFocusLost = true,
    Callback=function(Text)
        game.Players.LocalPlayer.Character.Humanoid.Health=0
        debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, Text:split"~")
    end
})
CharacterMods:CreateLabel("这会让你立即死亡")

CharacterMods:CreateButton({
    Name="立即死亡",
    Callback=function()
        game.Players.LocalPlayer.Character.Humanoid.Health=0
    end
})
CharacterMods:CreateButton({
    Name="复活",
    Callback=function()
        game.ReplicatedStorage.Bricks.Revive:FireServer()
    end
})
CharacterMods:CreateParagraph({Title = "注意", Content = "你需要至少一个复活,这样就可以跳过 \"你只可以复活一次\" 的信息, 或其他东东？？？"})

CharacterMods:CreateToggle({
    Name="哈哈开启跳跃",
    CurrentValue=false,
    Flag="enableJump",
    Callback=function(val)
        if val==true then
            con=game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=true
                    repeat 
                        task.wait()
                        if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):GetState()==Enum.HumanoidStateType.Freefall then else
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(3) end
                    until isJumping==false
                end
            end)

            con2=game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode==Enum.KeyCode.Space then
                    isJumping=false
                end
            end)
        else con:Disconnect() con2:Disconnect() end
    end
})

local Speed = 15

local EVC=CharacterMods:CreateToggle({
    Name="开启速度挂",
    CurrentValue=false,
    Callback=function() end
})

CharacterMods:CreateSlider({
    Name="速度",
    Range={15,100},
    Increment=5,
    Suffix="studs/每秒",
    CurrentValue=15,
    Flag="speed",
    Callback=function(val)
        for _, child in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if child.ClassName == "Part" then
                child.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
            end
        end
        Speed = tonumber(val)
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if EVC.CurrentValue==true then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end
end)
--#endregion
--#region Tools
--#region Vitamins
_G.VitaminsDurability = 0

Tools:CreateButton({
    Name="拿维他命",
    Callback = function()
        local Vitamins = game:GetObjects("rbxassetid://11685698403")[1]
        local idle = Vitamins.Animations:FindFirstChild("idle")
        local open = Vitamins.Animations:FindFirstChild("open")

        local tweenService = game:GetService("TweenService")

        local sound_open = Vitamins.Handle:FindFirstChild("sound_open")

        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacteAdded:Wait()
        local hum = char:WaitForChild("Humanoid")

        local idleTrack = hum.Animator:LoadAnimation(idle)
        local openTrack = hum.Animator:LoadAnimation(open)

        local Durability = 35
        local InTrans = false
        local Duration = 10

        local xUsed = tonumber(_G.VitaminsDurability)

        local v1 = {};



        function v1.AddDurability()
            InTrans = true
            hum:SetAttribute("SpeedBoost", 15)
            wait(Duration)
            InTrans = false
            hum:SetAttribute("SpeedBoost", 0)
        end




        function v1.SetupVitamins()
            Vitamins.Parent = game.Players.LocalPlayer.Backpack
            Vitamins.Name = "假的维他命哈哈哈"

            for slotNum, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool.Name == "假的维他命哈哈哈" then
                    local slot =game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").MainFrame.Hotbar:FindFirstChild(slotNum)
                    -- while task.wait() do
                    --     slot.DurabilityNumber.Text = "x"..xUsed
                    -- end
                    -- slot.DurabilityNumber.Text = "x"..xUsed
                    slot.DurabilityNumber.Visible = true
                    slot.DurabilityNumber.Text = "x"..xUsed

                    Vitamins.Unequipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                        slot.DurabilityNumber.Text = "x"..xUsed
                    end)

                    Vitamins.Equipped:Connect(function()
                        slot.DurabilityNumber.Visible = true
                    end)

                    Vitamins.Activated:Connect(function()
                        if not InTrans and xUsed > 0 then
                            xUsed = xUsed - 1
                            slot.DurabilityNumber.Visible = true
                            slot.DurabilityNumber.Text = "x"..xUsed
                            openTrack:Play()
                            sound_open:Play()
                    
                            tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {FieldOfView = 100}):Play()
                            v1.AddDurability()
                        end
                    end)
                end
            end




            Vitamins.Equipped:Connect(function()
                idleTrack:Play()
            end)


            Vitamins.Unequipped:Connect(function()
                idleTrack:Stop()

            end)
        end

        v1.SetupVitamins()

        function v1.AddLoop()
            while task.wait() do
                if InTrans then
                    wait()
                    hum.WalkSpeed = Durability
                else
                    hum.WalkSpeed = 16
                end
            end
        end

        while task.wait() do
            v1.AddLoop()
        end

        return v1


    end
})

Tools:CreateInput({
	Name = "维他命数量/耐久",
	PlaceholderText = "ex: 100",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        local durability = tonumber(Text)



        if durability then
            _G.VitaminsDurability = Text
        elseif not durability or durability == '0' then
            Rayfield:Notify({
                Title = "错误",
                Content = "请输入一个有效的数字.",
                Duration = 5,
                Image = 4483362458,
                Actions = {},
            })
        end
	end,    
})
 
Tools:CreateParagraph({Title = "注意", Content = "这些都是假的维他命但是也是有效果的. 其他人是开不见得. 请不要填写分数或小数，这会导致脚本被破坏或无效 ."})
--#endregion

--#region Dropdown
local toolList={"Skeleton Key", "Crucifix","Seek Crucifix","Halloween Crucifix", "Christmas Guns", "Candle", "Gummy Flashlight","Flashlight", "Gun"}
table.sort(toolList)
local toolFuncs={["Skeleton Key"]=function()
    if not isfile("skellyKey.rbxm") then
        writefile("skellyKey.rbxm", game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKey.rbxm")
    end
    local keyTool: Tool=game:GetObjects((getcustomasset or getsynasset)("skellyKey.rbxm"))[1]
    keyTool:SetAttribute("uses", 5)

    local function setupRoom(room)
        local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/skellyKeyRoomRep.lua")()
        local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true, Locked=true})
        newdoor.Model.Parent=workspace
        newdoor.Model:PivotTo(room.Door.Door.CFrame)
        newdoor.Model.Parent=room
        room.Door:Destroy()
        thing.ReplicateDoor({Model=newdoor.Model, Config={CustomKeyNames={"SkellyKey"}}, Debug={OnDoorPreOpened=function() end}})
    end
    keyTool.Equipped:Connect(function()
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            if room.Door:FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                room:SetAttribute("Replaced", true)
                setupRoom(room)
            end
        end
        con=workspace.CurrentRooms.ChildAdded:Connect(function(room)
            if room.Door:FindFirstChild"Lock" and not room:GetAttribute("Replaced") then
                room:SetAttribute("Replaced", true)
                setupRoom(room)
            end
        end)
    end)
    keyTool.Unequipped:Connect(function() con:Disconnect() end)

    if Plr.PlayerGui.MainUI.ItemShop.Visible then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))().CreateItem(keyTool, {
            Title = "骷髅钥匙",
            Desc = "傻逼现在没用了",
            Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
            Price = "点赞加关注",
            Stack = 1,
        })
    else keyTool.Parent=game.Players.LocalPlayer.Backpack end
end, ["Crucifix"]=function() 
    local function IsVisible(part)
        local vec, found=workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        local onscreen = found and vec.Z > 0
        local cfg = RaycastParams.new()
        cfg.FilterType = Enum.RaycastFilterType.Blacklist
        cfg.FilterDescendantsInstances = {part}
    
        local cast = workspace:Raycast(part.Position, (game.Players.LocalPlayer.Character.UpperTorso.Position - part.Position), cfg)
        if onscreen then
            if cast and (cast and cast.Instance).Parent==game.Players.LocalPlayer.Character then
                return true
            end
        end
    end
    
    local Equipped = false
    
    -- Edit this --
    getgenv().spawnKey = Enum.KeyCode.F4
    ---------------
    
    -- Services
    
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    
    -- Variables
    
    local Plr = Players.LocalPlayer
    local Char = Plr.Character or Plr.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    local RightArm = Char:WaitForChild("RightUpperArm")
    local LeftArm = Char:WaitForChild("LeftUpperArm")
    
    local RightC1 = RightArm.RightShoulder.C1
    local LeftC1 = LeftArm.LeftShoulder.C1
    
    local SelfModules = {
        Functions = loadstring(
            game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua")
        )(),
        CustomShop = loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"
            )
        )(),
    }
    
    local ModuleScripts = {
        MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
        SeekIntro = require(Plr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes.SeekIntro),
    }
    
    -- Functions

    local function setupCrucifix(tool)
        tool.Equipped:Connect(function()
            Equipped = true
            Char:SetAttribute("Hiding", true)
            for _, v in next, Hum:GetPlayingAnimationTracks() do
                v:Stop()
            end
    
            RightArm.Name = "R_Arm"
            LeftArm.Name = "L_Arm"
    
            RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
            LeftArm.LeftShoulder.C1 = LeftC1
                * CFrame.new(-0.2, -0.3, -0.5)
                * CFrame.Angles(math.rad(-125), math.rad(25), math.rad(25))
        end)
    
        tool.Unequipped:Connect(function()
            Equipped = false
            Char:SetAttribute("Hiding", nil)
            RightArm.Name = "RightUpperArm"
            LeftArm.Name = "LeftUpperArm"
    
            RightArm.RightShoulder.C1 = RightC1
            LeftArm.LeftShoulder.C1 = LeftC1
        end)
    end
    
    -- Scripts
    
    local CrucifixTool = game:GetObjects("rbxassetid://11590476113")[1]
    CrucifixTool.Name = "Crucifix"
    CrucifixTool.Parent = game.Players.LocalPlayer.Backpack
    
    -- game.UserInputService.InputBegan:Connect(function(input, proc)
    --     if proc then return end
    
    --     if input.KeyCode == input.KeyCode[getgenv().spawnKey] then
    --         local CrucifixTool = game:GetObjects("rbxassetid://11590476113")[1]
    --         CrucifixTool.Name = "Crucifix"
    --         CrucifixTool.Parent = game.Players.LocalPlayer.Backpack
    --     end
    -- end)
    -- Input handler
    
    setupCrucifix(CrucifixTool)
    
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    
    -- Variables
    
    local Plr = Players.LocalPlayer
    local Char = Plr.Character or Plr.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    
    local dupeCrucifix = Instance.new("BindableEvent")
    local function func(ins)
        wait(.01) -- Wait for the attribute
        if ins:GetAttribute("IsCustomEntity")==true and ins:GetAttribute("ClonedByCrucifix")~=true then
            local Chains = game:GetObjects("rbxassetid://11584227521")[1]
            Chains.Parent = workspace
            local chained = true
            local posTime = false
            local rotTime = false
            local tweenTime = false
            local intFound = true
    
            game:GetService("RunService").RenderStepped:Connect(function()
                if Equipped then
                    if ins.Parent~=nil and ins.PrimaryPart and IsVisible(ins.PrimaryPart) and (Root.Position-ins.PrimaryPart.Position).magnitude <= 25 then
                        local c=ins:Clone()
                        c:SetAttribute("ClonedByCrucifix", true)
                        c.RushNew.Anchored=true
                        c.Parent=ins.Parent
                        ins:Destroy()
                        dupeCrucifix:Fire(6,c.RushNew)
    

                        
                        -- Chains.PrimaryPart.Orientation = Chains.PrimaryPart.Orientation + Vector3.new(0, 3, 0)
    
                        local EntityRoot = c:FindFirstChild("RushNew")
    
                        if EntityRoot then



                            local Fake_FaceAttach = Instance.new("Attachment")
                            Fake_FaceAttach.Parent = EntityRoot
                            

                            for i, beam in pairs(Chains:GetDescendants()) do
                                if beam:IsA("BasePart") then
                                    beam.CanCollide = false
                                end
                                if beam.Name == "Beam" then
                                    beam.Attachment1 = Fake_FaceAttach
                                end
                            end
                            
                            if not posTime then
                                Chains:SetPrimaryPartCFrame(
                                    EntityRoot.CFrame * CFrame.new(0, -3.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
                                )
                                posTime = true
                            end
    
                            task.wait(1.35)
                            if not tweenTime then
    
                                task.spawn(function()
                                    while task.wait() do
                                        if Chains:FindFirstChild('Base') then
                                            Chains.Base.CFrame = Chains.Base.CFrame * CFrame.Angles(0,0 , math.rad(0.5))
                                        end
                                    end
                                end)

                                task.spawn(function()
                                    while task.wait() do
                                        for i, beam in pairs(Chains:GetDescendants()) do
                                            if beam.Name == "Beam" then
                                                beam.TextureLength = beam.TextureLength+0.035
                                            end
                                        end
                                    end
                                end)
    
    
                                game.TweenService
                                    :Create(
                                        EntityRoot,
                                        TweenInfo.new(6),
                                        { CFrame = EntityRoot.CFrame * CFrame.new(0, 50, 0) }
                                    )
                                    :Play()
                                
    
                                tweenTime = true
                                task.wait(1.5)
                                intFound = false
                                game:GetService("Debris"):AddItem(c, 0)
                                game:GetService("Debris"):AddItem(Chains, 0)
                            end
                        end
                    end
                end
            end)
        elseif ins.Name=="Lookman" then
            local c=ins
            task.spawn(function()
                repeat task.wait() until IsVisible(c.Core) and Equipped and c.Core.Attachment.Eyes.Enabled==true
                local pos=c.Core.Position
                dupeCrucifix:Fire(18.364, c.Core)
                task.spawn(function()
                    c:SetAttribute("Killing", true)
                    ModuleScripts.MainGame.camShaker:ShakeOnce(10, 10, 5, 0.15)
                    wait(5)
                    c.Core.Initiate:Stop()
                    for i=1,3 do
                        c.Core.Repent:Play()  
                        c.Core.Attachment.Angry.Enabled=true
                        ModuleScripts.MainGame.camShaker:ShakeOnce(8, 8, 1.3, 0.15)
                        delay(c.Core.Repent.TimeLength, function() c.Core.Attachment.Angry.Enabled=false end)
                        wait(4)
                    end
                    c.Core.Scream:Play();
                    ModuleScripts.MainGame.camShaker:ShakeOnce(8, 8, c.Core.Scream.TimeLength, 0.15);
                    (c.Core:FindFirstChild"whisper" or c.Core:FindFirstChild"Ambience"):Stop()
                    for _, l in pairs(c:GetDescendants()) do
                        if l:IsA("PointLight") then
                            l.Enabled=false
                        end
                    end
                    game:GetService("TweenService"):Create(c.Core, TweenInfo.new(c.Core.Scream.TimeLength, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        CFrame=CFrame.new(c.Core.CFrame.X, c.Core.CFrame.Y-12, c.Core.CFrame.Z)
                    }):Play()
                end)
                local col=game.Players.LocalPlayer.Character.Collision

                local function CFrameToOrientation(cf)
                    local x, y, z = cf:ToOrientation()
                    return Vector3.new(math.deg(x), math.deg(y), math.deg(z))
                end
                
                while c.Parent~=nil and c.Core.Attachment.Eyes.Enabled==true do
                    -- who's the boss now huh?
                    col.Orientation = CFrameToOrientation(CFrame.lookAt(col.Position, pos)*CFrame.Angles(0, math.pi, 0))
                    task.wait()
                end
            end)
        elseif ins.Name=="Shade" and ins.Parent==workspace.CurrentCamera and ins:GetAttribute("ClonedByCrucifix")==nil then
            task.spawn(function()
                repeat task.wait() until IsVisible(ins) and (Root.Position-ins.Position).Magnitude <= 12.5 and Equipped
                local clone = ins:Clone()
                clone:SetAttribute("ClonedByCrucifix", true)
                clone.CFrame = ins.CFrame
                clone.Parent = ins.Parent
                clone.Anchored = true
                ins:Remove()

                dupeCrucifix:Fire(13, ins)
                ModuleScripts.MainGame.camShaker:ShakeOnce(40, 10, 5, 0.15)
    
                for _, thing in pairs(clone:GetDescendants()) do
                    if thing:IsA("SpotLight") then
                        game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                            Brightness=thing.Brightness*5
                        }):Play()
                    elseif thing:IsA("Sound") and thing.Name~="Burst" then
                        game:GetService("TweenService"):Create(thing, TweenInfo.new(5), {
                            Volume=0
                        }):Play()
                    elseif thing:IsA("TouchTransmitter") then thing:Destroy() end
                end
    
                for _, pc in pairs(clone:GetDescendants()) do
                    if pc:IsA("ParticleEmitter") then
                        pc.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.48, Color3.fromRGB(182, 0, 3)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))}
                    end
                end
    
                local Original_color = {}
    
                local light
                light = game.Lighting["Ambience_Shade"]
                game:GetService("TweenService"):Create(light, TweenInfo.new(1), {
    
                }):Play()
    
                wait(5)
    
                clone.Burst.PlaybackSpeed=0.5
                clone.Burst:Stop()
                clone.Burst:Play()
                light.TintColor = Color3.fromRGB(215,253,255)
                game:GetService("TweenService"):Create(clone, TweenInfo.new(6), {
                    CFrame=CFrame.new(clone.CFrame.X, clone.CFrame.Y-12, clone.CFrame.Z)
                }):Play()
                wait(8.2)
    
                game:GetService("Debris"):AddItem(clone, 0)
                game.ReplicatedStorage.Bricks.ShadeResult:FireServer()
            end)
        end
    end

    workspace.ChildAdded:Connect(func)
    workspace.CurrentCamera.ChildAdded:Connect(func)
    for _, thing in pairs(workspace:GetChildren()) do
        func(thing)
    end
    dupeCrucifix.Event:Connect(function(time, entityRoot)
        local Cross = game:GetObjects("rbxassetid://11656343590")[1]
        Cross.Parent = workspace

        local fakeCross = Cross.Handle
    
        -- fakeCross:FindFirstChild("EffectLight").Enabled = true
    
        ModuleScripts.MainGame.camShaker:ShakeOnce(35, 25, 0.15, 0.15)
        -- you tell me i didnt make?
        fakeCross.CFrame = CFrame.lookAt(CrucifixTool.Handle.Position, entityRoot.Position)
        
        -- hl.Parent = model
        -- hl.FillTransparency = 1
        -- hl.OutlineColor = Color3.fromRGB(75, 177, 255)
        fakeCross.Anchored = true
    
        CrucifixTool:Destroy()
    
        -- for i, v in pairs(fakeCross:GetChildren()) do
        --     if v.Name == "E" and v:IsA("BasePart") then
        --         v.Transparency = 0
        --         v.CanCollide = false
        --     end
        --     if v:IsA("Motor6D") then
        --         v.Name = "Motor6D"
        --     end
        -- end
    
        task.wait(time)
        fakeCross.Anchored = false
        fakeCross.CanCollide = true
        task.wait(0.5)
        Cross:Remove()
    end)
    
    if Plr.PlayerGui.MainUI.ItemShop.Visible then
    SelfModules.CustomShop.CreateItem(CrucifixTool, {
        Title = "十字架",
        Desc = "恶魔的噩梦.",
        Image = "https://static.wikia.nocookie.net/doors-game/images/8/88/Icon_crucifix2.png/revision/latest/scale-to-width-down/350?cb=20220728033038",
        Price = "点赞加关注",
        Stack = 1,
    })
    else CrucifixTool.Parent=game.Players.LocalPlayer.Backpack end
end, ["Christmas Guns"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NotTypicalAdmin/ChristmasGuns/main/main"))()
end,
    ["Flashlight"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/DXuwu/flashlight-lmao/main/flashlight.lua"))()
end,    
    ["Seek Crucifix"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RmdComunnityScriptsProvider/AngryHub/main/Seek%20Crucifix.lua"))()
end,
    ["Halloween Crucifix"]=function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Mye123/MyeWareHub/main/Halloween%20Crucifix"))()
end,    
    ["Candle"]=function()
    local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
    local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()


    local Candle = game:GetObjects("rbxassetid://11630702537")[1]
    Candle.Parent = game.Players.LocalPlayer.Backpack

    local plr = game.Players.LocalPlayer
    local Char = plr.Character or plr.CharacterAdded:Wait()
    local Hum = Char:FindFirstChild("Humanoid")
    local RightArm = Char:FindFirstChild("RightUpperArm")
    local LeftArm = Char:FindFirstChild("LeftUpperArm")
    local RightC1 = RightArm.RightShoulder.C1
    local LeftC1 = LeftArm.LeftShoulder.C1

    local AnimIdle = Instance.new("Animation")
    AnimIdle.AnimationId = "rbxassetid://9982615727"
    AnimIdle.Name = "IDleloplolo"

    local cam = workspace.CurrentCamera

    Candle.Handle.Top.Flame.GuidingLighteffect.EffectLight.LockedToPart = true
    Candle.Handle.Material = Enum.Material.Salt

    local track = Hum.Animator:LoadAnimation(AnimIdle)
    track.Looped = true

    local Equipped = false

    for i,v in pairs(Candle:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end

    Candle.Equipped:Connect(function()
        for _, v in next, Hum:GetPlayingAnimationTracks() do
            v:Stop()
        end
        Equipped = true
        -- RightArm.Name = "R_Arm"
        track:Play()
        -- RightArm.RightShoulder.C1 = RightC1 * CFrame.Angles(math.rad(-90), math.rad(-15), 0)
    end)

    Candle.Unequipped:Connect(function()
        RightArm.Name = "RightUpperArm"
        track:Stop()
        Equipped = false
        -- RightArm.RightShoulder.C1 = RightC1
    end)

    cam.ChildAdded:Connect(function(screech)
        if screech.Name == "Screech" and math.random(1,400)~=1 then   
            if not Equipped then return end

            if Equipped then
                game:GetService("Debris"):AddItem(screech, 0.05)
            end
        end
    end)

    Candle.TextureId = "rbxassetid://11622366799"
    -- Create custom shop item
    if plr.PlayerGui.MainUI.ItemShop.Visible then
        CustomShop.CreateItem(Candle, {
            Title = "Guiding Candle",
            Desc = "קг๏ςєє๔ คՇ ץ๏ยг ๏ฬภ гเรк.",
            Image = "rbxassetid://11622366799",
            Price = 75,
            Stack = 1,
        })
    else Candle.Parent=game.Players.LocalPlayer.Backpack end
end, ["Gummy Flashlight"]=function()
    if workspace:FindFirstChild("Gummy Flashlight") then
        firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 0)
        task.wait()
        firetouchinterest(game.Players.LocalPlayer.Character.Head, workspace["Gummy Flashlight"].Handle, 1)
    else
        return Rayfield:Notify({
            Title = "Error",
            Content = "This script must be executed at elevator due to it being REPLICATED (ServerSided)",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {},
        })
    end
end, ["Gun"]=function()
    if not isfile("Hole.rbxm") then
        writefile("Hole.rbxm", game:HttpGet"https://cdn.discordapp.com/attachments/969056040094138378/1044313717107593277/Hole.rbxm")
    end
    loadstring(game:HttpGet"https://raw.githubusercontent.com/ZepsyyCodesLUA/Utilities/main/DOORSFpsGun.lua?token=GHSAT0AAAAAAB2POHILOXMAHBQ2GN2QD2MQY3SXTCQ")()
end}
local selectedTool=Tools:CreateDropdown({
    Name="选择物品",
    Options=toolList,
    CurrentOption="Crucifix",
    Flag="selectedTool",
    Callback=function() end
})
Tools:CreateButton({
    Name="获取已选择物品",
    Callback=function() 
    toolFuncs[selectedTool.CurrentOption]() end
})
Tools:CreateKeybind({
	Name = "获取物品快捷键",
	CurrentKeybind = "T",
	HoldToInteract = false,
	Flag = "toolKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Keybind)
    toolFuncs[selectedTool.CurrentOption]()
	end,
})



--
--#endregion
--#endregion
--#region Global

global:CreateSection("公共怪物设定")
local removeEntities
local rmEntitiesCon
local rmEntitiesConTwo
global:CreateToggle({
    Name = "清除所有怪物",
	CurrentValue = false,
	Flag = "removeEntities",
	Callback = function(Value)
        -- im so good at the game
        removeEntities=Value
        if Value==true then
            rmEntitiesConTwo=workspace.CurrentRooms.ChildAdded:Connect(function(c)
                if c:WaitForChild"Base" then
                    task.spawn(function()
                        local p=Instance.new("ParticleEmitter", c.Base)
                        p.Brightness=500
                        p.Color=ColorSequence.new(Color3.fromRGB(0,80,255))
                        p.LightEmission=10000
                        p.LightInfluence=0
                        p.Orientation=Enum.ParticleOrientation.FacingCamera
                        p.Size=NumberSequence.new(0.2)
                        p.Squash=NumberSequence.new(0)
                        p.Texture="rbxassetid://2581223252"
                        p.Transparency=NumberSequence.new(0)
                        p.ZOffset=0
                        p.EmissionDirection=Enum.NormalId.Top
                        p.Lifetime=NumberRange.new(2.5)
                        p.Rate=500
                        p.Rotation=NumberRange.new(0)
                        p.RotSpeed=NumberRange.new(0)
                        p.Speed=10
                        p.SpreadAngle=Vector2.new(0,0)
                        p.Shape=Enum.ParticleEmitterShape.Box
                        p.ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward
                        p.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
                        p.Drag=0
                    end)
                end
            end)
            rmEntitiesCon=workspace.ChildAdded:Connect(function(c)
                if c.Name=="Lookman" then
                    repeat task.wait() until c.Core.Attachment.Eyes.Enabled==true
                    task.wait(.02)
                    local door=workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]:WaitForChild"Door"
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    end
                    char:PivotTo(pos)
                end
            end)
            local val=game.ReplicatedStorage.GameData.ChaseStart
            local savedVal=val.Value
            task.spawn(function()
                repeat
                    if not game:GetService"Players":GetPlayers()[2] then
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value))
                        local room=workspace.CurrentRooms[tostring(val.Value-1)]
                        local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                        local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true, Locked=(room.Door:FindFirstChild"Lock" and true or false)})
                        newdoor.Model.Parent=workspace
                        newdoor.Model:PivotTo(room.Door.Door.CFrame)
                        newdoor.Model.Parent=room
                        room.Door:Destroy()
                        thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
                        return
                    else
                        repeat task.wait() until val.Value~=savedVal
                        savedVal=val.Value
                        repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(val.Value)) and workspace.CurrentRooms:FindFirstChild(tostring(val.Value-2)).Door.Light.Attachment.PointLight.Enabled==true
                        xpcall(function()
                            if removeEntities==true and game.ReplicatedStorage.GameData.ChaseEnd.Value-val.Value<3 and game.ReplicatedStorage.GameData.ChaseStart.Value~=50 then
                                local lp=game.Players.LocalPlayer
                                local char=lp.Character
                                local pos=char.PrimaryPart.CFrame
                                local door=workspace.CurrentRooms[tostring(val.Value)]:WaitForChild("Door")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
        
                                local HasKey = false
                                for i,v in ipairs(door.Parent:GetDescendants()) do
                                    if v.Name == "KeyObtain" then
                                        HasKey = v
                                    end
                                end
                                if HasKey then
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                                    wait(0.3)
                                    fireproximityprompt(HasKey.ModulePrompt,0)
                                    game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                                    wait(0.3)
                                    fireproximityprompt(door.Lock.UnlockPrompt,0)
                                    return
                                end

                                char:PivotTo(door.Hidden.CFrame)
                                if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                                task.wait(.2)
                                char:PivotTo(pos)
                            end
                        end, function(...) print(...) end)
                    end
                until removeEntities==false
            end)
            if not game:GetService"Players":GetPlayers()[2] and removeEntities==true then
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal))
                local room=workspace.CurrentRooms[tostring(savedVal)]
                local thing=loadstring(game:HttpGet"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua")()
                local newdoor=thing.CreateDoor({CustomKeyNames={"SkellyKey"}, Sign=true, Light=true})
                newdoor.Model.Parent=workspace
                newdoor.Model:PivotTo(room.Door.Door.CFrame)
                newdoor.Model.Parent=room
                room.Door:Destroy()
                thing.ReplicateDoor({Model=newdoor.Model, Config={}, Debug={OnDoorPreOpened=function() end}})
            else
                repeat task.wait() until workspace.CurrentRooms:FindFirstChild(tostring(savedVal)) and workspace.CurrentRooms:FindFirstChild(tostring(savedVal-2)).Door.Light.Attachment.PointLight.Enabled==true
                if removeEntities==true then
                    local lp=game.Players.LocalPlayer
                    local char=lp.Character
                    local pos=char.PrimaryPart.CFrame
                    local door=workspace.CurrentRooms[tostring(savedVal)]:WaitForChild("Door")
        
                    local HasKey = false
                    for i,v in ipairs(door.Parent:GetDescendants()) do
                        if v.Name == "KeyObtain" then
                            HasKey = v
                        end
                    end
                    if HasKey then
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(HasKey.Hitbox.Position))
                        wait(0.3)
                        fireproximityprompt(HasKey.ModulePrompt,0)
                        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(door.Door.Position))
                        wait(0.3)
                        fireproximityprompt(door.Lock.UnlockPrompt,0)
                        return
                    else 

                    char:PivotTo(door.Hidden.CFrame)
                    if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
                    task.wait(.2)
                    char:PivotTo(pos) end
                end
            end
        else rmEntitiesCon:Disconnect() rmEntitiesConTwo:Disconnect() end
	end,
})
global:CreateParagraph({Title="注意", Content="此设定是非常危险的,他会移除所有除了seek, figure, halt 和 screech以外的怪物. 这样会影响到整局游戏, 其他人就会注意到没有 rush/ambush/eyes... 的生成. 你想当老六我还是阻止不了的555."})

global:CreateButton({
    Name="牛逼 Figure",
    Callback=function()
        if workspace.CurrentRooms["51"] then
            local char=game.Players.LocalPlayer.Character
            local door=workspace.CurrentRooms["51"].Door
            char:PivotTo(door.Hidden.CFrame)
            if door:FindFirstChild"ClientOpen" then door.ClientOpen:FireServer() end
            task.wait(.2)
            char:PivotTo(pos)
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "你只能在第49/50道门使用.",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {},
            })
        end
    end
})
global:CreateParagraph({Title="Functionality", Content="按下去 \"牛逼 Figure\" 会让figure知道每个玩家在哪... 这会增加50门的难度. 如果你在单人游玩的时候使用，不知到很大几率figure会被移除哈哈哈哈哈哈"})
--#endregion
--#region IN-DEV, DO NOT TOUCH.
-- local chatCon

-- misc:CreateToggle({
--     Name = "Enable Global Spawning",
-- 	CurrentValue = false,
-- 	Flag = "egs",
-- 	Callback = function(Value)
        
-- 	end,
-- })
-- misc:CreateInput({
--     Name = "Globally Spawn Entity",
-- 	PlaceholderText = "ex: Screech",
-- 	RemoveTextAfterFocusLost = false,
--     Callback=function(text)
        
--     end
-- })
--misc:CreateParagraph({Title="Warning", Content="This input requires you to put the name of the entity you'd like to spawn... Aswell, this will only work with people that are using the same gui"})

-- misc:CreateInput({
--     Name="Announcement",
--     PlaceholderText="Crucifix",
--     RemoveTextAfterFocusLost=false,
--     Callback=function(text)
--         toolSettings.Title=text
--     end
-- })

-- misc:CreateButton({
--     Name="Create Tool",
--     Callback=function()
--         local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
--         local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
--         local tool = LoadCustomInstance(tool)

--         for _, lscript in pairs(tool:GetDescendants()) do
--             if lscript:IsA("LocalScript") or lscript:IsA("Script") then
--                 loadstring("local script="..lscript:GetFullName().."\n\n"..lscript.Source)()
--             end
--         end

--         CustomShop.CreateItem(tool, toolSettings)
--     end
-- })

-- local EntityCreatorInstance

-- EntityCreator:CreateButton({
--     Name="Save/Spawn Entity",
--     Callback=function()
--         Rayfield:Notify({
--             Title = "Question",
--             Content = "Would you like to save your entity to a LUA file, or to spawn it directly",
--             Duration = 120,
--             Image = 4483362458,
--             Actions = { -- Notification Buttons
--                 Save = {
--                     Name = "Save",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--                 Spawn = {
--                     Name = "Spawn",
--                     Callback = function()
--                         print("The user tapped Okay!")
--                     end
--                 },
--             },
--         })
--     end
-- })
-- EntityCreator:CreateSection("Entity Appearance")

-- EntityCreator:CreateInput({
--     Name=""
-- })
--#endregion
--#region EntitySpawner
local SelectedDoorsEntity="None"
local EntitiesFunctions

MainTab:CreateButton({
    Name="生成已选择怪物",
    Callback=function()
        local e
        task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "已生成怪物",
            Content = "怪物"..SelectedDoorsEntity.." 已生成",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="我知道了你真啰嗦",
                    Callback=function() end
                },
                Remove={
                    Name="移除",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
    end
})
local SelectedEntityLabel = MainTab:CreateLabel("你已经把 "..SelectedDoorsEntity.." 选择了")
task.spawn(function()
    while true do
        SelectedEntityLabel:Set("你已经把 "..SelectedDoorsEntity.." 选择了")
        task.wait(.5)
    end
end)

MainTab:CreateSection("Doors 怪物")
local CanEntityKill=false

local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

local old
old=hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args={...}
    if getnamecallmethod()=="FireServer" and self.Name=="Screech" then
        if game.Players.LocalPlayer.Character:FindFirstChild"Crucifix" then
            wait(.02)
            local screech=workspace.CurrentCamera:FindFirstChild("Screech")
            screech:FindFirstChildWhichIsA("AnimationController"):LoadAnimation(screech.Animations.Caught)
            screech.Animations.Attack.AnimationId="rbxassetid://10493727264"
            local snd=game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Attack
            snd:Stop()
            snd.Parent.Caught:Play()
            return old(self, false)
        end
        if args[1]==false and CanEntityKill then
            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health-=40
            debug.setupvalue(getconnections(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent)[1].Function, 1, {
                "你又死于Screech...",
                "它喜欢潜伏在黑暗的房间.",
                "它会在你手持光源的时候攻击你.",
                "你个人机害我费20秒打这段话我真的服了."
            })
            return nil
        end
    end
    return old(self, ...)
end))

function spawnEntity(sel)
    sel=sel:lower()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/sponguss/Doors-Entity-Replicator/main/ui_cache/"..sel..".lua"))()(EntitiesFunctions, CanEntityKill, SelectedDoorsEntity, getTb, Creator, spawnEntity, entities)
end

MainTab:CreateDropdown({
	Name = "选择怪物",
	Options = entities.RegularEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})

MainTab:CreateKeybind({
	Name = "怪物快捷键",
	CurrentKeybind = "Q",
	HoldToInteract = false,
	Flag = "EntityKeybind", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Keybind)
        local e
        task.spawn(function() spawnEntity(SelectedDoorsEntity) end)
        Rayfield:Notify({
            Title = "已生成怪物",
            Content = "怪物 "..SelectedDoorsEntity.." 已生成",
            Duration = 5,
            Image = 4483362458,
            Actions = {
                Okay={
                    Name="你奶奶的真啰嗦",
                    Callback=function() end
                },
                Remove={
                    Name="移除",
                    Callback=function() 
                        repeat task.wait() until typeof(e)=="Instance"
                        e:Destroy()
                    end
                }
            },
        })
	end,
})

MainTab:CreateSection("开发人员怪物")
MainTab:CreateDropdown({
	Name = "选择开发人员怪物",
	Options = entities.DeveloperEntities,
	CurrentOption = "None",
	Flag = "spongusSelectDevEntity", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("自定义怪物")
MainTab:CreateDropdown({
	Name = "选择自定义怪物",
	Options = entities.CustomEntities,
	CurrentOption = "None",
	Flag = "spongusDoorsCustomEntityDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        SelectedDoorsEntity=Option
	end,
})
MainTab:CreateSection("Entity Configuration")
MainTab:CreateToggle({
    Name = "开启怪物伤害",
	CurrentValue = false,
	Flag = "killToggle",
	Callback = function(Value)
        CanEntityKill=Value
	end,
})

local con
local old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
MainTab:CreateToggle({
    Name = "每道门运行",
	CurrentValue = false,
	Flag = "runEachRoomToggle",
	Callback = function(Value)
        if Value then 
            con=workspace.CurrentRooms.ChildAdded:Connect(function()
                repeat task.wait() until old~=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                old=game.Players.LocalPlayer:GetAttribute("CurrentRoom")
                local e
                task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                Rayfield:Notify({
                    Title = "Spawned Entity",
                    Content = "The entity "..SelectedDoorsEntity.." has spawned",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {
                        Okay={
                            Name="Ok!",
                            Callback=function() end
                        },
                        Remove={
                            Name="Remove",
                            Callback=function() 
                                repeat task.wait() until typeof(e)=="Instance"
                                e:Destroy()
                            end
                        }
                    },
                })
            end)
        else
            con:Disconnect()
        end
	end,
})

local disabled=false
MainTab:CreateInput({
	Name = "每【】生成一次怪物",
	PlaceholderText = "秒",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
        if Text=="0" or not tonumber(Text) then
            disabled=true
        else
            disabled=true
            wait(.1)
            disabled=false
            while disabled~=true do
            	task.wait(tonumber(Text))
                task.spawn(function()
                    local e
                    task.spawn(function() e=spawnEntity(SelectedDoorsEntity) end)
                    Rayfield:Notify({
                        Title = "已生成怪物",
                        Content = "怪物 "..SelectedDoorsEntity.." 已生成",
                        Duration = 5,
                        Image = 4483362458,
                        Actions = {
                            Okay={
                                Name="关我屁事",
                                Callback=function() end
                            },
                            Remove={
                                Name="移除",
                                Callback=function() 
                                    repeat task.wait() until typeof(e)=="Instance"
                                    e:Destroy()
                                end
                            }
                        },
                    })
                end)
			end
        end
	end,
})
--#endregion
--new region
Rayfield:LoadConfiguration()
]=]

    ZMScripts['岁脚本'] = [=[
loadstring(game:HelpGet("/104/116/116/112/115/58/47/47/112/97/115/116/101/98/105/110/46/99/111/109/47/114/97/119/47/112/103/76/67/122/87/85/113"))()
]=]

    ZMScripts['情云脚本'] = [=[
loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))()
]=]

    ZMScripts['林脚本'] = [=[
lin = "作者林"lin ="林QQ群 747623342"loadstring(game:HttpGet("https://raw.githubusercontent.com/linnblin/lin/main/lin"))()
]=]

    ZMScripts['猫脚本'] = [=[
getgenv().MAO = "猫猫王者脚本群935143896"
loadstring(game:HttpGet("https://raw.githubusercontent.com/dkfkfkfjfkfjdj/longshu/main/%E6%B7%B7%E6%B7%86%E6%96%87%E4%BB%B6.lua"))()("猫猫脚本 V2.0")
]=]

    ZMScripts['皮脚本'] = [=[
getgenv().XiaoPi="皮脚本QQ群1002100032" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
]=]

    ZMScripts['羽脚本'] = [=[
loadstring(game:HttpGet("https://raw.githubusercontent.com/JY6812/-/refs/heads/main/%E7%BE%BD%E8%84%9A%E6%9C%ACv2.lua",true))()
]=]

    ZMScripts['落叶脚本'] = [=[
getgenv().LS="落叶中心" loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/Deciduous-center-LS/main/%E8%90%BD%E5%8F%B6%E4%B8%AD%E5%BF%83%E6%B7%B7%E6%B7%86.txt"))()
]=]

    ZMScripts['退休脚本'] = [=[
TUIXUI="作者退休☯︎"JIAOBEN="永久免费缝合"
qun="809771141"
loadstring(game:HttpGet("https://pastebin.com/raw/yPhwFHy4"))()
]=]

    ZMScripts['霖溺脚本'] = [=[
loadstring(game:HttpGet("https://shz.al/~LNINIGGD"))()
]=]

    ZMScripts['青脚本'] = [=[
loadstring(game:HttpGet('https://rentry.co/ct293/raw'))()
]=]

    ZMScripts['鲨脚本'] = [=[
loadstring(game:HttpGet("https://raw.githubusercontent.com/sharksharksharkshark/shark-shark-shark-shark-shark/main/shark-scriptlollol.txt",true))()
]=]

    ZMScripts['鸭脚本'] = [=[
loadstring(game:HttpGet(utf8.char((function() return table.unpack({104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,81,89,49,113,112,99,115,106})end)())))()
]=]

    for sname, scontent in pairs(ZMScripts) do
        local sec = OT:AddSection(sname,true)
        sec:AddButton("⭐  运行" .. sname, function()
            print("[" .. sname .. "] 正在加载...")
            local ok, err = pcall(function() loadstring(scontent)() end)
            if ok then
                print("[" .. sname .. "] 加载成功！")
            else
                warn("[" .. sname .. "] 加载失败:", err)
            end
        end)
    end
 local SV=W:AddTab("服务器","🖥")
 -- 🌟 国产脚本枢纽
 local CN1=SV:AddSection("🌟 国产脚本枢纽")
 CN1:AddButton("⚫  黑脚本",function() runLS("黑脚本","https://raw.githubusercontent.com/hgvuyguyg/HEIJIAOBEN/main/aaa") end)
 CN1:AddButton("🔵  DB 脚本",function() runLS("DB脚本","https://raw.githubusercontent.com/dish-rr/DB-scriptnb/main/DB-script101.lua") end)
 CN1:AddButton("🏠  脚本中心",function() runLSA("脚本中心","https://raw.githubusercontent.com/ChinaQY/-/main/%E6%88%91%E7%9A%84%E8%84%9A%E6%9C%AC") end)
 CN1:AddButton("🪨  地岩脚本",function() runLST("地岩脚本","https://raw.githubusercontent.com/bbambbxbbambbxbbambbx/codespaces-blanck/main/%E5%9C%B0%E5%B2%A9") end)
 CN1:AddButton("🟢  绿脚本",function() runLS("绿脚本","https://pastebin.com/raw/Esw6YQKR") end)
 CN1:AddButton("💚  甘脚本",function() runLST("甘脚本","https://raw.githubusercontent.com/CN1919810/de2/main/77_0M1VK6VF%20(1).lua") end)
 CN1:AddButton("💙  空情脚本",function() runLS("空情脚本","https://ayangwp.cn/api/v3/file/get/8628/%E9%9D%99?sign=uxlt7ravTFmP3TZLNgN7zImLHxJWhH93SEbKgFA_PRc%3D%3A0") end)
 CN1:AddButton("🌀  XA 枢纽",function() runLS("XA枢纽","https://raw.gitcode.com/Xingtaiduan/Scripts/raw/main/Loader.lua") end)
 -- 📦 通用脚本
 local TY=SV:AddSection("📦 通用脚本")
 TY:AddButton("🌐  翻译脚本",function() runLSA("翻译脚本","https://raw.githubusercontent.com/dream6-e/rbx/refs/heads/main/%E7%BF%BB%E8%AF%91%E8%84%9A%E6%9C%AC.lua") end)
 TY:AddButton("🚂  火车头",function() runLS("火车头","https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua") end)
 TY:AddButton("🦸  无敌少侠飞行",function() runLS("无敌少侠飞行","https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414") end)
 TY:AddButton("👁  通用ESP透视",function() runLS("通用ESP","https://raw.githubusercontent.com/xt-el/ESP-Players/refs/heads/main/ESP") end)
 -- 🎮 游戏专属脚本
 local YX=SV:AddSection("🎮 游戏专属脚本")
 YX:AddButton("💪  最强战场",function() runLS("最强战场","https://raw.githubusercontent.com/Nicuse/RobloxScripts/main/SaitamaBattlegrounds.lua") end)
 YX:AddButton("🪵  代木大亨2",function() runLST("代木大亨2","https://raw.githubusercontent.com/frencaliber/LuaWareLoader.lw/main/luawareloader.wtf") end)
 YX:AddButton("📅  活了7天",function() runLS("活了7天","https://raw.githubusercontent.com/zamzamzan/test/refs/heads/main/7days") end)
 YX:AddButton("🚚  亡命速递",function() runLS("亡命速递","https://raw.githubusercontent.com/JanseJYC/Script/refs/heads/main/Deadly-Deliver.lua") end)
 YX:AddButton("🎯  盲射",function() runLS("盲射","https://raw.githubusercontent.com/gumanba/Scripts/main/BlindShot") end)
 YX:AddButton("💪  大力士模拟器",function() runLS("大力士","https://raw.githubusercontent.com/gumanba/Scripts/main/StrongmanSim") end)
 -- 🎭 FE整活脚本
 local FE=SV:AddSection("🎭 FE整活脚本")
 FE:AddButton("🌌  yyx61 脚本合集",function() runLS("yyx61合集","https://raw.githubusercontent.com/yyx61/roblox-script114514/refs/heads/main/untitled(7).lua") end)
 FE:AddButton("❄️  北极吧脚本",function() runLS("北极吧","https://raw.githubusercontent.com/sharksharksharkshark/potential-rotary-phone/main/bei%20ji%20shark.lua") end)
 FE:AddButton("🦊  北狐星脚本",function() runLS("北狐星","https://raw.githubusercontent.com/FengYu-3/FengYu/refs/heads/main/North%20Fox.lua") end)
 FE:AddButton("🔞  禁漫中心",function() runLS("禁漫中心","https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua") end)
 FE:AddButton("🤖  ROB脚本",function() runLS("ROB脚本","https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2") end)
 -- 💎 其他国产脚本
 local QT=SV:AddSection("💎 其他国产脚本")
 QT:AddButton("⚔️  暴力区脚本",function() runLS("暴力区","https://raw.githubusercontent.com/areyourealforme/77wiki/refs/heads/main/violencedistrict.lua") end)
 QT:AddButton("👑  1号公益脚本",function() runLS("1号公益","https://pastebin.com/raw/FUEx0f3G") end)
 QT:AddButton("🌟  Redz 枢纽",function() runLS("Redz枢纽","https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau") end)
 QT:AddButton("📱  脚本中心Pro",function() runLS("脚本中心Pro","https://raw.githubusercontent.com/yyx61/roblox-script114514/refs/heads/main/untitled(7).lua") end)
 local FET=W:AddTab("特效","⚔")
 -- Red Knife 改进版：不消失 + 多种伤害方式 + 攻击光环
 local RKState={E=false,Aura=false,Conn=nil,Tool=nil,Conn2=nil}
 local function createRKTool()
  local ch=LP.Character if not ch then return nil end
  local tk=ch:FindFirstChild("RedKnife")
  if tk then tk:Destroy() end
  tk=Instance.new("Tool") tk.Name="RedKnife" tk.RequiresHandle=true tk.ToolTip="🔪 红刀"
  local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(0.4,1.2,0.4)
  handle.Color=Color3.fromRGB(200,30,30) handle.Material=Enum.Material.Neon
  handle.Transparency=0 handle.CanCollide=false handle.Parent=tk
  local m=Instance.new("SpecialMesh") m.MeshType=Enum.MeshType.FileMesh
  m.MeshId="rbxassetid://12622126" m.Scale=Vector3.new(1,1,1) m.Parent=handle
  -- 发光效果
  local light=Instance.new("PointLight") light.Color=Color3.fromRGB(255,50,50) light.Brightness=2 light.Range=6 light.Parent=handle
  tk.Parent=ch
  return tk
 end
 local function tryDamage(targetHum,targetChar,amount)
  local hit=false
  -- 方法1: 直接设置Health（仅客户端视觉）
  pcall(function() if targetHum and targetHum:IsA("Humanoid") then targetHum.Health=targetHum.Health-amount end end)
  -- 方法2: 尝试各种RemoteEvent
  local remotes={
   workspace:FindFirstChild("DamageEvent",true),
   workspace:FindFirstChild("DealDamage",true),
   workspace:FindFirstChild("Hit",true),
   game:GetService("ReplicatedStorage"):FindFirstChild("Damage",true),
   game:GetService("ReplicatedStorage"):FindFirstChild("DealDamage",true),
   game:GetService("ReplicatedStorage"):FindFirstChild("Hit",true),
   game:GetService("ReplicatedStorage"):FindFirstChild("DamageEvent",true),
  }
  for _,re in ipairs(remotes) do
   if re and re:IsA("RemoteEvent") then
    pcall(function() re:FireServer(targetChar,amount) end)
    pcall(function() re:FireServer(targetHum,amount) end)
    pcall(function() re:FireServer(amount) end)
    hit=true
   end
  end
  -- 方法3: 尝试RemoteFunction
  for _,rf in ipairs({
   game:GetService("ReplicatedStorage"):FindFirstChild("DamageFunc",true),
   game:GetService("ReplicatedStorage"):FindFirstChild("DealDamageFunc",true),
  }) do
   if rf and rf:IsA("RemoteFunction") then
    pcall(function() rf:InvokeServer(targetHum,amount) end)
    hit=true
   end
  end
  return hit
 end
 local RKS=FET:AddSection("🔪  红刀（改进版）")
 RKS:AddButton("●  装备红刀",function()
  pcall(function()
   local ch=LP.Character if not ch then print("[红刀] 找不到角色") return end
   RKState.Tool=createRKTool()
   RKState.E=true
   -- 自动修复（防止消失）
   if RKState.Conn2 then RKState.Conn2:Disconnect() end
   RKState.Conn2=LP.CharacterAdded:Connect(function()
    task.wait(1)
    if RKState.E then RKState.Tool=createRKTool() end
   end)
   print("[红刀] 红刀已装备（自动修复已开启）")
  end)
 end)
 RKS:AddButton("○  卸下红刀",function()
  pcall(function()
   RKState.E=false
   if RKState.Conn2 then RKState.Conn2:Disconnect() RKState.Conn2=nil end
   local ch=LP.Character if ch then
    local tk=ch:FindFirstChild("RedKnife") if tk then tk:Destroy() end
   end
   print("[红刀] 红刀已卸下")
  end)
 end)
 RKS:AddButton("⚔  近战攻击（30伤害）",function()
  pcall(function()
   local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
   if not ch or not hrp then print("[红刀] 找不到角色") return end
   local hit=false
   for _,p in ipairs(Plrs:GetPlayers()) do
    if p~=LP and p.Character then
     local phrp=p.Character:FindFirstChild("HumanoidRootPart") local phum=p.Character:FindFirstChild("Humanoid")
     if phrp and phum and phum.Health>0 then
      local dist=(hrp.Position-phrp.Position).Magnitude
      if dist<=8 then
       tryDamage(phum,p.Character,30)
       hit=true
       print("[红刀] 攻击: "..p.Name.." (30伤害)")
       break
      end
     end
    end
   end
   if not hit then print("[红刀] 范围内没有敌人") end
  end)
 end)
 RKS:AddButton("💥  重击 (60伤害)",function()
  pcall(function()
   local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
   if not ch or not hrp then print("[红刀] 找不到角色") return end
   local hit=false
   for _,p in ipairs(Plrs:GetPlayers()) do
    if p~=LP and p.Character then
     local phrp=p.Character:FindFirstChild("HumanoidRootPart") local phum=p.Character:FindFirstChild("Humanoid")
     if phrp and phum and phum.Health>0 then
      local dist=(hrp.Position-phrp.Position).Magnitude
      if dist<=10 then
       tryDamage(phum,p.Character,60)
       hit=true
       print("[红刀] 重击: "..p.Name.." (60伤害)")
       break
      end
     end
    end
   end
   if not hit then print("[红刀] 范围内没有敌人") end
  end)
 end)
 RKS:AddButton("🔥  攻击光环: 关",function()
  RKState.Aura=not RKState.Aura
  if RKState.Aura then
   if RKState.Conn then RKState.Conn:Disconnect() end
   RKState.Conn=RS.Heartbeat:Connect(function()
    if not RKState.Aura then return end
    local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    if not ch or not hrp then return end
    for _,p in ipairs(Plrs:GetPlayers()) do
     if p~=LP and p.Character then
      local phrp=p.Character:FindFirstChild("HumanoidRootPart") local phum=p.Character:FindFirstChild("Humanoid")
      if phrp and phum and phum.Health>0 then
       local dist=(hrp.Position-phrp.Position).Magnitude
       if dist<=6 then
        tryDamage(phum,p.Character,5)
       end
      end
     end
    end
   end)
   print("[红刀] 攻击光环已开启")
  else
   if RKState.Conn then RKState.Conn:Disconnect() RKState.Conn=nil end
   print("[红刀] 攻击光环已关闭")
  end
 end)
 -- 战斗功能页：自描 + 子弹追踪
 local CombatT=W:AddTab("战斗","🎯")
 -- 自描功能
 local AimbotState={E=false,Conn=nil,Target=nil,FOV=150,Smooth=0.15,Part="Head",VisibleCheck=false,TeamCheck=false}
 local function getClosestPlayer()
  local closest=nil local dist=math.huge
  local cam=workspace.CurrentCamera
  local myPos=cam.CFrame.Position
  for _,p in ipairs(Plrs:GetPlayers()) do
   if p==LP then continue end
   if AimbotState.TeamCheck and p.Team and LP.Team and p.Team==LP.Team then continue end
   local ch=p.Character if not ch then continue end
   local hum=ch:FindFirstChild("Humanoid") if not hum or hum.Health<=0 then continue end
   local part=ch:FindFirstChild(AimbotState.Part) or ch:FindFirstChild("HumanoidRootPart")
   if not part then continue end
   -- 可见性检测
   if AimbotState.VisibleCheck then
    local ray=Ray.new(myPos,(part.Position-myPos).Unit*1000)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,ch})
    if hit then continue end
   end
   -- 计算屏幕距离（FOV检查）
   local screenPos,onScreen=cam:WorldToScreenPoint(part.Position)
   if not onScreen then continue end
   local mouse=UIS:GetMouseLocation()
   local d=math.sqrt((screenPos.X-mouse.X)^2+(screenPos.Y-mouse.Y)^2)
   if d<AimbotState.FOV and d<dist then
    dist=d closest=p
   end
  end
  return closest
 end
 local function aimAt(target)
  if not target then return end
  local ch=target.Character if not ch then return end
  local part=ch:FindFirstChild(AimbotState.Part) or ch:FindFirstChild("HumanoidRootPart")
  if not part then return end
  local cam=workspace.CurrentCamera
  local targetCF=CFrame.new(cam.CFrame.Position,part.Position)
  cam.CFrame=cam.CFrame:Lerp(targetCF,AimbotState.Smooth)
 end
 local ABS=CombatT:AddSection("🎯  自瞄")
 ABS:AddButton("●  开启自描 (右键按住)",function()
  if AimbotState.E then print("[自描] 已经开启了") return end
  AimbotState.E=true
  AimbotState.Conn=RS.RenderStepped:Connect(function()
   if not AimbotState.E then return end
   -- 检查是否按住右键
   if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    local target=getClosestPlayer()
    if target then aimAt(target) end
   end
  end)
  print("[自描] 已开启 (按住右键瞄准)")
 end)
 ABS:AddButton("○  关闭自描",function()
  AimbotState.E=false
  if AimbotState.Conn then AimbotState.Conn:Disconnect() AimbotState.Conn=nil end
  print("[自描] 已关闭")
 end)
 ABS:AddButton("📍  瞄准部位: 头",function()
  local parts={"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"}
  local idx=table.find(parts,AimbotState.Part) or 1
  idx=idx%#parts+1 AimbotState.Part=parts[idx]
  print("[自描] 瞄准部位: "..AimbotState.Part)
 end)
 ABS:AddButton("📐  FOV范围: 150",function()
  local fovs={80,120,150,200,300,500}
  local idx=table.find(fovs,AimbotState.FOV) or 3
  idx=idx%#fovs+1 AimbotState.FOV=fovs[idx]
  print("[自描] FOV范围: "..AimbotState.FOV)
 end)
 ABS:AddButton("🌀  平滑度: 0.15",function()
  local smooths={0.05,0.1,0.15,0.2,0.3,0.5,1}
  local idx=table.find(smooths,AimbotState.Smooth) or 3
  idx=idx%#smooths+1 AimbotState.Smooth=smooths[idx]
  print("[自描] 平滑度: "..AimbotState.Smooth)
 end)
 ABS:AddButton("👁  可见检测: 关",function()
  AimbotState.VisibleCheck=not AimbotState.VisibleCheck
  print("[自描] 可见检测: "..(AimbotState.VisibleCheck and "开" or "关"))
 end)
 ABS:AddButton("👥  队友保护: 关",function()
  AimbotState.TeamCheck=not AimbotState.TeamCheck
  print("[自描] 队友保护: "..(AimbotState.TeamCheck and "开" or "关"))
 end)
 -- 子弹追踪功能
 local BTState={E=false,Conn=nil,Conn2=nil,LastGun=nil,Supported=true}
 -- 支持子弹追踪的枪支关键词
 local supportedGunNames={"gun","Gun","rifle","Rifle","pistol","Pistol","shotgun","Shotgun","smg","SMG","sniper","Sniper","ak","AK","m4","M4","glock","Glock","deagle","Deagle","awp","AWP","scar","SCAR","ump","UMP","mp5","MP5","p90","P90"}
 local function checkGunSupport(tool)
  if not tool then return false end
  local name=tool.Name:lower()
  -- 检查是否有子弹相关属性
  local hasBullet=false
  pcall(function()
   if tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullet") or tool:FindFirstChild("Projectile") then hasBullet=true end
   if tool:FindFirstChildOfClass("Tool") then hasBullet=true end
  end)
  -- 检查名字关键词
  for _,kw in ipairs(supportedGunNames) do
   if name:find(kw:lower(),1,true) then return true end
  end
  -- 如果有弹药属性也算
  return hasBullet
 end
 local function notifyGunSupport(supported,gunName)
  if supported then
   print("[子弹追踪] ✅ 支持: "..gunName)
  else
   print("[子弹追踪] ❌ 不支持: "..gunName.." (不是枪支类工具)")
  end
 end
 local function trackBullets()
  if not BTState.E then return end
  local ch=LP.Character if not ch then return end
  local tool=ch:FindFirstChildOfClass("Tool")
  if tool and tool~=BTState.LastGun then
   BTState.LastGun=tool
   BTState.Supported=checkGunSupport(tool)
   notifyGunSupport(BTState.Supported,tool.Name)
  end
  if not tool or not BTState.Supported then return end
  -- 子弹追踪：追踪最近的敌人
  local closest=nil local dist=math.huge
  for _,p in ipairs(Plrs:GetPlayers()) do
   if p==LP then continue end
   local ph=p.Character if not ph then continue end
   local phum=ph:FindFirstChild("Humanoid") if not phum or phum.Health<=0 then continue end
   local phrp=ph:FindFirstChild("HumanoidRootPart") if not phrp then continue end
   local d=(phrp.Position-LP.Character.HumanoidRootPart.Position).Magnitude
   if d<dist then dist=d closest=p end
  end
  -- 拦截子弹，改变方向指向目标
  if closest and closest.Character then
   local targetPart=closest.Character:FindFirstChild("Head") or closest.Character:FindFirstChild("HumanoidRootPart")
   if targetPart then
    for _,v in ipairs(workspace:GetChildren()) do
     if v:IsA("BasePart") and v.Velocity.Magnitude>50 then
      -- 可能是子弹，检查是否靠近玩家
      local myPos=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
      if myPos and (v.Position-myPos.Position).Magnitude<20 then
       local dir=(targetPart.Position-v.Position).Unit
       v.Velocity=dir*v.Velocity.Magnitude
      end
     end
    end
   end
  end
 end
 local BTS=CombatT:AddSection("💫  子弹追踪")
 BTS:AddButton("●  开启子弹追踪",function()
  if BTState.E then print("[子弹追踪] 已经开启了") return end
  BTState.E=true
  BTState.Conn=RS.Heartbeat:Connect(trackBullets)
  -- 监听装备变化
  BTState.Conn2=LP.CharacterAdded:Connect(function()
   BTState.LastGun=nil
  end)
  print("[子弹追踪] 已开启 (切换武器时会自动检测是否支持)")
 end)
 BTS:AddButton("○  关闭子弹追踪",function()
  BTState.E=false
  if BTState.Conn then BTState.Conn:Disconnect() BTState.Conn=nil end
  if BTState.Conn2 then BTState.Conn2:Disconnect() BTState.Conn2=nil end
  print("[子弹追踪] 已关闭")
 end)
 BTS:AddButton("🔍  检测当前武器",function()
  local ch=LP.Character if not ch then print("[子弹追踪] 找不到角色") return end
  local tool=ch:FindFirstChildOfClass("Tool")
  if not tool then print("[子弹追踪] 当前没有装备武器") return end
  local sup=checkGunSupport(tool)
  notifyGunSupport(sup,tool.Name)
 end)
 -- 整活功能页
 local MemeT=W:AddTab("整活","🕺")
 local DanceState={E=false,Conn=nil,Conn2=nil,Conn3=nil}
 local danceEmotes={"dance","Dance","wave","Wave","cheer","Cheer","laugh","Laugh","zombie","Zombie","tpose","Tpose","default","Default","robot","Robot","twist","Twist"}
 local function sendChat(msg)
  pcall(function()
   -- 方法1: 新版TextChatService
   local TCS=game:GetService("TextChatService")
   if TCS then
    local channels=TCS:GetChannels()
    if #channels>0 then
     channels[1]:SendAsync(msg)
     return
    end
   end
  end)
  pcall(function()
   -- 方法2: 旧版DefaultChatSystem
   local RS2=game:GetService("ReplicatedStorage")
   local defaultChat=RS2:FindFirstChild("DefaultChatSystemChatEvents",true)
   if defaultChat then
    local sm=defaultChat:FindFirstChild("SayMessageRequest",true)
    if sm and sm:IsA("RemoteEvent") then
     sm:FireServer(msg,"All")
     return
    end
   end
  end)
  pcall(function()
   -- 方法3: SetCore ChatMakeSystemMessage fallback
   local StarterGui=game:GetService("StarterGui")
   StarterGui:SetCore("ChatMakeSystemMessage",{Text=msg})
  end)
  pcall(function()
   -- 方法4: 直接找Chat相关的RemoteEvent
   for _,r in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if r:IsA("RemoteEvent") then
     local rn=r.Name:lower()
     if rn:find("chat") or rn:find("say") or rn:find("message") then
      pcall(function() r:FireServer(msg) end)
     end
    end
   end
  end)
 end
 local function sayMemeLines()
  -- 魔性台词
  local lines={
   "命运你阿帕兹阿帕兹阿帕兹！",
   "配十八个币！配十八个币！",
   "8.28 复制打开抖音 小辣椒酱",
   "apt! apt! 阿帕兹！",
   "命运你配十八个币！",
   "阿帕兹阿帕兹阿帕兹！",
  }
  local idx=1
  while DanceState.E do
   task.wait(2.5)
   if not DanceState.E then break end
   sendChat(lines[idx])
   print("[整活] "..lines[idx])
   idx=idx%#lines+1
  end
 end
 local function doMemeDance()
  local ch=LP.Character if not ch then return end
  local hum=ch:FindFirstChild("Humanoid") if not hum then return end
  -- 尝试播放舞蹈动画
  local animId="rbxassetid://10895306795" -- 魔性舞蹈动画
  local anims={10895306795,507771019,507770818,484141977,484141807,6161544273}
  local idx=1
  DanceState.Conn2=RS.Stepped:Connect(function()
   if not DanceState.E then return end
   local c=LP.Character if not c then return end
   local h=c:FindFirstChild("Humanoid") if not h then return end
   local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
   -- 魔性摇摆：上下跳动+左右摇晃
   local t=os.clock()*8
   local bob=math.sin(t*2)*0.5
   local tilt=math.sin(t)*0.3
   hrp.CFrame=hrp.CFrame*CFrame.Angles(0,tilt*0.1,0)
  end)
  -- 尝试加载动画
  pcall(function()
   local hum2=hum
   local animator=hum2:FindFirstChildOfClass("Animator") or Instance.new("Animator")
   animator.Parent=hum2
   for _,id in ipairs(anims) do
    task.spawn(function()
     local anim=Instance.new("Animation")
     anim.AnimationId="rbxassetid://"..id
     local track=animator:LoadAnimation(anim)
     track.Looped=true
     track:Play()
    end)
   end
  end)
  -- 尝试触发游戏内置表情
  pcall(function()
   for _,emote in ipairs(danceEmotes) do
    task.spawn(function()
     hum:PlayEmote(emote)
    end)
   end
  end)
 end
 local MSec=MemeT:AddSection("💰  配十八个币")
 MSec:AddButton("💃  开始魔性舞蹈",function()
  if DanceState.E then print("[整活] 已经在跳了") return end
  DanceState.E=true
  local ch=LP.Character if not ch then print("[整活] 找不到角色") return end
  print("[整活] 🎵 配十八个币！阿帕兹阿帕兹！🎵")
  -- 开始跳舞
  doMemeDance()
  -- 开始说台词
  task.spawn(sayMemeLines)
  -- 重生后自动继续
  DanceState.Conn3=LP.CharacterAdded:Connect(function()
   task.wait(2)
   if DanceState.E then
    doMemeDance()
   end
  end)
 end)
 MSec:AddButton("🛑  停止舞蹈",function()
  DanceState.E=false
  if DanceState.Conn then DanceState.Conn:Disconnect() DanceState.Conn=nil end
  if DanceState.Conn2 then DanceState.Conn2:Disconnect() DanceState.Conn2=nil end
  if DanceState.Conn3 then DanceState.Conn3:Disconnect() DanceState.Conn3=nil end
  print("[整活] 停止舞蹈")
 end)
 MSec:AddButton("📢  说一句台词",function()
  local lines={
   "命运你阿帕兹阿帕兹阿帕兹！",
   "配十八个币！",
   "8.28 复制打开抖音",
   "apt! apt!",
   "阿帕兹！",
  }
  local line=lines[math.random(#lines)]
  sendChat(line)
  print("[整活] "..line)
 end)
 local Meme2=MemeT:AddSection("🎭  其他整活")
 Meme2:AddButton("😱  假装死亡",function()
  local ch=LP.Character if not ch then return end
  local hum=ch:FindFirstChild("Humanoid") if not hum then return end
  pcall(function() hum.Health=0 end)
  print("[整活] 假装死亡（仅客户端视觉）")
 end)
 Meme2:AddButton("🤸  超级跳跃",function()
  local ch=LP.Character if not ch then return end
  local hum=ch:FindFirstChild("Humanoid") if not hum then return end
  hum.JumpPower=200
  task.wait(2)
  hum.JumpPower=50
  print("[整活] 超级跳跃已触发 (2秒)")
 end)
 Meme2:AddButton("🌀  原地转圈",function()
  local ch=LP.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
  if not hrp then return end
  local t=0
  local conn
  conn=RS.Stepped:Connect(function()
   t=t+0.1
   if not hrp or not hrp.Parent then conn:Disconnect() return end
   hrp.CFrame=hrp.CFrame*CFrame.Angles(0,0.1,0)
  end)
  task.delay(3,function() conn:Disconnect() print("[整活] 转圈结束") end)
  print("[整活] 转起来了！(3秒)")
 end)
 local SetT=W:AddTab("设置","⚙")
 local CS2=SetT:AddSection("🎨 主题颜色")
 local colors={
  {Name="🔴  烈焰红",Color=Color3.fromRGB(255,80,80)},
  {Name="🟠  日落橙",Color=Color3.fromRGB(255,160,60)},
  {Name="🟡  璀璨金",Color=Color3.fromRGB(255,220,80)},
  {Name="🟢  翡翠绿",Color=Color3.fromRGB(80,255,140)},
  {Name="🔵  天空蓝",Color=Color3.fromRGB(100,200,255)},
  {Name="💎  青空色",Color=Color3.fromRGB(80,220,255)},
  {Name="🟣  梦幻紫",Color=Color3.fromRGB(180,120,255)},
 }
 for _,c in ipairs(colors) do
  CS2:AddButton(c.Name,function() W.ApplyAccent(c.Color) print("[设置] 主题颜色:"..c.Name) end)
 end
 local FXS=SetT:AddSection("✨  UI特效集")
 FXS:AddButton("🌈  彩虹边框: 关",function()
  Settings.FX.Rainbow=not Settings.FX.Rainbow
  W.ToggleRainbow(Settings.FX.Rainbow)
  print("[特效] 彩虹边框:"..(Settings.FX.Rainbow and "开" or "关"))
 end)
 FXS:AddButton("💫  流星环绕: 关",function()
  Settings.FX.Meteor=not Settings.FX.Meteor
  W.ToggleMeteor(Settings.FX.Meteor)
  print("[特效] 流星环绕:"..(Settings.FX.Meteor and "开" or "关"))
 end)
 FXS:AddButton("🌟  全部开启",function()
  Settings.FX.Rainbow=true Settings.FX.Meteor=true
  W.ToggleRainbow(true) W.ToggleMeteor(true)
  print("[特效] 全部特效已开启")
 end)
 FXS:AddButton("❌  全部关闭",function()
  Settings.FX.Rainbow=false Settings.FX.Meteor=false
  W.ToggleRainbow(false) W.ToggleMeteor(false)
  print("[特效] 全部特效已关闭")
 end)
 local BGS=SetT:AddSection("🎨  纯色背景")
 BGS:AddButton("❌  无背景",function() W.ApplyBG("",nil,1) print("[设置] 已关闭背景") end)
 local solidBgs={
  {Name="⚫  深邃黑",Color=Color3.fromRGB(10,10,15)},
  {Name="🔵  科技蓝",Color=Color3.fromRGB(15,20,40)},
  {Name="🟣  梦幻紫",Color=Color3.fromRGB(25,15,40)},
  {Name="🔴  烈焰红",Color=Color3.fromRGB(40,15,15)},
  {Name="🟢  翡翠绿",Color=Color3.fromRGB(15,35,25)},
  {Name="🟡  暗金色",Color=Color3.fromRGB(40,35,15)},
 }
 for _,bg in ipairs(solidBgs) do
  BGS:AddButton(bg.Name,function() W.ApplyBG("",bg.Color,0.4) print("[设置] 背景:"..bg.Name) end)
 end
 local BGS2=SetT:AddSection("🌈  渐变背景")
 local gradBgs={
  {Name="🌅  日落霞光",Grad={Color3.fromRGB(255,140,80),Color3.fromRGB(220,80,130),Color3.fromRGB(120,40,100)},Rot=90},
  {Name="🌊  深海蓝调",Grad={Color3.fromRGB(30,80,150),Color3.fromRGB(15,45,90),Color3.fromRGB(5,20,50)},Rot=90},
  {Name="🌌  宇宙星辰",Grad={Color3.fromRGB(50,20,100),Color3.fromRGB(25,10,55),Color3.fromRGB(8,3,20)},Rot=90},
  {Name="🌸  粉樱浪漫",Grad={Color3.fromRGB(255,180,200),Color3.fromRGB(230,130,170),Color3.fromRGB(180,90,140)},Rot=45},
  {Name="🌿  森林秘境",Grad={Color3.fromRGB(40,100,60),Color3.fromRGB(20,60,35),Color3.fromRGB(10,30,18)},Rot=90},
  {Name="🔥  烈焰燃烧",Grad={Color3.fromRGB(255,150,50),Color3.fromRGB(255,80,30),Color3.fromRGB(150,20,10)},Rot=45},
  {Name="💎  冰川极光",Grad={Color3.fromRGB(100,220,240),Color3.fromRGB(60,140,180),Color3.fromRGB(30,80,130)},Rot=90},
  {Name="🌙  午夜霓虹",Grad={Color3.fromRGB(10,10,30),Color3.fromRGB(50,20,80),Color3.fromRGB(10,10,30)},Rot=90},
  {Name="🍊  橙光暮色",Grad={Color3.fromRGB(255,200,100),Color3.fromRGB(255,120,60),Color3.fromRGB(200,60,40)},Rot=60},
  {Name="🦄  彩虹梦境",Grad={Color3.fromRGB(255,100,150),Color3.fromRGB(150,100,255),Color3.fromRGB(100,150,255)},Rot=45},
 }
 for _,bg in ipairs(gradBgs) do
  BGS2:AddButton(bg.Name,function()
   W.ApplyBG("",nil,nil,bg.Grad,bg.Rot) print("[设置] 渐变背景:"..bg.Name)
  end)
 end
 local DYInfo=SetT:AddSection("📱  抖音号")
 DYInfo:AddButton("🎵  关注 LoeTing20140224",function() print("抖音号: LoeTing20140224") end)
 DYInfo:AddButton("🎵  关注 43257824802",function() print("抖音号: 43257824802") end)
 local IT=W:AddTab("关于","ℹ")
 IT:AddButton("磊脚本 v4.0 PREMIUM",function() print("磊脚本 v4.0 尊享版") end)
 IT:AddButton("✨  PREMIUM · 尊享版",function() print("磊脚本 - 高端多功能辅助脚本") end)
 IT:AddButton("🎨  支持7种主题色",function() print("在设置页可切换主题颜色") end)
 IT:AddButton("🖼  支持自定义背景",function() print("在设置页可切换背景图") end)
 W:Show()
 print("[磊脚本] 加载完成！")
end