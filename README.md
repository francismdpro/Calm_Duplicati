### 📁 Duplicati Low Priority Setter

#Description du Script

Duplicati utilise beaucoup de ressources et personellement je lui ai mis une priorité de 9/10 (dans sa config). Ce script permet de changer la priorité au niveau windows pour le passer en basse priorité au cas où vous auriez besoin de votre ordinateur :)
Ceci permet aux tâches critiques du système et aux applications interactives de conserver une priorité élevée, assurant ainsi que les opérations de Duplicati n'impactent pas la fluidité générale du système.

#🛠️ Fonctionnalités

Recherche par Nom Partiel : Utilise un filtrage avancé pour trouver tous les processus liés à Duplicati, même si le nom complet varie (ex : Duplicati.GUI.TrayIcon, Duplicati.Service, etc.).

Élévation de Privilèges Automatique : Le script vérifie s'il est exécuté avec les droits d'administrateur. Si ce n'est pas le cas, il se relance automatiquement en demandant l'élévation des privilèges (via l'UAC) pour garantir qu'il peut modifier la priorité de n'importe quel processus.

Priorité Faible Définie : La priorité est fixée à Idle (la plus basse).

Pause à la Fin : Le script marque une pause à la fin pour permettre à l'utilisateur de lire le journal d'exécution et de vérifier le succès de l'opération.

#🚀 Utilisation

1. Sauvegarde du Fichier

Copiez le code ci-dessus dans un fichier.

Enregistrez-le sous le nom duplicalow.ps1 (ou tout autre nom avec l'extension .ps1).

IMPORTANT : Pour éviter les erreurs dues aux caractères accentués, assurez-vous que le fichier est enregistré avec l'encodage UTF-8.

2. Exécution

Exécutez le script en double-cliquant dessus ou en l'appelant depuis une console PowerShell :

.\duplicalow.ps1

Note : L'exécution du script déclenchera une fenêtre UAC (Contrôle de Compte Utilisateur) demandant l'autorisation d'administrateur.

💻 Code Clé

La recherche par nom partiel et le changement de priorité sont gérés par ces lignes :

# Recherche insensible à la casse de tous les processus contenant 'duplicati'
$Processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "(?i)$ProcessPartialName" }

# Définition de la priorité la plus basse
$Process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle



<img width="1219" height="832" alt="image" src="https://github.com/user-attachments/assets/771a578a-4f2c-4285-b646-d5652fed8e60" />
