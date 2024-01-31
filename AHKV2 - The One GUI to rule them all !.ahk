/*
===================================================================================================================================================================================

¤	THE ONE GUI TO RULE THEM ALL !

		--->	Press Ctrl Win Alt A to use

		--->	By Epic Keyboard Guy
		--->	Last Modified : 2024-01-30

===================================================================================================================================================================================
*/

/*
===================================================================================================================================================================================

¤	INI SECTION		--->	Do not remove comments (/* and */)

					--->	To be used with IniRead

===================================================================================================================================================================================
*/

/*
[Section]
Key=Value
*/

/*
===================================================================================================================================================================================

¤	AUTO-EXECUTE SECTION

===================================================================================================================================================================================
*/

If (!A_IsAdmin)
{
	Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
}

#Requires AutoHotKey v2
#SingleInstance Force

SetWorkingDir A_ScriptDir
SetTitleMatchMode 2 ; 1=Must start with   -   2=Must contain   -   3=Must Exact Match

TraySetIcon "The One GUI to rule them all !.ico"

/*
===================================================================================================================================================================================

¤	FIXED VARIABLES		--->	For easy modifications

===================================================================================================================================================================================
*/

; VAR_WHATEVER := "0"

/*
===================================================================================================================================================================================

¤	INCLUDE SECTION		--->	Include other AHK files here

===================================================================================================================================================================================
*/

#Include SaveReload.ahk

Exit

/*
===================================================================================================================================================================================

¤	Ctrl Win Alt A	--->	Show a GUI that lists all the hotkeys in all running script.

							Each hotkey will have two associated buttons :
								-One to launch it
								-One to Edit @ Line

							Use " ; " after a hotkey definition in your scripts to write a description of what it does
							For this script to work properly, every hotkey definition will need to be alone on its own line

===================================================================================================================================================================================
*/

