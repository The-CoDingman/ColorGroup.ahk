;CREDITS, NOTES, and OTHER GARBAGE
;///////////////////////////////////////////////////////////////////////////////////////////
; Special thank you to everyone whose code I stole and may have modified
; 	to fit my needs and goals
;
; Hellbent for their Image button library
;	https://www.autohotkey.com/boards/viewtopic.php?t=88153
;
; just me for their Class_OD_Colors, CtlColors, and Func_GUI_control_Subclass libraries
;	https://www.autohotkey.com/boards/viewtopic.php?t=338  -- Class_OD_Colors
;	https://www.autohotkey.com/boards/viewtopic.php?t=2197 -- CtlColors
;	https://www.autohotkey.com/boards/viewtopic.php?style=17&t=87318  -- Func_GUI_control_Subclass
;
; tic (Tariq Porter) for their Gdip standard library
;	https://www.autohotkey.com/boards/viewtopic.php?t=6517
;
;-------------------------------------------------------------------------------------------
;
; Work I can take credit for:
;	Compiling all these wonderful resources into one central location
;	Creating a mostly uniform way of calling all these libraries when creating your GUI
;	Testing... so much testing
;	Creation of the Custom Colored GUI class(?)
;
;-------------------------------------------------------------------------------------------
;
; Things I still need to do:
; 	Need to update each Class for if there are missing pieces
;	Need to create Class for colored Hotkey -- Code is Written Need to port it over to this document
;	Need to create Class for colored Checkbox -- Cannot seem to color the box itself
;	Need to create Class for colored Radio -- Cannot seem to color the input itself
;	Need to create Class for colored StatusBar? -- Unsure if doable yet
;	Need to create Class for colored MonthCal? -- DONE; Seems to be working, but I need to find out how to reset the UX theme
;	Need to create Class for Custom Colored GUIs -- Have not fleshed out the "Other Options" yet
;///////////////////////////////////////////////////////////////////////////////////////////
*/

Gdip_Startup()

CurrDateTimeHwnd := 000000000000
GuiFontCtlColor := LTrim(GuiFontColor, "0x")
GuiBackgroundCtlColor := LTrim(GuiBackgroundColor, "0x")
GuiControlDDLColor := "0x" GuiControlColor
GuiControlDDLFontColor := "0x" GuiControlFontColor

WM_LBUTTONUP = 0x202
OnMessage( WM_LBUTTONUP, "HandleMessage" )

WM_MOVING = 0x216
OnMessage( WM_MOVING, "HandleMessage" )

WM_NCPAINT = 0x133
OnMessage( WM_NCPAINT, "Focus_ColoredHotkey")

WM_ACTIVATE = 0x06
OnMessage( WM_ACTIVATE, "HotkeyCtrlEvent")  ; WM_ACTIVATE = 0x06

GLOBAL GUI_Color_FontControl := GuiControlFontColor, GUI_Color_BGControl := GuiControlColor
GuiButtonType1.SetSessionDefaults(GuiButtonTheme.All, GuiButtonTheme.Default, GuiButtonTheme.Hover, GuiButtonTheme.Pressed)

Gui +LastFound
hWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage(MsgNum, "ShellMessage")


;Tests
;///////////////////////////////////////////////////////////////////////////////////////////
/*


*/
;///////////////////////////////////////////////////////////////////////////////////////////


