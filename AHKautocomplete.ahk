;Copyright (c) 2013, Anthony Zhang
;All rights reserved.
;
;Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;
;Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
;Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
;Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
;THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetCapsLockState, AlwaysOff

; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; :::::::  Configurazione parametri                                      :::::::
; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
MaxResults := 20 ;maximum number of results to display
OffsetX := 0 ;offset in caret position in X axis
OffsetY := -80 ;offset from caret position in Y axis
BoxHeight := 80 ;height of the suggestions box in pixels

ResetKeyList := "Esc`nSpace`nHome`nPGUP`nPGDN`nEnd`nLeft`nRight`nRButton`nMButton`n,`n.`n/`n[`n]`n;`n\`n=`n```n"""  ;list of key names separated by `n that cause suggestions to reset
TriggerKeyList := "Tab`nEnter" ;list of key names separated by `n that trigger completion

CoordMode, Caret, Screen
SetKeyDelay, 0
SendMode, Input

; ::::::: Set-up suggestions window
Gui, Suggestions:Default
Gui, Font, s10, Courier New
Gui, +Delimiter`n
Gui, Add, ListBox, x0 y0 h%BoxHeight% 0x100 vMatched AltSubmit
Gui, -Caption +ToolWindow +AlwaysOnTop +LastFound
hWindow := WinExist()
Gui, Show, h%BoxHeight% Hide, AutoComplete

SetHotkeys(ResetKeyList,TriggerKeyList)

; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; :::::::  SUBRUTINES                                                    :::::::
; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; ::::::: Reset the current word variables & hide the prompt 
ResetWord:
Gui, Suggestions:Hide
Return

CapsLock & Space::
{
   ClipSave:=ClipboardAll
   clipboard=
   Send ^+{left}^+{left}^c
   Send {right}
   clipwait 2
   ;MsgBox %clipboard%
   selectedText = %clipboard% 

   whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   whr.Open("GET", "http://localhost:8080/" . selectedText, true)
   whr.Send()
   ;Using 'true' above and the call below allows the script to remain responsive.
   whr.WaitForResponse()
   ;MsgBox % whr.ResponseText
   APIReult := whr.ResponseText
   Clipboard:=ClipSave

   ; ::::::: Call the prediction model and show the suggested words 
   ; Attivo la finestra GUI
   Gui, Suggestions:Default

   MatchList := APIReult

   ;check for a lack of matches
   If (MatchList = "")
   {
      Gui, Hide
      Return
   }

   ;limit the number of results
   Position := InStr(MatchList,"`n",True,1,MaxResults)
   If Position
      MatchList := SubStr(MatchList,1,Position - 1)

   ;find the longest text width and add numbers
   MaxWidth := 0
   DisplayList := ""
   Loop, Parse, MatchList, `n
   {
      Entry := (A_Index < 10 ? A_Index . ". " : "   ") . A_LoopField
      Width := TextWidth(Entry)
      If (Width > MaxWidth)
         MaxWidth := Width
      DisplayList .= Entry . "`n"
   }
   MaxWidth += 30 ;add room for the scrollbar
   DisplayList := SubStr(DisplayList,1,-1)

   ;update the interface
   GuiControl,, Matched, `n%DisplayList%
   GuiControl, Choose, Matched, 1
   GuiControl, Move, Matched, w%MaxWidth% ;set the control width

   PosX := (A_CaretX != "" ? A_CaretX : 0) + OffsetX
   PosY := (A_CaretY != "" ? A_CaretY : 0) + OffsetY

   Gui, Show, x%PosX% y%PosY% w%MaxWidth% NoActivate ;show window

   Return
}

#IfWinExist AutoComplete ahk_class AutoHotkeyGUI

~LButton::
MouseGetPos,,, Temp1
If (Temp1 != hWindow)
    Gosub, ResetWord
Return

CapsLock & i::
Up::
Gui, Suggestions:Default
GuiControlGet, Temp1,, Matched
If Temp1 > 1 ;ensure value is in range
    GuiControl, Choose, Matched, % Temp1 - 1
Return

CapsLock & k::
Down::
Gui, Suggestions:Default
GuiControlGet, Temp1,, Matched
GuiControl, Choose, Matched, % Temp1 + 1
Return

!1::
!2::
!3::
!4::
!5::
!6::
!7::
!8::
!9::
!0::
Gui, Suggestions:Default
KeyWait, Alt
Key := SubStr(A_ThisHotkey, 2, 1)
GuiControl, Choose, Matched, % Key = 0 ? 10 : Key
Gosub, CompleteWord
Return

#IfWinExist


CompleteWord:
Critical

;only trigger word completion on non-interface event or double click on matched list
If (A_GuiEvent != "" && A_GuiEvent != "DoubleClick")
    Return

Gui, Suggestions:Default
Gui, Hide

;retrieve the word that was selected
GuiControlGet, Index,, Matched
TempList := "`n" . MatchList . "`n"
Position := InStr(TempList,"`n",0,1,Index) + 1
NewWord := SubStr(TempList,Position,InStr(TempList,"`n",0,Position) - Position)


Send ^+{left}
clipwait 2
;send the word
SendRaw, %NewWord%

Gosub, ResetWord
Return



TextWidth(String)
{
    static Typeface := "Courier New"
    static Size := 10
    static hDC, hFont := 0, Extent
    If !hFont
    {
        hDC := DllCall("GetDC","UPtr",0,"UPtr")
        Height := -DllCall("MulDiv","Int",Size,"Int",DllCall("GetDeviceCaps","UPtr",hDC,"Int",90),"Int",72)
        hFont := DllCall("CreateFont","Int",Height,"Int",0,"Int",0,"Int",0,"Int",400,"UInt",False,"UInt",False,"UInt",False,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"Str",Typeface)
        hOriginalFont := DllCall("SelectObject","UPtr",hDC,"UPtr",hFont,"UPtr")
        VarSetCapacity(Extent,8)
    }
    DllCall("GetTextExtentPoint32","UPtr",hDC,"Str",String,"Int",StrLen(String),"UPtr",&Extent)
    Return, NumGet(Extent,0,"UInt")
}



SetHotkeys(ResetKeyList,TriggerKeyList)
{
    Loop, Parse, ResetKeyList, `n
        Hotkey, ~*%A_LoopField%, ResetWord, UseErrorLevel

    Hotkey, IfWinExist, AutoComplete ahk_class AutoHotkeyGUI
    Loop, Parse, TriggerKeyList, `n
        Hotkey, %A_LoopField%, CompleteWord, UseErrorLevel
}