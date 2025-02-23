; ======== CONTROLLER SUPPORT FOR POKEMON INSURGENCE ========
#InstallKeybdHook
#UseHook Off
SendMode Input  ; Fastest key response
SetBatchLines -1
SetKeyDelay, 0   ; No input delay

; ======== CONTROLLER CONFIG ========
JoyID := 1       ; Change if multiple controllers
deadzone := 5    ; Tighter deadzone (adjust 1-10)
global prevStates := {}

; ======== LAUNCH GAME ========
Run, Game.exe  ; Replace with your EXE
WinWait, Pokemon Insurgence

#Persistent
SetTimer, ControllerInput, 5    ; Ultra-responsive 5ms polling
SetTimer, CheckGameProcess, 1000 ; Auto-close check

; ======== AUTO-CLOSE ========
CheckGameProcess:
  Process, Exist, Game.exe
  if (!ErrorLevel || !WinExist("Pokemon Insurgence")) {
    ; Release all keys on exit
    Send, {Right up}{Left up}{Down up}{Up up}
    for button, state in prevStates {
      Send, % "{" . GetKeyName(button) . " up}"
    }
    ExitApp
  }
return

; ======== CONTROLLER INPUT ========
ControllerInput:
  IfWinNotExist, Pokemon Insurgence
    ExitApp

  IfWinActive, Pokemon Insurgence
  {
    ; === LIGHTNING-FAST MOVEMENT ===
    GetKeyState, JoyX, %JoyID%JoyX
    GetKeyState, JoyY, %JoyID%JoyY
    GetKeyState, JoyPOV, %JoyID%JoyPOV

    ; D-pad takes priority
    DpadRight := (JoyPOV = 9000)
    DpadLeft := (JoyPOV = 27000)
    DpadDown := (JoyPOV = 18000)
    DpadUp := (JoyPOV = 0)

    ; Horizontal (Instantaneous)
    if (DpadRight || JoyX > 50 + deadzone)
      Send, {Right down}
    else if (DpadLeft || JoyX < 50 - deadzone)
      Send, {Left down}
    else
      Send, {Right up}{Left up}

    ; Vertical (Instantaneous)
    if (DpadDown || JoyY > 50 + deadzone)
      Send, {Down down}
    else if (DpadUp || JoyY < 50 - deadzone)
      Send, {Up down}
    else
      Send, {Down up}{Up up}

    ; === BUTTONS 1-12 (MAPPED TO GAME CONTROLS) ===
    Loop 12  ; Supports modern controllers
    {
      button := A_Index
      GetKeyState, state, % JoyID "Joy" button
      
      if (state = "D" && !prevStates.HasKey(button))
      {
        ; ---- Key Mappings ----
        if (button = 1)        ; A Button (Confirm)
          Send, {c down}
        else if (button = 2)   ; B Button (Cancel)
          Send, {x down}
        else if (button = 3)   ; X Button (Run)
          Send, {z down}
        else if (button = 4)   ; Y Button (Menu)
          Send, {Enter}
        else if (button = 5)   ; LB (Registered#1: Q)
          Send, {q down}
        else if (button = 6)   ; RB (Registered#2: W)
          Send, {w down}
        else if (button = 7)   ; Back (Autorun: S)
          Send, {s down}
        else if (button = 8)   ; Start (Quicksave: V)
          Send, {v down}
        else if (button = 9)   ; L3 (Speed-Up: M)
          Send, {m down}
        else if (button = 10)  ; R3 (DexNav: D)
          Send, {d down}
        else if (button = 11)  ; LT (Registered#4: T)
          Send, {t down}
        else if (button = 12)  ; RT (Registered#5: Y)
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
return

; Helper function
GetKeyName(index) {
  static keys := ["c","x","z","Enter","q","w","s","v","m","d","t","y"]
  return keys.HasKey(index) ? keys[index] : ""
}