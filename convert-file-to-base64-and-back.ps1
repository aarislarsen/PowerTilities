function Convert-BinaryToString 
{
    [CmdletBinding()]
    param 
    (
        [string] $FilePath
    )
    $File = [System.IO.File]::ReadAllBytes($FilePath);

    $Base64String = [System.Convert]::ToBase64String($File);
    set-clipboard -value $Base64String
    Write-Output "Content added to your clipboard, paste it into the EncodedString variable for Convert-StringToBinary"
}

function Convert-StringToBinary 
{
    [CmdletBinding()]
    param 
    (
        [string] $EncodedString,
        [string] $FilePath = (‘{0}\{1}’ -f $env:TEMP, [System.Guid]::NewGuid().ToString())
    )
 
    try 
    {
        if ($EncodedString.Length -ge 1) 
        {
            # decodes the base64 string
            $ByteArray = [System.Convert]::FromBase64String($EncodedString);
            [System.IO.File]::WriteAllBytes($FilePath, $ByteArray);
        }
    }
    catch 
    {
    }
 
    Write-Output -InputObject (Get-Item -Path $FilePath);
}
 

