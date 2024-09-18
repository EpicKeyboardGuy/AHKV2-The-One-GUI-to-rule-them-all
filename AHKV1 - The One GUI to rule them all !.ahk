/*
===================================================================================================================================================================================

	AHKV1

    THE ONE GUI TO RULE THEM ALL !

		--->	Press Ctrl Win Alt A to use

		--->	By Epic Keyboard Guy
		--->	Last Modified : 2024-09-17



===================================================================================================================================================================================
*/

/*
===================================================================================================================================================================================

	AUTO-EXECUTE SECTION

===================================================================================================================================================================================
*/

if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
}

#Persistent
#NoEnv
#SingleInstance, Force

SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2 ; Default=1(Must start with)   -   2=InStr()   -   3=Exact Match

var_ScriptIconPath := "./The One GUI to rule them all !.ico"

if (var_ScriptIconPath != "" && FileExist(var_ScriptIconPath))
{
	Menu, Tray, Icon, %var_ScriptIconPath%
}

/*
===================================================================================================================================================================================

    FIXED VARIABLES		--->	For easy modifications

===================================================================================================================================================================================
*/

KEY_DELAY := 50

Exit

/*
===================================================================================================================================================================================

    Ctrl S   --->   Save + Auto-reload

===================================================================================================================================================================================
*/

~^S:: ; Save + Auto-Reload

; If (WinActive("ahk_class SciTEWindow") && (WinActive(A_ScriptName)))
If (WinActive("ahk_exe Code.exe") && (WinActive(A_ScriptName)))
{
	Sleep, 200
	Reload
	Exit
}

Exit

/*
===================================================================================================================================================================================

    INCLUDE SECTION		--->	Include other AHK files here

===================================================================================================================================================================================
*/

; #Include Something.ahk

/*
===================================================================================================================================================================================

    Ctrl Win Alt A	--->	Show a GUI that lists all the hotkeys in all running script.

							Each hotkey will have two associated buttons :
								-One to launch it
								-One to open Scite at it's corresponding line in the code

							Use " ;" after a hotkey labels in your scripts to write a description of what it does

===================================================================================================================================================================================
*/

^#!A:: ; Show this window

var_HKSymbolReplaceArray := {"#":"Win ", "!":"Alt ", "^":"Ctrl ", "+":"Shift ", "&":"And", "<":"L-", ">":"R-", "*":"* ", "~":"(Unblocked) ", "$":"", "Up":"Up"}

var_CustomReplaceArray := {"NumpadAdd":"Numpad+", "NumpadSub":"Numpad-", "NumpadDiv":"Numpad/", "NumpadMult":"Numpad*", "NumpadDot":"Numpad."} ; https://www.autohotkey.com/docs/v1/KeyList.htm

var_ScriptNameExclusionArray := ["TillaGoto.ahk", "Toolbar.ahk"] ; You can exclude as many scripts as you want by adding their filename to this array

var_ScriptHwndArray := []
var_ScriptFullPathArray := []
var_ScriptNameArray := []
var_HKArray := {}
var_HKeyButtonArray := {}

DetectHiddenWindows, On
WinGet, var_AHKScript, List, % "ahk_class AutoHotkey"

Gui, GuiHKList:New, , % A_ScriptName . " - Hotkey List"
Gui, +AlwaysOnTop -MinimizeBox

Gui, Add, Button, xm gLbl_AHKDocButtonV1 +Default,	% "Goto : AHK Documentation V1"
Gui, Add, Button, x+m gLbl_AHKDocButtonV2,			% "Goto : AHK Documentation V2"


var_TabNames := ""

