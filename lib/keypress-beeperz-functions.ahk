﻿; KeypressOSD.ahk - beepers functions file
; Latest version at:
; http://marius.sucan.ro/media/files/blog/ahk-scripts/keypress-osd.ahk
;
; Charset for this file must be UTF 8 with BOM.
; it may not function properly otherwise.

#Persistent
#NoTrayIcon
#SingleInstance force
#NoEnv
#MaxHotkeysPerInterval 500
SetWorkingDir, %A_ScriptDir%

Global ToggleKeysBeeper  := 1
 , CapslockBeeper        := 1     ; only when the key is released
 , KeyBeeper             := 0     ; only when the key is released
 , ModBeeper             := 0     ; beeps for every modifier, when released
 , MouseBeeper           := 0     ; if both, ShowMouseButton and Visual Mouse Clicks are disabled, mouse click beeps will never occur
 , beepFiringKeys        := 0
 , TypingBeepers         := 0
 , DTMFbeepers           := 0
 , BeepSentry            := 0
 , prioritizeBeepers     := 0     ; this will probably make the OSD stall
 , IniFile               := "keypress-osd.ini"
 , ScriptelSuspendel     := 0
 , SilentMode     := 0
 , lastKeyUpTime := 0
 , lastModPressTime := 0
 , lastModPressTime2 := 0
 , LastFiredTime := 0
 , toggleLastState := 0
 , skipAbeep := 0
 , isBeeperzFile := 1
 , RunningCompiled := 0
 , ScriptelSuspendel := 0

;  IniRead, RunningCompiled, %inifile%, TempSettings, RunningCompiled, %RunningCompiled%
;  IniRead, ScriptelSuspendel, %inifile%, TempSettings, ScriptelSuspendel, %ScriptelSuspendel%
  IniRead, SilentMode, %inifile%, SavedSettings, SilentMode, %SilentMode%
  IniRead, MouseBeeper, %inifile%, SavedSettings, MouseBeeper, %MouseBeeper%
  IniRead, beepFiringKeys, %inifile%, SavedSettings, beepFiringKeys, %beepFiringKeys%
  IniRead, BeepSentry, %inifile%, SavedSettings, BeepSentry, %BeepSentry%
  IniRead, CapslockBeeper, %inifile%, SavedSettings, CapslockBeeper, %CapslockBeeper%
  IniRead, TypingBeepers, %inifile%, SavedSettings, TypingBeepers, %TypingBeepers%
  IniRead, DTMFbeepers, %inifile%, SavedSettings, DTMFbeepers, %DTMFbeepers%
  IniRead, ToggleKeysBeeper, %inifile%, SavedSettings, ToggleKeysBeeper, %ToggleKeysBeeper%
  IniRead, KeyBeeper, %inifile%, SavedSettings, KeyBeeper, %KeyBeeper%
  IniRead, ModBeeper, %inifile%, SavedSettings, ModBeeper, %ModBeeper%
  IniRead, prioritizeBeepers, %inifile%, SavedSettings, prioritizeBeepers, %prioritizeBeepers%

if (ScriptelSuspendel=1 || SilentMode=1)
   Return

if (prioritizeBeepers=1)
{
   Critical, on
   #MaxThreads 255
   #MaxThreadsPerHotkey 255
   #MaxThreadsBuffer On
}

CreateHotkey()
Return

