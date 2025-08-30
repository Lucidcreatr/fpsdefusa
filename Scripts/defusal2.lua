local Window = SXMLIB:CreateWindow({Name="SXMLIB Tools", Theme=SXMLIB.Themes.Black})
local MainSec = Window:CreateSection("Main")

MainSec:Button({
    label="Test Button",
    callback=function() print("Button clicked!") end
})

MainSec:Toggle({
    label="Test Toggle",
    callback=function(v) print("Toggle:", v) end
})

MainSec:Slider({
    label="Test Slider",
    min=0, max=100, default=50,
    callback=function(v) print("Slider:", v) end
})

MainSec:Dropdown({
    label="Test Dropdown",
    options={"A","B","C"},
    callback=function(val) print("Dropdown:", val) end
})

Window:Notify("GUI Loaded!", 3)
