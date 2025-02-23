; ======== CONTROLLER TO KEYBOARD + AUTO-CLOSE ========
#InstallKeybdHook
#UseHook Off
SendMode Event
SetBatchLines -1
SetKeyDelay, 0

; ======== LAUNCH GAME ========
Run, Game.exe  ; Replace with your EXE
WinWait, Pokemon Insurgence

; ======== CONTROLLER CONFIG ========
JoyID := 1  ; Change if multiple controllers
global prevStates := {}  ; Track button states

#Persistent
SetTimer, ControllerInput, 5  ; 5ms polling
SetTimer, CheckGameProcess, 1000  ; Auto-close check

; ======== AUTO-CLOSE ========
CheckGameProcess:
  Process, Exist, Game.exe
  if (!ErrorLevel || !WinExist("Pokemon Insurgence"))
  {
    ; Release all keys on exit
    for button, state in prevStates
    {
      Send, % "{ " . GetKeyName(button) . " up}"
    }
    ExitApp
  }
return

; ======== CONTROLLER INPUT (FULL) ========
ControllerInput:
  IfWinNotExist, Pokemon Insurgence
    ExitApp

  IfWinActive, Pokemon Insurgence
  {
    ; === JOYSTICK/D-PAD MOVEMENT ===
    GetKeyState, JoyX, %JoyID%JoyX
    GetKeyState, JoyY, %JoyID%JoyY
    GetKeyState, JoyPOV, %JoyID%JoyPOV

    ; D-pad directions
    DpadUp := (JoyPOV = 0)
    DpadRight := (JoyPOV = 9000)
    DpadDown := (JoyPOV = 18000)
    DpadLeft := (JoyPOV = 27000)

    ; Horizontal movement
    if (JoyX > 65 || DpadRight)
      Send, {Right down}
    else if (JoyX < 35 || DpadLeft)
      Send, {Left down}
    else
    {
      Send, {Right up}
      Send, {Left up}
    }

    ; Vertical movement
    if (JoyY > 65 || DpadDown)
      Send, {Down down}
    else if (JoyY < 35 || DpadUp)
      Send, {Up down}
    else
    {
      Send, {Down up}
      Send, {Up up}
    }

    ; === BUTTONS 1-8 ===
    Loop 8
    {
      button := A_Index
      GetKeyState, state, % JoyID "Joy" button
      
      if (state = "D" && !prevStates.HasKey(button))
      {
        ; Press
        if (button = 1)
          Send, {c down}
        else if (button = 2)
          Send, {x down}
        else if (button = 3)
          Send, {z down}
        else if (button = 4)
          Send, {Enter}
        else if (button = 5)
          Send, {q}
        else if (button = 6)
          Send, {w}
        else if (button = 7)
          Send, {Esc}
        else if (button = 8)
          Send, {v}
        prevStates[button] := true
      }
      else if (state = "U" && prevStates.HasKey(button))
      {
        ; Release
        if (button = 1)
          Send, {c up}
        else if (button = 2)
          Send, {x up}
        else if (button = 3)
          Send, {z up}
        else if (button = 4)
          Send, {Enter up}
        else if (button = 5)
          Send, {q up}
        else if (button = 6)
          Send, {w up}
        else if (button = 7)
          Send, {Esc up}
        else if (button = 8)
          Send, {v up}
        prevStates.Delete(button)
      }
    }
  }
  else  ; Release all keys if window inactive
  {
    ; Release movement keys
    Send, {Right up}
    Send, {Left up}
    Send, {Down up}
    Send, {Up up}
    
    ; Release action buttons
    for button, state in prevStates
    {
      Send, % "{ " . GetKeyName(button) . " up}"
    }
    prevStates := {}
  }
return

; Helper function for key names
GetKeyName(index) {
  static keys := ["c", "x", "z", "Enter", "q", "w", "Esc", "v"]
  return keys[index]
}