;ShellMessage Controls
;///////////////////////////////////////////////////////////////////////////////////////////
ShellMessage(wParam,lParam)
{
	global MonitorCount
	global EyeSaverRunning
	global EyeSaverMonitorIDArray
	global IsCustomColoredMonthCal_Visible
	
	if (EyeSaverRunning = 1)
	{
		Loop, %MonitorCount%
		{
			CurrMonitorID := EyeSaverMonitorIDArray[A_Index]
			WinSet, AlwaysOnTop, On, ahk_id %CurrMonitorID%
		}
	}
	
	if (wParam = 6) || (wParam = 32772) || (wParam = 4) ;HSHELL_WINDOWCREATED := 1
	{
		WinGetTitle, ActiveWindow, A
		if (ActiveWindow != A_ScriptName)
		{		
			if (IsCustomColoredMonthCal_Visible = 1)
			{
				IsCustomColoredMonthCal_Visible := 0
				Gui, CustomColoredMonthCal:Destroy
				Return
			}
		}
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////



;Custom Linebreak
;///////////////////////////////////////////////////////////////////////////////////////////////////////
LineBreak( Input ) {
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := "", CurrX := ""
		else
			CurrX := "x" Input.X
			
		if Options not contains YPos
			Input.Y := "", CurrY := ""
		else
			CurrY := "y" Input.Y
			
		if Options not contains WPos
			Input.W := "w" 2, CurrW := "w" 2
		else
			CurrW := "w" Input.W
			
		if Options not contains HPos
			Input.H := "h" 2, CurrH := "h" 2
		else
			CurrH := "h" Input.H
	
	Gui, % CurrOwner "Add", Text, % CurrX " " CurrY " " CurrW " " CurrH " " +0x1000
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;Colored GUI Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredGUI {
	;Colored GUI Class using a script from <name>
	static init , ColGUI := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd
		This._CreateNewColGUIObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewColGUIObject( hwnd , Input ) {
		local k , v  
		ColoredGUI.ColGUI[ hwnd ] := {}
		for k , v in Input
			ColoredGUI.ColGUI[ hwnd ][ k ] := v
		ColoredGUI.ColGUI[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrMsgBoxOwner, CurrMsgBoxDialogs,  CurrMsgBoxButtons, CurrMsgBoxIcon, CurrMsgBoxDefaultButton, CurrMsgBoxModality, CurrMsgBoxOther, CurrMsgBoxTitle, CurrMsgBoxText
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}

		if (Options = "")
		{	
			Gui, % "CustomColoredMsgBox:Destroy"
			if (CurrMsgBoxDialogs = 1)
				Try
					Gui, % CurrMsgBoxOwner "-Disabled"
			Pause, Off
			Return
		}
		
		;---------------------------------------------------------------------------------------------------------------
		;Defining Local Variables more precisely
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrMsgBoxOwner := Input.Owner ":"
			
		if Options not contains OwnDialogs
			Input.OwnDialogs := 0, CurrMsgBoxDialogs := 0
		else
		{
			if (Input.OwnDialogs != 1)
			{
				Input.OwnDialogs := 0
			}
			CurrMsgBoxDialogs := Input.OwnDialogs
		}
		
		if Options not contains Buttons
			Input.Buttons := 0, CurrMsgBoxButtons := 0
		else
		{
			if (Input.Buttons != 1) && (Input.Buttons != 2) && (Input.Buttons != 3) && (Input.Buttons != 4) && (Input.Buttons != 5) && (Input.Buttons != 6)
			{
				Input.Buttons := 0
			}
			CurrMsgBoxButtons := Input.Buttons
		}
			
		if Options not contains Icon
			Input.Icon := 0, CurrMsgBoxIcon := 0
		else
		{
			if (Input.Icon != 16) && (Input.Icon != 32) && (Input.Icon != 48) && (Input.Icon != 64)
			{
				Input.Icon := 0
			}
			CurrMsgBoxIcon := Input.Icon
		}
			
		if Options not contains DefaultButton
			Input.DefaultButton := 0, CurrMsgBoxDefaultButton := 0
		else
		{
			if (Input.DefaultButton != 256) && (Input.DefaultButton != 512) && (Input.DefaultButton != 768)
			{
				Input.DefaultButton := 0
			}
			CurrMsgBoxDefaultButton := Input.DefaultButton
		}
			
		if Options not contains Modality
			Input.Modality := 0, CurrMsgBoxModality := 0
		else
		{
			if (Input.Modality != 4096) && (Input.Modality != 8192) && (Input.Modality != 262144)
			{
				Input.Modality := 0
			}
			CurrMsgBoxModality := Input.Modality
		}
		
		if Options not contains Other
			Input.Other := 0, CurrMsgBoxOther := 0
		else
		{
			if (Input.Other != 16384) && (Input.Other != 524288) && (Input.Other != 1048576)
			{
				Input.Other := 0
			}
			CurrMsgBoxOther := Input.Other
		}
		
		if Options not contains Label
			Input.Label := "CustomColoredMsgBoxDefaultLabel", CurrMsgBoxLabel := "CustomColoredMsgBoxDefaultLabel"
		else
			CurrMsgBoxLabel := Input.Label
			
		if Options not contains Title
			Input.Title := "", CurrMsgBoxTitle := ""
		else
			CurrMsgBoxTitle := Input.Title
			
		if Options not contains Text
			Input.Text := "", CurrMsgBoxText := ""
		else
			CurrMsgBoxText := Input.Text
		
		;---------------------------------------------------------------------------------------------------------------
		Pause, Off
		Gui, % "CustomColoredMsgBox:New"
		Gui, % "CustomColoredMsgBox:Color", % GuiBackgroundColor
		Gui, % "CustomColoredMsgBox:Font", % "c" GuiFontColor
		
		;---------------------------------------------------------------------------------------------------------------
		;OwnDialogs controls
		if (CurrMsgBoxDialogs = 1)
		{
			Try
				Gui, % "CustomColoredMsgBox:+Owner" CurrMsgBoxOwner
			Try
				Gui, % CurrMsgBoxOwner "+Disabled"
		}
		
		;---------------------------------------------------------------------------------------------------------------
		;Modality controls
		if (Input.Modality = 4096) || (Input.Modality = 262144)
		{
			Gui, % "CustomColoredMsgBox:+AlwaysOnTop"
		}
		
		;---------------------------------------------------------------------------------------------------------------
		;Icon controls
		if (Input.Icon = 16)
		{
			Gui, % "CustomColoredMsgBox:Add", Picture, % "xm ym+4 w45 h45 icon4", %A_WinDir%\system32\user32.dll
			Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm+50 ym+5", % CurrMsgBoxText
		}
		else if (Input.Icon = 32)
		{
			Gui, % "CustomColoredMsgBox:Add", Picture, % "xm ym+4 w45 h45 icon3", %A_WinDir%\system32\user32.dll
			Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm+50 ym+5", % CurrMsgBoxText
		}
		else if (Input.Icon = 48)
		{
			Gui, % "CustomColoredMsgBox:Add", Picture, % "xm ym+4 w45 h45 icon2", %A_WinDir%\system32\user32.dll		
			Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm+50 ym+5", % CurrMsgBoxText
		}
		else if (Input.Icon = 64)
		{
			Gui, % "CustomColoredMsgBox:Add", Picture, % "xm ym+4 w45 h45 icon5", %A_WinDir%\system32\user32.dll
			Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm+50 ym+5", % CurrMsgBoxText
		}
		else
		{
			Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm ym+5", % CurrMsgBoxText
		}	
		
		Gui, % "CustomColoredMsgBox:Add", % "Text", % "xm ym vHiddenMsgBoxTitle", % CurrMsgBoxTitle A_Tab A_Tab A_Tab A_Tab A_Tab
		Gui, % "CustomColoredMsgBox:Show", % "AutoSize", % CurrMsgBoxTitle
		GuiControl, % "CustomColoredMsgBox:Hide", % "HiddenMsgBoxTitle"
		WinGet, CurrMsgBoxID, ID, A
		WinGetPos, CurrMsgBoxX, CurrY, CurrMsgBoxWidth, CurrMsgBoxHeight, A
		if (CurrMsgBoxHeight < 99)
			CurrMsgBoxHeight = 99
		NewMsgBoxHeight := CurrMsgBoxHeight + 45
		ButtonMsgBoxHeight := CurrMsgBoxHeight - 21
		
		;---------------------------------------------------------------------------------------------------------------
		;Button Controls
		if (CurrMsgBoxButtons = 0)
		{
			if (CurrMsgBoxWidth < 120)
				CurrMsgBoxWidth := 120
			OkButtonWidth := CurrMsgBoxWidth - 115
			OKButton := New HButton({Owner: "CustomColoredMsgBox", X: OkButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "OKButton", Text: "OK", Label: "CustomColoredMsgBoxLabel"})		
		}
		else if (CurrMsgBoxButtons = 1)
		{
			if (CurrMsgBoxWidth < 230)
				CurrMsgBoxWidth := 230
			OkButtonWidth     := CurrMsgBoxWidth - 220
			CancelButtonWidth := CurrMsgBoxWidth - 110
			
			OKButton     := New HButton({Owner: "CustomColoredMsgBox", X: OkButtonWidth,     Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "OKButton",     Text: "OK",     Label: "CustomColoredMsgBoxLabel"})		
			CancelButton := New HButton({Owner: "CustomColoredMsgBox", X: CancelButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "CancelButton", Text: "Cancel", Label: "CustomColoredMsgBoxLabel"})		
		}
		else if (CurrMsgBoxButtons = 2)
		{
			if (CurrMsgBoxWidth < 340)
				CurrMsgBoxWidth := 340
			AbortButtonWidth  := CurrMsgBoxWidth - 330
			RetryButtonWidth  := CurrMsgBoxWidth - 220
			IgnoreButtonWidth := CurrMsgBoxWidth - 110
			
			AbortButton  := New HButton({Owner: "CustomColoredMsgBox", X: AbortButtonWidth,  Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "AbortButton",  Text: "Abort",  Label: "CustomColoredMsgBoxLabel"})		
			RetryButton  := New HButton({Owner: "CustomColoredMsgBox", X: RetryButtonWidth,  Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "RetryButton",  Text: "Retry",  Label: "CustomColoredMsgBoxLabel"})		
			IgnoreButton := New HButton({Owner: "CustomColoredMsgBox", X: IgnoreButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "IgnoreButton", Text: "Ignore", Label: "CustomColoredMsgBoxLabel"})		
		}
		else if (CurrMsgBoxuttons = 3)
		{			
			if (CurrMsgBoxWidth < 340)
				CurrMsgBoxWidth := 340
			YesButtonWidth    := CurrMsgBoxWidth - 330
			NoButtonWidth     := CurrMsgBoxWidth - 220
			CancelButtonWidth := CurrMsgBoxWidth - 110
			
			YesButton    := New HButton({Owner: "CustomColoredMsgBox", X: YesButtonWidth,    Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "YesButton",    Text: "Yes",    Label: "CustomColoredMsgBoxLabel"})		
			NoButton     := New HButton({Owner: "CustomColoredMsgBox", X: NoButtonWidth,     Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "NoButton",     Text: "No",     Label: "CustomColoredMsgBoxLabel"})		
			CancelButton := New HButton({Owner: "CustomColoredMsgBox", X: CancelButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "CancelButton", Text: "Cancel", Label: "CustomColoredMsgBoxLabel"})		
		}
		else if (CurrMsgBoxButtons = 4)
		{
			if (CurrMsgBoxWidth < 230)
				CurrMsgBoxWidth := 230
			YesButtonWidth := CurrMsgBoxWidth - 220
			NoButtonWidth  := CurrMsgBoxWidth - 110
			
			YesButton     := New HButton({Owner: "CustomColoredMsgBox", X: YesButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "YesButton", Text: "Yes", Label: "CustomColoredMsgBoxLabel"})		
			NoButton      := New HButton({Owner: "CustomColoredMsgBox", X: NoButtonWidth,  Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "NoButton",  Text: "No",  Label: "CustomColoredMsgBoxLabel"})	
		}
		else if (CurrMsgBoxButtons = 5)
		{
			if (CurrMsgBoxWidth < 230)
				CurrMsgBoxWidth := 230
			RetryButtonWidth  := CurrMsgBoxWidth - 220
			CancelButtonWidth := CurrMsgBoxWidth - 110
			
			RetryButton     := New HButton({Owner: "CustomColoredMsgBox", X: RetryButtonWidth,  Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "RetryButton",  Text: "Retry",  Label: "CustomColoredMsgBoxLabel"})		
			CancelButton    := New HButton({Owner: "CustomColoredMsgBox", X: CancelButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "CancelButton", Text: "Cancel", Label: "CustomColoredMsgBoxLabel"})		
		}
		else if (CurrMsgBoxButtons = 6)
		{
			if (CurrMsgBoxWidth < 340)
				CurrMsgBoxWidth := 340
			CancelButtonWidth   := CurrMsgBoxWidth - 330
			TryAgainButtonWidth := CurrMsgBoxWidth - 220
			ContinueButtonWidth := CurrMsgBoxWidth - 110
			
			CancelButton   := New HButton({Owner: "CustomColoredMsgBox", X: CancelButtonWidth,   Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "CancelButton",   Text: "Cancel",    Label: "CustomColoredMsgBoxLabel"})		
			TryAgainButton := New HButton({Owner: "CustomColoredMsgBox", X: TryAgainButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "TryAgainButton", Text: "Try Again", Label: "CustomColoredMsgBoxLabel"})		
			ContinueButton := New HButton({Owner: "CustomColoredMsgBox", X: ContinueButtonWidth, Y: ButtonMsgBoxHeight, W: 100, H: 30, V: "ContinueButton", Text: "Continue",  Label: "CustomColoredMsgBoxLabel"})		
		}
		
		;---------------------------------------------------------------------------------------------------------------
		;Default Button Option
		if (CurrMsgBoxDefaultButton = 0)
		{
			if (CurrMsgBoxButtons = 1)
				GuiControl, CustomColoredMsgBox:Focus, OKButton
			else if (CurrMsgBoxButtons = 2)
				GuiControl, CustomColoredMsgBox:Focus, AbortButton
			else if (CurrMsgBoxButtons = 3)
				GuiControl, CustomColoredMsgBox:Focus, YesButton
			else if (CurrMsgBoxButtons = 4)
				GuiControl, CustomColoredMsgBox:Focus, YesButton
			else if (CurrMsgBoxButtons = 5)
				GuiControl, CustomColoredMsgBox:Focus, RetryButton
			else if (CurrMsgBoxButtons = 6)
				GuiControl, CustomColoredMsgBox:Focus, CancelButton
		}
		else if (CurrMsgBoxDefaultButton = 256)
		{
			if (CurrMsgBoxButtons = 1)
				GuiControl, CustomColoredMsgBox:Focus, CancelButton
			else if (CurrMsgBoxButtons = 2)
				GuiControl, CustomColoredMsgBox:Focus, RetryButton
			else if (CurrMsgBoxButtons = 3)
				GuiControl, CustomColoredMsgBox:Focus, NoButton
			else if (CurrMsgBoxButtons = 4)
				GuiControl, CustomColoredMsgBox:Focus, NoButton
			else if (CurrMsgBoxButtons = 5)
				GuiControl, CustomColoredMsgBox:Focus, CancelButton
			else if (CurrMsgBoxButtons = 6)
				GuiControl, CustomColoredMsgBox:Focus, TryAgainButton			
		}
		else if (CurrMsgBoxDefaultButton = 512)
		{
			if (CurrMsgBoxButtons = 1)
				GuiControl, CustomColoredMsgBox:Focus, OKButton
			else if (CurrMsgBoxButtons = 2)
				GuiControl, CustomColoredMsgBox:Focus, IgnoreButton
			else if (CurrMsgBoxButtons = 3)
				GuiControl, CustomColoredMsgBox:Focus, CancelButton
			else if (CurrMsgBoxButtons = 4)
				GuiControl, CustomColoredMsgBox:Focus, YesButton
			else if (CurrMsgBoxButtons = 5)
				GuiControl, CustomColoredMsgBox:Focus, RetryButton
			else if (CurrMsgBoxButtons = 6)
				GuiControl, CustomColoredMsgBox:Focus, ContinueButton
		}
		
		GroupboxYPos := CurrMsgBoxHeight - 35
		GroupboxWidth := CurrMsgBoxWidth - 4
		GroupboxHeight := NewMsgBoxHeight - 20
		GroupboxWidth2 := CurrMsgBoxWidth - 6
		GroupboxHeight2 := NewMsgBoxHeight - 21
		Gui, % "CustomColoredMsgBox:Add", % "Groupbox", % "x0  y-8 w" GroupboxWidth2 " h" GroupboxHeight2,
		Gui, % "CustomColoredMsgBox:Add", % "Groupbox", % "x-1 y-8 w" GroupboxWidth " h" GroupboxHeight,
		Gui, % "CustomColoredMsgBox:Add", % "Groupbox", % "x-2 y" GroupboxYPos " w" CurrMsgBoxWidth " h100",
		WinMove, A,, CurrMsgBoxX, CurrMsgBoxY, CurrMsgBoxWidth, NewMsgBoxHeight
		Pause, On
	}
}

	
	CustomColoredMsgBoxLabel(){
		global CurrMsgBoxLabel
		MsgBoxEvent := A_GuiControl
		if (CurrMsgBoxLabel = "CustomColoredMsgBoxDefaultLabel")
		{
			CustomColoredMsgBoxDefaultLabel()
			Return
		}
		else
			goSub, %CurrMsgBoxLabel%
		Return
	}
	
	CustomColoredMsgBoxClose(){
		global CurrMsgBoxLabel
		MsgBoxEvent := "Close"
		if (CurrMsgBoxLabel = "CustomColoredMsgBoxDefaultLabel")
		{
			CustomColoredMsgBoxDefaultLabel()
			Return
		}
		else
			goSub, %CurrMsgBoxLabel%
		Return
	}
	
	CustomColoredMsgBoxGuiClose(){
		global CurrMsgBoxLabel
		MsgBoxEvent := "GuiClose"
		if (CurrMsgBoxLabel = "CustomColoredMsgBoxDefaultLabel")
		{
			CustomColoredMsgBoxDefaultLabel()
			Return
		}
		else
			goSub, %CurrMsgBoxLabel%
		Return
	}
	
	CustomColoredMsgBoxGuiEscape(){
		global CurrMsgBoxLabel
		MsgBoxEvent := "GuiEscape"
		if (CurrMsgBoxLabel = "CustomColoredMsgBoxDefaultLabel")
		{
			CustomColoredMsgBoxDefaultLabel()
			Return
		}
		else
			goSub, %CurrMsgBoxLabel%
		Return
	}
	
	CustomColoredMsgBoxDefaultLabel(){
		global CurrMsgBoxOwner
		Gui, % "CustomColoredMsgBox:Destroy"
		if (CurrMsgBoxDialogs = 1)
			Try
				Gui, % CurrMsgBoxOwner "-Disabled"
		Pause, Off
		Return
	}

;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredMonthCal Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredMonthCal {
	;Colored MonthCal Class using a script from <name>
	static init , MonthCal := [] , Active , LastControl , HoldCtrl
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewMonthCalObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewMonthCalObject( hwnd , Input ) {
		local k , v  
		ColoredMonthCal.MonthCal[ hwnd ] := {}
		for k , v in Input
			ColoredMonthCal.MonthCal[ hwnd ][ k ] := v
		ColoredMonthCal.MonthCal[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains V
			Input.V := "", CurrV := "", CurrMonthCalHwnd := "hwnd"
		else
			CurrV := "v" Input.V, CurrMonthCalHwnd := Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Date
			Input.Date := "", CurrDate := ""
		else
			CurrDate := Input.Date
			
		LVColorArray := StrSplit(GuiControlColor)
		CurrLVColor := "0x" LVColorArray[5] LVColorArray[6] LVColorArray[3] LVColorArray[4] LVColorArray[1] LVColorArray[2]
		
		BackgroundColorArray := StrSplit(GuiBackgroundColor)
		CurrBackgroundColor := BackgroundColorArray[1] BackgroundColorArray[2] BackgroundColorArray[7] BackgroundColorArray[8] BackgroundColorArray[5] BackgroundColorArray[6] BackgroundColorArray[3] BackgroundColorArray[4]
		
		GuiFontColorArray := StrSplit(GuiFontColor)
		CurrGuiFontColor := GuiFontColorArray[1] GuiFontColorArray[2] GuiFontColorArray[7] GuiFontColorArray[8] GuiFontColorArray[5] GuiFontColorArray[6] GuiFontColorArray[3] GuiFontColorArray[4]

		Gui, % CurrOwner "Color", % GuiBackgroundColor
		Gui, % CurrOwner "Font", % "c" GuiFontColor
		
		Gui, % "+LastFound"
		Gui, % CurrOwner "Add", % "MonthCal", % "x" CurrX " y" CurrY " " CurrV " " CurrLabel " Hwndh" CurrMonthCalHwnd, % CurrDate
		GuiControl, % CurrOwner "Focus", % CurrMonthCalHwnd
		GuiControlGet, FinalFocus, % CurrOwner "Focus"
		DllCall("uxtheme\SetWindowTheme", "Ptr", h%CurrMonthCalHwnd%, "Ptr", 0, "UintP", 0)
		
		SendMessage, 0x100A, 0, %CurrLVColor%,          %FinalFocus% ;MCM_SETCOLOR   = 0x100A, MCSC_BACKGROUND   = 0, BGR = 0xFF0000 (Blue)
		SendMessage, 0x100A, 1, %CurrGuiFontColor%, %FinalFocus% ;MCM_SETCOLOR   = 0x100A, MCSC_TEXT         = 1, BGR = 0xFF00FF (Fuchsia)
		SendMessage, 0x100A, 2, %CurrLVColor%,          %FinalFocus% ;MCM_SETCOLOR   = 0x100A, MCSC_TITLEBK      = 2, BGR = 0x0000FF (Red)
		SendMessage, 0x100A, 3, %CurrGuiFontColor%, %FinalFocus% ;MCM_SETCOLOR   = 0x100A, MCSC_TITLETEXT    = 3, BGR = 0xFFFFFF (White)
		SendMessage, 0x100A, 4, %CurrLVColor%,          %FinalFocus% ;MCM_SETCOLOR   = 0x100A, MCSC_MONTHBK      = 4, BGR = 0x00FFFF (Yellow)
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredDateTime Class -- There are some limitations with this Class: You can only have one per GUI and the Gui has to have a title (ie: Gui, 1:Show)
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredDateTime {
	;Colored DateTime Class using a script from <name>
	static init , DateTime := [] , Active , LastControl , HoldCtrl
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewDateTimeObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewDateTimeObject( hwnd , Input ) {
		local k , v  
		ColoredDateTime.DateTime[ hwnd ] := {}
		for k , v in Input
			ColoredDateTime.DateTime[ hwnd ][ k ] := v
		ColoredDateTime.DateTime[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		
		if Options not contains Owner
			Input.Owner := "", CurrOwner := "", DateTimeOwner := ""
		else
			CurrOwner := Input.Owner ":", DateTimeOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 20, CurrH := 20
		else
			CurrH := Input.H
			
		if Options not contains V
			Input.V := "", CurrV := "", CurrDateTimeHwnd := "hwnd"
		else
			CurrV := "v" Input.V, CurrDateTimeHwnd := Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Date = 
			Input.Date := A_YYYY A_MM A_DD, CurrDate := A_YYYY A_MM A_DD
		else
			CurrDate := Input.Date
		
		CurrDateArray := StrSplit(CurrDate)
		CurrDate := CurrDateArray[5] CurrDateArray[6] "/" CurrDateArray[7] CurrDateArray[8] "/" CurrDateArray[1] CurrDateArray[2] CurrDateArray[3] CurrDateArray[4]
				
		LVColorArray := StrSplit(GuiControlColor)
		CurrLVColor := "0x" LVColorArray[5] LVColorArray[6] LVColorArray[3] LVColorArray[4] LVColorArray[1] LVColorArray[2]
		
		BackgroundColorArray := StrSplit(GuiBackgroundColor)
		CurrBackgroundColor := BackgroundColorArray[1] BackgroundColorArray[2] BackgroundColorArray[7] BackgroundColorArray[8] BackgroundColorArray[5] BackgroundColorArray[6] BackgroundColorArray[3] BackgroundColorArray[4]
	
		GuiFontColorArray := StrSplit(GuiFontColor)
		CurrGuiFontColor := GuiFontColorArray[1] GuiFontColorArray[2] GuiFontColorArray[7] GuiFontColorArray[8] GuiFontColorArray[5] GuiFontColorArray[6] GuiFontColorArray[3] GuiFontColorArray[4]
		
		Gui, % CurrOwner "Color", % GuiBackgroundColor
		Gui, % CurrOwner "Font", % "c" GuiFontColor
		Gui, % CurrOwner "Add", % "Edit", % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " ReadOnly +hwndh" CurrDateTimeHwnd, % CurrDate
		CtlColors.Attach(h%CurrDateTimeHwnd%, GuiControlColor, GuiControlFontColor)
		GuiControl, % CurrOwner "Focus", % "h" CurrDateTimeHwnd
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}

	
UpdateColoredDateTime() {
	global  DateTimeGuiName
	global  CurrDateTimeHwnd
	global  CustomColoredMonthCal
	global  IsCustomColoredMonthCal_Visible
	
	static  CurrMonthCalDate
	static  PrevMonthCalDate1
	static  PrevMonthCalDate2
	static  PrevMonthCalDate3
	static  FinalMonthCalDate
	
	GuiControlGet, CurrMonthCalDate, CustomColoredMonthCal:, CustomColoredMonthCal
	CurrMonthCalDateArray := StrSplit(CurrMonthCalDate)
	CurrMonthCalDate := CurrMonthCalDateArray[5] CurrMonthCalDateArray[6] "/" CurrMonthCalDateArray[7] CurrMonthCalDateArray[8] "/" CurrMonthCalDateArray[1] CurrMonthCalDateArray[2] CurrMonthCalDateArray[3] CurrMonthCalDateArray[4]
	if (CurrMonthCalDate = FinalMonthCalDate)
	{
		IsCustomColoredMonthCal_Visible := 0
		Gui, CustomColoredMonthCal:Destroy
		Gui, %DateTimeGuiName%:Default
		GuiControl, % "Text", %CurrDateTimeHwnd%, %CurrMonthCalDate%
		CurrMonthCalDate  := ""
		PrevMonthCalDate1 := ""
		PrevMonthCalDate2 := ""
		PrevMonthCalDate3 := ""
		FinalMonthCalDate := ""
	}
	
	if (PrevMonthCalDate1 != CurrMonthCalDate)
	{
		PrevMonthCalDate1 := CurrMonthCalDate
	}
	else if (PrevMonthCalDate1 = CurrMonthCalDate)
	{
		if (PrevMonthCalDate2 != PrevMonthCalDate1)
		{
			PrevMonthCalDate2 := PrevMonthCalDate1
		}
		else if (PrevMonthCalDate2 = PrevMonthCalDate1)
		{
			if (PrevMonthCalDate3 != PrevMonthCalDate2)
			{
				PrevMonthCalDate3 := PrevMonthCalDate2
			}
			else if (PrevMonthCalDate3 = PrevMonthCalDate2)
			{
				if (FinalMonthCalDate != PrevMonthCalDate3)
				{
					FinalMonthCalDate := PrevMonthCalDate3
					CurrMonthCalDate  := ""
					PrevMonthCalDate1 := ""
					PrevMonthCalDate2 := ""
					PrevMonthCalDate3 := ""
				}
			}
		}
	}
}

HandleMessage( p_w, p_l, p_m, p_hw ) {
    global  WM_MOVING
	global	WM_LBUTTONUP
	global  WM_LBUTTONDOWN
	global  CurrLVColor
	global  DateTimeOwner
	global  DateTimeGuiName
	global  CurrGuiFontColor
	global  CurrDateTimeHwnd
	global  CustomColoredMonthCal
	global	IsCustomColoredMonthCal_Visible
	
	if ( p_m = WM_MOVING )
	{
		if (IsCustomColoredMonthCal_Visible = 1)
		{
			IsCustomColoredMonthCal_Visible := 0
			Gui, CustomColoredMonthCal:Destroy
			Return
		}
	}
	
	else if ( p_m = WM_LBUTTONUP )
	{
		if (IsCustomColoredMonthCal_Visible = 1)
		{
			if (A_GuiControl != "CustomColoredMonthCal") && (A_GuiControl != CurrDateTimeHwnd)
			{
				IsCustomColoredMonthCal_Visible := 0
				Gui, CustomColoredMonthCal:Destroy
				Return
			}
			else
				Gui, CustomColoredMonthCal:Show
		}
		
		if ( A_GuiControl = CurrDateTimeHwnd )
		{	
			DateTimeGuiName := A_Gui
			if (IsCustomColoredMonthCal_Visible != 1)
			{
				IsCustomColoredMonthCal_Visible := 1
				WinGetPos, CurrMonthCalWindowX, CurrMonthCalWindowY,,, A
				GuiControlGet, CurrMonthCalEditPos, % DateTimeOwner "Pos", DateTime1
				GuiControlGet, CurrMonthCalEditDate1, % DateTimeOwner, DateTime1
				CurrMonthCalEditDateArray := StrSplit(CurrMonthCalEditDate1)
				CurrMonthCalEditDate := CurrMonthCalEditDateArray[7] CurrMonthCalEditDateArray[8] CurrMonthCalEditDateArray[9] CurrMonthCalEditDateArray[10] CurrMonthCalEditDateArray[1] CurrMonthCalEditDateArray[2] CurrMonthCalEditDateArray[4] CurrMonthCalEditDateArray[5]
				FinalMonthCalEditPosX := CurrMonthCalEditPosX + CurrMonthCalWindowX + 5
				FinalMonthCalEditPosY := CurrMonthCalEditPosY + CurrMonthCalWindowY + 20 + 27
				
				TempDateTimeOwner := RTrim(DateTimeGuiName, ":")
				Gui, CustomColoredMonthCal:New
				Gui, CustomColoredMonthCal:+AlwaysOnTop -Caption +Owner%TempDateTimeOwner%
				Gui, CustomColoredMonthCal:Color, %GuiBackgroundColor%
				Gui, CustomColoredMonthCal:Font, c%GuiFontColor%
				Gui, CustomColoredMonthCal:Margin, 0, 0
				Gui, +LastFound
				Gui, CustomColoredMonthCal:Add, MonthCal, x0 y0 vCustomColoredMonthCal HwndhCustomColoredMonthCal AltSubmit gUpdateColoredDateTime, %CurrMonthCalEditDate%
				
				UpdatedMonthCalHwnd := "MonthCal" CurrDateTimeHwnd "1"
				GuiControl, CustomColoredMonthCal:Focus, CustomColoredMonthCal
				GuiControlGet, CustomColoredMonthCalHwnd, CustomColoredMonthCal:Focus
					
				DllCall("uxtheme\SetWindowTheme", "Ptr", hCustomColoredMonthCal, "Ptr", 0, "UintP", 0)
				SendMessage, 0x100A, 0, %CurrLVColor%,          %CustomColoredMonthCalHwnd% ;MCM_SETCOLOR   = 0x100A, MCSC_BACKGROUND   = 0, BGR = 0xFF0000 (Blue)
				SendMessage, 0x100A, 1, %CurrGuiFontColor%, %CustomColoredMonthCalHwnd%     ;MCM_SETCOLOR   = 0x100A, MCSC_TEXT         = 1, BGR = 0xFF00FF (Fuchsia)
				SendMessage, 0x100A, 2, %CurrLVColor%,          %CustomColoredMonthCalHwnd% ;MCM_SETCOLOR   = 0x100A, MCSC_TITLEBK      = 2, BGR = 0x0000FF (Red)
				SendMessage, 0x100A, 3, %CurrGuiFontColor%, %CustomColoredMonthCalHwnd%     ;MCM_SETCOLOR   = 0x100A, MCSC_TITLETEXT    = 3, BGR = 0xFFFFFF (White)
				SendMessage, 0x100A, 4, %CurrLVColor%,          %CustomColoredMonthCalHwnd% ;MCM_SETCOLOR   = 0x100A, MCSC_MONTHBK      = 4, BGR = 0x00FFFF (Yellow)	
			
				Gui, CustomColoredMonthCal:Show, x%FinalMonthCalEditPosX% y%FinalMonthCalEditPosY% AutoSize
				GuiControl, CustomColoredMonthCal:Focus, CustomColoredMonthCal

			}
		}
	}
	
	else
		Tooltip
	
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredEdit Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredEdit {
	;Colored Edit Class using a script from <name>
	static init , Edit := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewEditObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewEditObject( hwnd , Input ) {
		local k , v  
		ColoredEdit.Edit[ hwnd ] := {}
		for k , v in Input
			ColoredEdit.Edit[ hwnd ][ k ] := v
		ColoredEdit.Edit[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 20, CurrH := 20
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains Text
			Input.Text := "", CurrText := ""
		else
			CurrText := Input.Text
		
		Gui, % CurrOwner "Color", % GuiBackgroundColor
		Gui, % CurrOwner "Font", % "c" GuiFontColor
		Gui, % CurrOwner "Add", Edit, % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " " CurrLabel " " CurrOptions " hwndhwnd", % CurrText
		CtlColors.Attach(hwnd, GuiControlColor, GuiControlFontColor)
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		CurrV := ""
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredHotkey Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredHotkey {
	;Colored Hotkey Class using a script from <name>
	static init , Hotkey := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewHotkeyObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewHotkeyObject( hwnd , Input ) {
		local k , v  
		ColoredHotkey.Hotkey[ hwnd ] := {}
		for k , v in Input
			ColoredHotkey.Hotkey[ hwnd ][ k ] := v
		ColoredHotkey.Hotkey[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 20, CurrH := 20
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V, CurrEditV := CurrV "AttachedEdit"
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains Text
			Input.Text := "", CurrText := ""
		else
			CurrText := Input.Text
		
		CurrText := StrReplace(CurrText, "`+", "Shift + "), CurrText := StrReplace(CurrText, "`!", "Alt + "), CurrText := StrReplace(CurrText, "`^", "Ctrl + ")
		
		Gui, % CurrOwner "Color", % GuiBackgroundColor
		Gui, % CurrOwner "Font", % "c" GuiFontColor
		
		Gui, % CurrOwner "Add", Hotkey, % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " " CurrLabel " " CurrOptions " hwndhwnd", % CurrText
		CtlColors.Attach(hwnd, GuiControlColor, GuiControlFontColor)
		Gui, % CurrOwner "Add", Edit,   % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrEditV " hwndhwnd", % CurrText
		CtlColors.Attach(hwnd, GuiControlColor, GuiControlFontColor)
		
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		CurrV := ""
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}

HotkeyCtrlEvent() {
	local  CurrEdit := A_GuiControl "AttachedEdit"
	GuiControlGet, CurrHotkey,, % A_GuiControl
	CurrHotkey := Format("{:T}", CurrHotkey)
	CurrHotkey := StrReplace(CurrHotkey, "+", "Shift + ")
	CurrHotkey := StrReplace(CurrHotkey, "^", "Ctrl + ")
	CurrHotkey := StrReplace(CurrHotkey, "!", "Alt + ")
	GuiControl, , % CurrEdit, % CurrHotkey ? CurrHotkey : "None"
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredDropDownList Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredDDL {
	;Colored DropDownList Class using a script from <name>
	static init , DropDownList := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewDDLObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewDDLObject( hwnd , Input ) {
		local k , v  
		ColoredDDL.DropDownList[ hwnd ] := {}
		for k , v in Input
			ColoredDDL.DropDownList[ hwnd ][ k ] := v
		ColoredDDL.DropDownList[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 15, CurrH := 15
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains List
			Input.List := "", CurrList := ""
		else
			CurrList := Input.List
			
		Gui, % CurrOwner "Font", % (FontOptions := "s8"), % (FontName := "Default")
		OD_Colors.SetItemHeight(FontOptions, FontName)
		Gui, % CurrOwner "Add", DDL, % "x" CurrX " y" CurrY " w" CurrW " " CurrV " " CurrLabel " +0x0210 " CurrOptions " hwndhwnd", % CurrList
		OD_Colors.Attach(hwnd,{T: GuiControlDDLFontColor, B: GuiControlDDLColor})
		PostMessage, 0x0153, -1, %CurrH%,, ahk_id %hwnd%  ; Set height of selection field.
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredComboBox Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredComboBox {
	;Colored ComboBox Class using a script from <name>
	static init , ComboBox := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewComboBoxObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewComboBoxObject( hwnd , Input ) {
		local k , v  
		ColoredComboBox.ComboBox[ hwnd ] := {}
		for k , v in Input
			ColoredComboBox.ComboBox[ hwnd ][ k ] := v
		ColoredComboBox.ComboBox[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 15, CurrH := 15
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains List
			Input.List := "", CurrList := ""
		else
			CurrList := Input.List
			
		Gui, % CurrOwner "Add", ComboBox, % "x" CurrX " y" CurrY " w" CurrW " " CurrV " " CurrLabel " " CurrOptions " hwndhwnd", % CurrList
		CtlColors.Attach(hwnd, GuiControlColor, GuiControlFontColor)
		;PostMessage, 0x0153, -1, %CurrH%,, ahk_id %hwnd%  ; Set height of selection field.
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredListBox Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredListBox {
	;Colored ListBox Class using a script from <name>
	static init , ListBox := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewListBoxObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewListBoxObject( hwnd , Input ) {
		local k , v  
		ColoredListox.ComboBox[ hwnd ] := {}
		for k , v in Input
			ColoredListBox.ComboBox[ hwnd ][ k ] := v
		ColoredListBox.ComboBox[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 15, CurrH := 15
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains List
			Input.List := "", CurrList := ""
		else
			CurrList := Input.List
			
		Gui, % CurrOwner "Add", ListBox, % "x" CurrX " y" CurrY " w" CurrW " " CurrV " " CurrLabel " " CurrOptions " hwndhwnd", % CurrList
		CtlColors.Attach(hwnd, GuiControlColor, GuiControlFontColor)
		CurrV := LTrim(CurrV, "v")
		GuiControl, % CurrOwner "Focus", % CurrV
		Gui, % CurrOwner "Show", w0 h0 y-5000
		Gui, % CurrOwner "Hide"
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredListView Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredLV {
	;Colored Listview Class using a script from <name>
	static init , ListView := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewListViewObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewListViewObject( hwnd , Input ) {
		local k , v  
		ColoredLV.ListView[ hwnd ] := {}
		for k , v in Input
			ColoredLV.ListView[ hwnd ][ k ] := v
		ColoredLV.ListView[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 75, CurrH := 75
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains Title
			Input.Title := Input.V, CurrTitle := Input.V
		else
			CurrTitle := Input.Title
			
		Gui, % CurrOwner "Add", ListView, % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " " CurrLabel " background" GuiControlColor " +LV0x4000 " CurrOptions " hwndhwnd", % CurrTitle
		Func_GUI_Control_Subclass(hwnd, "Func_ListView_Header_CustomDraw")
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredTreeView Class
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class ColoredTV {
	;Colored Treeview Class using a script from <name>
	static init , TreeView := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "") {
		local hwnd 			
		This._CreateNewTreeViewObject( hwnd := This._CreateControl( Input ) , Input )
		Return hwnd
	}

	_CreateNewTreeViewObject( hwnd , Input ) {
		local k , v  
		ColoredTV.TreeView[ hwnd ] := {}
		for k , v in Input
			ColoredTV.TreeView[ hwnd ][ k ] := v
		ColoredTV.TreeView[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ) {
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 75, CurrH := 75
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
			
		if Options not contains Label
			Input.Label := "", CurrLabel := ""
		else
			CurrLabel := "g" Input.Label
		
		if Options not contains Options
			Input.Options := "", CurrOptions := ""
		else
			CurrOptions := Input.Options
		
		if Options not contains Title
			Input.Title := Input.V, CurrTitle := Input.V
		else
			CurrTitle := Input.Title
			
		Gui, % CurrOwner "Add", TreeView, % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " " CurrLabel " background" GuiControlColor " +LV0x4000 " CurrOptions " hwndhwnd", % CurrTitle
		Func_GUI_Control_Subclass(hwnd, "Func_ListView_Header_CustomDraw")
		Return hwnd
	}
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredButton Class There are some limitations with this Class: The Gui has to have a title (ie: Gui, 1:Show) for labels to work
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Class HButton	{
	;Gen 3 Button Class By Hellbent
	static init , Button := [] , Active , LastControl , HoldCtrl 
	
	__New( Input := "" , All := "" , Default := "" , Hover := "" , Pressed := "" ){
		local hwnd 
		
		if( !HButton.init && HButton.init := 1 ) ;If this is the first time the class is being used.
			HButton._SetHoverTimer() ;Set a timer to watch to see if the cursor goes over one of the controls.
			
		This._CreateNewButtonObject( hwnd := This._CreateControl( Input ) , Input )
		This._BindButton( hwnd , Input )
		This._GetButtonBitmaps( hwnd , Input , All , Default , Hover , Pressed )
		This._DisplayButton( hwnd , HButton.Button[hwnd].Bitmaps.Default.hBitmap )
		return hwnd
	}

	_DisplayButton( hwnd , hBitmap){
		SetImage( hwnd , hBitmap )
	}
	
	_GetButtonBitmaps( hwnd , Input := "" , All := "" , Default := "" , Hover := "" , Pressed := "" ){
		HButton.Button[hwnd].Bitmaps := GuiButtonType1.CreateButtonBitmapSet( Input , All , Default , Hover , Pressed )
	}
	
	_CreateNewButtonObject( hwnd , Input ){
		local k , v  
		HButton.Button[ hwnd ] := {}

		for k , v in Input
			HButton.Button[ hwnd ][ k ] := v
		
		HButton.Button[ hwnd ].Hwnd := hwnd
	}
	
	_CreateControl( Input ){
		local hwnd
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			if (k = "X") || (k = "Y") || (k = "W") || (k = "H")
				k := k "Pos"
			Options := Options k " = " v "`n"
		}
		
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
			
		if Options not contains XPos
			Input.X := 0, CurrX := 0
		else
			CurrX := Input.X
			
		if Options not contains YPos
			Input.Y := 0, CurrY := 0
		else
			CurrY := Input.Y
			
		if Options not contains WPos
			Input.W := 100, CurrW := 100
		else
			CurrW := Input.W
			
		if Options not contains HPos
			Input.H := 25, CurrH := 25
		else
			CurrH := Input.H
		
		if Options not contains V
			Input.V := "", CurrV := ""
		else
			CurrV := "v" Input.V
		
		Gui, % CurrOwner "Add", Pic, % "x" CurrX " y" CurrY " w" CurrW " h" CurrH " " CurrV " " CurrLabel " hwndhwnd 0xE"  
		return hwnd
	}
	
	_BindButton( hwnd , Input ){
		local bd
		bd := This._OnClick.Bind( This )
		local Options, CurrOwner, CurrX, CurrY, CurrW, CurrH, CurrV, CurrOptions, CurrLabel, CurrDate, CurrText, CurrTitle
		
		local k, v, Options
		for k , v in Input
		{
			Options := Options k " = " v "`n"
		}
		if Options not contains Owner
			Input.Owner := "", CurrOwner := ""
		else
			CurrOwner := Input.Owner ":"
		if (CurrOwner = ":")
			CurrOwner := ""
			
		GuiControl, % CurrOwner "+G" , % hwnd , % bd
	}
	
	_SetHoverTimer( timer := "" ){
		local HoverTimer
		
		if( !HButton.HoverTimer ) 
			HButton.HoverTimer := ObjBindMethod( HButton , "_OnHover" ) 
		
		HoverTimer := HButton.HoverTimer
		SetTimer , % HoverTimer , % ( Timer ) ? ( Timer ) : ( 100 )
	}
	
	_OnHover(){
		local Ctrl
		
		MouseGetPos,,,,ctrl,2
		if( HButton.Button[ ctrl ] && !HButton.Active ){
			HButton.Active := 1
			HButton.LastControl := ctrl
			HButton._DisplayButton( ctrl , HButton.Button[ ctrl ].Bitmaps.Hover.hBitmap )
		}
		else if( HButton.Active && ctrl != HButton.LastControl ){
			HButton.Active := 0
			HButton._DisplayButton( HButton.LastControl , HButton.Button[ HButton.LastControl ].Bitmaps.Default.hBitmap )
		}
	}
	
	_OnClick(){
		local Ctrl, last
		
		HButton._SetHoverTimer( "Off" )
		
		MouseGetPos,,,, Ctrl , 2
		last := ctrl
		HButton._SetFocus( ctrl )
		HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Pressed.hBitmap )
		
		While(GetKeyState("LButton"))
			sleep, 60
		
		HButton._SetHoverTimer()
		
		loop, 2
			This._OnHover()
		
		MouseGetPos,,,, Ctrl , 2
		
		if(ctrl!=last){
			HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Default.hBitmap )
		}
		else{
			HButton._DisplayButton( last , HButton.Button[ last ].Bitmaps.Hover.hBitmap )
			if( HButton.Button[ last ].Label ){
				if(IsFunc( HButton.Button[ last ].Label ) )
					fn := Func( HButton.Button[ last ].Label )
					, fn.Call()
				
				else
				{
					CustomColoredMsgBoxDefaultLabel()
					gosub, % HButton.Button[ last ].Label
				}
			}
		}
	}
	
	_SetFocus( ctrl ){
		GuiControl, % HButton.Button[ ctrl ].Owner ":Focus" , % ctrl
	}
	
	DeleteButton( hwnd ){
		for k , v in HButton.Button[ hwnd ].Bitmaps
				Gdip_DisposeImage( HButton.Button[hwnd].Bitmaps[k].pBitmap )
				, DeleteObject( HButton.Button[ hwnd ].Bitmaps[k].hBitmap )
				
		GuiControl , % HButton.Button[ hwnd ].Owner ":Move", % hwnd , % "x-1 y-1 w0 h0" 
		HButton.Button[ hwnd ] := ""
	}
}

;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
Class GuiButtonType1	{

	static List := [ "Default" , "Hover" , "Pressed" ]
	
	_CreatePressedBitmap(){
		
		local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Pressed
		
		Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )
		
		Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-8 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W-7 , fObj.H-10 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 5 , fObj.W-11 , fObj.H-12 , 5 ) , Gdip_DeleteBrush( Brush )
			
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )
		
		arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]
		
		Loop, % 8
			
			Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 1 + arr[A_Index].X + fObj.TextOffsetX " y" 3 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )
		
		Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 1 + fObj.TextOffsetX " y" 3 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
	if( fObj.ButtonAddGlossy ){
		
		Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 5 , 10 , fObj.W-11 , ( fObj.H / 2 ) - 10   ) , Gdip_DeleteBrush( Brush )

		Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 5  , 10 + ( fObj.H / 2 ) - 10 , fObj.W-11 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )
				
	}

		Gdip_DeleteGraphics( G )
		
		Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )
		
		return Bitmap
	}
	
	_CreateHoverBitmap(){
		
		local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Hover
		
		Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )
		
		Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_BrushCreateSolid( fObj.ButtonCenterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-9 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H-10 , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 4 , 5 , fObj.W-9 , fObj.H-11 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 5 , 7 , fObj.W-11 , fObj.H-14 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 7 , fObj.W-11 , fObj.H-14 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )
		
		arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]
		
		Loop, % 8
			
			Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + arr[A_Index].X + fObj.TextOffsetX " y" 2 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )
		
		Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + fObj.TextOffsetX " y" 2 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
		if( fObj.ButtonAddGlossy = 1 ){
			
			Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 , fObj.W-13 , ( fObj.H / 2 ) - 10   ) , Gdip_DeleteBrush( Brush )
			
			Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )
			
			Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 6  , 10 + ( fObj.H / 2 ) - 10 , fObj.W-13 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )
					
		}
	
		Gdip_DeleteGraphics( G )
		
		Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )
		
		return Bitmap
		
	}
	
	_CreateDefaultBitmap(){
		
		local arr := [] , Bitmap := {} , fObj := This.CurrentBitmapData.Default
		
		Bitmap.pBitmap := Gdip_CreateBitmap( fObj.W , fObj.H ) , G := Gdip_GraphicsFromImage( Bitmap.pBitmap ) , Gdip_SetSmoothingMode( G , 2 )
	
		Brush := Gdip_BrushCreateSolid( fObj.BackgroundColor ) , Gdip_FillRectangle( G , Brush , -1 , -1 , fObj.W+2 , fObj.H+2 ) , Gdip_DeleteBrush( Brush )
	
		Brush := Gdip_BrushCreateSolid( fObj.ButtonOuterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 2 , 3 , fObj.W-5 , fObj.H-7 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_BrushCreateSolid( fObj.ButtonCenterBorderColor ) , Gdip_FillRoundedRectangle( G , Brush , 3 , 4 , fObj.W-7 , fObj.H-9 , 5 ) , Gdip_DeleteBrush( Brush )
	
		Brush := Gdip_CreateLineBrushFromRect( 0 , 0 , fObj.W , fObj.H-10 , fObj.ButtonInnerBorderColor1 , fObj.ButtonInnerBorderColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 4 , 5 , fObj.W-9 , fObj.H-11 , 5 ) , Gdip_DeleteBrush( Brush )
	
		Brush := Gdip_CreateLineBrushFromRect( 5 , 7 , fObj.W-11 , fObj.H-14 , fObj.ButtonMainColor1 , fObj.ButtonMainColor2 , 1 , 1 ) , Gdip_FillRoundedRectangle( G , Brush , 5 , 7 , fObj.W-11 , fObj.H-14 , 5 ) , Gdip_DeleteBrush( Brush )
		
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextBottomColor1 , fObj.TextBottomColor2 , 1 , 1 )
		
		arr := [ { X: -1 , Y: -1 } , { X: 0 , Y: -1 } , { X: 1 , Y: -1 } , { X: -1 , Y: 0 } , { X: 1 , Y: 0 } , { X: -1 , Y: 1 } , { X: 0 , Y: 1 } , { X: 1 , Y: 1 } ]
		
		Loop, % 8
			
			Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + arr[A_Index].X + fObj.TextOffsetX " y" 2 + arr[A_Index].Y + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
		Brush := Gdip_CreateLineBrushFromRect( 0 , 2 , fObj.W , fObj.H , fObj.TextTopColor1 , fObj.TextTopColor2 , 1 , 1 )
		
		Gdip_TextToGraphics( G , fObj.Text , "s" fObj.FontSize " " fObj.FontOptions " c" Brush " x" 0 + fObj.TextOffsetX " y" 2 + fObj.TextOffsetY , fObj.Font , fObj.W + fObj.TextOffsetW , fObj.H + fObj.TextOffsetH )
	
		if( fObj.ButtonAddGlossy ){
		
			Brush := Gdip_BrushCreateSolid( fObj.GlossTopColor ) , Gdip_FillRectangle( G , Brush , 6 , 10 , fObj.W-13 , ( fObj.H / 2 ) - 10   ) , Gdip_DeleteBrush( Brush )
			
			Brush := Gdip_BrushCreateSolid( fObj.GlossTopAccentColor ) , Gdip_FillRectangle( G , Brush , 10 , 12 , fObj.W-21 , fObj.H / 15 ) , Gdip_DeleteBrush( Brush )
			
			Brush := Gdip_BrushCreateSolid( fObj.GlossBottomColor ) , Gdip_FillRectangle( G , Brush , 6  , 10 + ( fObj.H / 2 ) - 10 , fObj.W-13 , ( fObj.H / 2 ) - 7 ) , Gdip_DeleteBrush( Brush )
				
		}
	
		Gdip_DeleteGraphics( G )
		
		Bitmap.hBitmap := Gdip_CreateHBITMAPFromBitmap( Bitmap.pBitmap )
		
		return Bitmap
		
	}
	
	_GetMasterDefaultValues(){ ;Default State
		
		local Default := {}
		
		Default.pBitmap := "" 
		, Default.hBitmap := ""
		, Default.Font := "Arial"
		, Default.FontOptions := " Bold Center vCenter "
		, Default.FontSize := "12"
		, Default.Text := "Button"
		, Default.W := 10
		, Default.H := 10
		, Default.TextBottomColor1 := "0x0002112F"
		, Default.TextBottomColor2 := Default.TextBottomColor1
		, Default.TextTopColor1 := "0xFFFFFFFF"
		, Default.TextTopColor2 := "0xFF000000"
		, Default.TextOffsetX := 0
		, Default.TextOffsetY := 0
		, Default.TextOffsetW := 0
		, Default.TextOffsetH := 0
		, Default.BackgroundColor := "0xFF22262A"
		, Default.ButtonOuterBorderColor := "0xFF161B1F"	
		, Default.ButtonCenterBorderColor := "0xFF262B2F"	
		, Default.ButtonInnerBorderColor1 := "0xFF3F444A"
		, Default.ButtonInnerBorderColor2 := "0xFF24292D"
		, Default.ButtonMainColor1 := "0xFF272C32"
		, Default.ButtonMainColor2 := "" Default.ButtonMainColor1
		, Default.ButtonAddGlossy := 0
		, Default.GlossTopColor := "0x11FFFFFF"
		, Default.GlossTopAccentColor := "0x05FFFFFF"	
		, Default.GlossBottomColor := "0x33000000"
		
		return Default
		
	}
	
	_GetMasterHoverValues(){ ;Hover State
		
		local Default := {}
		
		Default.pBitmap := ""
		, Default.hBitmap := ""
		, Default.Font := "Arial"
		, Default.FontOptions := " Bold Center vCenter "
		, Default.FontSize := "12"
		, Default.Text := "Button"
		, Default.W := 10
		, Default.H := 10
		, Default.TextBottomColor1 := "0x0002112F"
		, Default.TextBottomColor2 := Default.TextBottomColor1
		, Default.TextTopColor1 := "0xFFFFFFFF"
		, Default.TextTopColor2 := "0xFF000000"
		, Default.TextOffsetX := 0
		, Default.TextOffsetY := 0
		, Default.TextOffsetW := 0
		, Default.TextOffsetH := 0
		, Default.BackgroundColor := "0xFF22262A"
		, Default.ButtonOuterBorderColor := "0xFF161B1F"	
		, Default.ButtonCenterBorderColor := "0xFF262B2F"	
		, Default.ButtonInnerBorderColor1 := "0xFF3F444A"
		, Default.ButtonInnerBorderColor2 := "0xFF24292D"
		, Default.ButtonMainColor1 := "0xFF373C42"
		, Default.ButtonMainColor2 := "" Default.ButtonMainColor1
		, Default.ButtonAddGlossy := 0
		, Default.GlossTopColor := "0x11FFFFFF"
		, Default.GlossTopAccentColor := "0x05FFFFFF"	
		, Default.GlossBottomColor := "0x33000000"
		
		return Default
		
	}
	
	_GetMasterPressedValues(){ ;Pressed State
		
		local Default := {}
		
		Default.pBitmap := ""
		, Default.hBitmap := ""
		, Default.Font := "Arial"
		, Default.FontOptions := " Bold Center vCenter "
		, Default.FontSize := "12"
		, Default.Text := "Button"
		, Default.W := 10
		, Default.H := 10
		, Default.TextBottomColor1 := "0x0002112F"
		, Default.TextBottomColor2 := Default.TextBottomColor1
		, Default.TextTopColor1 := "0xFFFFFFFF"
		, Default.TextTopColor2 := "0xFF000000"
		, Default.TextOffsetX := 0
		, Default.TextOffsetY := 0
		, Default.TextOffsetW := 0
		, Default.TextOffsetH := 0
		, Default.BackgroundColor := "0xFF22262A"
		, Default.ButtonOuterBorderColor := "0xFF62666a"
		, Default.ButtonCenterBorderColor := "0xFF262B2F"	
		, Default.ButtonInnerBorderColor1 := "0xFF151A20"
		, Default.ButtonInnerBorderColor2 := "0xFF151A20"
		, Default.ButtonMainColor1 := "0xFF12161a"
		, Default.ButtonMainColor2 := "0xFF33383E"
		, Default.ButtonAddGlossy := 0
		, Default.GlossTopColor := "0x11FFFFFF"
		, Default.GlossTopAccentColor := "0x05FFFFFF"	
		, Default.GlossBottomColor := "0x33000000"
	
		return Default
		
	}
	
	SetSessionDefaults( All := "" , Default := "" , Hover := "" , Pressed := "" ){ ;Set the default values based on user input
		
		This.SessionBitmapData := {} 
		, This.Preset := 1
		, This.init := 0
		
		This._LoadDefaults("SessionBitmapData")
		
		This._SetSessionData( All , Default , Hover , Pressed )
		
	}
	
	_SetSessionData( All := "" , Default := "" , Hover := "" , Pressed := "" ){
		
		local index , k , v , i , j
	
		if( IsObject( All ) ){
			
			Loop, % GuiButtonType1.List.Length()	{
				index := A_Index
				For k , v in All
					This.SessionBitmapData[ GuiButtonType1.List[ index ] ][ k ] := v
			}
		}
		
		For k , v in GuiButtonType1.List
			if( isObject( %v% ) )
				For i , j in %v%
					This.SessionBitmapData[ GuiButtonType1.List[ k ] ][ i ] := j
				
	}
	
	_LoadDefaults( input := "" ){
		
		This.CurrentBitmapData := "" , This.CurrentBitmapData := {}
			
		For k , v in This.SessionBitmapData
			This.CurrentBitmapData[k] := {}
		
		This[ input ].Default := This._GetMasterDefaultValues()
		, This[ input ].Hover := This._GetMasterHoverValues()
		, This[ input ].Pressed := This._GetMasterPressedValues()
		
	}
	
	_SetCurrentBitmapDataFromSessionData(){
		
		local k , v , i , j
			
		This.CurrentBitmapData := "" , This.CurrentBitmapData := {}
			
		For k , v in This.SessionBitmapData
		{
			This.CurrentBitmapData[k] := {}
			
			For i , j in This.SessionBitmapData[k]
				
				This.CurrentBitmapData[k][i] := j

		}
		
	}
	
	_UpdateCurrentBitmapData( All := "" , Default := "" , Hover := "" , Pressed := "" ){
		
		local k , v , i , j
		
		if( IsObject( All ) ){
			
			Loop, % GuiButtonType1.List.Length()	{
				
				index := A_Index
			
				For k , v in All
					
					This.CurrentBitmapData[ GuiButtonType1.List[ index ] ][ k ] := v
					
			}
		}
		
		For k , v in GuiButtonType1.List
			
			if( isObject( %v% ) )
				
				For i , j in %v%
					
					This.CurrentBitmapData[ GuiButtonType1.List[ k ] ][ i ] := j
				
	}
	
	_UpdateInstanceData( obj := ""){
		
		For k , v in GuiButtonType1.List	
			
			This.CurrentBitmapData[v].Text := obj.Text
			, This.CurrentBitmapData[v].W := obj.W
			, This.CurrentBitmapData[v].H := obj.H
			
	}

	CreateButtonBitmapSet( obj := "" ,  All := "" , Default := "" , Hover := "" , Pressed := ""  ){ ;Create a new button
		
		local Bitmaps := {}
		
		if( This.Preset )
				
			This._SetCurrentBitmapDataFromSessionData()
			
		else
			
			This._LoadDefaults( "CurrentBitmapData" )
			
		This._UpdateCurrentBitmapData( All , Default , Hover , Pressed )
		
		This._UpdateInstanceData( obj )
		 
		Bitmaps.Default := This._CreateDefaultBitmap()
		, Bitmaps.Hover := This._CreateHoverBitmap()
		, Bitmaps.Pressed := This._CreatePressedBitmap()
		
		return Bitmaps
		
	}
	
}

;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
;****************************************************************************************************************************************************************************************
/*
;Template for setting button session defaults

MasterTheme(){
	
	local Theme := {}

	Theme.All := {}
	
	Theme.All.pBitmap := ""
	, Theme.All.hBitmap := ""
	, Theme.All.Font := "Arial"
	, Theme.All.FontOptions := " Bold Center vCenter "
	, Theme.All.FontSize := "12"
	, Theme.All.Text := "Button"
	, Theme.All.W := 10
	, Theme.All.H := 10
	, Theme.All.TextBottomColor1 := "0x0002112F"
	, Theme.All.TextBottomColor2 := Theme.All.TextBottomColor1
	, Theme.All.TextTopColor1 := "0xFFFFFFFF"
	, Theme.All.TextTopColor2 := "0xFF000000"
	, Theme.All.TextOffsetX := 0
	, Theme.All.TextOffsetY := 0
	, Theme.All.TextOffsetW := 0
	, Theme.All.TextOffsetH := 0
	, Theme.All.BackgroundColor := "0xFF22262A"
	, Theme.All.ButtonOuterBorderColor := "0xFF62666a"
	, Theme.All.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.All.ButtonInnerBorderColor1 := "0xFF151A20"
	, Theme.All.ButtonInnerBorderColor2 := "0xFF151A20"
	, Theme.All.ButtonMainColor1 := "0xFF12161a"
	, Theme.All.ButtonMainColor2 := "0xFF33383E"
	, Theme.All.ButtonAddGlossy := 0
	, Theme.All.GlossTopColor := "0x11FFFFFF"
	, Theme.All.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.All.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Default := {}
	
	Theme.Default.pBitmap := "" 
	, Theme.Default.hBitmap := ""
	, Theme.Default.Font := "Arial"
	, Theme.Default.FontOptions := " Bold Center vCenter "
	, Theme.Default.FontSize := "12"
	, Theme.Default.Text := "Button"
	, Theme.Default.W := 10
	, Theme.Default.H := 10
	, Theme.Default.TextBottomColor1 := "0x0002112F"
	, Theme.Default.TextBottomColor2 := Theme.Default.TextBottomColor1
	, Theme.Default.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Default.TextTopColor2 := "0xFF000000"
	, Theme.Default.TextOffsetX := 0
	, Theme.Default.TextOffsetY := 0
	, Theme.Default.TextOffsetW := 0
	, Theme.Default.TextOffsetH := 0
	, Theme.Default.BackgroundColor := "0xFF22262A"
	, Theme.Default.ButtonOuterBorderColor := "0xFF161B1F"	
	, Theme.Default.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Default.ButtonInnerBorderColor1 := "0xFF3F444A"
	, Theme.Default.ButtonInnerBorderColor2 := "0xFF24292D"
	, Theme.Default.ButtonMainColor1 := "0xFF272C32"
	, Theme.Default.ButtonMainColor2 := "" Theme.Default.ButtonMainColor1
	, Theme.Default.ButtonAddGlossy := 0
	, Theme.Default.GlossTopColor := "0x11FFFFFF"
	, Theme.Default.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Default.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Hover := {}
	
	Theme.Hover.pBitmap := ""
	, Theme.Hover.hBitmap := ""
	, Theme.Hover.Font := "Arial"
	, Theme.Hover.FontOptions := " Bold Center vCenter "
	, Theme.Hover.FontSize := "12"
	, Theme.Hover.Text := "Button"
	, Theme.Hover.W := 10
	, Theme.Hover.H := 10
	, Theme.Hover.TextBottomColor1 := "0x0002112F"
	, Theme.Hover.TextBottomColor2 := Theme.Hover.TextBottomColor1
	, Theme.Hover.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Hover.TextTopColor2 := "0xFF000000"
	, Theme.Hover.TextOffsetX := 0
	, Theme.Hover.TextOffsetY := 0
	, Theme.Hover.TextOffsetW := 0
	, Theme.Hover.TextOffsetH := 0
	, Theme.Hover.BackgroundColor := "0xFF22262A"
	, Theme.Hover.ButtonOuterBorderColor := "0xFF161B1F"	
	, Theme.Hover.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Hover.ButtonInnerBorderColor1 := "0xFF3F444A"
	, Theme.Hover.ButtonInnerBorderColor2 := "0xFF24292D"
	, Theme.Hover.ButtonMainColor1 := "0xFF373C42"
	, Theme.Hover.ButtonMainColor2 := "" Theme.Hover.ButtonMainColor1
	, Theme.Hover.ButtonAddGlossy := 0
	, Theme.Hover.GlossTopColor := "0x11FFFFFF"
	, Theme.Hover.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Hover.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	Theme.Pressed := {}
	
	Theme.Pressed.pBitmap := ""
	, Theme.Pressed.hBitmap := ""
	, Theme.Pressed.Font := "Arial"
	, Theme.Pressed.FontOptions := " Bold Center vCenter "
	, Theme.Pressed.FontSize := "12"
	, Theme.Pressed.Text := "Button"
	, Theme.Pressed.W := 10
	, Theme.Pressed.H := 10
	, Theme.Pressed.TextBottomColor1 := "0x0002112F"
	, Theme.Pressed.TextBottomColor2 := Theme.Pressed.TextBottomColor1
	, Theme.Pressed.TextTopColor1 := "0xFFFFFFFF"
	, Theme.Pressed.TextTopColor2 := "0xFF000000"
	, Theme.Pressed.TextOffsetX := 0
	, Theme.Pressed.TextOffsetY := 0
	, Theme.Pressed.TextOffsetW := 0
	, Theme.Pressed.TextOffsetH := 0
	, Theme.Pressed.BackgroundColor := "0xFF22262A"
	, Theme.Pressed.ButtonOuterBorderColor := "0xFF62666a"
	, Theme.Pressed.ButtonCenterBorderColor := "0xFF262B2F"	
	, Theme.Pressed.ButtonInnerBorderColor1 := "0xFF151A20"
	, Theme.Pressed.ButtonInnerBorderColor2 := "0xFF151A20"
	, Theme.Pressed.ButtonMainColor1 := "0xFF12161a"
	, Theme.Pressed.ButtonMainColor2 := "0xFF33383E"
	, Theme.Pressed.ButtonAddGlossy := 0
	, Theme.Pressed.GlossTopColor := "0x11FFFFFF"
	, Theme.Pressed.GlossTopAccentColor := "0x05FFFFFF"	
	, Theme.Pressed.GlossBottomColor := "0x33000000"
	
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	;<<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>><<<<<>>>>>(_____)<<<<<>>>>>
	;<*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&
	
	
	return Theme
}
*/
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;GDIP.AHK
;///////////////////////////////////////////////////////////////////////////////////////////////////////
; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
;
; Updated 2/20/2014 - fixed Gdip_CreateRegion() and Gdip_GetClipRegion() on AHK Unicode x86
; Updated 5/13/2013 - fixed Gdip_SetBitmapToClipboard() on AHK Unicode x64
;
;#####################################################################################
;#####################################################################################
; STATUS ENUMERATION
; Return values for functions specified to have status enumerated return type
;#####################################################################################
;
; Ok =						= 0
; GenericError				= 1
; InvalidParameter			= 2
; OutOfMemory				= 3
; ObjectBusy				= 4
; InsufficientBuffer		= 5
; NotImplemented			= 6
; Win32Error				= 7
; WrongState				= 8
; Aborted					= 9
; FileNotFound				= 10
; ValueOverflow				= 11
; AccessDenied				= 12
; UnknownImageFormat		= 13
; FontFamilyNotFound		= 14
; FontStyleNotFound			= 15
; NotTrueTypeFont			= 16
; UnsupportedGdiplusVersion	= 17
; GdiplusNotInitialized		= 18
; PropertyNotFound			= 19
; PropertyNotSupported		= 20
; ProfileNotFound			= 21
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################
;
; UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
; BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
; StretchBlt(dDC, dx, dy, dw, dh, sDC, sx, sy, sw, sh, Raster="")
; SetImage(hwnd, hBitmap)
; Gdip_BitmapFromScreen(Screen=0, Raster="")
; CreateRectF(ByRef RectF, x, y, w, h)
; CreateSizeF(ByRef SizeF, w, h)
; CreateDIBSection
;
;#####################################################################################

; Function:     			UpdateLayeredWindow
; Description:  			Updates a layered window with the handle to the DC of a gdi bitmap
; 
; hwnd        				Handle of the layered window to update
; hdc           			Handle to the DC of the GDI bitmap to update the window with
; Layeredx      			x position to place the window
; Layeredy      			y position to place the window
; Layeredw      			Width of the window
; Layeredh      			Height of the window
; Alpha         			Default = 255 : The transparency (0-255) to set the window transparency
;
; return      				If the function succeeds, the return value is nonzero
;
; notes						If x or y omitted, then layered window will use its current coordinates
;							If w or h omitted then current width and height will be used

UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if ((x != "") && (y != ""))
		VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")

	if (w = "") ||(h = "")
		WinGetPos,,, w, h, ahk_id %hwnd%
   
	return DllCall("UpdateLayeredWindow"
					, Ptr, hwnd
					, Ptr, 0
					, Ptr, ((x = "") && (y = "")) ? 0 : &pt
					, "int64*", w|h<<32
					, Ptr, hdc
					, "int64*", 0
					, "uint", 0
					, "UInt*", Alpha<<16|1<<24
					, "uint", 2)
}

;#####################################################################################

; Function				BitBlt
; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle 
;						of pixels from the specified source device context into a destination device context.
;
; dDC					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of the area to copy
; dh					height of the area to copy
; sDC					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS				= 0x00000042
; NOTSRCERASE			= 0x001100A6
; NOTSRCCOPY			= 0x00330008
; SRCERASE				= 0x00440328
; DSTINVERT				= 0x00550009
; PATINVERT				= 0x005A0049
; SRCINVERT				= 0x00660046
; SRCAND				= 0x008800C6
; MERGEPAINT			= 0x00BB0226
; MERGECOPY				= 0x00C000CA
; SRCCOPY				= 0x00CC0020
; SRCPAINT				= 0x00EE0086
; PATCOPY				= 0x00F00021
; PATPAINT				= 0x00FB0A09
; WHITENESS				= 0x00FF0062
; CAPTUREBLT			= 0x40000000
; NOMIRRORBITMAP		= 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdi32\BitBlt"
					, Ptr, dDC
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, Ptr, sDC
					, "int", sx
					, "int", sy
					, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				StretchBlt
; Description			The StretchBlt function copies a bitmap from a source rectangle into a destination rectangle, 
;						stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
;						The system stretches or compresses the bitmap according to the stretching mode currently set in the destination device context.
;
; ddc					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination rectangle
; dh					height of destination rectangle
; sdc					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Raster				raster operation code
;
; return				If the function succeeds, the return value is nonzero
;
; notes					If no raster operation is specified, then SRCCOPY is used. It uses the same raster operations as BitBlt		

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdi32\StretchBlt"
					, Ptr, ddc
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, Ptr, sdc
					, "int", sx
					, "int", sy
					, "int", sw
					, "int", sh
					, "uint", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				SetStretchBltMode
; Description			The SetStretchBltMode function sets the bitmap stretching mode in the specified device context
;
; hdc					handle to the DC
; iStretchMode			The stretching mode, describing how the target will be stretched
;
; return				If the function succeeds, the return value is the previous stretching mode. If it fails it will return 0
;
; STRETCH_ANDSCANS 		= 0x01
; STRETCH_ORSCANS 		= 0x02
; STRETCH_DELETESCANS 	= 0x03
; STRETCH_HALFTONE 		= 0x04

SetStretchBltMode(hdc, iStretchMode=4)
{
	return DllCall("gdi32\SetStretchBltMode"
					, A_PtrSize ? "UPtr" : "UInt", hdc
					, "int", iStretchMode)
}

;#####################################################################################

; Function				SetImage
; Description			Associates a new image with a static control
;
; hwnd					handle of the control to update
; hBitmap				a gdi bitmap to associate the static control with
;
; return				If the function succeeds, the return value is nonzero

SetImage(hwnd, hBitmap)
{
	SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
	E := ErrorLevel
	DeleteObject(E)
	return E
}

;#####################################################################################

; Function				SetSysColorToControl
; Description			Sets a solid colour to a control
;
; hwnd					handle of the control to update
; SysColor				A system colour to set to the control
;
; return				If the function succeeds, the return value is zero
;
; notes					A control must have the 0xE style set to it so it is recognised as a bitmap
;						By default SysColor=15 is used which is COLOR_3DFACE. This is the standard background for a control
;
; COLOR_3DDKSHADOW				= 21
; COLOR_3DFACE					= 15
; COLOR_3DHIGHLIGHT				= 20
; COLOR_3DHILIGHT				= 20
; COLOR_3DLIGHT					= 22
; COLOR_3DSHADOW				= 16
; COLOR_ACTIVEBORDER			= 10
; COLOR_ACTIVECAPTION			= 2
; COLOR_APPWORKSPACE			= 12
; COLOR_BACKGROUND				= 1
; COLOR_BTNFACE					= 15
; COLOR_BTNHIGHLIGHT			= 20
; COLOR_BTNHILIGHT				= 20
; COLOR_BTNSHADOW				= 16
; COLOR_BTNTEXT					= 18
; COLOR_CAPTIONTEXT				= 9
; COLOR_DESKTOP					= 1
; COLOR_GRADIENTACTIVECAPTION	= 27
; COLOR_GRADIENTINACTIVECAPTION	= 28
; COLOR_GRAYTEXT				= 17
; COLOR_HIGHLIGHT				= 13
; COLOR_HIGHLIGHTTEXT			= 14
; COLOR_HOTLIGHT				= 26
; COLOR_INACTIVEBORDER			= 11
; COLOR_INACTIVECAPTION			= 3
; COLOR_INACTIVECAPTIONTEXT		= 19
; COLOR_INFOBK					= 24
; COLOR_INFOTEXT				= 23
; COLOR_MENU					= 4
; COLOR_MENUHILIGHT				= 29
; COLOR_MENUBAR					= 30
; COLOR_MENUTEXT				= 7
; COLOR_SCROLLBAR				= 0
; COLOR_WINDOW					= 5
; COLOR_WINDOWFRAME				= 6
; COLOR_WINDOWTEXT				= 8

SetSysColorToControl(hwnd, SysColor=15)
{
   WinGetPos,,, w, h, ahk_id %hwnd%
   bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
   pBrushClear := Gdip_BrushCreateSolid(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
   pBitmap := Gdip_CreateBitmap(w, h), G := Gdip_GraphicsFromImage(pBitmap)
   Gdip_FillRectangle(G, pBrushClear, 0, 0, w, h)
   hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
   SetImage(hwnd, hBitmap)
   Gdip_DeleteBrush(pBrushClear)
   Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
   return 0
}

;#####################################################################################

; Function				Gdip_BitmapFromScreen
; Description			Gets a gdi+ bitmap from the screen
;
; Screen				0 = All screens
;						Any numerical value = Just that screen
;						x|y|w|h = Take specific coordinates with a width and height
; Raster				raster operation code
;
; return      			If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1:		one or more of x,y,w,h not passed properly
;
; notes					If no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen=0, Raster="")
{
	if (Screen = 0)
	{
		Sysget, x, 76
		Sysget, y, 77	
		Sysget, w, 78
		Sysget, h, 79
	}
	else if (SubStr(Screen, 1, 5) = "hwnd:")
	{
		Screen := SubStr(Screen, 6)
		if !WinExist( "ahk_id " Screen)
			return -2
		WinGetPos,,, w, h, ahk_id %Screen%
		x := y := 0
		hhdc := GetDCEx(Screen, 3)
	}
	else if (Screen&1 != "")
	{
		Sysget, M, Monitor, %Screen%
		x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
	}
	else
	{
		StringSplit, S, Screen, |
		x := S1, y := S2, w := S3, h := S4
	}

	if (x = "") || (y = "") || (w = "") || (h = "")
		return -1

	chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ? hhdc : GetDC()
	BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
	ReleaseDC(hhdc)
	
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
	return pBitmap
}

;#####################################################################################

; Function				Gdip_BitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd					handle to the window to get a bitmap from
;
; return				If the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
	WinGetPos,,, Width, Height, ahk_id %hwnd%
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################

; Function    			CreateRectF
; Description			Creates a RectF object, containing a the coordinates and dimensions of a rectangle
;
; RectF       			Name to call the RectF object
; x            			x-coordinate of the upper left corner of the rectangle
; y            			y-coordinate of the upper left corner of the rectangle
; w            			Width of the rectangle
; h            			Height of the rectangle
;
; return      			No return value

CreateRectF(ByRef RectF, x, y, w, h)
{
   VarSetCapacity(RectF, 16)
   NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}

;#####################################################################################

; Function    			CreateRect
; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;
; RectF       			Name to call the RectF object
; x            			x-coordinate of the upper left corner of the rectangle
; y            			y-coordinate of the upper left corner of the rectangle
; w            			Width of the rectangle
; h            			Height of the rectangle
;
; return      			No return value

CreateRect(ByRef Rect, x, y, w, h)
{
	VarSetCapacity(Rect, 16)
	NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
}
;#####################################################################################

; Function		    	CreateSizeF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF         		Name to call the SizeF object
; w            			w-value for the SizeF object
; h            			h-value for the SizeF object
;
; return      			No Return value

CreateSizeF(ByRef SizeF, w, h)
{
   VarSetCapacity(SizeF, 8)
   NumPut(w, SizeF, 0, "float"), NumPut(h, SizeF, 4, "float")     
}
;#####################################################################################

; Function		    	CreatePointF
; Description			Creates a SizeF object, containing an 2 values
;
; SizeF         		Name to call the SizeF object
; w            			w-value for the SizeF object
; h            			h-value for the SizeF object
;
; return      			No Return value

CreatePointF(ByRef PointF, x, y)
{
   VarSetCapacity(PointF, 8)
   NumPut(x, PointF, 0, "float"), NumPut(y, PointF, 4, "float")     
}
;#####################################################################################

; Function				CreateDIBSection
; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w						width of the bitmap to create
; h						height of the bitmap to create
; hdc					a handle to the device context to use the palette from
; bpp					bits per pixel (32 = ARGB)
; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return				returns a DIB. A gdi bitmap
;
; notes					ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi, 40, 0)
	
	NumPut(w, bi, 4, "uint")
	, NumPut(h, bi, 8, "uint")
	, NumPut(40, bi, 0, "uint")
	, NumPut(1, bi, 12, "ushort")
	, NumPut(0, bi, 16, "uInt")
	, NumPut(bpp, bi, 14, "ushort")
	
	hbm := DllCall("CreateDIBSection"
					, Ptr, hdc2
					, Ptr, &bi
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "uint*", ppvBits
					, Ptr, 0
					, "uint", 0, Ptr)

	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

;#####################################################################################

; Function				PrintWindow
; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd					A handle to the window that will be copied
; hdc					A handle to the device context
; Flags					Drawing options
;
; return				If the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY			= 1

PrintWindow(hwnd, hdc, Flags=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("PrintWindow", Ptr, hwnd, Ptr, hdc, "uint", Flags)
}

;#####################################################################################

; Function				DestroyIcon
; Description			Destroys an icon and frees any memory the icon occupied
;
; hIcon					Handle to the icon to be destroyed. The icon must not be in use
;
; return				If the function succeeds, the return value is nonzero

DestroyIcon(hIcon)
{
	return DllCall("DestroyIcon", A_PtrSize ? "UPtr" : "UInt", hIcon)
}

;#####################################################################################

PaintDesktop(hdc)
{
	return DllCall("PaintDesktop", A_PtrSize ? "UPtr" : "UInt", hdc)
}

;#####################################################################################

CreateCompatibleBitmap(hdc, w, h)
{
	return DllCall("gdi32\CreateCompatibleBitmap", A_PtrSize ? "UPtr" : "UInt", hdc, "int", w, "int", h)
}

;#####################################################################################

; Function				CreateCompatibleDC
; Description			This function creates a memory device context (DC) compatible with the specified device
;
; hdc					Handle to an existing device context					
;
; return				returns the handle to a device context or 0 on failure
;
; notes					If this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc=0)
{
   return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}

;#####################################################################################

; Function				SelectObject
; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc					Handle to a DC
; hgdiobj				A handle to the object to be selected into the DC
;
; return				If the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes					The specified object must have been created by using one of the following functions
;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;						Font - CreateFont, CreateFontIndirect
;						Pen - CreatePen, CreatePenIndirect
;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes					If the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION			= 2 Region consists of a single rectangle
; COMPLEXREGION			= 3 Region consists of more than one rectangle
; NULLREGION			= 1 Region is empty

SelectObject(hdc, hgdiobj)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}

;#####################################################################################

; Function				DeleteObject
; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;						After the object is deleted, the specified handle is no longer valid
;
; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
   return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

;#####################################################################################

; Function				GetDC
; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window. 
;
; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen					
;
; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd=0)
{
	return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
}

;#####################################################################################

; DCX_CACHE = 0x2
; DCX_CLIPCHILDREN = 0x8
; DCX_CLIPSIBLINGS = 0x10
; DCX_EXCLUDERGN = 0x40
; DCX_EXCLUDEUPDATE = 0x100
; DCX_INTERSECTRGN = 0x80
; DCX_INTERSECTUPDATE = 0x200
; DCX_LOCKWINDOWUPDATE = 0x400
; DCX_NORECOMPUTE = 0x100000
; DCX_NORESETATTRS = 0x4
; DCX_PARENTCLIP = 0x20
; DCX_VALIDATE = 0x200000
; DCX_WINDOW = 0x1

GetDCEx(hwnd, flags=0, hrgnClip=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
    return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
}

;#####################################################################################

; Function				ReleaseDC
; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc					Handle to the device context to be released
; hwnd					Handle to the window whose device context is to be released
;
; return				1 = released
;						0 = not released
;
; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function. 

ReleaseDC(hdc, hwnd=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}

;#####################################################################################

; Function				DeleteDC
; Description			The DeleteDC function deletes the specified device context (DC)
;
; hdc					A handle to the device context
;
; return				If the function succeeds, the return value is nonzero
;
; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
   return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}
;#####################################################################################

; Function				Gdip_LibraryVersion
; Description			Get the current library version
;
; return				the library version
;
; notes					This is useful for non compiled programs to ensure that a person doesn't run an old version when testing your scripts

Gdip_LibraryVersion()
{
	return 1.45
}

;#####################################################################################

; Function				Gdip_LibrarySubVersion
; Description			Get the current library sub version
;
; return				the library sub version
;
; notes					This is the sub-version currently maintained by Rseding91
Gdip_LibrarySubVersion()
{
	return 1.47
}

;#####################################################################################

; Function:    			Gdip_BitmapFromBRA
; Description: 			Gets a pointer to a gdi+ bitmap from a BRA file
;
; BRAFromMemIn			The variable for a BRA file read to memory
; File					The name of the file, or its number that you would like (This depends on alternate parameter)
; Alternate				Changes whether the File parameter is the file name or its number
;
; return      			If the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1 = The BRA variable is empty
;						-2 = The BRA has an incorrect header
;						-3 = The BRA has information missing
;						-4 = Could not find file inside the BRA

Gdip_BitmapFromBRA(ByRef BRAFromMemIn, File, Alternate=0)
{
	Static FName = "ObjRelease"
	
	if !BRAFromMemIn
		return -1
	Loop, Parse, BRAFromMemIn, `n
	{
		if (A_Index = 1)
		{
			StringSplit, Header, A_LoopField, |
			if (Header0 != 4 || Header2 != "BRA!")
				return -2
		}
		else if (A_Index = 2)
		{
			StringSplit, Info, A_LoopField, |
			if (Info0 != 3)
				return -3
		}
		else
			break
	}
	if !Alternate
		StringReplace, File, File, \, \\, All
	RegExMatch(BRAFromMemIn, "mi`n)^" (Alternate ? File "\|.+?\|(\d+)\|(\d+)" : "\d+\|" File "\|(\d+)\|(\d+)") "$", FileInfo)
	if !FileInfo
		return -4
	
	hData := DllCall("GlobalAlloc", "uint", 2, Ptr, FileInfo2, Ptr)
	pData := DllCall("GlobalLock", Ptr, hData, Ptr)
	DllCall("RtlMoveMemory", Ptr, pData, Ptr, &BRAFromMemIn+Info2+FileInfo1, Ptr, FileInfo2)
	DllCall("GlobalUnlock", Ptr, hData)
	DllCall("ole32\CreateStreamOnHGlobal", Ptr, hData, "int", 1, A_PtrSize ? "UPtr*" : "UInt*", pStream)
	DllCall("gdiplus\GdipCreateBitmapFromStream", Ptr, pStream, A_PtrSize ? "UPtr*" : "UInt*", pBitmap)
	If (A_PtrSize)
		%FName%(pStream)
	Else
		DllCall(NumGet(NumGet(1*pStream)+8), "uint", pStream)
	return pBitmap
}

;#####################################################################################

; Function				Gdip_DrawRectangle
; Description			This function uses a pen to draw the outline of a rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawRoundedRectangle
; Description			This function uses a pen to draw the outline of a rounded rectangle into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	Gdip_ResetClip(pGraphics)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_ResetClip(pGraphics)
	return E
}

;#####################################################################################

; Function				Gdip_DrawEllipse
; Description			This function uses a pen to draw the outline of an ellipse into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the top left of the rectangle the ellipse will be drawn into
; y						y-coordinate of the top left of the rectangle the ellipse will be drawn into
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_DrawBezier
; Description			This function uses a pen to draw the outline of a bezier (a weighted curve) into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the bezier
; y1					y-coordinate of the start of the bezier
; x2					x-coordinate of the first arc of the bezier
; y2					y-coordinate of the first arc of the bezier
; x3					x-coordinate of the second arc of the bezier
; y3					y-coordinate of the second arc of the bezier
; x4					x-coordinate of the end of the bezier
; y4					y-coordinate of the end of the bezier
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawBezier(pGraphics, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawBezier"
					, Ptr, pgraphics
					, Ptr, pPen
					, "float", x1
					, "float", y1
					, "float", x2
					, "float", y2
					, "float", x3
					, "float", y3
					, "float", x4
					, "float", y4)
}

;#####################################################################################

; Function				Gdip_DrawArc
; Description			This function uses a pen to draw the outline of an arc into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the arc
; y						y-coordinate of the start of the arc
; w						width of the arc
; h						height of the arc
; StartAngle			specifies the angle between the x-axis and the starting point of the arc
; SweepAngle			specifies the angle between the starting and ending points of the arc
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawArc"
					, Ptr, pGraphics
					, Ptr, pPen
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "float", StartAngle
					, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawPie
; Description			This function uses a pen to draw the outline of a pie into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x						x-coordinate of the start of the pie
; y						y-coordinate of the start of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success
;
; notes					as all coordinates are taken from the top left of each pixel, then the entire width/height should be specified as subtracting the pen width

Gdip_DrawPie(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawPie", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_DrawLine
; Description			This function uses a pen to draw a line into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; x1					x-coordinate of the start of the line
; y1					y-coordinate of the start of the line
; x2					x-coordinate of the end of the line
; y2					y-coordinate of the end of the line
;
; return				status enumeration. 0 = success		

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawLine"
					, Ptr, pGraphics
					, Ptr, pPen
					, "float", x1
					, "float", y1
					, "float", x2
					, "float", y2)
}

