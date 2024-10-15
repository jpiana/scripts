# Definir el rango de IPs a escanear
$startIP = "192.168.1.1"
$endIP = "192.168.1.254"

# Convertir IPs a enteros para facilitar el escaneo de rango
function ConvertTo-Int {
    param([string]$ipAddress)
    [uint32]($ipAddress.Split('.') | % {[int]$_} | % {$_ -band 255} | % {$result = ($_ -band 255); $result} -join '.')
}

$startInt = ConvertTo-Int $startIP
$endInt = ConvertTo-Int $endIP

# Convertir entero de vuelta a dirección IP
function ConvertTo-IP {
    param([uint32]$intIP)
    return (($intIP -shr 24) -band 255).ToString() + "." +
           (($intIP -shr 16) -band 255).ToString() + "." +
           (($intIP -shr 8) -band 255).ToString() + "." +
           ($intIP -band 255).ToString()
}

# Escaneo de compartidas para una IP específica
function Get-NetworkShares {
    param([string]$computerName)
    try {
        $shares = Get-WmiObject -Class Win32_Share -ComputerName $computerName -ErrorAction Stop
        if ($shares) {
            foreach ($share in $shares) {
                Write-Host "Computer: $computerName | Share: $($share.Name) | Path: $($share.Path)"
            }
        }
    }
    catch {
        # Silenciosamente ignorar cualquier error, si no es accesible
    }
}

# Escanear el rango de IPs
for ($i = $startInt; $i -le $endInt; $i++) {
    $currentIP = ConvertTo-IP $i
    # Intentar directamente acceder a las compartidas sin hacer ping
    Get-NetworkShares -computerName $currentIP
}
