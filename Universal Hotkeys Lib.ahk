/*
===================================================================================================================================================================================
¤	Universal Hotkeys Lib.ahk

        --->	Include this file (#Include "Universal Hotkeys Lib.ahk") in any of your scripts to give them the hotkeys below

		--->	By Epic Keyboard Guy
		--->	Last Modified : 2025-02-18
===================================================================================================================================================================================
*/

If (A_ScriptName = "Universal Hotkeys Lib.ahk")
{
    ExitApp ; Meaning : This script is not runnable by itself, it needs to be included. (with #Include)
}

/*
===================================================================================================================================================================================
¤	Ctrl S   --->   Save + Auto-reload
===================================================================================================================================================================================
*/

#HotIf WinActive("ahk_exe Code.exe") ; This hotkey works only while VS Code is the active window

~^S:: ; Save + Auto-Reload
{
	Sleep 200
	Reload
	Exit
}

#HotIf ; End of #HotIf

/*
===================================================================================================================================================================================
¤	Ctrl Shift Win Alt F12		--->	Edit
===================================================================================================================================================================================
*/

~^+#!F12:: ; Edit
{
	Run("`"" . "C:\Users\" . A_UserName . "\AppData\Local\Programs\Microsoft VS CodeCode.exe" . "`"" . " " . "`"" . A_ScriptFullPath . "`"")

	Exit
}

/*
===================================================================================================================================================================================
¤	Ctrl Shift Esc		--->	Reload
===================================================================================================================================================================================
*/

~^+Escape:: ; Reload
{
	Reload
	Exit
}

/*
===================================================================================================================================================================================
¤	Ctrl Alt Delete		--->	Reload
===================================================================================================================================================================================
*/

~^!Del:: ; Reload
{
	Reload
	Exit
}

/*
===================================================================================================================================================================================
¤	Win + Escape		--->	Reload
===================================================================================================================================================================================
*/

#Escape:: ; Reload
{
	Reload
	Exit
}
