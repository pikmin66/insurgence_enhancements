; ======== CONTROLLER TO KEYBOARD + AUTO-CLOSE ========
#InstallKeybdHook
#UseHook Off
SendMode Event
SetBatchLines -1
SetKeyDelay, 50  ; Added slight delay for stubborn inputs

; ======== LAUNCH GAME ========
Run, Game.exe  ; Replace with your EXE
WinWait, Pokemon Insurgence

; ======== CONTROLLER CONFIG ========
JoyID := 1  ; Change if multiple controllers
global prevStates := {}  ; Track button states

; ======== DEADZONE TWEAKS ========
deadzone := 15  ; More responsive deadzone (adjust as needed)

#Persistent
SetTimer, ControllerInput, 10  ; Slightly slower polling for stability
SetTimer, CheckGameProcess, 1000

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

    ; Horizontal movement (tighter deadzone)
    if (JoyX > (50 + deadzone) || DpadRight)
      Send, {Right down}
    else if (JoyX < (50 - deadzone) || DpadLeft)
      Send, {Left down}
    else
    {
      Send, {Right up}
      Send, {Left up}
    }

    ; Vertical movement (tighter deadzone)
    if (JoyY > (50 + deadzone) || DpadDown)
      Send, {Down down}
    else if (JoyY < (50 - deadzone) || DpadUp)
      Send, {Up down}
    else
    {
      Send, {Down up}
      Send, {Up up}
    }

    ; === BUTTONS 1-12 (Supports R1/R2/Start/Select/etc) ===
    Loop 12  ; Changed from 8 to 12 for extra buttons
    {
      button := A_Index
      GetKeyState, state, % JoyID "Joy" button
      
      if (state = "D" && !prevStates.HasKey(button))
      {
        ; --- Updated Button Mapping ---
        if (button = 1)       ; A Button (Confirm)
          Send, {c down}
        else if (button = 2)  ; B Button (Cancel)
          Send, {x down}
        else if (button = 3)  ; X Button (Run)
          Send, {z down}
        else if (button = 4)  ; Y Button (Menu)
          Send, {Enter}
        else if (button = 5)  ; LB (Registered#1: Q)
          Send, {q down}
        else if (button = 6)  ; RB (Registered#2: W)
          Send, {w down}
        else if (button = 7)  ; Back/Select (Autorun: S)
          Send, {s down}
        else if (button = 8)  ; Start (Quicksave: V)
          Send, {v down}
        else if (button = 9)  ; L3 (Speed-Up: M)
          Send, {m down}
        else if (button = 10) ; R3 (DexNav: D)
          Send, {d down}
        else if (button = 11) ; LT (Registered#4: T)
          Send, {t down}
        else if (button = 12) ; RT (Registered#5: Y)
          Send, {y down}
        
        prevStates[button] := true
      }
      else if (state = "U" && prevStates.HasKey(button))
      {
        ; Release keys
        key := GetKeyName(button)
        Send, % "{" . key . " up}"
        prevStates.Delete(button)
      }
    }
  }
  else  ; Release all keys if window inactive
  {
    ; Release movement keys
    Send, {Right up}{Left up}{Down up}{Up up}
    
    ; Release action buttons
    for button, state in prevStates
    {
      key := GetKeyName(button)
      Send, % "{" . key . " up}"
    }
    prevStates := {}
  }
return

; Helper function (expanded for 12 buttons)
GetKeyName(index) {
  static keys := ["c","x","z","Enter","q","w","s","v","m","d","t","y"]
  return keys.HasKey(index) ? keys[index] : ""
}