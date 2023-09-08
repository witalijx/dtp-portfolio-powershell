param(
    [string]$DateiPfad
)

# Module laden und zu Azure verbinden
Import-Module AzureAD
Connect-AzureAD

function EmailGenerieren {
    param (
        [string]$Vorname,
        [string]$Nachname,
        [int16]$Versuch
    )
    $Domain = "@avatexschool.onmicrosoft.com"
    $Teil1 = $Vorname.ToLower().Replace('ä','ae').Replace('ö','oe').Replace('ü','ue').Substring(0, 1)
    $Teil2 = $Nachname.ToLower().Replace('ä','ae').Replace('ö','oe').Replace('ü','ue')
    $StartIndex = 0 + $Versuch
    $Teil2 = $Teil2.Substring($StartIndex, 1)
    return $Teil1 + $Teil2 + $Domain
}

# Daten aus einer CSV-Datei importieren und jeden Datensatz verarbeiten
Import-Csv -Path $DateiPfad -Delimiter ";" | ForEach-Object {
    $Vorname = $_.Vorname
    $Nachname = $_.Nachname
    $Passwort = $_.Passwort
    $BenutzerErstellt = $false
    $Versuch = 0
    while ($BenutzerErstellt -eq $false) {
        $Fehler = $false
        $Email = EmailGenerieren -Vorname $Vorname -Nachname $Nachname -Versuch $Versuch
        $PasswortProfil = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswortProfil.Password = $Passwort
        $VollerName = $Vorname + " " + $Nachname
        try {
            New-AzureADUser -DisplayName $VollerName -GivenName $Vorname -SurName $Nachname -UserPrincipalName $Email -UsageLocation "CH" -MailNickName $Vorname -PasswordProfile $PasswortProfil -AccountEnabled $true | out-null
        }
        catch {
            Write-Output "Benutzer $VollerName mit Email $Email konnte nicht erstellt werden."
            $Versuch += 1
            $Fehler = $true
        }
        if(!$Fehler){
            $BenutzerErstellt = $true
            Write-Output "Benutzer $VollerName mit Email $Email wurde erstellt."
        }
    }
}