;#####################################################################################

; Function				Gdip_DrawLines
; Description			This function uses a pen to draw a series of joined lines into the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pPen					Pointer to a pen
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success				

Gdip_DrawLines(pGraphics, pPen, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}
	return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointF, "int", Points0)
}

;#####################################################################################

; Function				Gdip_FillRectangle
; Description			This function uses a brush to fill a rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rectangle
; y						y-coordinate of the top left of the rectangle
; w						width of the rectanlge
; h						height of the rectangle
;
; return				status enumeration. 0 = success

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillRectangle"
					, Ptr, pGraphics
					, Ptr, pBrush
					, "float", x
					, "float", y
					, "float", w
					, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRoundedRectangle
; Description			This function uses a brush to fill a rounded rectangle in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the rounded rectangle
; y						y-coordinate of the top left of the rounded rectangle
; w						width of the rectanlge
; h						height of the rectangle
; r						radius of the rounded corners
;
; return				status enumeration. 0 = success

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	return E
}

;#####################################################################################

; Function				Gdip_FillPolygon
; Description			This function uses a brush to fill a polygon in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Points				the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return				status enumeration. 0 = success
;
; notes					Alternate will fill the polygon as a whole, wheras winding will fill each new "segment"
; Alternate 			= 0
; Winding 				= 1

