; ======== PERFORMANCE TWEAKS ========
#InstallKeybdHook
#UseHook Off
SendMode Event
SetBatchLines -1
SetKeyDelay, 0

; ======== GLOBAL VARIABLES ========
global prevGameWidth := 0
global prevGameHeight := 0
global prevStates := {}
global hBlackBG

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

; ======== CONTROLLER CONFIG ========
JoyID := 1
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
    Gui, BlackBG:Destroy
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