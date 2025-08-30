-- Minimal Test GUI
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Kütüphaneyi yükle
local SXMLIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua"))()

-- Ana pencere
local Window = SXMLIB:CreateWindow({Name="Test GUI", Title="Test GUI", Theme=SXMLIB.Themes.Black})

-- Section ekle
local TestSec = Window:CreateSection("Main Section")

-- Toggle
TestSec:Toggle({label="Test Toggle", callback=function(v) print("Toggle:",v) end})

-- Button
TestSec:Button({label="Test Button", callback=function() print("Button clicked") end})

-- Slider
TestSec:Slider({label="Test Slider", min=0, max=100, default=50, callback=function(v) print("Slider:",v) end})

-- Dropdown
TestSec:Dropdown({label="Test Dropdown", options={"Option 1","Option 2","Option 3"}, callback=function(opt) print("Dropdown:",opt) end})

-- Bildirim
Window:Notify("GUI Loaded!",3)
