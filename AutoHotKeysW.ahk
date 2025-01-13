#Requires AutoHotkey v2.0

; 1. for_loop script: Trigger macro when "²" is typed
²::SendText("for (int i = 0; i < total; i++")

; 2. Close_Window script
; AutoHotkey script to close the current window using Shift + Esc
+Esc:: {
    WinClose("A")  ; Close the currently active window
}

; 3. Line selection script
; AutoHotkey script to select the current line using Ctrl+L
!l::
{
    Send("{Home}+{End}")
}

; 4. Window_Size script
; Constants for SetWindowPos
SWP_NOSIZE := 0x0001
SWP_NOMOVE := 0x0002
SWP_NOZORDER := 0x0004
SWP_NOACTIVATE := 0x0010

; Function to set window position and size
SetWindowPosition(hwnd, x, y, width, height) {
    ; Ensure valid width and height
    if (width <= 0 || height <= 0) {
        MsgBox("Invalid width or height specified.")
        return false
    }
    ; Call the Windows API function
    result := DllCall("SetWindowPos"
        , "Ptr", hwnd        ; Window handle
        , "Ptr", 0           ; hWndInsertAfter (0 for no change)
        , "Int", x           ; X position
        , "Int", y           ; Y position
        , "Int", width       ; Width
        , "Int", height      ; Height
        , "UInt", SWP_NOZORDER | SWP_NOACTIVATE) ; Flags
    return result != 0  ; Returns true if successful
}

; Increase window width
^!Right::
{
    hwnd := WinExist("A")  ; Get the handle of the active window
    if !hwnd {
        MsgBox("No active window found. Ensure a window is focused.")
        return
    }
    WinGetPos(&x, &y, &width, &height, hwnd)
    if !(x + y + width + height) {
        MsgBox("Failed to retrieve window position or size.")
        return
    }
    if !SetWindowPosition(hwnd, x, y, width + 50, height) {
        MsgBox("Error resizing window.")
    }
}

; Decrease window width
^!Left::
{
    hwnd := WinExist("A")
    if !hwnd {
        MsgBox("No active window found. Ensure a window is focused.")
        return
    }
    WinGetPos(&x, &y, &width, &height, hwnd)
    if !(x + y + width + height) {
        MsgBox("Failed to retrieve window position or size.")
        return
    }
    if !SetWindowPosition(hwnd, x, y, width - 50, height) {
        MsgBox("Error resizing window.")
    }
}

; Increase window height
^!Down::
{
    hwnd := WinExist("A")
    if !hwnd {
        MsgBox("No active window found. Ensure a window is focused.")
        return
    }
    WinGetPos(&x, &y, &width, &height, hwnd)
    if !(x + y + width + height) {
        MsgBox("Failed to retrieve window position or size.")
        return
    }
    if !SetWindowPosition(hwnd, x, y, width, height + 50) {
        MsgBox("Error resizing window.")
    }
}

; Decrease window height
^!Up::
{
    hwnd := WinExist("A")
    if !hwnd {
        MsgBox("No active window found. Ensure a window is focused.")
        return
    }
    WinGetPos(&x, &y, &width, &height, hwnd)
    if !(x + y + width + height) {
        MsgBox("Failed to retrieve window position or size.")
        return
    }
    if !SetWindowPosition(hwnd, x, y, width, height - 50) {
        MsgBox("Error resizing window.")
    }
}

;5. Window mover script
; Assign new macros to function keys
F1::MoveWindowToPosition("FirstThird")
F2::MoveWindowToPosition("MiddleThird")
F3::MoveWindowToPosition("LastThird")
F4::MoveWindowToPosition("TwoThirdsLeft")
F5::MoveWindowToPosition("TwoThirdsRight")
F6::MoveWindowToPosition("FirstHalf")
F7::MoveWindowToPosition("SecondHalf")
F8::MoveWindowToPosition("BottomRightQuarter")
F9::MoveWindowToPosition("TopRightQuarter")

; Function to move and resize window to specified position
MoveWindowToPosition(position) {
    hwnd := WinExist("A")  ; Get the handle of the active window
    if !hwnd {
        MsgBox("No active window found. Ensure a window is focused.")
        return
    }

    ; Retrieve the monitor where the active window is located
    monitor := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
    if !monitor {
        MsgBox("Failed to retrieve monitor for the active window.")
        return
    }

    ; Create MONITORINFO structure
    mi := Buffer(40, 0)  ; Allocate 40 bytes (MONITORINFO size)
    NumPut("UInt", 40, mi, 0)  ; Set the size of the structure

    ; Get monitor information
    if !DllCall("GetMonitorInfoW", "Ptr", monitor, "Ptr", mi) {
        MsgBox("Failed to get monitor information.")
        return
    }

    ; Extract monitor dimensions
    monitorLeft := NumGet(mi, 4, "Int")
    monitorTop := NumGet(mi, 8, "Int")
    monitorRight := NumGet(mi, 12, "Int")
    monitorBottom := NumGet(mi, 16, "Int")
    monitorWidth := monitorRight - monitorLeft
    monitorHeight := monitorBottom - monitorTop

    ; Calculate target position and size
    switch position {
        case "FirstThird":
            x := monitorLeft, y := monitorTop, w := monitorWidth // 3, h := monitorHeight
        case "MiddleThird":
            x := monitorLeft + monitorWidth // 3, y := monitorTop, w := monitorWidth // 3, h := monitorHeight
        case "LastThird":
            x := monitorLeft + 2 * (monitorWidth // 3), y := monitorTop, w := monitorWidth // 3, h := monitorHeight
        case "TwoThirdsLeft":
            x := monitorLeft, y := monitorTop, w := 2 * (monitorWidth // 3), h := monitorHeight
        case "TwoThirdsRight":
            x := monitorLeft + monitorWidth // 3, y := monitorTop, w := 2 * (monitorWidth // 3), h := monitorHeight
        case "FirstHalf":
            x := monitorLeft, y := monitorTop, w := monitorWidth // 2, h := monitorHeight
        case "SecondHalf":
            x := monitorLeft + monitorWidth // 2, y := monitorTop, w := monitorWidth // 2, h := monitorHeight
        case "BottomRightQuarter":
            x := monitorLeft + monitorWidth // 2, y := monitorTop + monitorHeight // 2, w := monitorWidth // 2, h := monitorHeight // 2
        case "TopRightQuarter":
            x := monitorLeft + monitorWidth // 2, y := monitorTop, w := monitorWidth // 2, h := monitorHeight // 2
        default:
            MsgBox("Invalid position specified.")
            return
    }

    ; Call the Windows API to set window position and size
    if !DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", 0, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", 0x0040) { ; SWP_NOZORDER
        MsgBox("Failed to move and resize window using SetWindowPos.")
    }
}

;6. WSL opener script 
; Define a hotkey to open the WSL Ubuntu terminal in the home directory
^!u::Run("wsl.exe ~", "", "Max")

;7. Minimize window
^!-:: WinMinimize("A")  ; Minimize the currently active window

; Toggle Cinematic Mode using Ctrl + Alt + T
^!t:: {
    Send("t")  ; Simulates pressing the 'T' key
}

; Toggle Full Screen Mode using Ctrl + Alt + F
^!f:: {
    Send("f")  ; Simulates pressing the 'F' key
}

; AutoHotkey script to send "# ----" when "³" is pressed
³:: {
    Send("{#} ----------------------------{Enter}{Enter}{#} ----------------------------")
}
