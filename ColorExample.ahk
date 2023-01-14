;SCRIPT CONTROLS
;///////////////////////////////////////////////////////////////////////////////////////////
;You can Modify this Section as you see fit for your program, these are just my "go-to" settings
#InstallKeybdHook
SendMode Input
#UseHook
#Persistent
CoordMode, Mouse, Screen
#noEnv
#singleInstance, force
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
SetWinDelay -1
SetBatchLines -1

;-------------------------------------------------------------------------------------------

;This section is used to showcase the different designs I have included as examples
;You MUST define the five varaibles shown below BEFORE your '#Include ColorGroup.ahk' command
InputBox, SkinDesign, Custom Controls, Enter Design:,, 300, 125,,,,, 1
if (SkinDesign = 1)
{
	GuiButtonTheme := HBCustomButton1()
	GuiFontColor := 0xFFFFFF
	GuiBackgroundColor := 0x3B3F44
	GuiControlColor := "53595F"
	GuiControlFontColor := "FFFFFF"
}

else if (SkinDesign = 2)
{
	GuiButtonTheme := HBCustomButton2()
	GuiFontColor := 0xFFFFFF
	GuiBackgroundColor := 0x000C33
	GuiControlColor := "001866"
	GuiControlFontColor := "FFFFFF"
}

else if (SkinDesign = 3)
{
	GuiButtonTheme := HBCustomButton3()
	GuiFontColor := 0xFFFFFF
	GuiBackgroundColor := 0xAE37AE
	GuiControlColor := "C851C8"
	GuiControlFontColor := "FFFFFF"
}

#Include Colorgroup.ahk
;///////////////////////////////////////////////////////////////////////////////////////////


;GUI Creation
;///////////////////////////////////////////////////////////////////////////////////////////
Gui, New ;Creates a new GUI
Gui, Color, %GuiBackgroundColor% ;Sets the background color of your GUI
Gui, Font, c%GuiFontColor% ; Sets the Font Color of your GUI

;These are how you will call/create each control
TestButton1    := New HButton({X: 10, Y: 5, W: 120, H: 30, V: "TestButton1", Label: "TestLabel", Text: "Test"})
TestEdit1      := New ColoredEdit({X: 145, Y: 10, W: 120, H: 20, V: "TestEdit1", Options: "", Text: "Save and Close"})
TestLV1        := New ColoredLV({X: 290, Y: 10, W: 120, H: 75, V: "TestLV1",  Options: "NoSort +Grid +ReadOnly", Label: "TestLabel", Title: "Software: 1"})
MonthCalTest1  := New ColoredMonthCal({X: 435, Y: 10, V: "MonthCal1", Label: "TestLabel", Date: "20910202"})
DateTimeTest1  := New ColoredDateTime({X: 690, Y: 10, W: 120, H:20, V: "DateTime1", Date: "20100101"})
TestDDL1       := New ColoredDDL({X: 10, Y: 210, W: 115, H: 15, V: "TestDDL1", Options: "", Label: "TestLabel", List: "Save Me!||Close|Boop|Whomp"})
TestComboBox1  := New ColoredComboBox({X: 145, Y: 210, W: 120, H: 15, V: "TestComboBox1", Options: "", Label: "TestLabel", List: "Option #1||Option #2|Option #3|Option #4|Option #5"})
TestListBox1   := New ColoredListbox({X: 290, Y: 210, W: 120, H:50, V: "TestListBox1", Options: "", Label: "TestLabel", List: "Red|Blue|Green|Black|White||"})
TestHotkey1    := New ColoredHotkey({X: 435, Y: 210, W: 120, V: "TestHotkey1", Text: "!^+L"})
TestTreeView1  := New ColoredTV({X: 690, Y: 210, W: 120, H:100, V: "TestTreeView", Label: "TestLabel", Title: "Software: 1"})

;This loop is just here to quickly fill the example TreeView
Loop, 3
{
	CurrTVItem := TV_Add("Item #" A_Index, 0)
	Loop, 5
	{
		TV_Add("Sub-Item #" A_Index, CurrTVItem)
	}
}