Gdip_FillPolygon(pGraphics, pBrush, Points, FillMode=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}   
	return DllCall("gdiplus\GdipFillPolygon", Ptr, pGraphics, Ptr, pBrush, Ptr, &PointF, "int", Points0, "int", FillMode)
}

;#####################################################################################

; Function				Gdip_FillPie
; Description			This function uses a brush to fill a pie in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the pie
; y						y-coordinate of the top left of the pie
; w						width of the pie
; h						height of the pie
; StartAngle			specifies the angle between the x-axis and the starting point of the pie
; SweepAngle			specifies the angle between the starting and ending points of the pie
;
; return				status enumeration. 0 = success

Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillPie"
					, Ptr, pGraphics
					, Ptr, pBrush
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "float", StartAngle
					, "float", SweepAngle)
}

;#####################################################################################

; Function				Gdip_FillEllipse
; Description			This function uses a brush to fill an ellipse in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; x						x-coordinate of the top left of the ellipse
; y						y-coordinate of the top left of the ellipse
; w						width of the ellipse
; h						height of the ellipse
;
; return				status enumeration. 0 = success

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}

;#####################################################################################

; Function				Gdip_FillRegion
; Description			This function uses a brush to fill a region in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Region
;
; return				status enumeration. 0 = success
;
; notes					You can create a region Gdip_CreateRegion() and then add to this

