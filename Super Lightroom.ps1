<#
.SYNOPSIS
  Recherche et définit la priorité des processus dont le nom CONTIENT "lightroom classic"
  à "Élevée" (AboveNormal).

.NOTES
  Ce script vérifie les privilèges d'administrateur, se relance si nécessaire et fait une pause à la fin.
  Attention: 'AboveNormal' est généralement recommandé plutôt que 'High' pour éviter les instabilités système.
#>

$ProcessPartialName = "lightroom classic"
# 'AboveNormal' (32) est souvent un bon compromis. Utilisez 'High' (128) pour la priorité maximale.
$PriorityClass = [System.Diagnostics.ProcessPriorityClass]::AboveNormal 
$PriorityName = "Supérieure à la normale (AboveNormal)"

# --- Vérification et élévation des privilèges (nécessaire pour modifier la priorité) ---
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
# On suppose que le nom de l'exécutable est 'lightroom' ou contient 'lightroom classic'.
$Processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "(?i)lightroom|(?i)lightroom classic" }
$ProcessCount = $Processes.Count
$ChangesMade = 0

if ($Processes) {
    Write-Host "$ProcessCount processus trouvés. Modification de la priorité vers '$PriorityName'..."
    
    # Parcourir chaque processus et définir sa priorité
    foreach ($Process in $Processes) {
        try {
            # Définir la propriété PriorityClass
            $Process.PriorityClass = $PriorityClass
            Write-Host " - Priorité du processus $($Process.Id) - $($Process.ProcessName) définie sur '$PriorityName'. ✅"
            $ChangesMade++
        }
        catch {
            # Cela peut arriver si le processus vient d'être terminé ou si l'accès est refusé
            Write-Warning "Erreur: Impossible de changer la priorité du processus $($Process.Id) - $($Process.ProcessName). ❌ $($_.Exception.Message)"
        }
    }
    Write-Host "Opération terminée : $ChangesMade sur $ProcessCount processus ont été mis en priorité $PriorityName."
}
else {
    Write-Host "Aucun processus contenant '$ProcessPartialName' trouvé. 🔍"
}

# ----------------------------------------------------------------------------------
# --- Pause Finale ---
# ----------------------------------------------------------------------------------
Write-Host ""
Write-Host "--------------------------------------------------------"
Read-Host "Appuyez sur Entrée pour fermer la fenêtre..."