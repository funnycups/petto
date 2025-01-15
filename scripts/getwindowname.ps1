$OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Win32 { [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow(); [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count); }'
$handle = [Win32]::GetForegroundWindow()
$text = New-Object -TypeName System.Text.StringBuilder -ArgumentList 256
[Win32]::GetWindowText($handle, $text, $text.Capacity) | Out-Null
$windowTitle = $text.ToString()
$encodedOutput = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($windowTitle))
Write-Output $encodedOutput