Gdip_FillRegion(pGraphics, pBrush, Region)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillRegion", Ptr, pGraphics, Ptr, pBrush, Ptr, Region)
}

;#####################################################################################

; Function				Gdip_FillPath
; Description			This function uses a brush to fill a path in the Graphics of a bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBrush				Pointer to a brush
; Region				Pointer to a Path
;
; return				status enumeration. 0 = success

Gdip_FillPath(pGraphics, pBrush, Path)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, Path)
}

;#####################################################################################

; Function				Gdip_DrawImagePointsRect
; Description			This function draws a bitmap into the Graphics of another bitmap and skews it
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; Points				Points passed as x1,y1|x2,y2|x3,y3 (3 points: top left, top right, bottom left) describing the drawing of the bitmap
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source rectangle
; sh					height of source rectangle
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter

Gdip_DrawImagePointsRect(pGraphics, pBitmap, Points, sx="", sy="", sw="", sh="", Matrix=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}

	if (Matrix&1 = "")
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
		
	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		sx := 0, sy := 0
		sw := Gdip_GetImageWidth(pBitmap)
		sh := Gdip_GetImageHeight(pBitmap)
	}

	E := DllCall("gdiplus\GdipDrawImagePointsRect"
				, Ptr, pGraphics
				, Ptr, pBitmap
				, Ptr, &PointF
				, "int", Points0
				, "float", sx
				, "float", sy
				, "float", sw
				, "float", sh
				, "int", 2
				, Ptr, ImageAttr
				, Ptr, 0
				, Ptr, 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return E
}

;#####################################################################################

; Function				Gdip_DrawImage
; Description			This function draws a bitmap into the Graphics of another bitmap
;
; pGraphics				Pointer to the Graphics of a bitmap
; pBitmap				Pointer to a bitmap to be drawn
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of destination image
; dh					height of destination image
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; sw					width of source image
; sh					height of source image
; Matrix				a matrix used to alter image attributes when drawing
;
; return				status enumeration. 0 = success
;
; notes					if sx,sy,sw,sh are missed then the entire source bitmap will be used
;						Gdip_DrawImage performs faster
;						Matrix can be omitted to just draw with no alteration to ARGB
;						Matrix may be passed as a digit from 0 - 1 to change just transparency
;						Matrix can be passed as a matrix with any delimiter. For example:
;						MatrixBright=
;						(
;						1.5		|0		|0		|0		|0
;						0		|1.5	|0		|0		|0
;						0		|0		|1.5	|0		|0
;						0		|0		|0		|1		|0
;						0.05	|0.05	|0.05	|0		|1
;						)
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (Matrix&1 = "")
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		if (dx = "" && dy = "" && dw = "" && dh = "")
		{
			sx := dx := 0, sy := dy := 0
			sw := dw := Gdip_GetImageWidth(pBitmap)
			sh := dh := Gdip_GetImageHeight(pBitmap)
		}
		else
		{
			sx := sy := 0
			sw := Gdip_GetImageWidth(pBitmap)
			sh := Gdip_GetImageHeight(pBitmap)
		}
	}

	E := DllCall("gdiplus\GdipDrawImageRectRect"
				, Ptr, pGraphics
				, Ptr, pBitmap
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "float", sx
				, "float", sy
				, "float", sw
				, "float", sh
				, "int", 2
				, Ptr, ImageAttr
				, Ptr, 0
				, Ptr, 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return E
}

;#####################################################################################

; Function				Gdip_SetImageAttributesColorMatrix
; Description			This function creates an image matrix ready for drawing
;
; Matrix				a matrix used to alter image attributes when drawing
;						passed with any delimeter
;
; return				returns an image matrix on sucess or 0 if it fails
;
; notes					MatrixBright = 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1
;						MatrixGreyScale = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1
;						MatrixNegative = -1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|0|0|0|0|1

Gdip_SetImageAttributesColorMatrix(Matrix)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	VarSetCapacity(ColourMatrix, 100, 0)
	Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
	StringSplit, Matrix, Matrix, |
	Loop, 25
	{
		Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
		NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes", A_PtrSize ? "UPtr*" : "uint*", ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", Ptr, ImageAttr, "int", 1, "int", 1, Ptr, &ColourMatrix, Ptr, 0, "int", 0)
	return ImageAttr
}

;#####################################################################################

; Function				Gdip_GraphicsFromImage
; Description			This function gets the graphics for a bitmap used for drawing functions
;
; pBitmap				Pointer to a bitmap to get the pointer to its graphics
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					a bitmap can be drawn into the graphics of another bitmap

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
	return pGraphics
}

;#####################################################################################

; Function				Gdip_GraphicsFromHDC
; Description			This function gets the graphics from the handle to a device context
;
; hdc					This is the handle to the device context
;
; return				returns a pointer to the graphics of a bitmap
;
; notes					You can draw a bitmap into the graphics of another bitmap

Gdip_GraphicsFromHDC(hdc)
{
    DllCall("gdiplus\GdipCreateFromHDC", A_PtrSize ? "UPtr" : "UInt", hdc, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
    return pGraphics
}

;#####################################################################################

; Function				Gdip_GetDC
; Description			This function gets the device context of the passed Graphics
;
; hdc					This is the handle to the device context
;
; return				returns the device context for the graphics of a bitmap

Gdip_GetDC(pGraphics)
{
	DllCall("gdiplus\GdipGetDC", A_PtrSize ? "UPtr" : "UInt", pGraphics, A_PtrSize ? "UPtr*" : "UInt*", hdc)
	return hdc
}

;#####################################################################################

; Function				Gdip_ReleaseDC
; Description			This function releases a device context from use for further use
;
; pGraphics				Pointer to the graphics of a bitmap
; hdc					This is the handle to the device context
;
; return				status enumeration. 0 = success

Gdip_ReleaseDC(pGraphics, hdc)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipReleaseDC", Ptr, pGraphics, Ptr, hdc)
}

;#####################################################################################

