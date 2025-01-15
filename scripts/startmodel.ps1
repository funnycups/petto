cd D:\language-model\rwkv
$process = Start-Process 'py310/python.exe' -ArgumentList './backend-python/main.py', '--port', '8888' -WindowStyle Hidden -PassThru
$process.Id
Start-Sleep -s 10
$body = @{
    customCuda = $false
    deploy = $false
    model = "models/RWKV-x060-World-3B-v2.1-20240417-ctx4096.pth"
    strategy = "cuda fp16"
    tokenizer = ""
} | ConvertTo-Json
Invoke-RestMethod -Uri 'http://127.0.0.1:8888/switch-model' -Method 'Post' -Body $body -ContentType 'application/json'| Out-Null