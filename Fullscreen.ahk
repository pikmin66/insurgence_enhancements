; ======== PERFORMANCE TWEAKS ========
#InstallKeybdHook
#UseHook Off
SendMode Event
SetBatchLines -1
SetKeyDelay, 0

; ======== GLOBAL VARIABLES ========
global prevStates := {}  ; Fixed initialization

; ======== BLACK BACKGROUND ========
Gui, Color, 000000
Gui, -Caption +ToolWindow +AlwaysOnTop
Gui, Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%

; ======== LAUNCH GAME ========
Run, "Game.exe"
WinWait, Pokemon Insurgence

; ======== CENTERING SYSTEM ========
SetTitleMatchMode, 2
WinGetPos,,, Width, Height, Pokemon Insurgence
ScreenWidth := A_ScreenWidth
ScreenHeight := A_ScreenHeight
Gosub, CenterWindow

; ======== WINDOW STYLING ========
WinSet, Style, -0xC00000, Pokemon Insurgence
WinSet, Style, -0x40000, Pokemon Insurgence
WinSet, AlwaysOnTop, On, Pokemon Insurgence
WinActivate, Pokemon Insurgence

; ======== CONTROLLER CONFIG ========
#Persistent
SetTimer, ControllerInput, 5
JoyID := 1

; ======== PROCESS TRACKING ========
Process, Exist, Game.exe
gamePID := ErrorLevel
SetTimer, CheckGameProcess, 1000
SetTimer, ForceFocus, 500

return

; ======== DYNAMIC CENTERING ========
CenterWindow:
  WinGetPos,,, CurrentWidth, CurrentHeight, Pokemon Insurgence
  XPos := (A_ScreenWidth - CurrentWidth) // 2
  YPos := (A_ScreenHeight - CurrentHeight) // 2
  WinMove, Pokemon Insurgence,, %XPos%, %YPos%
return

; ======== WINDOW MANAGEMENT ========
ForceFocus:
  IfWinExist, Pokemon Insurgence
  {
    WinGetPos,,, CurrentWidth, CurrentHeight, Pokemon Insurgence
    Gosub, CenterWindow
    WinSet, Style, -0xC00000, Pokemon Insurgence
    WinSet, Style, -0x40000, Pokemon Insurgence
    WinActivate, Pokemon Insurgence
  }
return

; ======== AUTO-CLOSE ========
CheckGameProcess:
  Process, Exist, %gamePID%
  gameRunning := ErrorLevel
  IfWinNotExist, Pokemon Insurgence
    gameRunning := 0

  if (!gameRunning)
  {
    Gui, Destroy
    WinSet, AlwaysOnTop, Off, Pokemon Insurgence
    WinSet, Style, +0xC00000, Pokemon Insurgence
    WinSet, Style, +0x40000, Pokemon Insurgence
    ExitApp
  }
return

; ======== CONTROLLER INPUT (FIXED) ========
ControllerInput:
  IfWinNotExist, Pokemon Insurgence
    ExitApp

  IfWinActive, Pokemon Insurgence
  {
    ; --- Movement ---
    GetKeyState, JoyX, %JoyID%JoyX
    GetKeyState, JoyY, %JoyID%JoyY
    GetKeyState, JoyPOV, %JoyID%JoyPOV

    DpadUp := (JoyPOV = 0)
    DpadRight := (JoyPOV = 9000)
    DpadDown := (JoyPOV = 18000)
    DpadLeft := (JoyPOV = 27000)

    ; Horizontal
    if (JoyX > 65 || DpadRight)
      Send, {Right down}
    else if (JoyX < 35 || DpadLeft)
      Send, {Left down}
    else
    {
      Send, {Right up}
      Send, {Left up}
    }

    ; Vertical
    if (JoyY > 65 || DpadDown)
      Send, {Down down}
    else if (JoyY < 35 || DpadUp)
      Send, {Up down}
    else
    {
      Send, {Down up}
      Send, {Up up}
    }

    ; --- Buttons ---
    global prevStates  ; Access global variable
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
  else  ; Release all keys if inactive
  {
    for button, state in prevStates
    {
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
    }
    prevStates := {}
  }
return