; Function				Gdip_GraphicsClear
; Description			Clears the graphics of a bitmap ready for further drawing
;
; pGraphics				Pointer to the graphics of a bitmap
; ARGB					The colour to clear the graphics to
;
; return				status enumeration. 0 = success
;
; notes					By default this will make the background invisible
;						Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics

Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
{
    return DllCall("gdiplus\GdipGraphicsClear", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_BlurBitmap
; Description			Gives a pointer to a blurred bitmap from a pointer to a bitmap
;
; pBitmap				Pointer to a bitmap to be blurred
; Blur					The Amount to blur a bitmap by from 1 (least blur) to 100 (most blur)
;
; return				If the function succeeds, the return value is a pointer to the new blurred bitmap
;						-1 = The blur parameter is outside the range 1-100
;
; notes					This function will not dispose of the original bitmap

Gdip_BlurBitmap(pBitmap, Blur)
{
	if (Blur > 100) || (Blur < 1)
		return -1	
	
	sWidth := Gdip_GetImageWidth(pBitmap), sHeight := Gdip_GetImageHeight(pBitmap)
	dWidth := sWidth//Blur, dHeight := sHeight//Blur

	pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight)
	G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetInterpolationMode(G1, 7)
	Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, sWidth, sHeight)

	Gdip_DeleteGraphics(G1)

	pBitmap2 := Gdip_CreateBitmap(sWidth, sHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_SetInterpolationMode(G2, 7)
	Gdip_DrawImage(G2, pBitmap1, 0, 0, sWidth, sHeight, 0, 0, dWidth, dHeight)

	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(pBitmap1)
	return pBitmap2
}

;#####################################################################################

; Function:     		Gdip_SaveBitmapToFile
; Description:  		Saves a bitmap to a file in any supported format onto disk
;   
; pBitmap				Pointer to a bitmap
; sOutput      			The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality      			If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return      			If the function succeeds, the return value is zero, otherwise:
;						-1 = Extension supplied is not a supported file format
;						-2 = Could not get a list of encoders on system
;						-3 = Could not find matching encoder for specified file format
;						-4 = Could not get WideChar name of output file
;						-5 = Could not save file to disk
;
; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality=75)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	SplitPath, sOutput,,, Extension
	if Extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
		return -1
	Extension := "." Extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
	if !(nCount && nSize)
		return -2
	
	If (A_IsUnicode){
		StrGet_Name := "StrGet"
		Loop, %nCount%
		{
			sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
			if !InStr(sString, "*" Extension)
				continue
			
			pCodec := &ci+idx
			break
		}
	} else {
		Loop, %nCount%
		{
			Location := NumGet(ci, 76*(A_Index-1)+44)
			nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int",  0, "uint", 0, "uint", 0)
			VarSetCapacity(sString, nSize)
			DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
			if !InStr(sString, "*" Extension)
				continue
			
			pCodec := &ci+76*(A_Index-1)
			break
		}
	}
	
	if !pCodec
		return -3

	if (Quality != 75)
	{
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
		if Extension in .JPG,.JPEG,.JPE,.JFIF
		{
			DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
			VarSetCapacity(EncoderParameters, nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
			Loop, % NumGet(EncoderParameters, "UInt")      ;%
			{
				elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
				if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
				{
					p := elem+&EncoderParameters-pad-4
					NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
					break
				}
			}      
		}
	}

	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wOutput, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize)
		VarSetCapacity(wOutput, -1)
		if !VarSetCapacity(wOutput)
			return -4
		E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", p ? p : 0)
	}
	else
		E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", p ? p : 0)
	return E ? -5 : 0
}

;#####################################################################################

; Function				Gdip_GetPixel
; Description			Gets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				Returns the ARGB value of the pixel

Gdip_GetPixel(pBitmap, x, y)
{
	DllCall("gdiplus\GdipBitmapGetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "uint*", ARGB)
	return ARGB
}

;#####################################################################################

; Function				Gdip_SetPixel
; Description			Sets the ARGB of a pixel in a bitmap
;
; pBitmap				Pointer to a bitmap
; x						x-coordinate of the pixel
; y						y-coordinate of the pixel
;
; return				status enumeration. 0 = success

Gdip_SetPixel(pBitmap, x, y, ARGB)
{
   return DllCall("gdiplus\GdipBitmapSetPixel", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", x, "int", y, "int", ARGB)
}

;#####################################################################################

; Function				Gdip_GetImageWidth
; Description			Gives the width of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the width in pixels of the supplied bitmap

Gdip_GetImageWidth(pBitmap)
{
   DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
   return Width
}

;#####################################################################################

; Function				Gdip_GetImageHeight
; Description			Gives the height of a bitmap
;
; pBitmap				Pointer to a bitmap
;
; return				Returns the height in pixels of the supplied bitmap

Gdip_GetImageHeight(pBitmap)
{
   DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
   return Height
}

;#####################################################################################

; Function				Gdip_GetDimensions
; Description			Gives the width and height of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	DllCall("gdiplus\GdipGetImageWidth", Ptr, pBitmap, "uint*", Width)
	DllCall("gdiplus\GdipGetImageHeight", Ptr, pBitmap, "uint*", Height)
}

;#####################################################################################

Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Gdip_GetImageDimensions(pBitmap, Width, Height)
}

;#####################################################################################

Gdip_GetImagePixelFormat(pBitmap)
{
	DllCall("gdiplus\GdipGetImagePixelFormat", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", Format)
	return Format
}

;#####################################################################################

; Function				Gdip_GetDpiX
; Description			Gives the horizontal dots per inch of the graphics of a bitmap
;
; pBitmap				Pointer to a bitmap
; Width					ByRef variable. This variable will be set to the width of the bitmap
; Height				ByRef variable. This variable will be set to the height of the bitmap
;
; return				No return value
;						Gdip_GetDimensions(pBitmap, ThisWidth, ThisHeight) will set ThisWidth to the width and ThisHeight to the height

Gdip_GetDpiX(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiX", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpix)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetDpiY(pGraphics)
{
	DllCall("gdiplus\GdipGetDpiY", A_PtrSize ? "UPtr" : "uint", pGraphics, "float*", dpiy)
	return Round(dpiy)
}

;#####################################################################################

Gdip_GetImageHorizontalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageHorizontalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpix)
	return Round(dpix)
}

;#####################################################################################

Gdip_GetImageVerticalResolution(pBitmap)
{
	DllCall("gdiplus\GdipGetImageVerticalResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float*", dpiy)
	return Round(dpiy)
}

;#####################################################################################

Gdip_BitmapSetResolution(pBitmap, dpix, dpiy)
{
	return DllCall("gdiplus\GdipBitmapSetResolution", A_PtrSize ? "UPtr" : "uint", pBitmap, "float", dpix, "float", dpiy)
}

;#####################################################################################

Gdip_CreateBitmapFromFile(sFile, IconNumber=1, IconSize="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	, PtrA := A_PtrSize ? "UPtr*" : "UInt*"
	
	SplitPath, sFile,,, ext
	if ext in exe,dll
	{
		Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
		BufSize := 16 + (2*(A_PtrSize ? A_PtrSize : 4))
		
		VarSetCapacity(buf, BufSize, 0)
		Loop, Parse, Sizes, |
		{
			DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", A_LoopField, "int", A_LoopField, PtrA, hIcon, PtrA, 0, "uint", 1, "uint", 0)
			
			if !hIcon
				continue

			if !DllCall("GetIconInfo", Ptr, hIcon, Ptr, &buf)
			{
				DestroyIcon(hIcon)
				continue
			}
			
			hbmMask  := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
			hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
			if !(hbmColor && DllCall("GetObject", Ptr, hbmColor, "int", BufSize, Ptr, &buf))
			{
				DestroyIcon(hIcon)
				continue
			}
			break
		}
		if !hIcon
			return -1

		Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
		hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		if !DllCall("DrawIconEx", Ptr, hdc, "int", 0, "int", 0, Ptr, hIcon, "uint", Width, "uint", Height, "uint", 0, Ptr, 0, "uint", 3)
		{
			DestroyIcon(hIcon)
			return -2
		}
		
		VarSetCapacity(dib, 104)
		DllCall("GetObject", Ptr, hbm, "int", A_PtrSize = 8 ? 104 : 84, Ptr, &dib) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
		Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0)) ; padding
		DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, Ptr, Bits, PtrA, pBitmapOld)
		pBitmap := Gdip_CreateBitmap(Width, Height)
		G := Gdip_GraphicsFromImage(pBitmap)
		, Gdip_DrawImage(G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
		SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapOld)
		DestroyIcon(hIcon)
	}
	else
	{
		if (!A_IsUnicode)
		{
			VarSetCapacity(wFile, 1024)
			DllCall("kernel32\MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sFile, "int", -1, Ptr, &wFile, "int", 512)
			DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &wFile, PtrA, pBitmap)
		}
		else
			DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &sFile, PtrA, pBitmap)
	}
	
	return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hbm, "int", Background)
	return hbm
}

;#####################################################################################

Gdip_CreateBitmapFromHICON(hIcon)
{
	DllCall("gdiplus\GdipCreateBitmapFromHICON", A_PtrSize ? "UPtr" : "UInt", hIcon, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_CreateHICONFromBitmap(pBitmap)
{
	DllCall("gdiplus\GdipCreateHICONFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hIcon)
	return hIcon
}

;#####################################################################################

Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, A_PtrSize ? "UPtr" : "UInt", 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    Return pBitmap
}

;#####################################################################################

Gdip_CreateBitmapFromClipboard()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if !DllCall("OpenClipboard", Ptr, 0)
		return -1
	if !DllCall("IsClipboardFormatAvailable", "uint", 8)
		return -2
	if !hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
		return -3
	if !pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
		return -4
	if !DllCall("CloseClipboard")
		return -5
	DeleteObject(hBitmap)
	return pBitmap
}

;#####################################################################################

Gdip_SetBitmapToClipboard(pBitmap)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
	hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
	pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
	DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
	DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), Ptr), Ptr, NumGet(oi, off1, "UInt"))
	DllCall("GlobalUnlock", Ptr, hdib)
	DllCall("DeleteObject", Ptr, hBitmap)
	DllCall("OpenClipboard", Ptr, 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "uint", 8, Ptr, hdib)
	DllCall("CloseClipboard")
}

;#####################################################################################

Gdip_CloneBitmapArea(pBitmap, x, y, w, h, Format=0x26200A)
{
	DllCall("gdiplus\GdipCloneBitmapArea"
					, "float", x
					, "float", y
					, "float", w
					, "float", h
					, "int", Format
					, A_PtrSize ? "UPtr" : "UInt", pBitmap
					, A_PtrSize ? "UPtr*" : "UInt*", pBitmapDest)
	return pBitmapDest
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_CreatePen(ARGB, w)
{
   DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
   return pPen
}

;#####################################################################################

Gdip_CreatePenFromBrush(pBrush, w)
{
	DllCall("gdiplus\GdipCreatePen2", A_PtrSize ? "UPtr" : "UInt", pBrush, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
	return pPen
}

;#####################################################################################

Gdip_BrushCreateSolid(ARGB=0xff000000)
{
	DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}

;#####################################################################################

; HatchStyleHorizontal = 0
; HatchStyleVertical = 1
; HatchStyleForwardDiagonal = 2
; HatchStyleBackwardDiagonal = 3
; HatchStyleCross = 4
; HatchStyleDiagonalCross = 5
; HatchStyle05Percent = 6
; HatchStyle10Percent = 7
; HatchStyle20Percent = 8
; HatchStyle25Percent = 9
; HatchStyle30Percent = 10
; HatchStyle40Percent = 11
; HatchStyle50Percent = 12
; HatchStyle60Percent = 13
; HatchStyle70Percent = 14
; HatchStyle75Percent = 15
; HatchStyle80Percent = 16
; HatchStyle90Percent = 17
; HatchStyleLightDownwardDiagonal = 18
; HatchStyleLightUpwardDiagonal = 19
; HatchStyleDarkDownwardDiagonal = 20
; HatchStyleDarkUpwardDiagonal = 21
; HatchStyleWideDownwardDiagonal = 22
; HatchStyleWideUpwardDiagonal = 23
; HatchStyleLightVertical = 24
; HatchStyleLightHorizontal = 25
; HatchStyleNarrowVertical = 26
; HatchStyleNarrowHorizontal = 27
; HatchStyleDarkVertical = 28
; HatchStyleDarkHorizontal = 29
; HatchStyleDashedDownwardDiagonal = 30
; HatchStyleDashedUpwardDiagonal = 31
; HatchStyleDashedHorizontal = 32
; HatchStyleDashedVertical = 33
; HatchStyleSmallConfetti = 34
; HatchStyleLargeConfetti = 35
; HatchStyleZigZag = 36
; HatchStyleWave = 37
; HatchStyleDiagonalBrick = 38
; HatchStyleHorizontalBrick = 39
; HatchStyleWeave = 40
; HatchStylePlaid = 41
; HatchStyleDivot = 42
; HatchStyleDottedGrid = 43
; HatchStyleDottedDiamond = 44
; HatchStyleShingle = 45
; HatchStyleTrellis = 46
; HatchStyleSphere = 47
; HatchStyleSmallGrid = 48
; HatchStyleSmallCheckerBoard = 49
; HatchStyleLargeCheckerBoard = 50
; HatchStyleOutlinedDiamond = 51
; HatchStyleSolidDiamond = 52
; HatchStyleTotal = 53
Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
{
	DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}

;#####################################################################################

Gdip_CreateTextureBrush(pBitmap, WrapMode=1, x=0, y=0, w="", h="")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	, PtrA := A_PtrSize ? "UPtr*" : "UInt*"
	
	if !(w && h)
		DllCall("gdiplus\GdipCreateTexture", Ptr, pBitmap, "int", WrapMode, PtrA, pBrush)
	else
		DllCall("gdiplus\GdipCreateTexture2", Ptr, pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, PtrA, pBrush)
	return pBrush
}

;#####################################################################################

; WrapModeTile = 0
; WrapModeTileFlipX = 1
; WrapModeTileFlipY = 2
; WrapModeTileFlipXY = 3
; WrapModeClamp = 4
Gdip_CreateLineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	CreatePointF(PointF1, x1, y1), CreatePointF(PointF2, x2, y2)
	DllCall("gdiplus\GdipCreateLineBrush", Ptr, &PointF1, Ptr, &PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
	return LGpBrush
}

;#####################################################################################

; LinearGradientModeHorizontal = 0
; LinearGradientModeVertical = 1
; LinearGradientModeForwardDiagonal = 2
; LinearGradientModeBackwardDiagonal = 3
Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
	CreateRectF(RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", A_PtrSize ? "UPtr" : "UInt", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
	return LGpBrush
}

;#####################################################################################

Gdip_CloneBrush(pBrush)
{
	DllCall("gdiplus\GdipCloneBrush", A_PtrSize ? "UPtr" : "UInt", pBrush, A_PtrSize ? "UPtr*" : "UInt*", pBrushClone)
	return pBrushClone
}

;#####################################################################################
; Delete resources
;#####################################################################################

Gdip_DeletePen(pPen)
{
   return DllCall("gdiplus\GdipDeletePen", A_PtrSize ? "UPtr" : "UInt", pPen)
}

;#####################################################################################

Gdip_DeleteBrush(pBrush)
{
   return DllCall("gdiplus\GdipDeleteBrush", A_PtrSize ? "UPtr" : "UInt", pBrush)
}

;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
   return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}

;#####################################################################################

Gdip_DeleteGraphics(pGraphics)
{
   return DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

;#####################################################################################

Gdip_DisposeImageAttributes(ImageAttr)
{
	return DllCall("gdiplus\GdipDisposeImageAttributes", A_PtrSize ? "UPtr" : "UInt", ImageAttr)
}

;#####################################################################################

Gdip_DeleteFont(hFont)
{
   return DllCall("gdiplus\GdipDeleteFont", A_PtrSize ? "UPtr" : "UInt", hFont)
}

;#####################################################################################

Gdip_DeleteStringFormat(hFormat)
{
   return DllCall("gdiplus\GdipDeleteStringFormat", A_PtrSize ? "UPtr" : "UInt", hFormat)
}

;#####################################################################################

Gdip_DeleteFontFamily(hFamily)
{
   return DllCall("gdiplus\GdipDeleteFontFamily", A_PtrSize ? "UPtr" : "UInt", hFamily)
}

;#####################################################################################

Gdip_DeleteMatrix(Matrix)
{
   return DllCall("gdiplus\GdipDeleteMatrix", A_PtrSize ? "UPtr" : "UInt", Matrix)
}

;#####################################################################################
; Text functions
;#####################################################################################

Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
{
	IWidth := Width, IHeight:= Height
	
	RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
	RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
	RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
	RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
	RegExMatch(Options, "i)NoWrap", NoWrap)
	RegExMatch(Options, "i)R(\d)", Rendering)
	RegExMatch(Options, "i)S(\d+)(p*)", Size)

	if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
		PassBrush := 1, pBrush := Colour2
	
	if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
		return -1

	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		if RegExMatch(Options, "\b" A_loopField)
		Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
  
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		if RegExMatch(Options, "\b" A_loopField)
			Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}

	xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
	ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
	Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
	Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
	if !PassBrush
		Colour := "0x" (Colour2 ? Colour2 : "ff000000")
	Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
	Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12

	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
	if !(hFamily && hFont && hFormat && pBrush && pGraphics)
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
   
	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

	if vPos
	{
		StringSplit, ReturnRC, ReturnRC, |
		
		if (vPos = "vCentre") || (vPos = "vCenter")
			ypos += (Height-ReturnRC4)//2
		else if (vPos = "Top") || (vPos = "Up")
			ypos := 0
		else if (vPos = "Bottom") || (vPos = "Down")
			ypos := Height-ReturnRC4
		
		CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	}

	if !Measure
		E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)

	if !PassBrush
		Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)   
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}

;#####################################################################################

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}
	
	return DllCall("gdiplus\GdipDrawString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, pBrush)
}

;#####################################################################################

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	VarSetCapacity(RC, 16)
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)   
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}
	
	DllCall("gdiplus\GdipMeasureString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, &RC
					, "uint*", Chars
					, "uint*", Lines)
	
	return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

; Near = 0
; Center = 1
; Far = 2
Gdip_SetStringFormatAlign(hFormat, Align)
{
   return DllCall("gdiplus\GdipSetStringFormatAlign", A_PtrSize ? "UPtr" : "UInt", hFormat, "int", Align)
}

; StringFormatFlagsDirectionRightToLeft    = 0x00000001
; StringFormatFlagsDirectionVertical       = 0x00000002
; StringFormatFlagsNoFitBlackBox           = 0x00000004
; StringFormatFlagsDisplayFormatControl    = 0x00000020
; StringFormatFlagsNoFontFallback          = 0x00000400
; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
; StringFormatFlagsNoWrap                  = 0x00001000
; StringFormatFlagsLineLimit               = 0x00002000
; StringFormatFlagsNoClip                  = 0x00004000 
Gdip_StringFormatCreate(Format=0, Lang=0)
{
   DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
   return hFormat
}

; Regular = 0
; Bold = 1
; Italic = 2
; BoldItalic = 3
; Underline = 4
; Strikeout = 8
Gdip_FontCreate(hFamily, Size, Style=0)
{
   DllCall("gdiplus\GdipCreateFont", A_PtrSize ? "UPtr" : "UInt", hFamily, "float", Size, "int", Style, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFont)
   return hFont
}

Gdip_FontFamilyCreate(Font)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wFont, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, Ptr, &wFont, "int", nSize)
	}
	
	DllCall("gdiplus\GdipCreateFontFamilyFromName"
					, Ptr, A_IsUnicode ? &Font : &wFont
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "UInt*", hFamily)
	
	return hFamily
}

;#####################################################################################
; Matrix functions
;#####################################################################################

Gdip_CreateAffineMatrix(m11, m12, m21, m22, x, y)
{
   DllCall("gdiplus\GdipCreateMatrix2", "float", m11, "float", m12, "float", m21, "float", m22, "float", x, "float", y, A_PtrSize ? "UPtr*" : "UInt*", Matrix)
   return Matrix
}

Gdip_CreateMatrix()
{
   DllCall("gdiplus\GdipCreateMatrix", A_PtrSize ? "UPtr*" : "UInt*", Matrix)
   return Matrix
}

