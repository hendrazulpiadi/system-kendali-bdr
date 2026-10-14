# Server lokal sederhana (tanpa Python/Node) untuk Sistem Kendali BDR.
# Jalankan:  powershell -ExecutionPolicy Bypass -File serve.ps1
# Lalu buka: http://localhost:8080/

param(
    [int]$Port = 8080
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".svg"  = "image/svg+xml"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".ico"  = "image/x-icon"
}

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "Server aktif di http://localhost:$Port/  (Ctrl+C untuk berhenti)" -ForegroundColor Green
Write-Host "Root: $root" -ForegroundColor DarkGray

while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)

        $requestLine = $reader.ReadLine()
        if (-not $requestLine) { $client.Close(); continue }

        # baca sisa header sampai baris kosong
        while (($line = $reader.ReadLine()) -ne $null -and $line -ne "") { }

        $parts = $requestLine -split ' '
        $rawPath = if ($parts.Length -ge 2) { $parts[1] } else { "/" }
        $path = $rawPath.Split('?')[0]
        $path = [System.Uri]::UnescapeDataString($path)
        if ($path -eq "/") { $path = "/index.html" }

        $filePath = Join-Path $root ($path.TrimStart('/'))

        if (Test-Path -LiteralPath $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $ctype = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }

            $header = "HTTP/1.1 200 OK`r`nContent-Type: $ctype`r`nContent-Length: $($bytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bytes, 0, $bytes.Length)
            Write-Host "200  $path" -ForegroundColor DarkGreen
        } else {
            $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
            $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain; charset=utf-8`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($body, 0, $body.Length)
            Write-Host "404  $path" -ForegroundColor DarkYellow
        }

        $stream.Flush()
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $client.Close()
    }
}
