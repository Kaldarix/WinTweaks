' WinTweaks - Confirm Proceed Prompt
Set objShell = CreateObject("WScript.Shell")

' 4 = Yes/No buttons | 36 = Question Mark / Warning Icon
' Yes = Confirm Proceed (6) | No = Go Back / Update (7)
intBtn = objShell.Popup("Are you sure you want to proceed?" & vbCrLf & "Your vesrion might contain bugs.", 0, "WinTweaks - Notice", 4 + 64)