Loop, % var_AHKScript
{
	var_CurrentScriptHwnd := var_AHKScript%A_Index%
	WinGetTitle, var_CurrentScriptWinTitle, % "ahk_id " . var_CurrentScriptHwnd
	var_CurrentScriptFullPath := StrSplit(var_CurrentScriptWinTitle, " - AutoHotkey")[1]

	var_TempArray := StrSplit(var_CurrentScriptFullPath, "\")

	var_CurrentScriptName := var_TempArray[var_TempArray.Length()]

	var_Excluded := False

	Loop, % var_ScriptNameExclusionArray.Length()
	{
		If (var_CurrentScriptName = var_ScriptNameExclusionArray[A_Index])
		{
			var_Excluded := true

			;~ MsgBox % var_Excluded . "`n`n" . var_CurrentScriptName

			Break
		}
	}

	If (!var_Excluded)
	{
		var_ScriptHwndArray.Push(var_CurrentScriptHwnd)
		var_ScriptFullPathArray.Push(var_CurrentScriptFullPath)
		var_ScriptNameArray.Push(var_CurrentScriptName)

		var_TabNames .= var_CurrentScriptName . "|"
	}
}

;~ Loop, % var_ScriptFullPathArray.Length()
;~ {
	;~ MsgBox % var_ScriptFullPathArray[A_Index]
;~ }


Gui, Add, Tab3, xm vvar_ScriptTab, % var_TabNames

Loop, % var_ScriptFullPathArray.Length()
{
	Gui, Tab, % A_Index

	var_TabNumber := Format("{1:05}", A_Index)

	var_CurrentScriptHwnd := var_ScriptHwndArray[A_Index]

	WinGetTitle, var_CurrentScriptWinTitle, % "ahk_id " . var_CurrentScriptHwnd
	var_CurrentScriptFullPath := StrSplit(var_CurrentScriptWinTitle, " - AutoHotkey")[1]

	var_HKCount := 0
	var_HKeyButtonMaxW := 0
	var_HKInfoTextMaxW := 0

	Loop, Read, % var_CurrentScriptFullPath
	{
		var_CtrlQed := InStr(A_LoopReadLine, ";~")

		If ((var_FoundPos := InStr(A_LoopReadLine, "::")) && !var_CtrlQed && A_Index != A_LineNumber) ; The right side of the && is to avoid the detection of this line because it also contains "::" even though it's not a hotkey
		{
			var_HKCount++

			var_HKCountControlName := Format("{1:05}", var_HKCount)

			var_CurrentHK := SubStr(A_LoopReadLine, 1, (var_FoundPos - 1))

			If (var_FoundPos := InStr(A_LoopReadLine, ";"))
			{
				var_CurrentHKInfo := SubStr(A_LoopReadLine, var_FoundPos + 1)
			}
			Else
			{
				var_CurrentHKInfo := "   --->   "
			}

			var_Key := "var_HKeyButton" . var_TabNumber . var_HKCountControlName
			var_Value := var_CurrentHK

			var_HKeyButtonArray[var_Key] := var_Value
			var_HKArray[var_Key] := var_Value

			for var_Key, var_Value in var_HKSymbolReplaceArray
			{
				var_CurrentHK := StrReplace(var_CurrentHK, var_Key, var_Value)
			}

			for var_Key, var_Value in var_CustomReplaceArray
			{
				var_CurrentHK := StrReplace(var_CurrentHK, var_Key, var_Value)
			}

;--------------------------------------------------------------------------------------------------
;	This layout is cursed... first "Add" should have the xm option but it does not work inside a Tab
;	In this case it does not matter because all the GuiControl will be resized and/or moved later
;--------------------------------------------------------------------------------------------------

			Gui, Add, Button,				gLbl_HKButton	vvar_HKeyButton%var_TabNumber%%var_HKCountControlName%,	% var_CurrentHK
			Gui, Add, Text,		x+m							vvar_HKInfoText%var_TabNumber%%var_HKCountControlName%,	% var_CurrentHKInfo
			Gui, Add, Text,		x+m	Right 					vvar_HKLineText%var_TabNumber%%var_HKCountControlName%,	% "@Line : "
			Gui, Add, Button,	x+m	w100 	gLbl_LineButton vvar_LineButton%var_TabNumber%%var_HKCountControlName%,	% A_Index

			var_CurrentHKTextPosW := 0
			GuiControlGet, var_CurrentHKTextPos, Pos, % var_CurrentHK

			If (var_HKeyButtonMaxW < var_CurrentHKTextPosW)
			{
				var_HKeyButtonMaxW := var_CurrentHKTextPosW
			}

			var_CurrentHKInfoTextPosW := 0
			GuiControlGet, var_CurrentHKInfoTextPos, Pos, % var_CurrentHKInfo

			If (var_HKInfoTextMaxW < var_CurrentHKInfoTextPosW)
			{
				var_HKInfoTextMaxW := var_CurrentHKInfoTextPosW
			}
		}
	}

	var_HKeyButtonMaxW += 10
	var_HKInfoTextMaxW += 10
	GuiControlGet, var_HKLineTextPos, Pos, var_HKLineText0000100001

	Loop, % var_HKCount
	{
		var_HKCountControlName := Format("{1:05}", A_Index)

		GuiControl, Move,	var_HKeyButton%var_TabNumber%%var_HKCountControlName%	, % "W" . (var_HKeyButtonMaxW) . " " . "X10"
		GuiControl, Move,	var_HKInfoText%var_TabNumber%%var_HKCountControlName%	, % "X" . (var_HKeyButtonMaxW + 15) . "W" . (var_HKInfoTextMaxW)
		GuiControl, Move,	var_HKLineText%var_TabNumber%%var_HKCountControlName%	, % "X" . (var_HKeyButtonMaxW + 15 + var_HKInfoTextMaxW)
		GuiControl, Move,	var_LineButton%var_TabNumber%%var_HKCountControlName%	, % "X" . (var_HKeyButtonMaxW + 15 + var_HKInfoTextMaxW + var_HKLineTextPosW)
	}

	;~ GuiControl, +Default, var_LineButton%var_TabNumber%%var_HKCountControlName%
}

DetectHiddenWindows, Off

Gui, Show, AutoSize
Return

;--------------------------------------------------------------------------------------------------
;   Lbl_AHKDocButtonV1
;--------------------------------------------------------------------------------------------------
Lbl_AHKDocButtonV1:

Gui, Destroy

var_URL := "https://www.autohotkey.com/docs/v1/"
var_WinTitle := "Quick Reference | AutoHotkey v1"
var_WaitTime := 5

Run, %var_URL%

WinWaitActive, %var_WinTitle%, , %var_WaitTime%
if ErrorLevel
{
    MsgBox, WinWait timed out.
    Exit
}

BlockInput On
Sleep 500
Send !S
BlockInput Off

Exit

;--------------------------------------------------------------------------------------------------
;	Lbl_AHKDocButtonV2
;--------------------------------------------------------------------------------------------------
Lbl_AHKDocButtonV2:

Gui, Destroy

var_URL := "https://www.autohotkey.com/docs/v2/"
var_WinTitle := "Quick Reference | AutoHotkey v2"
var_WaitTime := 5

Run, %var_URL%

WinWaitActive, %var_WinTitle%, , %var_WaitTime%
if ErrorLevel
{
    MsgBox, WinWait timed out.
    Exit
}

BlockInput On
Sleep 500
Send !S
BlockInput Off

Exit

;--------------------------------------------------------------------------------------------------
;	GuiHKListGuiClose
;--------------------------------------------------------------------------------------------------
GuiHKListGuiClose:
GuiHKListGuiEscape:
{
	Gui, Destroy
	Exit
}

;--------------------------------------------------------------------------------------------------
;	Lbl_HKButton
;--------------------------------------------------------------------------------------------------
Lbl_HKButton:

var_CurrentScriptName := var_ScriptNameArray[SubStr(A_GuiControl, StrLen("var_LineButton") + 1, 5)]

If (A_ScriptName = var_CurrentScriptName)
{
	var_HKLabel := var_HKeyButtonArray[A_GuiControl]

	Gui, Destroy

	GoSub, % var_HKLabel
}
Else
{
	var_SendString := f_ConvertHKLabelToSend(var_HKArray[A_GuiControl])

	Gui, Destroy

	;~ MsgBox % var_SendString

	BlockInput, On

	SendLevel, 1
	Send, % var_SendString

	BlockInput, Off
}

Exit

;--------------------------------------------------------------------------------------------------
;	Lbl_LineButton
;--------------------------------------------------------------------------------------------------
Lbl_LineButton:

GuiControlGet, var_SciteLineNumber, , % A_GuiControl

var_SciteTarget := """" . var_ScriptFullPathArray[SubStr(A_GuiControl, StrLen("var_LineButton") + 1, 5)] . """"
var_SciteLineNumber := "-goto:" . var_SciteLineNumber

Run, "C:\M-DRIVE\SYSTEM\AutoHotKey\SciTE\Scite.exe" %var_SciteTarget% %var_SciteLineNumber%

Gui, Destroy

Exit

/*
===================================================================================================================================================================================

    Ctrl Shift Win Alt Numpad*	--->	TEST

===================================================================================================================================================================================
*/
^+#!NumpadMult:: ; TEST - Temporary experimental code goes here

var_test := "Test"

MsgBox % var_Test

Exit



#IfWinActive

/*
===================================================================================================================================================================================

    Ctrl Escape		--->	Disable the Ctrl+Esc Keyboard Shortcut (Open start menu)

===================================================================================================================================================================================
*/

^Escape:: ; Do Nothing - Disable Windows Shortcut (Open Start Menu)

Exit



f_ConvertHKLabelToSend(var_HKLabel)
{
	; var_HKSymbolReplaceArray := {"#":"Win ", "!":"Alt ", "^":"Ctrl ", "+":"Shift ", "&":"And", "<":"L-", ">":"R-", "*":"* ", "~":"(Unblocked) ", "$":"", "Up":"Up"}

	var_ExclusionArray := [" ", ";", "&", "*", "~", "$"]

	var_SpecialSymbolArray := ["^", "+", "!", "#"]



	var_ReturnString := ""

	var_FirstNonSpecialSymbol := true


	Loop, % StrLen(var_HKLabel)
	{
		var_Continue := False

		var_CurrentChar := SubStr(var_HKLabel, A_Index, 1)

		;~ MsgBox % var_CurrentChar

		Loop, % var_SpecialSymbolArray.Length()
		{
			If (var_CurrentChar = var_SpecialSymbolArray[A_Index])
			{
				var_ReturnString .= var_CurrentChar
				var_Continue := true
				Continue
			}
		}

		If (var_Continue)
		{
			Continue
		}

		Loop, % var_ExclusionArray.Length()
		{
			If (var_CurrentChar = var_ExclusionArray[A_Index])
			{
				var_Continue := true
				Continue
			}
		}

		If (var_Continue)
		{
			Continue
		}

		If (var_FirstNonSpecialSymbol)
		{
			var_ReturnString .= "{" . var_CurrentChar
			var_FirstNonSpecialSymbol := False
			Continue
		}
		Else
		{
			var_ReturnString .= var_CurrentChar
		}
	}

	var_ReturnString .= "}"

	Return (var_ReturnString)
}

/*
===================================================================================================================================================================================

	EXAMPLES	--->	Feel free to remove these hotkeys

===================================================================================================================================================================================
*	/

; ^#!b:: ; Example - This hotkey is disabled but you will see it in the GUI
{
	MsgBox("Ctrl + Win + Alt + B")

	Exit
}


/*
===================================================================================================================================================================================

    END

===================================================================================================================================================================================
*/