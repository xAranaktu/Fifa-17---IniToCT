#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=IniToCT 17.Exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Fileversion=1.2
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <array.au3>
#include <File.au3>
#include <String.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <GuiTreeView.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("IniToCT 17", 555, 493, 695, 183)
$Label1 = GUICtrlCreateLabel(".INI files to convert:", 10, 10, 260, 17, $SS_CENTER)
GUICtrlSetFont(-1, 12, 400, 0, "Verdana")
$TreeView1 = GUICtrlCreateTreeView(10, 35, 260, 321, BitOR($GUI_SS_DEFAULT_TREEVIEW, $TVS_CHECKBOXES))
$Button1 = GUICtrlCreateButton("Select all", 300, 35, 140, 25)
$Button2 = GUICtrlCreateButton("Open selected in notepad", 300, 70, 140, 25)
$Progress1 = GUICtrlCreateProgress(35, 415, 500, 33)
GUICtrlSetState(-1, $GUI_HIDE)
$Button3 = GUICtrlCreateButton("Convert!", 300, 255, 140, 25)
$Label2 = GUICtrlCreateLabel("Converting...", 32, 375, 500, 22, $SS_CENTER)
GUICtrlSetFont(-1, 12, 400, 0, "Verdana")
GUICtrlSetState(-1, $GUI_HIDE)
$Button4 = GUICtrlCreateButton("Donate", 300, 325, 140, 25)
$Button5 = GUICtrlCreateButton("GitHub", 300, 290, 140, 25)
$Label3 = GUICtrlCreateLabel("", 32, 456, 500, 22)
GUICtrlSetFont(-1, 12, 400, 0, "Verdana")
GUICtrlSetState(-1, $GUI_HIDE)
$Button6 = GUICtrlCreateButton("Restore original files", 300, 105, 140, 25)
$Radio1 = GUICtrlCreateRadio("Convert to .CT", 300, 195, 90, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Radio2 = GUICtrlCreateRadio("Convert to .txt", 300, 220, 90, 17)
$Button7 = GUICtrlCreateButton("About", 456, 325, 70, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global Const $OrginalIniFilePath = @ScriptDir & "\ORG_INIFILES\"
Global Const $UserIniFilePath = @ScriptDir & "\USER_INIFILES\"
Global Const $ConvertedCT = @ScriptDir & "\Converted.CT"
Global Const $Convertedtxt = @ScriptDir & "\Converted.txt"


Global $countChanges = 0
Global $allSelected = False
Global $outputCT = True
Global $hTreeItems[35]

Dim $arrSections[0], $arrValues[0]

FillGUITree()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			selectAll()
		Case $Button2
			openInNotepad()
		Case $Button3
			Start()
		Case $Button4
			Donate()
		Case $Button5
			Github()
		Case $Button6
			RestoreOriginal()
		Case $Button7
			About()
	EndSwitch
WEnd

Func About()
	If @Compiled Then
		Local $ver = FileGetVersion(@ScriptFullPath)
	Else
		Local $ver = "Not compiled"
	EndIf
	Local $txt = "Tool created by Aranaktu" & @CRLF & _
			"File version: " & $ver & @CRLF & _
			"For more info visit GitHub."
	MsgBox(0, "About", $txt)
EndFunc   ;==>About

Func Github()
	ShellExecute("https://github.com/xAranaktu/Fifa-17---IniToCT")
EndFunc   ;==>Github

Func Donate()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=J8F4UH72WG7RY")
EndFunc   ;==>Donate

Func RestoreOriginal()
	If MsgBox(4, "", "Are you sure that you want to restore ALL original .ini files?") = 7 Then
		MsgBox(64, "", "Restoring file process aborted by the user.")
		Return
	EndIf

	Local $IniFiles = _FileListToArray($OrginalIniFilePath, "*")
	Local $failed = False
	For $i = 1 To UBound($IniFiles) - 1
		If FileCopy($OrginalIniFilePath & $IniFiles[$i], $UserIniFilePath & $IniFiles[$i], 1) = 0 Then
			$failed = True
			ExitLoop
		EndIf
	Next

	If $failed Then
		MsgBox(16, "", "Restoring process failed. :(")
	Else
		MsgBox(64, "", "Restoring process completed! :)")
	EndIf
EndFunc   ;==>RestoreOriginal

Func Start()
	GUICtrlSetState($Progress1, $GUI_SHOW)
	GUICtrlSetState($Label2, $GUI_SHOW)
	GUICtrlSetState($Label3, $GUI_SHOW)

	If BitAND(GUICtrlRead($Radio1), $GUI_CHECKED) Then
		$outputCT = True
	Else
		$outputCT = False
	EndIf

	UpdateProgressBar(0, "")


	Local $currentFile = ""
	Local $selectedItems = 0
	For $i = 0 To UBound($hTreeItems) - 1
		If BitAND(GUICtrlRead($hTreeItems[$i]), $GUI_CHECKED) Then
			$selectedItems += 1
			$currentFile = _GUICtrlTreeView_GetText($TreeView1, $hTreeItems[$i])
			UpdateProgressBar((100 / UBound($hTreeItems)) * $i, "Converting: " & $currentFile)
			CompareIni($currentFile)
			CreateScript()
		Else
			UpdateProgressBar((100 / UBound($hTreeItems)) * $i, "Converting:")
		EndIf
	Next

	If $selectedItems > 0 And $countChanges > 0 Then
		UpdateProgressBar(100, "CONVERTED!")
		If MsgBox(4, "DONE!", "Your .ini files has been converted." & @CRLF & "You have made " & $countChanges & " changes in " & $selectedItems & " file(s)." & @CRLF & "Do you want to execute script now?") = 6 Then
			If $outputCT = True Then
				ShellExecute($ConvertedCT)
			Else
				ShellExecute($Convertedtxt)
			EndIf
		EndIf
	ElseIf $selectedItems = 0 Then
		MsgBox(48, "", "Whoops... It seems that you didn't selected anything.")
	ElseIf $countChanges = 0 Then
		MsgBox(48, "", "Whoops... It seems that you didn't changed anything in .ini files.")
	Else
		MsgBox(48, "", "Unknown error")
	EndIf

	Dim $arrSections[0], $arrValues[0] ; cleaning arrays
	$selectedItems = 0
	$countChanges = 0
	GUICtrlSetState($Progress1, $GUI_HIDE)
	GUICtrlSetState($Label2, $GUI_HIDE)
	GUICtrlSetState($Label3, $GUI_HIDE)
EndFunc   ;==>Start

Func UpdateProgressBar($val, $text)
	GUICtrlSetData($Progress1, $val)
	GUICtrlSetData($Label3, $text)
EndFunc   ;==>UpdateProgressBar

Func selectAll()
	$allSelected = Not $allSelected
	For $i = 0 To UBound($hTreeItems) - 1
		_GUICtrlTreeView_SetChecked($TreeView1, $hTreeItems[$i], $allSelected)
	Next

	If $allSelected Then
		GUICtrlSetData($Button1, "Unselect all")
	Else
		GUICtrlSetData($Button1, "Select all")
	EndIf
EndFunc   ;==>selectAll

Func openInNotepad()
	For $i = 0 To UBound($hTreeItems) - 1
		If BitAND(GUICtrlRead($hTreeItems[$i]), $GUI_CHECKED) Then
			ShellExecute($UserIniFilePath & _GUICtrlTreeView_GetText($TreeView1, $hTreeItems[$i]))
		EndIf
	Next
EndFunc   ;==>openInNotepad

Func FillGUITree()
	Local $IniFiles = _FileListToArray($OrginalIniFilePath, "*")
	For $i = 1 To UBound($IniFiles) - 1
		$hTreeItems[$i - 1] = GUICtrlCreateTreeViewItem($IniFiles[$i], $TreeView1)
	Next
EndFunc   ;==>FillGUITree

Func CreateScript()
	Local $fScriptTemplate = @ScriptDir & "\data\ScriptTemplate.txt"

	If Not FileExists($fScriptTemplate) Then
		MsgBox(16, "ERROR!", "ScriptTemplate file does't exists. Did you deleted it? :(")
		Return
	EndIf

	Dim $arrTemplate
	_FileReadToArray($fScriptTemplate, $arrTemplate, 0)
	For $i = 0 To UBound($arrSections) - 1
		_ArrayInsert($arrTemplate, 33, "str" & $i & ":") ; Create label for string to be compared
		_ArrayInsert($arrTemplate, 34, "  db " & "'" & $arrSections[$i] & "', 0") ; Our string
	Next

	For $i = 0 To UBound($arrSections) - 1
		_ArrayInsert($arrTemplate, 32, "label_str" & $i & ":") ;
		_ArrayInsert($arrTemplate, 33, "  mov rsi, [ptrVal]") ;
		_ArrayInsert($arrTemplate, 34, "  mov [rsi+08]," & IntOrFloat($arrValues[$i])) ; Here we mov our changed value into [rax+08]
		_ArrayInsert($arrTemplate, 35, "  jmp exit") ;
	Next

	For $i = 0 To UBound($arrSections) - 1
		_ArrayInsert($arrTemplate, 30, "  mov [saveRDX], rdx")
		_ArrayInsert($arrTemplate, 31, "  mov rcx, #" & StringLen($arrSections[$i]))
		_ArrayInsert($arrTemplate, 32, "  sub [saveRDX], rcx")
		_ArrayInsert($arrTemplate, 33, "  sub [saveRDX], 01")
		_ArrayInsert($arrTemplate, 34, "  mov rsi, str" & $i)
		_ArrayInsert($arrTemplate, 35, "  mov rdi, [saveRDX]")
		_ArrayInsert($arrTemplate, 36, "  rep cmpsb")
		_ArrayInsert($arrTemplate, 37, "  je label_str" & $i)
	Next

	For $i = 0 To UBound($arrSections) - 1
		_ArrayInsert($arrTemplate, 7, "label(label_str" & $i & ")")
	Next

	If $outputCT = True Then
		If ScriptToCT($arrTemplate) = 0 Then
			Return
		EndIf
	Else
		_FileWriteFromArray($Convertedtxt, $arrTemplate)
	EndIf
EndFunc   ;==>CreateScript

Func ScriptToCT($arrTemplate)
	Local $fCT_Template = @ScriptDir & "\data\CT_Template.CT"

	If Not FileExists($fCT_Template) Then
		MsgBox(16, "ERROR!", "CT_Template file does't exists. Did you deleted it? :(")
		Return 0
	EndIf

	Dim $arrInScriptToCT
	_FileReadToArray($fCT_Template, $arrInScriptToCT, 0)
	For $i = 0 To UBound($arrTemplate) - 1
		_ArrayInsert($arrInScriptToCT, 10, $arrTemplate[UBound($arrTemplate) - $i - 1])
	Next
	_FileWriteFromArray($ConvertedCT, $arrInScriptToCT)
	Return 1

EndFunc   ;==>ScriptToCT

Func IntOrFloat($ValueToCheck)
	; If value from .ini file contains '.' then it's float value, otherwise it's int.
	If StringInStr($ValueToCheck, ".") = 0 Then
		Return "(int)" & $ValueToCheck ; (int)
	Else
		Return "(float)" & $ValueToCheck ; (float)
	EndIf
EndFunc   ;==>IntOrFloat

Func CompareIni($iniName)
	Local $fOrg = $OrginalIniFilePath & $iniName
	Local $fUser = $UserIniFilePath & $iniName

	If Not FileExists($fOrg) Then
		MsgBox(16, "ERROR!", $fOrg & " not exists")
		Return
	ElseIf Not FileExists($fUser) Then
		MsgBox(16, "ERROR!", $fUser & " not exists")
		Return
	EndIf

	Local $arrOriginalFile[_FileCountLines($fOrg)]
	Local $arrUserFile[_FileCountLines($fUser)]

	_FileReadToArray($fOrg, $arrOriginalFile)
	_FileReadToArray($fUser, $arrUserFile)

	If $arrOriginalFile[0] <> $arrUserFile[0] Then
		MsgBox(16, "ERROR!", "Original lines: " & $arrOriginalFile[0] & @CRLF & "User file lines: " & $arrUserFile[0])
		Return
	EndIf

	Local $Section = "" ; INI Section name goes here
	Local $temp = "" ; Temp var for multi purpose
	Local $firstChar = ''
	Local $lastChar = ''
	For $i = 1 To $arrOriginalFile[0]
		$firstChar = StringLeft($arrOriginalFile[$i], 1)
		$lastChar = StringRight($arrOriginalFile[$i], 1)
		If $firstChar == "[" Then
			$Section = _StringBetween($arrOriginalFile[$i], "[", "]")[0] ; Remove '[' and ']' from section name because we don't need it.
		ElseIf $firstChar == "/" Or StringIsSpace($firstChar) Then
			ContinueLoop ; Skip empty and comment lines
		EndIf

		If $arrOriginalFile[$i] <> $arrUserFile[$i] Then
			$temp = StringStripWS($arrUserFile[$i], 8) ; Strips the white space in a string.
			$temp = StringSplit($temp, "//")[1] ; Remove comment

			_ArrayAdd($arrSections, $Section & "/" & StringSplit($temp, "=")[1]) ; Add changed setting name to array
			_ArrayAdd($arrValues, StringSplit($temp, "=")[2]) ; Add changed setting value to array
			$countChanges += 1
		EndIf

	Next
EndFunc   ;==>CompareIni
