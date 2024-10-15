{\rtf1\ansi\ansicpg1252\cocoartf2818
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww25080\viewh19680\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Definir el rango de IPs a escanear\
$startIP = "192.168.1.1"\
$endIP = "192.168.1.254"\
\
# Convertir IPs a enteros para facilitar el escaneo de rango\
function ConvertTo-Int \{\
    param([string]$ipAddress)\
    [uint32]($ipAddress.Split('.') | % \{[int]$_\} | % \{$_ -band 255\} | % \{$result = ($_ -band 255); $result\} -join '.')\
\}\
\
$startInt = ConvertTo-Int $startIP\
$endInt = ConvertTo-Int $endIP\
\
# Convertir entero de vuelta a direcci\'f3n IP\
function ConvertTo-IP \{\
    param([uint32]$intIP)\
    return (($intIP -shr 24) -band 255).ToString() + "." +\
           (($intIP -shr 16) -band 255).ToString() + "." +\
           (($intIP -shr 8) -band 255).ToString() + "." +\
           ($intIP -band 255).ToString()\
\}\
\
# Escaneo de compartidas para una IP espec\'edfica\
function Get-NetworkShares \{\
    param([string]$computerName)\
    try \{\
        $shares = Get-WmiObject -Class Win32_Share -ComputerName $computerName -ErrorAction Stop\
        if ($shares) \{\
            foreach ($share in $shares) \{\
                Write-Host "Computer: $computerName | Share: $($share.Name) | Path: $($share.Path)"\
            \}\
        \}\
    \}\
    catch \{\
        # Silenciosamente ignorar cualquier error, si no es accesible\
    \}\
\}\
\
# Escanear el rango de IPs\
for ($i = $startInt; $i -le $endInt; $i++) \{\
    $currentIP = ConvertTo-IP $i\
    # Intentar directamente acceder a las compartidas sin hacer ping\
    Get-NetworkShares -computerName $currentIP\
\}\
}