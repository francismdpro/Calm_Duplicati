<#
.SYNOPSIS
  Recherche et définit la priorité des processus dont le nom CONTIENT "duplicati" à "Faible" (Idle).

.NOTES
  Ce script vérifie les privilèges d'administrateur, se relance si nécessaire et fait une pause à la fin.
#>

$ProcessPartialName = "duplicati"
$PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle # La priorité la plus basse

# --- Vérification et élévation des privilèges ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    
    Write-Warning "Le script n'est pas exécuté en tant qu'administrateur. Tentative d'élévation..."

    # Créer l'argument pour relancer le script (contenant le chemin du script actuel)
    $ScriptPath = $MyInvocation.MyCommand.Path

    # Démarrer une nouvelle instance de PowerShell avec "RunAs" (demande UAC)
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$ScriptPath`""
    
    # Quitter l'instance non-administrateur
    exit
}

# ----------------------------------------------------------------------------------
# --- Début du code principal (exécuté avec les droits d'administrateur) ---
# ----------------------------------------------------------------------------------

Write-Host "Le script s'exécute avec les privilèges d'administrateur."
Write-Host "Recherche des processus contenant '$ProcessPartialName' dans leur nom..."

# Utiliser Where-Object pour filtrer par nom partiel. 
# Le flag '(?i)' rend la recherche insensible à la casse.
$Processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "(?i)$ProcessPartialName" }
$ProcessCount = $Processes.Count
$ChangesMade = 0

if ($Processes) {
    Write-Host "$ProcessCount processus trouvés. Modification de la priorité vers 'Faible'..."
    
    # Parcourir chaque processus et définir sa priorité
    foreach ($Process in $Processes) {
        try {
            # Définir la propriété PriorityClass à 'Idle'
            $Process.PriorityClass = $PriorityClass
            Write-Host " - Priorité du processus $($Process.Id) - $($Process.ProcessName) définie sur 'Faible'. ✅"
            $ChangesMade++
        }
        catch {
            # Cela peut arriver si le processus vient d'être terminé ou si l'accès est refusé
            Write-Warning "Erreur: Impossible de changer la priorité du processus $($Process.Id) - $($Process.ProcessName). ❌ $($_.Exception.Message)"
        }
    }
    Write-Host "Opération terminée : $ChangesMade sur $ProcessCount processus ont été mis en priorité Faible."
}
else {
    Write-Host "Aucun processus contenant '$ProcessPartialName' trouvé. 🔍"
}

# ----------------------------------------------------------------------------------
# --- Pause Finale ---
# ----------------------------------------------------------------------------------
Write-Host ""
Write-Host "--------------------------------------------------------"
# Correction: Utilisation de caractères ASCII uniquement pour eviter les erreurs d'encodage
Read-Host "Appuyez sur Entree pour fermer la fenetre..."
