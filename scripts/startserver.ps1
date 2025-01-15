cd $PSScriptRoot\..\speech
$process = Start-Process 'python.exe' -ArgumentList './infer_server.py', '--port', '5000', '--use_pun', 'True' -WindowStyle Hidden -PassThru
$process.Id