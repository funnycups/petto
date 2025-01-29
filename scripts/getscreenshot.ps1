[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
function screenshot([Drawing.Rectangle]$bounds, $path) {
    $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
    $bmp.Save($path)
    $graphics.Dispose()
    $bmp.Dispose()
}
$vc = Get-WmiObject -class "Win32_VideoController"
$bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $vc.CurrentHorizontalResolution[1], $vc.CurrentVerticalResolution[1])
screenshot $bounds ".\screenshot.png"
$filePath = [System.IO.Path]::GetFullPath(".\screenshot.png")
$absolutePathBytes = [System.Text.Encoding]::UTF8.GetBytes($filePath)
[System.Convert]::ToBase64String($absolutePathBytes)