;#####################################################################################
; GraphicsPath functions
;#####################################################################################

; Alternate = 0
; Winding = 1
Gdip_CreatePath(BrushMode=0)
{
	DllCall("gdiplus\GdipCreatePath", "int", BrushMode, A_PtrSize ? "UPtr*" : "UInt*", Path)
	return Path
}

Gdip_AddPathEllipse(Path, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", A_PtrSize ? "UPtr" : "UInt", Path, "float", x, "float", y, "float", w, "float", h)
}

Gdip_AddPathPolygon(Path, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}   

	return DllCall("gdiplus\GdipAddPathPolygon", Ptr, Path, Ptr, &PointF, "int", Points0)
}

Gdip_DeletePath(Path)
{
	return DllCall("gdiplus\GdipDeletePath", A_PtrSize ? "UPtr" : "UInt", Path)
}

;#####################################################################################
; Quality functions
;#####################################################################################

; SystemDefault = 0
; SingleBitPerPixelGridFit = 1
; SingleBitPerPixel = 2
; AntiAliasGridFit = 3
; AntiAlias = 4
Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", RenderingHint)
}

; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
{
   return DllCall("gdiplus\GdipSetInterpolationMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", InterpolationMode)
}

; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
   return DllCall("gdiplus\GdipSetSmoothingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", SmoothingMode)
}

; CompositingModeSourceOver = 0 (blended)
; CompositingModeSourceCopy = 1 (overwrite)
Gdip_SetCompositingMode(pGraphics, CompositingMode=0)
{
   return DllCall("gdiplus\GdipSetCompositingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", CompositingMode)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}

Gdip_Shutdown(pToken)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("FreeLibrary", Ptr, hModule)
	return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.
Gdip_RotateWorldTransform(pGraphics, Angle, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipRotateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", Angle, "int", MatrixOrder)
}

Gdip_ScaleWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipScaleWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_TranslateWorldTransform(pGraphics, x, y, MatrixOrder=0)
{
	return DllCall("gdiplus\GdipTranslateWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "int", MatrixOrder)
}

Gdip_ResetWorldTransform(pGraphics)
{
	return DllCall("gdiplus\GdipResetWorldTransform", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

Gdip_GetRotatedTranslation(Width, Height, Angle, ByRef xTranslation, ByRef yTranslation)
{
	pi := 3.14159, TAngle := Angle*(pi/180)	

	Bound := (Angle >= 0) ? Mod(Angle, 360) : 360-Mod(-Angle, -360)
	if ((Bound >= 0) && (Bound <= 90))
		xTranslation := Height*Sin(TAngle), yTranslation := 0
	else if ((Bound > 90) && (Bound <= 180))
		xTranslation := (Height*Sin(TAngle))-(Width*Cos(TAngle)), yTranslation := -Height*Cos(TAngle)
	else if ((Bound > 180) && (Bound <= 270))
		xTranslation := -(Width*Cos(TAngle)), yTranslation := -(Height*Cos(TAngle))-(Width*Sin(TAngle))
	else if ((Bound > 270) && (Bound <= 360))
		xTranslation := 0, yTranslation := -Width*Sin(TAngle)
}

Gdip_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)
	if !(Width && Height)
		return -1
	RWidth := Ceil(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Ceil(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

; RotateNoneFlipNone   = 0
; Rotate90FlipNone     = 1
; Rotate180FlipNone    = 2
; Rotate270FlipNone    = 3
; RotateNoneFlipX      = 4
; Rotate90FlipX        = 5
; Rotate180FlipX       = 6
; Rotate270FlipX       = 7
; RotateNoneFlipY      = Rotate180FlipX
; Rotate90FlipY        = Rotate270FlipX
; Rotate180FlipY       = RotateNoneFlipX
; Rotate270FlipY       = Rotate90FlipX
; RotateNoneFlipXY     = Rotate180FlipNone
; Rotate90FlipXY       = Rotate270FlipNone
; Rotate180FlipXY      = RotateNoneFlipNone
; Rotate270FlipXY      = Rotate90FlipNone 

Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
{
	return DllCall("gdiplus\GdipImageRotateFlip", A_PtrSize ? "UPtr" : "UInt", pBitmap, "int", RotateFlipType)
}

; Replace = 0
; Intersect = 1
; Union = 2
; Xor = 3
; Exclude = 4
; Complement = 5
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
   return DllCall("gdiplus\GdipSetClipRect",  A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, Path, "int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
   return DllCall("gdiplus\GdipResetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics, "UInt*", Region)
	return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", A_PtrSize ? "UPtr" : "UInt", Region)
}

;#####################################################################################
; BitmapLockBits
;#####################################################################################

Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	CreateRect(Rect, x, y, w, h)
	VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
	E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
	Stride := NumGet(BitmapData, 8, "Int")
	Scan0 := NumGet(BitmapData, 16, Ptr)
	return E
}

;#####################################################################################

Gdip_UnlockBits(pBitmap, ByRef BitmapData)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
}

;#####################################################################################

Gdip_SetLockBitPixel(ARGB, Scan0, x, y, Stride)
{
	Numput(ARGB, Scan0+0, (x*4)+(y*Stride), "UInt")
}

;#####################################################################################

Gdip_GetLockBitPixel(Scan0, x, y, Stride)
{
	return NumGet(Scan0+0, (x*4)+(y*Stride), "UInt")
}

;#####################################################################################

Gdip_PixelateBitmap(pBitmap, ByRef pBitmapOut, BlockSize)
{
	static PixelateBitmap
	
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!PixelateBitmap)
	{
		if A_PtrSize != 8 ; x86 machine code
		MCode_PixelateBitmap =
		(LTrim Join
		558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
		397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
		8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
		4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
		C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
		8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
		148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
		B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
		F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
		038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
		1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
		FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
		D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
		45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
		89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
		0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
		75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
		8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
		B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
		451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
		75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
		8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
		)
		else ; x64 machine code
		MCode_PixelateBitmap =
		(LTrim Join
		4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
		448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
		4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
		C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
		24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
		004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
		0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
		DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
		024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
		99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
		8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
		4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
		000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
		ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
		4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
		99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
		8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
		2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
		FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
		83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
		F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
		0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
		413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
		)
		
		VarSetCapacity(PixelateBitmap, StrLen(MCode_PixelateBitmap)//2)
		Loop % StrLen(MCode_PixelateBitmap)//2		;%
			NumPut("0x" SubStr(MCode_PixelateBitmap, (2*A_Index)-1, 2), PixelateBitmap, A_Index-1, "UChar")
		DllCall("VirtualProtect", Ptr, &PixelateBitmap, Ptr, VarSetCapacity(PixelateBitmap), "uint", 0x40, A_PtrSize ? "UPtr*" : "UInt*", 0)
	}

	Gdip_GetImageDimensions(pBitmap, Width, Height)
	
	if (Width != Gdip_GetImageWidth(pBitmapOut) || Height != Gdip_GetImageHeight(pBitmapOut))
		return -1
	if (BlockSize > Width || BlockSize > Height)
		return -2

	E1 := Gdip_LockBits(pBitmap, 0, 0, Width, Height, Stride1, Scan01, BitmapData1)
	E2 := Gdip_LockBits(pBitmapOut, 0, 0, Width, Height, Stride2, Scan02, BitmapData2)
	if (E1 || E2)
		return -3

	E := DllCall(&PixelateBitmap, Ptr, Scan01, Ptr, Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)
	
	Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapOut, BitmapData2)
	return 0
}

;#####################################################################################

Gdip_ToARGB(A, R, G, B)
{
	return (A << 24) | (R << 16) | (G << 8) | B
}

;#####################################################################################

Gdip_FromARGB(ARGB, ByRef A, ByRef R, ByRef G, ByRef B)
{
	A := (0xff000000 & ARGB) >> 24
	R := (0x00ff0000 & ARGB) >> 16
	G := (0x0000ff00 & ARGB) >> 8
	B := 0x000000ff & ARGB
}

;#####################################################################################

Gdip_AFromARGB(ARGB)
{
	return (0xff000000 & ARGB) >> 24
}

;#####################################################################################

Gdip_RFromARGB(ARGB)
{
	return (0x00ff0000 & ARGB) >> 16
}

;#####################################################################################

Gdip_GFromARGB(ARGB)
{
	return (0x0000ff00 & ARGB) >> 8
}

;#####################################################################################

Gdip_BFromARGB(ARGB)
{
	return 0x000000ff & ARGB
}

;#####################################################################################

StrGetB(Address, Length=-1, Encoding=0)
{
	; Flexible parameter handling:
	if Length is not integer
	Encoding := Length,  Length := -1

	; Check for obvious errors.
	if (Address+0 < 1024)
		return

	; Ensure 'Encoding' contains a numeric identifier.
	if Encoding = UTF-16
		Encoding = 1200
	else if Encoding = UTF-8
		Encoding = 65001
	else if SubStr(Encoding,1,2)="CP"
		Encoding := SubStr(Encoding,3)

	if !Encoding ; "" or 0
	{
		; No conversion necessary, but we might not want the whole string.
		if (Length == -1)
			Length := DllCall("lstrlen", "uint", Address)
		VarSetCapacity(String, Length)
		DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
	}
	else if Encoding = 1200 ; UTF-16
	{
		char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
		VarSetCapacity(String, char_count)
		DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
	}
	else if Encoding is integer
	{
		; Convert from target encoding to UTF-16 then to the active code page.
		char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
		VarSetCapacity(String, char_count * 2)
		char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
		String := StrGetB(&String, char_count, 1200)
	}
	
	return String
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ODColors.ahk
;///////////////////////////////////////////////////////////////////////////////////////////////////////
; ======================================================================================================================
; AHK 1.1.13+
; ======================================================================================================================
; Namespace:   OD_Colors
; Function:    Helper class for colored items in ListBox and DropDownList controls.
; AHK version: 1.1.13.00 (U64)
; Tested on:   Win 7 Pro x64
; Language:    English
; Version:     1.0.01.00/2013-10-24/just me
; MSDN:        Owner-Drawn ListBox -> http://msdn.microsoft.com/en-us/library/hh298352(v=vs.85).aspx
; Credits:     THX, Holle. You never gave up trying to manage it. So I remembered your problem from time to time
;              and finally found this solution.
; ======================================================================================================================
; How to use:  To register a control call OD_Colors.Attach() passing two parameters:
;                 Hwnd   - HWND of the control
;                 Colors - Object which may contain the following keys:
;                          T - default text color.
;                          B - default background color.
;                          The one-based index of items with special text and/or background colors.
;                          Each of this keys contains an object with up to two key/value pairs:
;                             T - text colour.
;                             B - background colour.
;                          Color values have to be passed as RGB integer values (0xRRGGBB).
;                          If either T or B is not specified, the control's default colour will be used.
;              To update a control after content or colour changes call OD_Colors.Update() passing two parameters:
;                 Hwnd   - HWND of the control.
;                 Colors - see above.
;              To unregister a control call OD_Colors.Detach() passing one parameter:
;                 Hwnd  - see above.
; Note:        ListBoxes must have the styles LBS_OWNERDRAWFIXED (0x0010) and LBS_HASSTRINGS (0x0040),
;              DropDownLists CBS_OWNERDRAWFIXED (0x0010) and  CBS_HASSTRINGS (0x0200) set at creation time.
;              Before adding the control, you have to set OD_Colors.ItemHeight (see OD_Colors.MeasureItem).
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================

Class OD_Colors {
   ; ===================================================================================================================
   ; Class variables ===================================================================================================
   ; ===================================================================================================================
   ; WM_MEASUREITEM := 0x002C
   Static OnMessageInit := OnMessage(0x002C, "OD_Colors.MeasureItem")
   Static ItemHeight := 0
   Static Controls := {}
   ; ===================================================================================================================
   ; You must not instantiate this class! ==============================================================================
   ; ===================================================================================================================
   __New(P*) {
      Return False
   }
   ; ===================================================================================================================
   ; Public methods ====================================================================================================
   ; ===================================================================================================================
   Attach(HWND, Colors) {
      Static WM_DRAWITEM := 0x002B
      If !IsObject(Colors)
         Return False
      This.Controls[HWND] := {}
      ControlGet, Content, List, , , ahk_id %HWND%
      This.Controls[HWND].Items := StrSplit(Content, "`n")
      This.Controls[HWND].Colors := {}
      For Key, Value In Colors {
         If (Key = "T") {
            This.Controls[HWND].Colors.T := ((Value & 0xFF) << 16) | (Value & 0x00FF00) | ((Value >> 16) & 0xFF)
            Continue
         }
         If (Key = "B") {
            This.Controls[HWND].Colors.B := ((Value & 0xFF) << 16) | (Value & 0x00FF00) | ((Value >> 16) & 0xFF)
            Continue
         }
         If ((Item := Round(Key)) = Key) {
            If ((C := Value.T) <> "")
               This.Controls[HWND].Colors[Item, "T"] := ((C & 0xFF) << 16) | (C & 0x00FF00) | ((C >> 16) & 0xFF)
            If ((C := Value.B) <> "")
               This.Controls[HWND].Colors[Item, "B"] := ((C & 0xFF) << 16) | (C & 0x00FF00) | ((C >> 16) & 0xFF)
         }
      }
      If !OnMessage(WM_DRAWITEM)
         OnMessage(WM_DRAWITEM, "OD_Colors.DrawItem")
      WinSet, Redraw, , ahk_id %HWND%
      Return True
   }
   ; ===================================================================================================================
   Detach(HWND) {
      This.Controls.Remove(HWND, "")
      If (This.Controls.MaxIndex = "")
         OnMessage(WM_DRAWITEM, "")
      WinSet, Redraw, , ahk_id %HWND%
      Return True
   }
   ; ===================================================================================================================
   Update(HWND, Colors := "") {
      If This.Controls.HasKey(HWND)
         This.Detach(HWND)
      Return This.Attach(HWND)
   }
   ; ===================================================================================================================
   SetItemHeight(FontOptions, FontName) {
      Gui, OD_Colors_SetItemHeight:Font, %FontOptions%, %FontName%
      Gui, OD_Colors_SetItemHeight:Add, Text, 0x200 hwndHTX, Dummy
      VarSetCapacity(RECT, 16, 0)
      DllCall("User32.dll\GetClientRect", "Ptr", HTX, "Ptr", &RECT)
      Gui, OD_Colors_SetItemHeight:Destroy
      Return (OD_Colors.ItemHeight := NumGet(RECT, 12, "Int"))
   }
   ; ===================================================================================================================
   ; Called by system ==================================================================================================
   ; ===================================================================================================================
   MeasureItem(lParam, Msg, Hwnd) { ; first param 'wParam' is passed as 'This'.
      ; ----------------------------------------------------------------------------------------------------------------
      ; Sent once to the parent window of an OWNERDRAWFIXED ListBox or ComboBox when an the control is being created.
      ; When the owner receives this message, the system has not yet determined the height and width of the font used
      ; in the control. That is why OD_Colors.ItemHeight must be set to an appropriate value before the control will be
      ; created by Gui, Add, ... You either might call 'OD_Colors.SetItemHeight' passing the current font options and
      ; name to calculate the value or set it manually.
      ; WM_MEASUREITEM      -> http://msdn.microsoft.com/en-us/library/bb775925(v=vs.85).aspx
      ; MEASUREITEMSTRUCT   -> http://msdn.microsoft.com/en-us/library/bb775804(v=vs.85).aspx
      ; ----------------------------------------------------------------------------------------------------------------
      ; lParam -> MEASUREITEMSTRUCT offsets
      Static offHeight := 16
      NumPut(OD_Colors.ItemHeight, lParam + 0, offHeight, "Int")
      Return True
   }
   ; ===================================================================================================================
   DrawItem(lParam, Msg, Hwnd) { ; first param 'wParam' is passed as 'This'.
      ; ----------------------------------------------------------------------------------------------------------------
      ; Sent to the parent window of an owner-drawn ListBox or ComboBox when a visual aspect of the control has changed.
      ; WM_DRAWITEM         -> http://msdn.microsoft.com/en-us/library/bb775923(v=vs.85).aspx
      ; DRAWITEMSTRUCT      -> http://msdn.microsoft.com/en-us/library/bb775802(v=vs.85).aspx
      ; ----------------------------------------------------------------------------------------------------------------
      ; lParam / DRAWITEMSTRUCT offsets
      Static offItem := 8, offAction := offItem + 4, offState := offAction + 4, offHWND := offState + A_PtrSize
           , offDC := offHWND + A_PtrSize, offRECT := offDC + A_PtrSize, offData := offRECT + 16
      ; Owner Draw Type
      Static ODT := {2: "LISTBOX", 3: "COMBOBOX"}
      ; Owner Draw Action
      Static ODA_DRAWENTIRE := 0x0001, ODA_SELECT := 0x0002, ODA_FOCUS := 0x0004
      ; Owner Draw State
      Static ODS_SELECTED := 0x0001, ODS_FOCUS := 0x0010
      ; Draw text format flags
      Static DT_Flags := 0x24 ; DT_SINGLELINE = 0x20, DT_VCENTER = 0x04
      ; ----------------------------------------------------------------------------------------------------------------
      Critical ; may help in case of drawing issues
      HWND := NumGet(lParam + offHWND, 0, "UPtr")
      If OD_Colors.Controls.HasKey(HWND) && ODT.HasKey(NumGet(lParam + 0, 0, "UInt")) {
         ODCtrl := OD_Colors.Controls[HWND]
         Item := NumGet(lParam + offItem, 0, "Int") + 1
         Action := NumGet(lParam + offAction, 0, "UInt")
         State := NumGet(lParam + offState, 0, "UInt")
         HDC := NumGet(lParam + offDC, 0, "UPtr")
         RECT := lParam + offRECT
         If (Action = ODA_FOCUS)
            Return True
         If ODCtrl.Colors.HasKey("B")
            CtrlBgC := ODCtrl.Colors.B
         Else
            CtrlBgC := DllCall("Gdi32.dll\GetBkColor", "Ptr", HDC, "UInt")
         If ODCtrl.Colors.HasKey("T")
            CtrlTxC := ODCtrl.Colors.T
         Else
            CtrlTxC := DllCall("Gdi32.dll\GetTextColor", "Ptr", HDC, "UInt")
         BgC := ODCtrl.Colors[Item].HasKey("B") ? ODCtrl.Colors[Item].B : CtrlBgC
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BgC, "UPtr")
         DllCall("User32.dll\FillRect", "Ptr", HDC, "Ptr", RECT, "Ptr", Brush)
         DllCall("Gdi32.dll\DeleteObject", "Ptr", Brush)
         Txt := ODCtrl.Items[Item], Len := StrLen(Txt)
         TxC := ODCtrl.Colors[Item].HasKey("T") ? ODCtrl.Colors[Item].T : CtrlTxC
         NumPut(NumGet(RECT + 0, 0, "Int") + 2, RECT + 0, 0, "Int")
         DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "Int", 1) ; TRANSPARENT
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", TxC)
         DllCall("User32.dll\DrawText", "Ptr", HDC, "Ptr", &Txt, "Int", Len, "Ptr", RECT, "UInt", DT_Flags)
         NumPut(NumGet(RECT + 0, 0, "Int") - 2, RECT + 0, 0, "Int")
         If (State & ODS_SELECTED)
            DllCall("User32.dll\DrawFocusRect", "Ptr", HDC, "Ptr", RECT)
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CtrlTxC)
         Return True
      }
   }
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;ColoredLV.ahk
;///////////////////////////////////////////////////////////////////////////////////////////////////////
Func_ListView_Header_CustomDraw(H, M, W, L, IdSubclass, RefData)
{
	;https:;www.autohotkey.com/boards/viewtopic.php?style=17&t=87318
	;by just me 07.03.2021
	
	Global GUI_Color_FontControl, GUI_Color_BGControl
	
	Static DC_Brush := DllCall("GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
	, DC_Pen := DllCall("GetStockObject", "UInt", 19, "UPtr") ; DC_PEN = 19
	, HDM_GETITEM := (A_IsUnicode ? 0x120B : 0x1203) ; ? HDM_GETITEMW : HDM_GETITEMA
	, OHWND := 0
	, OCode := (2 * A_PtrSize)
	, ODrawStage := OCode + A_PtrSize
	, OHDC := ODrawStage + A_PtrSize
	, ORect := OHDC + A_PtrSize
	, OItemSpec := ORect + 16
	, OItemState := OItemSpec + A_PtrSize
	, LM := 4 ; left margin of the first column (determined experimentally)
	, TM := 6 ; left and right text margins (determined experimentally)
	, Grid := 1 ; Grid Yes or No
	;, DefGridClr := DllCall("GetSysColor", "Int", 15, "UInt") ; COLOR_3DFACE
	
	
	;
	Critical 1000 ; ?
	;
	
	
	If (M = 0x004E) && (NumGet(L + OCode, "Int") = -12)
	{
		; WM_NOTIFY -> NM_CUSTOMDRAW
		
		
		;GET: Sending control's HWND
			HHD := NumGet(L + OHWND, "UPtr")
		
	  
		;Note: It's BGR instead of RGB!
			RegExMatch(GUI_Color_BGControl, "O)(.{0,2})(.{0,2})(.{0,2})", Dummy_Value)
			, GUI_Color_BG := "0x" Dummy_Value.Value( 3 ) Dummy_Value.Value( 2 ) Dummy_Value.Value( 1 )
			, RegExMatch(GUI_Color_FontControl, "O)(.{0,2})(.{0,2})(.{0,2})", Dummy_Value)
			, GUI_Color_FontNormal := "0x" Dummy_Value.Value( 3 ) Dummy_Value.Value( 2 ) Dummy_Value.Value( 1 )
		
		DrawStage := NumGet(L + ODrawStage, "UInt")
		
		; -------------------------------------------------------------------------------------------------------------
		
		If (DrawStage = 0x00010001)
		{
			; CDDS_ITEMPREPAINT
			
			;GET: The item's text, format and column order
				Item := NumGet(L + OItemSpec, "Ptr")
				, VarSetCapacity(HDITEM, 24 + (6 * A_PtrSize), 0)
				, VarSetCapacity(ItemTxt, 520, 0)
				, NumPut(0x86, HDITEM, "UInt") ; HDI_TEXT (0x02) | HDI_FORMAT (0x04) | HDI_ORDER (0x80)
				, NumPut(&ItemTxt, HDITEM, 8, "Ptr")
				, NumPut(260, HDITEM, 8 + (2 * A_PtrSize), "Int")
				, DllCall("SendMessage", "Ptr", HHD, "UInt", HDM_GETITEM, "Ptr", Item, "Ptr", &HDITEM)
				, VarSetCapacity(ItemTxt, -1)
				, Fmt := NumGet(HDITEM, 12 + (2 * A_PtrSize), "UInt") & 3
				, Order := NumGet(HDITEM, 20 + (3 * A_PtrSize), "Int")
			  
			;GET: The device context
				HDC := NumGet(L + OHDC, "Ptr")
			
			;Draw: A solid rectangle for the background
				VarSetCapacity(RC, 16, 0)
				, DllCall("CopyRect", "Ptr", &RC, "Ptr", L + ORect)
				, NumPut(NumGet(RC, "Int") + (!(Item | Order) ? LM : 0), RC, "Int")
				, NumPut(NumGet(RC, 8, "Int") + 1, RC, 8, "Int")
				, DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", GUI_Color_BG)
				, DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
			
			;Draw: The text
				DllCall("SetBkMode", "Ptr", HDC, "UInt", 0)
				, DllCall("SetTextColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
				, DllCall("InflateRect", "Ptr", L + ORect, "Int", -TM, "Int", 0)
			
			; DT_EXTERNALLEADING (0x0200) | DT_SINGLELINE (0x20) | DT_VCENTER (0x04)
			; HDF_LEFT (0) -> DT_LEFT (0)
			; HDF_CENTER (2) -> DT_CENTER (1)
			; HDF_RIGHT (1) -> DT_RIGHT (2)
				DT_ALIGN := 0x0224 + ((Fmt & 1) ? 2 : (Fmt & 2) ? 1 : 0)
				, DllCall("DrawText", "Ptr", HDC, "Ptr", &ItemTxt, "Int", -1, "Ptr", L + ORect, "UInt", DT_ALIGN)
				
			
			;Draw: A 'Grid' Line
				If (Grid) && (Order)
				{
					DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
					, DllCall("SetDCPenColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
					
					
					/*
					, L := NumGet(RC,  0, "Int") ; Left
					, T := NumGet(RC,  4, "Int") ; Top
					, R := NumGet(RC,  8, "Int") ; Right
					, B := NumGet(RC, 12, "Int") ; Bottom
					*/
					
					
					;Left
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC,  4, "Int"), NumGet(RC,  0, "Int"), NumGet(RC, 12, "Int") ), "Int", 2)
					
					;Top
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC,  4, "Int"), NumGet(RC,  8, "Int"), NumGet(RC, 4, "Int") ), "Int", 2)
					
					;Bottom
						, DllCall("Polyline", "Ptr", HDC, "Ptr", Func_SetRect( RCL, NumGet(RC,  0, "Int"), NumGet(RC, 12, "Int") - 1, NumGet(RC, 8, "Int"), NumGet(RC, 12, "Int") - 1 ), "Int", 2)
				}
			
			
			Return 4 ; CDRF_SKIPDEFAULT
		}
		
		; -------------------------------------------------------------------------------------------------------------
		
		If (DrawStage = 1)
		{
			; CDDS_PREPAINT
			Return 0x30 ; CDRF_NOTIFYITEMDRAW | CDRF_NOTIFYPOSTPAINT
		}
		
		; -------------------------------------------------------------------------------------------------------------
		
		
		If (DrawStage = 2)
		{
			; CDDS_POSTPAINT
			
			VarSetCapacity(RC, 16, 0)
			, DllCall("GetClientRect", "Ptr", HHD, "Ptr", &RC, "UInt")
			, Cnt := DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1200, "Ptr", 0, "Ptr", 0, "Int") ; HDM_GETITEMCOUNT
			, VarSetCapacity(RCI, 16, 0)
			, DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1207, "Ptr", Cnt - 1, "Ptr", &RCI) ; HDM_GETITEMRECT
			, R1 := NumGet(RC, 8, "Int")
			, R2 := NumGet(RCI, 8, "Int")
			
			If (R2 < R1)
			{
				
				;Conflict: with LVS_EX_LABELTIP LV0x4000 > shows only the background without text
				
				HDC := NumGet(L + OHDC, "UPtr")
				, NumPut(R2, RC, 0, "Int")
				, DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", GUI_Color_BG)
				, DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
				
				
				If (Grid)
				{
					DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
					, DllCall("SetDCPenColor", "Ptr", HDC, "UInt", GUI_Color_FontNormal)
					, NumPut(NumGet(RC, 0, "Int"), RC, 8, "Int")
					, DllCall("Polyline", "Ptr", HDC, "Ptr", &RC, "Int", 2)
				}
				
			}
			
			Return 4 ; CDRF_SKIPDEFAULT
		}
		
		
		; All other drawing stages ------------------------------------------------------------------------------------
		Return 0 ; CDRF_DODEFAULT
	}
	Else If (M = 0x0002)
	{
		; WM_DESTROY
		Func_GUI_Control_Subclass(H, "") ; remove the subclass procedure
	}
	
	
	; All messages not completely handled by the function must be passed to the DefSubclassProc:
	Return DllCall("DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "Ptr")
}


