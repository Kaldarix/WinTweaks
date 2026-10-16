' WinTweaks - Update Prompt
Set objShell = CreateObject("WScript.Shell")

' 3 = Yes/No/Cancel buttons | 48 = Warning Icon
' Yes = Update (6) | No = Proceed (7)
intBtn = objShell.Popup("Your WinTweaks version is outdated!" & vbCrLf & "Would you like to update?", 0, "WinTweaks - Warning", 3 + 48)