^#!A:: ; Show this window
{
;--------------------------------------------------------------------------------------------------
;¤	USER PREFERENCE SECTION
;--------------------------------------------------------------------------------------------------

; Use this string anywere on the line of a Hotkey definition to prevent it from being detected
	var_StrToDisable := ";;;"

; You can exclude as many scripts as you want by adding their filename to this array :
	arr_ScriptNameExclusion :=	[
									"TillaGoto.ahk",
									"Toolbar.ahk",
									"WindowSpy.ahk"
								]

; Rename keys to your liking using this map :
; Help : (https://www.autohotkey.com/docs/v2/KeyList.htm)
	map_CustomReplace := 	Map(
									"NumpadAdd"		,	"Numpad+"		,
									"NumpadSub"		,	"Numpad-"		,
									"NumpadDiv"		,	"Numpad/"		,
									"NumpadMult"	,	"Numpad*"		,
									"NumpadDot"		,	"Numpad."
								)	
	

	var_GuiTitle :=  A_ScriptName . " - Hotkey List"

;--------------------------------------------------------------------------------------------------
;¤	END OF USER PREFERENCE SECTION
;--------------------------------------------------------------------------------------------------

	map_HKSymbolReplace :=	Map(
									"#"		,	"Win "			,
									"!"		,	"Alt "			,
									"^"		,	"Ctrl "			,
									"+"		, 	"Shift "		,
									"&"		,	"And"			,
									"<"		,	"L-"			,
									">"		,	"R-"			,
									"*"		,	"* "			,
									"~"		,	"(Passthrough) ",
									"$"		,	""				,
									"Up"	,	"Up"
								)

	DetectHiddenWindows true

	arr_AllRunningScriptsHWND := WinGetList("ahk_class AutoHotkey")

	arr_NonExcludedScripts := []

	map_DetectedHotkeys := Map()

;--------------------------------------------------------------------------------------------------
;¤	CREATE GUI
;--------------------------------------------------------------------------------------------------

	gui_HK := Gui("+AlwaysOnTop -MinimizeBox" , var_GuiTitle)
	gui_HK.OnEvent("Close", f_GuiHKClose)
	gui_HK.OnEvent("Escape", f_GuiHKClose)

;--------------------------------------------------------------------------------------------------
;¤	ADD WHATEVER YOU WANT HERE
;--------------------------------------------------------------------------------------------------

	gui_HK.AHKV1DocButton := gui_HK.addButton("xm",				"Goto : AHK Documentation V1")
	gui_HK.AHKV2DocButton := gui_HK.addButton("x+m +Default",	"Goto : AHK Documentation V2")
	gui_HK.AHKV1DocButton.OnEvent("Click", f_AHKV1DocButton)
	gui_HK.AHKV2DocButton.OnEvent("Click", f_AHKV2DocButton)

;--------------------------------------------------------------------------------------------------
;¤	GET TAB NAMES	--->	Meaning : Build the list of all non-excluded scripts
;--------------------------------------------------------------------------------------------------

	arr_TabNames := []

	; This next block of code is to make sure that this script is always in the first tab
	; Comment it out if you dont care (It's tab_number will be random (meaning : in whatever order found by WinGetList()))
	{
		arr_ScriptNameExclusion.Push(A_ScriptName)

		obj_CurrentScript := Object()

		obj_CurrentScript.var_HWND 		:= 	A_ScriptHwnd
		obj_CurrentScript.var_FileName 	:=	A_ScriptName
		obj_CurrentScript.var_FullPath 	:=	A_ScriptFullPath
		obj_CurrentScript.var_HKCount 	:=	0

		arr_NonExcludedScripts.Push(obj_CurrentScript.Clone())
		arr_TabNames.Push(A_ScriptName)
	}

	Loop arr_AllRunningScriptsHWND.Length
	{
		var_CurrentScriptHWND := 		arr_AllRunningScriptsHWND[A_Index]
		var_CurrentScriptHWND := 	WinGetTitle("ahk_id " . var_CurrentScriptHwnd)
		var_CurrentScriptFullPath := 	StrSplit(var_CurrentScriptHWND, " - AutoHotkey")[1]

		arr_TEMP := StrSplit(var_CurrentScriptFullPath, "\")

		var_CurrentScriptFileName := arr_TEMP[-1]

		var_Excluded := False

		Loop arr_ScriptNameExclusion.Length
		{
			If (var_CurrentScriptFileName = arr_ScriptNameExclusion[A_Index])
			{
				var_Excluded := true

				Break
			}
		}

		If (!var_Excluded)
		{
			obj_CurrentScript := Object()

			obj_CurrentScript.var_HWND 		:= 	var_CurrentScriptHWND
			obj_CurrentScript.var_FileName 	:=	var_CurrentScriptFileName
			obj_CurrentScript.var_FullPath 	:=	var_CurrentScriptFullPath
			obj_CurrentScript.var_HKCount 	:=	0

			arr_NonExcludedScripts.Push(obj_CurrentScript.Clone())
			arr_TabNames.Push(var_CurrentScriptFileName)
		}
	}

;--------------------------------------------------------------------------------------------------
;¤	ADD THE SCRIPTS TAB
;--------------------------------------------------------------------------------------------------
	
	gui_HK.Tab := gui_HK.AddTab3("xm -Wrap", arr_TabNames)

;--------------------------------------------------------------------------------------------------
;¤	POPULATES TABS	--->	Create buttons and info-text for all Hotkeys of each non-excluded script
;--------------------------------------------------------------------------------------------------

	var_HKeyButtonMaxW := 0
	var_HKInfoTextMaxW := 0

	Loop arr_NonExcludedScripts.Length
	{
		gui_HK.Tab.UseTab(A_Index)

		var_CurrentTabNumber := Format("{1:05}", A_Index)

		Loop Read, arr_NonExcludedScripts[var_CurrentTabNumber].var_FullPath		; This loop will read the current script, line by line
		{
			var_IsDisabled := InStr(A_LoopReadLine, var_StrToDisable)

;--------------------------------------------------------------------------------------------------
;¤	DETECT HOTKEYS		--->	Inside this loop, A_Index represent a line number
;--------------------------------------------------------------------------------------------------

			If ((var_FoundPos := InStr(A_LoopReadLine, "::")) && !var_IsDisabled && A_Index != A_LineNumber) ; The rightmost "&&" is to avoid self-detection of this line because it also contains "::" even though it's not a hotkey
			{
				arr_NonExcludedScripts[var_CurrentTabNumber].var_HKCount++

				var_CurrentControlNumber := var_CurrentTabNumber . Format("{1:05}", arr_NonExcludedScripts[var_CurrentTabNumber].var_HKCount)

				var_CurrentHK := SubStr(A_LoopReadLine, 1, (var_FoundPos - 1))

				If (var_FoundPos := InStr(A_LoopReadLine, ";"))
				{
					var_CurrentHKInfo := SubStr(A_LoopReadLine, var_FoundPos + 1)
				}
				Else
				{
					var_CurrentHKInfo := "   --->   "
				}

				var_Key := "var_HKeyButton" . var_CurrentControlNumber
				var_Value := var_CurrentHK

				map_DetectedHotkeys[var_Key] := var_Value

				for var_Key, var_Value in map_HKSymbolReplace
				{
					var_CurrentHK := StrReplace(var_CurrentHK, var_Key, var_Value)
				}

				for var_Key, var_Value in map_CustomReplace
				{
					var_CurrentHK := StrReplace(var_CurrentHK, var_Key, var_Value)
				}

;--------------------------------------------------------------------------------------------------
;	This layout is cursed... The first "Gui.Add()" should have the "xm" option but this option does not work inside a Tab.
;	WorkAround : Add the first control without the "xm" option and move it once you're done adding all the "x+m" controls
;
;	On this particular GUI it does not matter because all the GuiControl will be repositioned later
;--------------------------------------------------------------------------------------------------

				gui_HK.AddButton("							vvar_HKeyButton" . var_CurrentControlNumber,	var_CurrentHK		)
				gui_HK.AddText("x+m							vvar_HKInfoText" . var_CurrentControlNumber,	var_CurrentHKInfo	)
				gui_HK.AddText("x+m	Right 					vvar_HKLineText" . var_CurrentControlNumber,	"@Line : "			)
				gui_HK.AddButton("x+m	w60 				vvar_LineButton" . var_CurrentControlNumber,	A_Index				)

				gui_HK["var_HKeyButton" . var_CurrentControlNumber].OnEvent("Click", f_HKButton)
				gui_HK["var_LineButton" . var_CurrentControlNumber].OnEvent("Click", f_LineButton)

;--------------------------------------------------------------------------------------------------
;¤	FIND MAX WIDTH	--->	For each HKButton and each HKInfoText, remember the width value of the widest
;--------------------------------------------------------------------------------------------------
			
				gui_HK["var_HKeyButton" . var_CurrentControlNumber].GetPos( , , &var_CurrentHKButtonW, )
				gui_HK["var_HKInfoText" . var_CurrentControlNumber].GetPos( , , &var_CurrentHKInfoTextW, )

				If (var_HKeyButtonMaxW < var_CurrentHKButtonW)
				{
					var_HKeyButtonMaxW := var_CurrentHKButtonW
				}

				If (var_HKInfoTextMaxW < var_CurrentHKInfoTextW)
				{
					var_HKInfoTextMaxW := var_CurrentHKInfoTextW
				}
			}
		} ;END OF Loop Read
	} ;END OF Loop arr_NonExcludedScripts.Length

;--------------------------------------------------------------------------------------------------
;¤	REPOSITIONING
;--------------------------------------------------------------------------------------------------

	var_HKeyButtonMaxW += 10
	var_HKInfoTextMaxW += 10
	var_HKLineTextW := 40
	; gui_HK["var_HKLineText" . "00001" . "00001"].GetPos( , , &var_HKLineTextW, )
	; MsgBox(var_HKLineTextW)
	
	Loop arr_NonExcludedScripts.Length
	{
		var_CurrentTabNumber := Format("{1:05}", A_Index)

		Loop arr_NonExcludedScripts[A_Index].var_HKCount
		{
			var_CurrentControlNumber := var_CurrentTabNumber . Format("{1:05}", A_Index)

			gui_HK["var_HKeyButton" . var_CurrentControlNumber].Move(20,																,var_HKeyButtonMaxW	, )
			gui_HK["var_HKInfoText" . var_CurrentControlNumber].Move(var_HKeyButtonMaxW + 25,											,var_HKInfoTextMaxW	, )
			gui_HK["var_HKLineText" . var_CurrentControlNumber].Move(var_HKeyButtonMaxW + 25 + var_HKInfoTextMaxW,						,					, )
			gui_HK["var_LineButton" . var_CurrentControlNumber].Move(var_HKeyButtonMaxW + 25 + var_HKInfoTextMaxW + var_HKLineTextW,	,					, )
		}
	}

;--------------------------------------------------------------------------------------------------
;¤	GUI.SHOW()
;--------------------------------------------------------------------------------------------------

	DetectHiddenWindows false

	gui_HK.Show("AutoSize Center")
	Exit

;--------------------------------------------------------------------------------------------------
;¤	f_GuiHKClose
;--------------------------------------------------------------------------------------------------

	f_GuiHKClose(*)
	{
		gui_HK.Destroy()
		Exit
	}

;--------------------------------------------------------------------------------------------------
;¤	f_AHKV1DocButton - OPTIONAL
;--------------------------------------------------------------------------------------------------
	f_AHKV1DocButton(*)
	{
		gui_HK.Destroy()

		var_URL := "https://www.autohotkey.com/docs/v1/"
		var_WinTitle := "Quick Reference | AutoHotkey v1"

		BlockInput true
		{
			run (var_URL)

			WinWait(var_WinTitle, , 5)
			Sleep 200
			WinActivate(var_WinTitle)
			Sleep 200

			Send "!s"
		}
		BlockInput false

		Exit
	}

;--------------------------------------------------------------------------------------------------
;¤	f_AHKV2DocButton - OPTIONAL
;--------------------------------------------------------------------------------------------------
	f_AHKV2DocButton(*)
	{
		gui_HK.Destroy()

		var_URL := "https://www.autohotkey.com/docs/v2/"
		var_WinTitle := "Quick Reference | AutoHotkey v2"

		BlockInput true
		{
			run (var_URL)

			WinWait(var_WinTitle, , 5)
			Sleep 200
			WinActivate(var_WinTitle)
			Sleep 200

			Send "!s"
		}
		BlockInput false

		Exit
	}

;--------------------------------------------------------------------------------------------------
;¤	f_HKButton
;--------------------------------------------------------------------------------------------------
	f_HKButton(obj_GuiButton, *)
	{
		var_SendString := (f_ConvertHKLabelToSend(map_DetectedHotkeys[obj_GuiButton.Name]))

		gui_HK.Destroy()

		BlockInput true
		{
			Send var_SendString
		}
		BlockInput false

		Exit
	}

;--------------------------------------------------------------------------------------------------
;¤	f_LineButton
;--------------------------------------------------------------------------------------------------
	f_LineButton(obj_GuiButton, *)
	{
		var_TargetLineNumber := obj_GuiButton.Text
		var_TargetTabNumber := SubStr(obj_GuiButton.Name, StrLen("var_LineButton") + 1, 5)
		var_TargetScriptFullPath := arr_NonExcludedScripts[var_TargetTabNumber].var_FullPath

		gui_HK.Destroy()

		; You might need to change the path and options here if you're not using VS Code or if it's not installed in the default location
		
		; MsgBox("`"C:\Users\" . A_UserName . "\AppData\Local\Programs\Microsoft VS Code\Code.exe`"" . " " . "-r -g" . " " . "`"" . var_TargetScriptFullPath . "`"" . ":" . var_TargetLineNumber)

		Run "`"C:\Users\" . A_UserName . "\AppData\Local\Programs\Microsoft VS Code\Code.exe`"" . " " . "-r -g" . " " . "`"" . var_TargetScriptFullPath . "`"" . ":" . var_TargetLineNumber

		Exit
	}


/*
===================================================================================================================================================================================

¤	f_ConvertHKLabelToSend	--->	Convert a Hotkey label name into a string that can be used with the Send command

							--->	WORK IN PROGRESS...
									--->	As of right now I havent tested any hotkey that uses the "&" symbol but I'm pretty sure they wont work.
									--->	I also havent tested any Hotstring
									--->	I also havent tested anything that uses the "*" symbol
									--->	I also havent tested ">", "<", and "<^>" symbols

									--->	So... yeah... still a lot of work to be done here.

===================================================================================================================================================================================
*/

	f_ConvertHKLabelToSend(var_HKLabel)
	{
		var_ExclusionArray := [" ", ";", "&", "*", "~", "$"]

		var_SpecialSymbolArray := ["^", "+", "!", "#"]

		var_ReturnString := ""

		var_FirstNonSpecialSymbol := true


		Loop StrLen(var_HKLabel)
		{
			var_Continue := False

			var_CurrentChar := SubStr(var_HKLabel, A_Index, 1)

			Loop var_SpecialSymbolArray.Length
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

			Loop var_ExclusionArray.Length
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
				var_ReturnString .= "{" . StrLower(var_CurrentChar)
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

	Exit
}

/*
===================================================================================================================================================================================

¤	Ctrl Numpad+	/	Ctrl Numpad-	--->   *** NEXT / PREVIOUS ***	"Currency Sign" symbol

			--->	If you're using a Canadian French Keyboard Layout, I suggest replacing the `currency sign` string below by "^!5" to avoid detection of these line

			--->	Otherwise you would need to find out what key combination produce the generic currency symbol on your keyboard

			--->	https://en.wikipedia.org/wiki/Currency_sign_(typography)

===================================================================================================================================================================================
*/

HotIfWinActive "ahk_exe Code.exe"
^#!NumpadAdd:: ; Only in VS Code : Goto Next "Currency Sign" symbol
{
	BlockInput true
	{
		Send "^f"
		Send "¤"
		Send "{Enter}"
		Send "{Esc}"
	}
	BlockInput false

	Exit
}

;==================================================================================================================================================================================

^#!NumpadSub:: ; Only in VS Code : Goto Previous "Currency Sign" symbol
{
	BlockInput true
	{
		Send "^f"
		Send "¤"
		Send "+{Enter}"
		Send "{Esc}"
	}
	BlockInput false

	Exit
}
HotIf

; ^#!b:: ; Example - This hotkey is disabled but you will see it in the GUI
{
	MsgBox("Ctrl + Win + Alt + B")

	Exit
}

;;; ^#!c:: ; Example - This hotkey is disabled and it will not be displayed in the GUI
{
	MsgBox("Ctrl + Win + Alt + C")

	Exit
}

^#!d:: ;;; Example - This hotkey is NOT disabled but it won't be displayed in the GUI
{
	MsgBox("Ctrl + Win + Alt + D")

	Exit
}

Exit