CreateHotkey() {

    If (MouseBeeper=1)
    {
       Loop, Parse, % "LButton|MButton|RButton|WheelDown|WheelUp|WheelLeft|WheelRight", |
             Hotkey, % "~*" A_LoopField, OnMousePressed, useErrorLevel
    }

    If (keyBeeper=1 || beepFiringKeys=1)
    {
        Loop, 24 ; F1-F24
        {
           Hotkey, % "~*F" A_Index, OnKeyPressed, useErrorLevel
           Hotkey, % "~*F" A_Index " Up", OnKeyUp, useErrorLevel
        }

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        Loop, Parse, NumpadKeysList, |
        {
           Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }

        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
        {
            Hotkey, % "~*Numpad" A_Index - 1, OnKeyPressed, UseErrorLevel
            Hotkey, % "~*Numpad" A_Index - 1 " Up", OnKeyUp, UseErrorLevel
        }

        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"

        Loop, Parse, NumpadSymbols, |
        {
           Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
           Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }

        Otherkeys := "XButton1|XButton2|Browser_Forward|Browser_Back|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|Help|Sleep|PrintScreen|CtrlBreak|Break|AppsKey|Tab|Enter|Esc"
                   . "|Left|Right|Down|Up|End|Home|PgUp|PgDn|Space|Del|BackSpace|Insert|CapsLock|ScrollLock|NumLock|Pause|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pausesc146|sc123"
        Loop, Parse, Otherkeys, |
        {
            Hotkey, % "~*" A_LoopField, OnKeyPressed, useErrorLevel
            Hotkey, % "~*" A_LoopField " Up", OnKeyUp, useErrorLevel
        }
    }

    If (ToggleKeysBeeper=1)
    {
        ToggleKeys := "CapsLock|ScrollLock|NumLock"
        Loop, Parse, ToggleKeys, |
              Hotkey, % "~*" A_LoopField " Up", OnToggleUp, useErrorLevel
    }

    If (TypingBeepers=1 && keyBeeper=1)
    {

        NumpadKeysList := "NumpadDel|NumpadIns|NumpadEnd|NumpadDown|NumpadPgdn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgup|NumpadEnter"
        NumpadSymbols := "NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub"
        Loop, Parse, NumpadKeysList, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, Parse, NumpadSymbols, |
              Hotkey, % "~*" A_LoopField " Up", OnNumpadsGeneralUp, useErrorLevel

        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsGeneralUp, UseErrorLevel

        Loop, 24 ; F1-F24
              Hotkey, % "~*F" A_Index " Up", OnFunctionKeyUp, useErrorLevel

        Enterz := "NumpadEnter|Enter"
        OtherTypingKeysz := "Tab|Esc|PrintScreen|CtrlBreak|AppsKey|Insert"
        Hotkey, ~*Del Up, OnTypingKeysDelUp, useErrorLevel
        Hotkey, ~*BackSpace Up, OnTypingKeysBkspUp, useErrorLevel
        Hotkey, ~*Space Up, OnTypingKeysSpaceUp, useErrorLevel
        Hotkey, ~*Left Up, OnTypingLeftUp, useErrorLevel
        Hotkey, ~*Right Up, OnTypingRightUp, useErrorLevel
        Hotkey, ~*Home Up, OnTypingHomeUp, useErrorLevel
        Hotkey, ~*End Up, OnTypingEndUp, useErrorLevel
        Hotkey, ~*PgUp Up, OnTypingPgUpUp, useErrorLevel
        Hotkey, ~*PgDn Up, OnTypingPgDnUp, useErrorLevel
        Hotkey, ~*Up Up, OnTypingUpUp, useErrorLevel
        Hotkey, ~*Down Up, OnTypingDnUp, useErrorLevel
        Loop, Parse, Enterz, |
            Hotkey, % "~*" A_LoopField " Up", OnTypingKeysEnterUp, useErrorLevel
        Loop, Parse, OtherTypingKeysz, |
            Hotkey, % "~*" A_LoopField " Up", ONotherDistinctKeysUp, useErrorLevel

        MediaKeys := "Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause"
        Loop, Parse, MediaKeys, |
            Hotkey, % "~*" A_LoopField, OnMediaPressed, useErrorLevel

    }

    If (modBeeper=1 || beepFiringKeys=1)
    {
        For i, mod in ["LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin"]
        {
          Hotkey, % "~*" mod, OnModPressed, useErrorLevel
          Hotkey, % "~*" mod " Up", OnModUp, useErrorLevel
        }
    }

    If (DTMFbeepers=1)
    {
        Hotkey, ~*NumpadDot Up, OnNumpadsDTMFUp, useErrorLevel
        Loop, 10 ; Numpad0 - Numpad9 ; numlock on
              Hotkey, % "~*Numpad" A_Index - 1 " Up", OnNumpadsDTMFUp, UseErrorLevel
    }
}