;These are different ways to create "LineBreaks" which are the nice divider lines you see everyone on the GUI
LineBreak({X: 0, Y: 0, W: 3000})
LineBreak({X: 0, Y: 0, H: 341})
LineBreak({X: 0, Y: 200, W: 3000})
LineBreak({X: 135, Y: 0, H: 341})
LineBreak({X: 275, Y: 0, H: 341})
LineBreak({X: 420, Y: 0, H: 341})
LineBreak({X: 675, Y: 0, H: 341})
LineBreak({X: 0, Y: 340, W: 3000})
LineBreak({X:818, Y: 0, H: 341})
Gui, Show, w820 h342 Center
Return
;///////////////////////////////////////////////////////////////////////////////////////////


;LABELS
;///////////////////////////////////////////////////////////////////////////////////////////
TestLabel:
ColoredMsgBox := New ColoredGUI({Title: "Success!", Buttons: 1, Label: "FirstMsgBox", Text: "You did it! You clicked: " A_GuiControl "`nEvent: " CurrV})
New ColoredGui() ;This is an easy way to close your custom MsgBox
Return

FirstMsgBox:
if (A_GuiControl = "OKButton")
	MsgBox, You clicked Ok!
else if (A_GuiControl = "CancelButton")
	MsgBox, You clicked Cancel!
