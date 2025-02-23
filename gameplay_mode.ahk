; ======== PERFORMANCE TWEAKS ========
#InstallKeybdHook
#UseHook Off
SendMode Input  ; Fastest key response
SetBatchLines -1
SetKeyDelay, 0

; ======== GLOBAL VARIABLES ========
global prevGameWidth := 0
global prevGameHeight := 0
global prevStates := {}
global hBlackBG

; ======== CONTROLLER CONFIG ========
JoyID := 1       ; Change if multiple controllers
deadzone := 5    ; Tighter deadzone (adjust 1-10)

; ======== BLACK BACKGROUND ========
Gui, BlackBG:New, +HwndhBlackBG -Caption +ToolWindow +E0x20  ; Click-through
Gui, BlackBG:Color, 000000
Gui, BlackBG:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight% NoActivate

; ======== LAUNCH GAME ========
Run, Game.exe  ; Replace with your EXE
WinWait, Pokemon Insurgence

; ======== FORCE BORDERLESS ========
SetTitleMatchMode, 2
WinSet, Style, -0xC00000, Pokemon Insurgence  ; Remove title bar
WinSet, Style, -0x40000, Pokemon Insurgence   ; Remove border
WinSet, AlwaysOnTop, On, Pokemon Insurgence   ; Keep above background
WinActivate, Pokemon Insurgence

; ======== INITIAL WINDOW SETUP ========
Sleep, 2000  ; Let game stabilize
UpdateGameWindowSize(true)  ; Force borderless on launch

#Persistent
SetTimer, ControllerInput, 5
SetTimer, CheckGameProcess, 1000
SetTimer, WindowSizeMonitor, 500

return

; ======== DYNAMIC WINDOW ADJUSTMENT ========
WindowSizeMonitor:
  UpdateGameWindowSize()
return

UpdateGameWindowSize(force := false) {
  global prevGameWidth, prevGameHeight, hBlackBG
  
  ; Force borderless mode
  WinSet, Style, -0xC00000, Pokemon Insurgence  ; Remove title bar
  WinSet, Style, -0x40000, Pokemon Insurgence   ; Remove border
  
  ; Get window position/size
  WinGetPos, X, Y, CurrentWidth, CurrentHeight, Pokemon Insurgence
  if (!force && CurrentWidth = prevGameWidth && CurrentHeight = prevGameHeight)
    return
  
  ; Update black background cutout
  WinSet, Region, %X%-%Y% %CurrentWidth% %CurrentHeight%, ahk_id %hBlackBG%
  
  ; Center window
  XPos := (A_ScreenWidth - CurrentWidth) // 2
  YPos := (A_ScreenHeight - CurrentHeight) // 2
  WinMove, Pokemon Insurgence,, %XPos%, %YPos%
  
  prevGameWidth := CurrentWidth
  prevGameHeight := CurrentHeight
}

; ======== AUTO-CLOSE ========
CheckGameProcess:
  Process, Exist, Game.exe
  if (!ErrorLevel || !WinExist("Pokemon Insurgence")) {
    ; Release all keys on exit
    Send, {Right up}{Left up}{Down up}{Up up}
    for button, state in prevStates {
      Send, % "{" . GetKeyName(button) . " up}"
    }
    Gui, BlackBG:Destroy
    ExitApp
  }
return

; ======== CONTROLLER INPUT (REVISED) ========
ControllerInput:
  IfWinNotExist, Pokemon Insurgence
    ExitApp

  IfWinActive, Pokemon Insurgence
  {
    ; === PRECISE MOVEMENT ===
    GetKeyState, JoyX, %JoyID%JoyX
    GetKeyState, JoyY, %JoyID%JoyY
    GetKeyState, JoyPOV, %JoyID%JoyPOV

    ; D-pad takes priority
    DpadRight := (JoyPOV = 9000)
    DpadLeft := (JoyPOV = 27000)
    DpadDown := (JoyPOV = 18000)
    DpadUp := (JoyPOV = 0)

    ; Horizontal Axis
    if (DpadRight || JoyX > 50 + deadzone)
      Send, {Right down}
    else if (DpadLeft || JoyX < 50 - deadzone)
      Send, {Left down}
    else
      Send, {Right up}{Left up}

    ; Vertical Axis
    if (DpadDown || JoyY > 50 + deadzone)
      Send, {Down down}
    else if (DpadUp || JoyY < 50 - deadzone)
      Send, {Up down}
    else
      Send, {Down up}{Up up}

    ; === CONTROLLER BUTTONS (1-12) ===
    global prevStates
    Loop 12 {
      button := A_Index
      GetKeyState, state, % JoyID "Joy" button
      
      if (state = "D" && !prevStates.HasKey(button)) {
        if (button = 1)        ; A - Confirm
          Send, {c down}
        else if (button = 2)   ; B - Cancel
          Send, {x down}
        else if (button = 3)   ; X - Run
          Send, {z down}
        else if (button = 4)   ; Y - Menu
          Send, {Enter down}
        else if (button = 5)   ; LB - Q
          Send, {q down}
        else if (button = 6)   ; RB - W
          Send, {w down}
        else if (button = 7)   ; Back - Autorun (S)
          Send, {s down}
        else if (button = 8)   ; Start - Quicksave (V)
          Send, {v down}
        else if (button = 9)   ; L3 - Speed-Up (M)
          Send, {m down}
        else if (button = 10)  ; R3 - DexNav (D)
          Send, {d down}
        else if (button = 11)  ; LT - T
          Send, {t down}
        else if (button = 12)  ; RT - Y
          Send, {y down}
        
        prevStates[button] := true
      }
      else if (state = "U" && prevStates.HasKey(button)) {
        key := GetKeyName(button)
        Send, % "{" . key . " up}"
        prevStates.Delete(button)
      }
    }
  }
  else {  ; Release all inputs if window inactive
    Send, {Right up}{Left up}{Down up}{Up up}
    for button, state in prevStates {
      Send, % "{" . GetKeyName(button) . " up}"
    }
    prevStates := {}
  }
return

; ======== HELPER FUNCTION ========
GetKeyName(index) {
  static keys := ["c","x","z","Enter","q","w","s","v","m","d","t","y"]
  return keys.HasKey(index) ? keys[index] : ""
}