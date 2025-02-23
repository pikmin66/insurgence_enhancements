; ======== BORDERLESS FULLSCREEN + AUTO-CLOSE ========
#SingleInstance Force
#InstallKeybdHook
SetBatchLines -1

; ======== GLOBAL VARIABLES ========
global hBlackBG  ; Black background GUI handle
global prevWidth := 0, prevHeight := 0

; ======== BLACK BACKGROUND ========
Gui, BlackBG:New, +HwndhBlackBG -Caption +ToolWindow +E0x20  ; Click-through
Gui, BlackBG:Color, 000000
Gui, BlackBG:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight% NoActivate

; ======== LAUNCH GAME ========
Run, Game.exe  ; Replace with your EXE
WinWait, Pokemon Insurgence

; ======== INITIAL SETUP ========
SetTitleMatchMode, 2
SetWinDelay, 100  ; Increase delay for window operations

; Wait for game to apply settings (adjust if needed)
Sleep, 3000  ; Increased delay for slow systems

; ======== FORCE BORDERLESS & CENTER ========
UpdateWindowState(true)  ; Initial setup

; ======== WINDOW MANAGEMENT ========
SetTimer, UpdateWindowState, 500  ; Check every 500ms
SetTimer, CheckGameProcess, 1000

return

; ======== DYNAMIC WINDOW HANDLER ========
UpdateWindowState(force := false) {
  global prevWidth, prevHeight, hBlackBG
  
  ; Force borderless mode
  WinSet, Style, -0xC00000, Pokemon Insurgence  ; Remove title bar
  WinSet, Style, -0x40000, Pokemon Insurgence   ; Remove border
  WinSet, AlwaysOnTop, On, Pokemon Insurgence   ; Keep above background
  
  ; Get current window state
  WinGetPos, X, Y, W, H, Pokemon Insurgence
  
  ; Only update if size changes or forced
  if (W != prevWidth || H != prevHeight || force) {
    ; Center window
    XPos := (A_ScreenWidth - W) // 2
    YPos := (A_ScreenHeight - H) // 2
    WinMove, Pokemon Insurgence,, %XPos%, %YPos%
    
    ; Update black background cutout
    WinSet, Region, %XPos%-%YPos% %W% %H%, ahk_id %hBlackBG%
    
    ; Store new dimensions
    prevWidth := W
    prevHeight := H
  }
}

; ======== AUTO-CLOSE ========
CheckGameProcess:
  Process, Exist, Game.exe
  if (!ErrorLevel || !WinExist("Pokemon Insurgence")) {
    Gui, BlackBG:Destroy
    WinSet, Style, +0xC00000, Pokemon Insurgence  ; Restore title bar
    WinSet, Style, +0x40000, Pokemon Insurgence   ; Restore border
    ExitApp
  }
return