else
	Msgbox, :(
	
New ColoredGUI() ;This is an easy way to close your custom MsgBox
Return
;///////////////////////////////////////////////////////////////////////////////////////////


;CUSTOM BUTTONS
;///////////////////////////////////////////////////////////////////////////////////////////
;These are used as part of Hellbent's image button library, read more on his post if you need to learn how to create these.
HBCustomButton1()
{
	local MyButtonDesign := {}
	MyButtonDesign.All := {}
	MyButtonDesign.Default := {}
	MyButtonDesign.Hover := {}
	MyButtonDesign.Pressed := {}
	;********************************
	;All
	MyButtonDesign.All.W := 180 , MyButtonDesign.All.H := 35 , MyButtonDesign.All.Text := "Edit Quick Links" , MyButtonDesign.All.FontSize := "11" , MyButtonDesign.All.TextOffsetY := "-1" , MyButtonDesign.All.BackgroundColor := "0xFF3b3f44" , MyButtonDesign.All.ButtonMainColor1 := "0x253C3F45" , MyButtonDesign.All.ButtonMainColor2 := "0x50202225" , MyButtonDesign.All.ButtonAddGlossy := "0"
	;********************************
	;Default
	MyButtonDesign.Default.W := 180 , MyButtonDesign.Default.H := 35 , MyButtonDesign.Default.Text := "Edit Quick Links" , MyButtonDesign.Default.Font := "Arial" , MyButtonDesign.Default.FontOptions := " Bold Center vCenter " , MyButtonDesign.Default.FontSize := "11" , MyButtonDesign.Default.H := "0x0002112F" , MyButtonDesign.Default.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Default.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Default.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Default.TextOffsetX := "0" , MyButtonDesign.Default.TextOffsetY := "-1" , MyButtonDesign.Default.TextOffsetW := "0" , MyButtonDesign.Default.TextOffsetH := "0" , MyButtonDesign.Default.BackgroundColor := "0xFF3b3f44" , MyButtonDesign.Default.ButtonOuterBorderColor := "0xFF000000" , MyButtonDesign.Default.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Default.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Default.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Default.ButtonMainColor1 := "0x253C3F45" , MyButtonDesign.Default.ButtonMainColor2 := "0x50FFFFFF" , MyButtonDesign.Default.ButtonAddGlossy := "0" , MyButtonDesign.Default.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Default.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Default.GlossBottomColor := "33000000"
	;********************************
	;Hover
	MyButtonDesign.Hover.W := 180 , MyButtonDesign.Hover.H := 35 , MyButtonDesign.Hover.Text := "Edit Quick Links" , MyButtonDesign.Hover.Font := "Arial" , MyButtonDesign.Hover.FontOptions := " Bold Center vCenter " , MyButtonDesign.Hover.FontSize := "11" , MyButtonDesign.Hover.H := "0x0002112F" , MyButtonDesign.Hover.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Hover.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextOffsetX := "0" , MyButtonDesign.Hover.TextOffsetY := "-1" , MyButtonDesign.Hover.TextOffsetW := "0" , MyButtonDesign.Hover.TextOffsetH := "0" , MyButtonDesign.Hover.BackgroundColor := "0xFF3b3f44" , MyButtonDesign.Hover.ButtonOuterBorderColor := "0xFF000000" , MyButtonDesign.Hover.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Hover.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Hover.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Hover.ButtonMainColor1 := "0x253C3F45" , MyButtonDesign.Hover.ButtonMainColor2 := "0x50202225" , MyButtonDesign.Hover.ButtonAddGlossy := "1" , MyButtonDesign.Hover.GlossTopColor := "0x5ffffff" , MyButtonDesign.Hover.GlossTopAccentColor := "05ffffff" , MyButtonDesign.Hover.GlossBottomColor := "5ffffff"
	;********************************
	;Pressed
	MyButtonDesign.Pressed.W := 180 , MyButtonDesign.Pressed.H := 35 , MyButtonDesign.Pressed.Text := "Edit Quick Links" , MyButtonDesign.Pressed.Font := "Arial" , MyButtonDesign.Pressed.FontOptions := " Bold Center vCenter " , MyButtonDesign.Pressed.FontSize := "11" , MyButtonDesign.Pressed.H := "0x0002112F" , MyButtonDesign.Pressed.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Pressed.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextOffsetX := "0" , MyButtonDesign.Pressed.TextOffsetY := "-1" , MyButtonDesign.Pressed.TextOffsetW := "0" , MyButtonDesign.Pressed.TextOffsetH := "0" , MyButtonDesign.Pressed.BackgroundColor := "0xFF3b3f44" , MyButtonDesign.Pressed.ButtonOuterBorderColor := "0xFF000000" , MyButtonDesign.Pressed.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Pressed.ButtonInnerBorderColor1 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonInnerBorderColor2 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonMainColor1 := "0x253C3F45" , MyButtonDesign.Pressed.ButtonMainColor2 := "0x50202225" , MyButtonDesign.Pressed.ButtonAddGlossy := "0" , MyButtonDesign.Pressed.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Pressed.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Pressed.GlossBottomColor := "33000000"
	;********************************
	
	return MyButtonDesign
}

HBCustomButton2()
{
	local MyButtonDesign := {}
	MyButtonDesign.All := {}
	MyButtonDesign.Default := {}
	MyButtonDesign.Hover := {}
	MyButtonDesign.Pressed := {}
	;********************************
	;All
	MyButtonDesign.All.W := 100 , MyButtonDesign.All.H := 30 , MyButtonDesign.All.Text := "Test!" , MyButtonDesign.All.FontSize := "11" , MyButtonDesign.All.TextOffsetY := "-1" , MyButtonDesign.All.BackgroundColor := "0xFF000C33" , MyButtonDesign.All.ButtonMainColor1 := "0x99001866" , MyButtonDesign.All.ButtonMainColor2 := "0x99001866" , MyButtonDesign.All.ButtonAddGlossy := "0"
	;********************************
	;Default
	MyButtonDesign.Default.W := 100 , MyButtonDesign.Default.H := 30 , MyButtonDesign.Default.Text := "Test!" , MyButtonDesign.Default.Font := "Arial" , MyButtonDesign.Default.FontOptions := " Bold Center vCenter " , MyButtonDesign.Default.FontSize := "11" , MyButtonDesign.Default.H := "0x00FFFFFF" , MyButtonDesign.Default.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Default.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Default.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Default.TextOffsetX := "0" , MyButtonDesign.Default.TextOffsetY := "-1" , MyButtonDesign.Default.TextOffsetW := "0" , MyButtonDesign.Default.TextOffsetH := "0" , MyButtonDesign.Default.BackgroundColor := "0xFF000C33" , MyButtonDesign.Default.ButtonOuterBorderColor := "0x25FFFFFF" , MyButtonDesign.Default.ButtonCenterBorderColor := "0x25FFFFFF" , MyButtonDesign.Default.ButtonInnerBorderColor1 := "0x99FFFFFF" , MyButtonDesign.Default.ButtonInnerBorderColor2 := "0x99000000" , MyButtonDesign.Default.ButtonMainColor1 := "0x99001866" , MyButtonDesign.Default.ButtonMainColor2 := "0x99001866" , MyButtonDesign.Default.ButtonAddGlossy := "0" , MyButtonDesign.Default.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Default.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Default.GlossBottomColor := "33000000"
	;********************************
	;Hover
	MyButtonDesign.Hover.W := 100 , MyButtonDesign.Hover.H := 30 , MyButtonDesign.Hover.Text := "Test!" , MyButtonDesign.Hover.Font := "Arial" , MyButtonDesign.Hover.FontOptions := " Bold Center vCenter " , MyButtonDesign.Hover.FontSize := "11" , MyButtonDesign.Hover.H := "0x00FFFFFF" , MyButtonDesign.Hover.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Hover.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextOffsetX := "0" , MyButtonDesign.Hover.TextOffsetY := "-1" , MyButtonDesign.Hover.TextOffsetW := "0" , MyButtonDesign.Hover.TextOffsetH := "0" , MyButtonDesign.Hover.BackgroundColor := "0xFF000C33" , MyButtonDesign.Hover.ButtonOuterBorderColor := "0x50FFFFFF" , MyButtonDesign.Hover.ButtonCenterBorderColor := "0x50FFFFFF" , MyButtonDesign.Hover.ButtonInnerBorderColor1 := "0x99FFFFFF" , MyButtonDesign.Hover.ButtonInnerBorderColor2 := "0x99000000" , MyButtonDesign.Hover.ButtonMainColor1 := "0x99001866" , MyButtonDesign.Hover.ButtonMainColor2 := "0x99001866" , MyButtonDesign.Hover.ButtonAddGlossy := "1" , MyButtonDesign.Hover.GlossTopColor := "0x25000000" , MyButtonDesign.Hover.GlossTopAccentColor := "5FFFFFF" , MyButtonDesign.Hover.GlossBottomColor := "25000000"
	;********************************
	;Pressed
	MyButtonDesign.Pressed.W := 100 , MyButtonDesign.Pressed.H := 30 , MyButtonDesign.Pressed.Text := "Test!" , MyButtonDesign.Pressed.Font := "Arial" , MyButtonDesign.Pressed.FontOptions := " Bold Center vCenter " , MyButtonDesign.Pressed.FontSize := "11" , MyButtonDesign.Pressed.H := "0x00FFFFFF" , MyButtonDesign.Pressed.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Pressed.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextOffsetX := "0" , MyButtonDesign.Pressed.TextOffsetY := "-1" , MyButtonDesign.Pressed.TextOffsetW := "0" , MyButtonDesign.Pressed.TextOffsetH := "0" , MyButtonDesign.Pressed.BackgroundColor := "0xFF000C33" , MyButtonDesign.Pressed.ButtonOuterBorderColor := "0x10FFFFFF" , MyButtonDesign.Pressed.ButtonCenterBorderColor := "0x10FFFFFF" , MyButtonDesign.Pressed.ButtonInnerBorderColor1 := "0x50FFFFFF" , MyButtonDesign.Pressed.ButtonInnerBorderColor2 := "0x25FFFFFF" , MyButtonDesign.Pressed.ButtonMainColor1 := "0x99001866" , MyButtonDesign.Pressed.ButtonMainColor2 := "0x99001866" , MyButtonDesign.Pressed.ButtonAddGlossy := "0" , MyButtonDesign.Pressed.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Pressed.GlossTopAccentColor := "5FFFFFF" , MyButtonDesign.Pressed.GlossBottomColor := "33000000"
	;********************************
	
	return MyButtonDesign
}

HBCustomButton3()
{
	local MyButtonDesign := {}
	MyButtonDesign.All := {}
	MyButtonDesign.Default := {}
	MyButtonDesign.Hover := {}
	MyButtonDesign.Pressed := {}
	;********************************
	;All
	MyButtonDesign.All.W := 100 , MyButtonDesign.All.H := 30 , MyButtonDesign.All.Text := "Test!" , MyButtonDesign.All.FontSize := "11" , MyButtonDesign.All.BackgroundColor := "0xFFAE37AE" , MyButtonDesign.All.ButtonMainColor1 := "0x99320132" , MyButtonDesign.All.ButtonMainColor2 := "0x99320132" , MyButtonDesign.All.ButtonAddGlossy := "1"
	;********************************
	;Default
	MyButtonDesign.Default.W := 100 , MyButtonDesign.Default.H := 30 , MyButtonDesign.Default.Text := "Test!" , MyButtonDesign.Default.Font := "Arial" , MyButtonDesign.Default.FontOptions := " Bold Center vCenter " , MyButtonDesign.Default.FontSize := "11" , MyButtonDesign.Default.H := "0x00FFFFFF" , MyButtonDesign.Default.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Default.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Default.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Default.TextOffsetX := "0" , MyButtonDesign.Default.TextOffsetY := "-1" , MyButtonDesign.Default.TextOffsetW := "0" , MyButtonDesign.Default.TextOffsetH := "0" , MyButtonDesign.Default.BackgroundColor := "0xFFAE37AE" , MyButtonDesign.Default.ButtonOuterBorderColor := "0x15FFFFFF" , MyButtonDesign.Default.ButtonCenterBorderColor := "0x15FFFFFF" , MyButtonDesign.Default.ButtonInnerBorderColor1 := "0x75000000" , MyButtonDesign.Default.ButtonInnerBorderColor2 := "0x75000000" , MyButtonDesign.Default.ButtonMainColor1 := "0x99320132" , MyButtonDesign.Default.ButtonMainColor2 := "0x99320132" , MyButtonDesign.Default.ButtonAddGlossy := "1" , MyButtonDesign.Default.GlossTopColor := "0x25000000" , MyButtonDesign.Default.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Default.GlossBottomColor := "25000000"
	;********************************
	;Hover
	MyButtonDesign.Hover.W := 100 , MyButtonDesign.Hover.H := 30 , MyButtonDesign.Hover.Text := "Test!" , MyButtonDesign.Hover.Font := "Arial" , MyButtonDesign.Hover.FontOptions := " Bold Center vCenter " , MyButtonDesign.Hover.FontSize := "11" , MyButtonDesign.Hover.H := "0x00FFFFFF" , MyButtonDesign.Hover.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Hover.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextOffsetX := "0" , MyButtonDesign.Hover.TextOffsetY := "-1" , MyButtonDesign.Hover.TextOffsetW := "0" , MyButtonDesign.Hover.TextOffsetH := "0" , MyButtonDesign.Hover.BackgroundColor := "0xFFAE37AE" , MyButtonDesign.Hover.ButtonOuterBorderColor := "0x25FFFFFF" , MyButtonDesign.Hover.ButtonCenterBorderColor := "0x25FFFFFF" , MyButtonDesign.Hover.ButtonInnerBorderColor1 := "0x99000000" , MyButtonDesign.Hover.ButtonInnerBorderColor2 := "0x99000000" , MyButtonDesign.Hover.ButtonMainColor1 := "0x99320132" , MyButtonDesign.Hover.ButtonMainColor2 := "0x99320132" , MyButtonDesign.Hover.ButtonAddGlossy := "1" , MyButtonDesign.Hover.GlossTopColor := "0x25000000" , MyButtonDesign.Hover.GlossTopAccentColor := "5FFFFFF" , MyButtonDesign.Hover.GlossBottomColor := "25000000"
	;********************************
	;Pressed
	MyButtonDesign.Pressed.W := 100 , MyButtonDesign.Pressed.H := 30 , MyButtonDesign.Pressed.Text := "Test!" , MyButtonDesign.Pressed.Font := "Arial" , MyButtonDesign.Pressed.FontOptions := " Bold Center vCenter " , MyButtonDesign.Pressed.FontSize := "11" , MyButtonDesign.Pressed.H := "0x00FFFFFF" , MyButtonDesign.Pressed.TextBottomColor2 := "0x00FFFFFF" , MyButtonDesign.Pressed.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextOffsetX := "-1" , MyButtonDesign.Pressed.TextOffsetY := "-2" , MyButtonDesign.Pressed.TextOffsetW := "0" , MyButtonDesign.Pressed.TextOffsetH := "0" , MyButtonDesign.Pressed.BackgroundColor := "0xFFAE37AE" , MyButtonDesign.Pressed.ButtonOuterBorderColor := "0x5FFFFFF" , MyButtonDesign.Pressed.ButtonCenterBorderColor := "0x5FFFFFF" , MyButtonDesign.Pressed.ButtonInnerBorderColor1 := "0x99000000" , MyButtonDesign.Pressed.ButtonInnerBorderColor2 := "0x99000000" , MyButtonDesign.Pressed.ButtonMainColor1 := "0x99320132" , MyButtonDesign.Pressed.ButtonMainColor2 := "0x99320132" , MyButtonDesign.Pressed.ButtonAddGlossy := "1" , MyButtonDesign.Pressed.GlossTopColor := "0x25000000" , MyButtonDesign.Pressed.GlossTopAccentColor := "5FFFFFF" , MyButtonDesign.Pressed.GlossBottomColor := "25000000"
	;********************************
	
	return MyButtonDesign
}

HBCustomButton4()
{
	local MyButtonDesign := {}
	MyButtonDesign.All := {}
	MyButtonDesign.Default := {}
	MyButtonDesign.Hover := {}
	MyButtonDesign.Pressed := {}
	;********************************
	;All
	MyButtonDesign.All.W := 200 , MyButtonDesign.All.H := 65 , MyButtonDesign.All.Text := " Button " , MyButtonDesign.All.BackgroundColor := "0xFF22262A"
	;********************************
	;Default
	MyButtonDesign.Default.W := 200 , MyButtonDesign.Default.H := 65 , MyButtonDesign.Default.Text := "Button" , MyButtonDesign.Default.Font := "Arial" , MyButtonDesign.Default.FontOptions := " Bold Center vCenter " , MyButtonDesign.Default.FontSize := "12" , MyButtonDesign.Default.H := "0x0002112F" , MyButtonDesign.Default.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Default.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Default.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Default.TextOffsetX := "0" , MyButtonDesign.Default.TextOffsetY := "0" , MyButtonDesign.Default.TextOffsetW := "0" , MyButtonDesign.Default.TextOffsetH := "0" , MyButtonDesign.Default.ButtonOuterBorderColor := "0xFF161B1F" , MyButtonDesign.Default.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Default.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Default.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Default.ButtonMainColor1 := "0xFF272C32" , MyButtonDesign.Default.ButtonMainColor2 := "0xFF272C32" , MyButtonDesign.Default.ButtonAddGlossy := "1" , MyButtonDesign.Default.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Default.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Default.GlossBottomColor := "33000000"
	;********************************
	;Hover
	MyButtonDesign.Hover.W := 200 , MyButtonDesign.Hover.H := 65 , MyButtonDesign.Hover.Text := "Button" , MyButtonDesign.Hover.Font := "Arial" , MyButtonDesign.Hover.FontOptions := " Bold Center vCenter " , MyButtonDesign.Hover.FontSize := "12" , MyButtonDesign.Hover.H := "0x0002112F" , MyButtonDesign.Hover.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Hover.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Hover.TextOffsetX := "0" , MyButtonDesign.Hover.TextOffsetY := "0" , MyButtonDesign.Hover.TextOffsetW := "0" , MyButtonDesign.Hover.TextOffsetH := "0" , MyButtonDesign.Hover.ButtonOuterBorderColor := "0xFF161B1F" , MyButtonDesign.Hover.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Hover.ButtonInnerBorderColor1 := "0xFF3F444A" , MyButtonDesign.Hover.ButtonInnerBorderColor2 := "0xFF24292D" , MyButtonDesign.Hover.ButtonMainColor1 := "0xFF373C42" , MyButtonDesign.Hover.ButtonMainColor2 := "0xFF373C42" , MyButtonDesign.Hover.ButtonAddGlossy := "1" , MyButtonDesign.Hover.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Hover.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Hover.GlossBottomColor := "33000000"
	;********************************
	;Pressed
	MyButtonDesign.Pressed.W := 200 , MyButtonDesign.Pressed.H := 65 , MyButtonDesign.Pressed.Text := "Button" , MyButtonDesign.Pressed.Font := "Arial" , MyButtonDesign.Pressed.FontOptions := " Bold Center vCenter " , MyButtonDesign.Pressed.FontSize := "12" , MyButtonDesign.Pressed.H := "0x0002112F" , MyButtonDesign.Pressed.TextBottomColor2 := "0x0002112F" , MyButtonDesign.Pressed.TextTopColor1 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextTopColor2 := "0xFFFFFFFF" , MyButtonDesign.Pressed.TextOffsetX := "0" , MyButtonDesign.Pressed.TextOffsetY := "0" , MyButtonDesign.Pressed.TextOffsetW := "0" , MyButtonDesign.Pressed.TextOffsetH := "0" , MyButtonDesign.Pressed.ButtonOuterBorderColor := "0xFF62666a" , MyButtonDesign.Pressed.ButtonCenterBorderColor := "0xFF262B2F" , MyButtonDesign.Pressed.ButtonInnerBorderColor1 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonInnerBorderColor2 := "0xFF151A20" , MyButtonDesign.Pressed.ButtonMainColor1 := "0xFF12161a" , MyButtonDesign.Pressed.ButtonMainColor2 := "0xFF33383E" , MyButtonDesign.Pressed.ButtonAddGlossy := "0" , MyButtonDesign.Pressed.GlossTopColor := "0x11FFFFFF" , MyButtonDesign.Pressed.GlossTopAccentColor := "05FFFFFF" , MyButtonDesign.Pressed.GlossBottomColor := "33000000"
	;********************************
	
	return MyButtonDesign
}
;///////////////////////////////////////////////////////////////////////////////////////////