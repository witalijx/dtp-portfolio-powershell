param(
    [string]$VerzeichnisPfad
)
# Überprüfen, ob der angegebene Pfad existiert
if (-not (Test-Path -Path $VerzeichnisPfad -PathType Container)) {
    Write-Host "Der angegebene Pfad existiert nicht."
    exit
}

# Erstelle ein Array, um Informationen über die Dateien zu speichern
$DateiInformationen = @()

# Durchsuche das Verzeichnis und seine Unterverzeichnisse nach Dateien
Get-ChildItem -Path $VerzeichnisPfad -File -Recurse | ForEach-Object {
    $Datei = $_
    $DateiInformation = [PSCustomObject]@{
        Dateiname = $Datei.Name
        Dateipfad = $Datei.FullName
        Groesse_MB = [math]::Round(($Datei.Length / 1MB), 2)
        Dateiendung = $Datei.Extension
        Erstelldatum = $Datei.CreationTime
        Letztes_Bearbeitungsdatum = $Datei.LastWriteTime
    }
    $DateiInformationen += $DateiInformation
}

# Sortiere die Dateien nach Grösse gross -> klein
$DateiInformationen = $DateiInformationen | Sort-Object -Property Groesse_MB -Descending

# Wähle die ersten 100 Dateien
$GroessteDateien = $DateiInformationen | Select-Object -First 100

# CSV erstellen
$GroessteDateien | Export-Csv -Path "bigfiles.csv" -NoTypeInformation

Write-Host "Die 100 grössten Dateien wurden in die Datei Top100Dateien.csv exportiert."