Func_SetRect(ByRef RC, L := 0, T := 0, R := 0, B := 0)
{
	VarSetCapacity(RC, 16, 0)
	, NumPut(L, RC,  0, "Int")
	, NumPut(T, RC,  4, "Int")
	, NumPut(R, RC,  8, "Int")
	, NumPut(B, RC, 12, "Int")
	
	Return &RC
}


Func_GUI_Control_Subclass(HCTL, FuncName, Data := 0)
{
	; ======================================================================================================================
	; SubclassControl	 Installs, updates, or removes the subclass callback for the specified control.
	; Parameters:		  HCTL	  -  Handle to the control.
	;						  FuncName -  Name of the callback function as string.
	;										  If you pass an empty string, the subclass callback will be removed.
	;						  Data	  -  Optional integer value passed as dwRefData to the callback function.
	; Return value:		Non-zero if the subclass callback was successfully installed, updated, or removed;
	;						  otherwise, False.
	; Remarks:			  The callback function must have exactly six parameters, see
	;						  SUBCLASSPROC -> msdn.microsoft.com/en-us/library/bb776774(v=vs.85).aspx
	; MSDN:				  Subclassing Controls -> msdn.microsoft.com/en-us/library/bb773183(v=vs.85).aspx
	; ======================================================================================================================
	
	Static ControlCB := []
	
	If ControlCB.HasKey(HCTL)
	{
		DllCall("RemoveWindowSubclass", "Ptr", HCTL, "Ptr", ControlCB[ HCTL ], "Ptr", HCTL)
		, DllCall("GlobalFree", "Ptr", ControlCB[ HCTL ], "Ptr")
		, ControlCB.Delete(HCTL)
		
		If (FuncName = "")
		{
			Return True
		}
	}
	
	If !DllCall("IsWindow", "Ptr", HCTL, "UInt")
	|| !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 6)
	|| !(CB := RegisterCallback(FuncName, , 6))
		Return Falsewingetac
	
	If !DllCall("SetWindowSubclass", "Ptr", HCTL, "Ptr", CB, "Ptr", HCTL, "Ptr", Data)
	{
		Return (DllCall("GlobalFree", "Ptr", CB, "Ptr") & 0)
	}
	
	Return (ControlCB[ HCTL ] := CB)
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;CUSTOM COLORED EDIT BOXES
;///////////////////////////////////////////////////////////////////////////////////////////////////////
SetEditColor(hEdit, b_color_rgb := "", f_color_rgb := 0) {
   static arr := [], _ := OnMessage( 0x133, Func("WM_CTLCOLOREDIT").Bind(arr) )
   
   if arr.HasKey(hEdit)
      DllCall("DeleteObject", Ptr, arr[hEdit, "hBrush"])
   if (b_color_rgb = "")
      arr.Delete(hEdit)
   else {
      for k, v in ["b", "f"]
         %v%_color_bgr := DllCall("Ws2_32\ntohl", UInt, %v%_color_rgb << 8, UInt)
      hBrush := DllCall("CreateSolidBrush", UInt, b_color_bgr, Ptr)
      arr[hEdit] := {b_color: b_color_bgr, f_color: f_color_bgr, hBrush: hBrush}
   }
   WinSet, Redraw,, ahk_id %hEdit%
}

WM_CTLCOLOREDIT(arr, hDC, hEdit) {
   if !arr.HasKey(hEdit)
      Return
   
   DllCall("SetBkColor"  , Ptr, hDC, UInt, arr[hEdit, "b_color"])
   DllCall("SetTextColor", Ptr, hDC, UInt, arr[hEdit, "f_color"])
   Return arr[hEdit, "hBrush"]
}
;///////////////////////////////////////////////////////////////////////////////////////////////////////


;Class_CtlColors.ahk
;///////////////////////////////////////////////////////////////////////////////////////////////////////
; ======================================================================================================================
; AHK 1.1+
; ======================================================================================================================
; Function:          Auxiliary object to color controls on WM_CTLCOLOR... notifications.
;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;                    Checkboxes and Radios accept only background colors due to design.
; Namespace:         CtlColors
; Tested with:       1.1.25.02
; Tested on:         Win 10 (x64)
; Change log:        1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
;                    1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
;                    1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
;                    1.0.01.00/2014-02-15/just me  -  changed class initialization.
;                    1.0.00.00/2014-02-14/just me  -  initial release.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class CtlColors {
   ; ===================================================================================================================
   ; Class variables
   ; ===================================================================================================================
   ; Registered Controls
   Static Attached := {}
   ; OnMessage Handlers
   Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
   ; Message Handler Function
   Static MessageHandler := "CtlColors_OnMessage"
   ; Windows Messages
   Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
   ; HTML Colors (BGR)
   Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                 , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                 , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
   ; Transparent Brush
   Static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
   ; System Colors
   Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
   ; Error message in case of errors
   Static ErrorMsg := ""
   ; Class initialization
   Static InitClass := CtlColors.ClassInit()
   ; ===================================================================================================================
   ; Constructor / Destructor
   ; ===================================================================================================================
   __New() { ; You must not instantiate this class!
      If (This.InitClass == "!DONE!") { ; external call after class initialization
         This["!Access_Denied!"] := True
         Return False
      }
   }
   ; ----------------------------------------------------------------------------------------------------------------
   __Delete() {
      If This["!Access_Denied!"]
         Return
      This.Free() ; free GDI resources
   }
   ; ===================================================================================================================
   ; ClassInit       Internal creation of a new instance to ensure that __Delete() will be called.
   ; ===================================================================================================================
   ClassInit() {
      CtlColors := New CtlColors
      Return "!DONE!"
   }
   ; ===================================================================================================================
   ; CheckBkColor    Internal check for parameter BkColor.
   ; ===================================================================================================================
   CheckBkColor(ByRef BkColor, Class) {
      This.ErrorMsg := ""
      If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
         This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
         Return False
      }
      BkColor := BkColor = "" ? This.SYSCOLORS[Class]
              :  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
              :  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; CheckTxColor    Internal check for parameter TxColor.
   ; ===================================================================================================================
   CheckTxColor(ByRef TxColor) {
      This.ErrorMsg := ""
      If (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
         This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
         Return False
      }
      TxColor := TxColor = "" ? ""
              :  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
              :  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; Attach          Registers a control for coloring.
   ; Parameters:     HWND        - HWND of the GUI control                                   
   ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ;                 ----------- Optional 
   ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Attach(HWND, BkColor, TxColor := "") {
      ; Names of supported classes
      Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
      ; Button styles
      Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
      ; Editstyles
      Static ES_READONLY := 0x800
      ; Default class background colors
      Static COLOR_3DFACE := 15, COLOR_WINDOW := 5
      ; Initialize default background colors on first call -------------------------------------------------------------
      If (This.SYSCOLORS.Edit = "") {
         This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
         This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
         This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
      }
      This.ErrorMsg := ""
      ; Check colors ---------------------------------------------------------------------------------------------------
      If (BkColor = "") && (TxColor = "") {
         This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
         Return False
      }
      ; Check HWND -----------------------------------------------------------------------------------------------------
      If !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "UInt") {
         This.ErrorMsg := "Invalid parameter HWND: " . HWND
         Return False
      }
      If This.Attached.HasKey(HWND) {
         This.ErrorMsg := "Control " . HWND . " is already registered!"
         Return False
      }
      Hwnds := [CtrlHwnd]
      ; Check control's class ------------------------------------------------------------------------------------------
      Classes := ""
      WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
      This.ErrorMsg := "Unsupported control class: " . CtrlClass
      If !ClassNames.HasKey(CtrlClass)
         Return False
      ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
      If (CtrlClass = "Edit")
         Classes := ["Edit", "Static"]
      Else If (CtrlClass = "Button") {
         IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
            Classes := ["Static"]
         Else
            Return False
      }
      Else If (CtrlClass = "ComboBox") {
         VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
         NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
         DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
         Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
         Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
         Classes := ["Edit", "Static", "ListBox"]
      }
      If !IsObject(Classes)
         Classes := [CtrlClass]
      ; Check background color -----------------------------------------------------------------------------------------
      If (BkColor <> "Trans")
         If !This.CheckBkColor(BkColor, Classes[1])
            Return False
      ; Check text color -----------------------------------------------------------------------------------------------
      If !This.CheckTxColor(TxColor)
         Return False
      ; Activate message handling on the first call for a class --------------------------------------------------------
      For I, V In Classes {
         If (This.HandledMessages[V] = 0)
            OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
         This.HandledMessages[V] += 1
      }
      ; Store values for HWND ------------------------------------------------------------------------------------------
      If (BkColor = "Trans")
         Brush := This.NullBrush
      Else
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
      For I, V In Hwnds
         This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
      ; Redraw control -------------------------------------------------------------------------------------------------
      DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
      This.ErrorMsg := ""
      Return True
   }
   ; ===================================================================================================================
   ; Change          Change control colors.
   ; Parameters:     HWND        - HWND of the GUI control
   ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ;                 ----------- Optional 
   ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; Remarks:        If the control isn't registered yet, Add() is called instead internally.
   ; ===================================================================================================================
   Change(HWND, BkColor, TxColor := "") {
      ; Check HWND -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      HWND += 0
      If !This.Attached.HasKey(HWND)
         Return This.Attach(HWND, BkColor, TxColor)
      CTL := This.Attached[HWND]
      ; Check BkColor --------------------------------------------------------------------------------------------------
      If (BkColor <> "Trans")
         If !This.CheckBkColor(BkColor, CTL.Classes[1])
            Return False
      ; Check TxColor ------------------------------------------------------------------------------------------------
      If !This.CheckTxColor(TxColor)
         Return False
      ; Store Colors ---------------------------------------------------------------------------------------------------
      If (BkColor <> CTL.BkColor) {
         If (CTL.Brush) {
            If (Ctl.Brush <> This.NullBrush)
               DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
            This.Attached[HWND].Brush := 0
         }
         If (BkColor = "Trans")
            Brush := This.NullBrush
         Else
            Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
         For I, V In CTL.Hwnds {
            This.Attached[V].Brush := Brush
            This.Attached[V].BkColor := BkColor
         }
      }
      For I, V In Ctl.Hwnds
         This.Attached[V].TxColor := TxColor
      This.ErrorMsg := ""
      DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
      Return True
   }
   ; ===================================================================================================================
   ; Detach          Stop control coloring.
   ; Parameters:     HWND        - HWND of the GUI control
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Detach(HWND) {
      This.ErrorMsg := ""
      HWND += 0
      If This.Attached.HasKey(HWND) {
         CTL := This.Attached[HWND].Clone()
         If (CTL.Brush) && (CTL.Brush <> This.NullBrush)
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
         For I, V In CTL.Classes {
            If This.HandledMessages[V] > 0 {
               This.HandledMessages[V] -= 1
               If This.HandledMessages[V] = 0
                  OnMessage(This.WM_CTLCOLOR[V], "")
         }  }
         For I, V In CTL.Hwnds
            This.Attached.Remove(V, "")
         DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
         CTL := ""
         Return True
      }
      This.ErrorMsg := "Control " . HWND . " is not registered!"
      Return False
   }
   ; ===================================================================================================================
   ; Free            Stop coloring for all controls and free resources.
   ; Return values:  Always True.
   ; ===================================================================================================================
   Free() {
      For K, V In This.Attached
         If (V.Brush) && (V.Brush <> This.NullBrush)
            DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
      For K, V In This.HandledMessages
         If (V > 0) {
            OnMessage(This.WM_CTLCOLOR[K], "")
            This.HandledMessages[K] := 0
         }
      This.Attached := {}
      Return True
   }
   ; ===================================================================================================================
   ; IsAttached      Check if the control is registered for coloring.
   ; Parameters:     HWND        - HWND of the GUI control
   ; Return values:  On success  - True
   ;                 On failure  - False
   ; ===================================================================================================================
   IsAttached(HWND) {
      Return This.Attached.HasKey(HWND)
   }
}
; ======================================================================================================================
; CtlColors_OnMessage
; This function handles CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
CtlColors_OnMessage(HDC, HWND) {
   Critical
   If CtlColors.IsAttached(HWND) {
      CTL := CtlColors.Attached[HWND]
      If (CTL.TxColor != "")
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CTL.TxColor)
      If (CTL.BkColor = "Trans")
         DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "UInt", 1) ; TRANSPARENT = 1
      Else
         DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", CTL.BkColor)
      Return CTL.Brush
   }
}