OnKeyPressed() {
    Thread, priority, -30
    If (beepFiringKeys=1)
       SetTimer, firedBeeperTimer, 20, -20
}

OnModPressed() {
    Thread, priority, -30
    Critical, off

    If (beepFiringKeys=1 && (A_TickCount-lastModPressTime < 350))
       SetTimer, modfiredBeeperTimer, 20, -20

    If ((A_TickCount-lastModPressTime < 350) || skipAbeep=1)
    {
       skipAbeep := 0
       Global lastModPressTime := A_TickCount
       Return
    }

    If (ModBeeper = 1) && (A_TickCount-lastKeyUpTime > 100) && (A_TickCount-lastModPressTime2 > 350)
       modsBeeper()

    Global lastModPressTime2 := A_TickCount
}

OnMediaPressed() {
   Thread, priority, -10
   SetTimer, volBeeperTimer, 30, -20
}

OnKeyUp() {
    Global lastKeyUpTime := A_TickCount
    If (keyBeeper=1)
       keysBeeper()
    checkIfSkipAbeep()
}

OnToggleUp() {
    Global lastKeyUpTime := A_TickCount
    toggleLastState := (toggleLastState=1) ? 0 : 1
    toggleBeeper()
    checkIfSkipAbeep()
}

OnTypingLeftUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysArrowsL.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingHomeUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysHome.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingEndUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysEnd.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingPgUpUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysPgUp.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingPgDnUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysPgDn.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingRightUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysArrowsR.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnFunctionKeyUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\functionKeys.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

ONotherDistinctKeysUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\otherDistinctKeys.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnNumpadsGeneralUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\numpads.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnNumpadsDTMFUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   sound2PlayNow := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, "ad")+2, 1)

   If InStr(A_ThisHotkey, "dot")
      sound2PlayNow := "A"

   SoundPlay("sounds\num" sound2PlayNow "pad.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysEnterUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysEnter.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysDelUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysDel.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysBkspUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysBksp.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingKeysSpaceUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysSpace.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingUpUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysArrowsU.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnTypingDnUp() {
   Global lastKeyUpTime := A_TickCount
   Sleep, 15
   SoundPlay("sounds\typingkeysArrowsD.wav", prioritizeBeepers)
   checkIfSkipAbeep()
}

OnModUp() {
   Thread, Priority, -10
   Critical, off

   If (ModBeeper = 1) && (A_TickCount-lastModPressTime > 250) && (A_TickCount-lastModPressTime2 > 450)
      modsBeeper()
}

toggleBeeper() {
   Sleep, 15
   If (toggleLastState=1)
      SoundPlay("sounds\caps.wav", prioritizeBeepers)
   Else
      SoundPlay("sounds\cups.wav", prioritizeBeepers)
}

capsBeeper() {
   Sleep, 15
   SoundPlay("sounds\caps.wav", prioritizeBeepers)
}

keysBeeper() {
   Sleep, 15
   SoundPlay("sounds\keys.wav", prioritizeBeepers)
}

volBeeperTimer() {
   Thread, priority, -10
   If ((A_TickCount-lastKeyUpTime < 700) && keyBeeper=1)
   {
      SetTimer, , off
      Return
   }
   Sleep, 15
   SoundPlay("sounds\media.wav", prioritizeBeepers)
   SetTimer, , off
}

deadKeysBeeper() {
   Critical, on
   SoundPlay("sounds\deadkeys.wav", 1)
}

modsBeeper() {
   Thread, Priority, -10
   Critical, off

   Global lastModPressTime := A_TickCount
   SoundPlay("sounds\mods.wav", prioritizeBeepers)
}

firedBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   If ((A_TickCount-lastKeyUpTime < 600) && keyBeeper=1)
   {
      SetTimer, , off
      Return
   }

   If ((A_TickCount-LastFiredTime > 100) && keyBeeper=1)
   {
      Sleep, 20
      Global LastFiredTime := A_TickCount
      SetTimer, , off
      Return
   }
   SoundPlay("sounds\firedkey.wav")
   Sleep, 40
   Global LastFiredTime := A_TickCount
   SetTimer, , off
}

modfiredBeeperTimer() {
   Thread, Priority, -20
   Critical, off

   If ((A_TickCount-LastFiredTime < 200) && keyBeeper=1)
   {
      Sleep, 20
      SetTimer, , off
      Return
   }
   SoundPlay("sounds\modfiredkey.wav")
   Sleep, 40
   Global LastFiredTime := A_TickCount

   SetTimer, , off
}

OnLetterPressed() {
    If (ScriptelSuspendel=1 || SilentMode=1)
       Return

    GetKeyState, CapsState, CapsLock, T
    If (CapslockBeeper = 1)
    {
        If (CapsState = "D")
           capsBeeper()
        Else If (KeyBeeper = 1)
           keysBeeper()
    }

    If (CapslockBeeper=0 && KeyBeeper=1 && SilentMode=0)
        keysBeeper()
    checkIfSkipAbeep()
}

OnDeathKeyPressed() {
  Critical, on
  If (ScriptelSuspendel=1 || SilentMode=1)
     Return
  deadKeysBeeper()
  checkIfSkipAbeep()
}

OnMousePressed() {
    Critical, Off
    Thread, Priority, -50
    If (silentMode=1)
       Return

    If (MouseBeeper = 1) && (A_ThisHotkey ~= "i)(LButton|MButton|RButton)")
    {
       If (TypingBeepers=1 && InStr(A_ThisHotkey, "RButton"))
          SoundPlay("sounds\clickR.wav")
       Else If (TypingBeepers=1 && InStr(A_ThisHotkey, "MButton"))
          SoundPlay("sounds\clickM.wav")
       Else
          SoundPlay("sounds\clicks.wav")
    } Else If (MouseBeeper = 1) && (A_ThisHotkey ~= "i)(WheelDown|WheelUp|WheelLeft|WheelRight)")
    {
       SoundPlay("sounds\firedkey.wav")
       Sleep, 40
    }

}

checkIfSkipAbeep() {
    skipAbeep := 0
    static modifiers := ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
    For i, mod in modifiers
    {
        If GetKeyState(mod)
           skipAbeep := 1
    }
}

firingKeys() {
   Thread, Priority, -20
   Critical, off

   SoundPlay("sounds\modfiredkey.wav")
   Sleep, 20
}

holdingKeys() {
   Thread, Priority, -20
   Critical, off

   SoundPlay("sounds\holdingKeys.wav")
   Sleep, 20
}

PlaySoundTest() {
   Thread, Priority, -20
   Critical, off
   Sleep, 50
   SoundPlay("sounds\keys.wav")
   Sleep, 50
}

; function by Drugwash:
; ===============================
SoundPlay(snd, wait:=0) {
  If (ScriptelSuspendel="Y")
     Return

  Static hM := DllCall("kernel32\GetModuleHandleW", "Str", A_ScriptFullPath, "Ptr")
  f := BeepSentry=1 ? "0x80012" : "0x12"
  w := wait ? 0 : 0x2001
  If (RunningCompiled="Y")
  {
	  SplitPath, snd, snd
	  StringUpper, snd, snd
	  hMod:=hM, flags := f|w|0x40004
	} Else
	{
	  hMod := 0, flags := f|w|0x20000
	}

  Return DllCall("winmm\PlaySoundW"
	  , "Str", snd
	  , "Ptr", hMod
	  , "UInt", flags)	; SND_RESOURCE|SND_NOWAIT|SND_NOSTOP|SND_NODEFAULT|SND_ASYNC
}