#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=AutoRadmin.exe
#AutoIt3Wrapper_Res_Comment=AutoIt script for Radmin connection
#AutoIt3Wrapper_Res_Description=AutoIt script for Radmin connection
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=AutoRadmin
#AutoIt3Wrapper_Res_ProductVersion=3.5.2.1
#AutoIt3Wrapper_Res_CompanyName=https://github.com/egormkn/AutoRadmin
#AutoIt3Wrapper_Res_LegalCopyright=Egor Makarenko
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Build|%date%
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; AutoRadmin - script for automatic Radmin connection
;
; Author: Egor Makarenko
; Website: https://github.com/egormkn/AutoRadmin
;
; Configuration file: config.ini
; Default configuration:
;   ARGS=/connect:desktop.example.com:4899 /through:server.example.com:4899 /fullstretch
;   CONNECTUSER=Alice
;   CONNECTPASS=12345678
;   THROUGHUSER=Bob
;   THROUGHPASS=87654321

#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <Misc.au3>

; Enforce a design paradigm where only one instance of the script may be running
_Singleton("AutoRadmin")

; Script should not pause after click on tray icon
AutoItSetOption("TrayAutoPause", 0)

; Set case-insensitive substring match for window titles
AutoItSetOption("WinTitleMatchMode", -2)

Global $ARGS, $CONNECTUSER, $CONNECTPASS, $THROUGHUSER, $THROUGHPASS
Local Const $dir = @TempDir & "\AutoRadmin"
Local $overwrite = False

If ProcessExists("Radmin.exe") Then
	MsgBox(0, "Error", "Radmin.exe is already running")
	Exit
EndIf

If (Not FileExists($dir)) And (Not DirCreate($dir)) Then
	MsgBox(0, "Error", "Can't create directory: " & $dir)
	Exit
EndIf

If (Not FileInstall(".\7za.exe", $dir & "\7za.exe", $overwrite ? $FC_OVERWRITE : $FC_NOOVERWRITE)) And $overwrite Then
	MsgBox(0, "Error", "Can't unpack file: " & $dir & "\7za.exe")
	Exit
EndIf

If (Not FileInstall(".\RadminViewerPortable.zip", $dir & "\Radmin.zip", $overwrite ? $FC_OVERWRITE : $FC_NOOVERWRITE)) And $overwrite Then
	MsgBox(0, "Error", "Can't unpack file: " & $dir & "\Radmin.zip")
	Exit
EndIf

Local $unzipCommand = $dir & "\7za.exe x Radmin.zip -y -ao" & ($overwrite ? "a" : "s")

RunWait($unzipCommand, $dir)
If (@error <> 0) Then
	MsgBox(0, "Error", "Can't unzip Radmin.zip using " & $unzipCommand)
	Exit
EndIf

If Not FileExists("config.ini") Then
	If Not FileInstall(".\config.ini", @ScriptDir & "\config.ini") Then
		MsgBox(0, "Error", "Can't unpack file: " & @ScriptDir & "\config.ini")
	Else
		MsgBox(0, "Error", "Please setup the config file: " & @ScriptDir & "\config.ini")
		Run("notepad.exe " & @ScriptDir & "\config.ini", @ScriptDir, @SW_SHOWNORMAL)
	EndIf
	Exit
EndIf

Local $config = FileOpen(@ScriptDir & "\config.ini", $FO_READ)

If ($config = -1) Then
	MsgBox(0, "Error", "Unable to open config.ini")
	Exit
EndIf

Local $line, $param

While True
	$line = FileReadLine($config)
	If (@error <> 0) Then ExitLoop
	$param = StringRegExp($line, '^([A-Z_]+)=(.*)$', $STR_REGEXPARRAYMATCH)
	If (@error <> 0) Then ContinueLoop
	Assign($param[0], $param[1], $ASSIGN_EXISTFAIL)
WEnd

FileClose($config)

Local $command = $dir & "\Radmin.exe"

If $ARGS <> "" Then
	$command &= " " & $ARGS
EndIf

Local $PID = Run($command, $dir)
If (@error <> 0) Then
	MsgBox(0, "Error", "Can't start Radmin with " & $command)
	Exit
EndIf

If StringInStr($ARGS, "/through:") Then
	Local $hWnd = WinWait("Система безопасности Radmin", "", 10)
	If ($hWnd = 0) Then
		MsgBox(0, "Error", "Timeout reached for connection through Radmin server: " & $command)
		Exit
	EndIf
	ControlSend($hWnd, "", "[CLASS:Edit; INSTANCE:1]", $THROUGHUSER)
	ControlSend($hWnd, "", "[CLASS:Edit; INSTANCE:2]", $THROUGHPASS)
	ControlClick($hWnd, "", "[CLASS:Button; INSTANCE:2]")
	Sleep(1000)
EndIf

If StringInStr($ARGS, "/connect:") Then
	Local $hWnd = WinWait("Система безопасности Radmin", "", 10)
	If ($hWnd = 0) Then
		MsgBox(0, "Error", "Timeout reached for connection to Radmin server: " & $command)
		Exit
	EndIf
	ControlSend($hWnd, "", "[CLASS:Edit; INSTANCE:1]", $CONNECTUSER)
	ControlSend($hWnd, "", "[CLASS:Edit; INSTANCE:2]", $CONNECTPASS)
	ControlClick($hWnd, "", "[CLASS:Button; INSTANCE:2]")
EndIf
