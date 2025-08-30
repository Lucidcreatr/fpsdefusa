local SXMLIB = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/sxmlib/main/SXMLIB.lua"))()

local GUI = SXMLIB.new({Theme=SXMLIB.Themes.Blue})
local Win = GUI:CreateWindow({Title="Test GUI"})

local Main = Win:Section("Main Section")
Main:Button({label="Test Button", callback=function() print("Button clicked!") end})
Main:Toggle({label="Test Toggle", callback=function(v) print("Toggle:",v) end})

GUI:Notify("GUI Loaded!", 3)
