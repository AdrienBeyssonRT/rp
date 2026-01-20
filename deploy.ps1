# Script PowerShell de déploiement automatique du Reverse Proxy
# Installe toutes les dépendances nécessaires sur Windows

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Déploiement Reverse Proxy HTTPS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si on est en mode administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Ce script nécessite des privilèges administrateur" -ForegroundColor Yellow
    Write-Host "Relancez PowerShell en tant qu'administrateur" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Détection du système : Windows" -ForegroundColor Green
Write-Host ""

# Vérifier si Chocolatey est installé
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "📦 Installation de Chocolatey (gestionnaire de paquets)..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey installé" -ForegroundColor Green
}

# Fonction pour installer un package avec Chocolatey
function Install-Package {
    param([string]$PackageName, [string]$DisplayName)
    
    $installed = Get-Command $PackageName -ErrorAction SilentlyContinue
    
    if ($installed) {
        Write-Host "✅ $DisplayName : Déjà installé ($($installed.Source))" -ForegroundColor Green
        return $true
    }
    
    Write-Host "📦 Installation de $DisplayName..." -ForegroundColor Yellow
    try {
        choco install $PackageName -y --no-progress
        Write-Host "✅ $DisplayName installé" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Erreur lors de l'installation de $DisplayName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $false
    }
}

# Installer les dépendances
Write-Host "🔧 Installation des dépendances..." -ForegroundColor Cyan
Write-Host ""

# Nginx
$nginxOk = Install-Package -PackageName "nginx" -DisplayName "Nginx"

# OpenSSL
$opensslOk = Install-Package -PackageName "openssl" -DisplayName "OpenSSL"

# Python 3
$pythonOk = Install-Package -PackageName "python3" -DisplayName "Python 3"

# Git (pour cloner des repos si nécessaire)
$gitOk = Install-Package -PackageName "git" -DisplayName "Git"

# Ansible via pip
Write-Host "📦 Installation d'Ansible..." -ForegroundColor Yellow
$ansibleInstalled = Get-Command ansible -ErrorAction SilentlyContinue

if (-not $ansibleInstalled) {
    try {
        python -m pip install --upgrade pip
        python -m pip install ansible
        Write-Host "✅ Ansible installé" -ForegroundColor Green
        $ansibleOk = $true
    } catch {
        Write-Host "❌ Erreur lors de l'installation d'Ansible" -ForegroundColor Red
        Write-Host "Essayez manuellement : pip install ansible" -ForegroundColor Yellow
        $ansibleOk = $false
    }
} else {
    Write-Host "✅ Ansible : Déjà installé" -ForegroundColor Green
    $ansibleOk = $true
}

# Vérifier les installations
Write-Host ""
Write-Host "🔍 Vérification des installations..." -ForegroundColor Cyan
Write-Host ""

function Check-Command {
    param([string]$CommandName, [string]$DisplayName)
    
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($cmd) {
        $version = & $CommandName --version 2>&1 | Select-Object -First 1
        Write-Host "✅ $DisplayName : $($cmd.Source)" -ForegroundColor Green
        if ($version) {
            Write-Host "   Version : $version" -ForegroundColor Gray
        }
        return $true
    } else {
        Write-Host "❌ $DisplayName : Non installé" -ForegroundColor Red
        return $false
    }
}

$allOk = $true
$allOk = (Check-Command -CommandName "nginx" -DisplayName "Nginx") -and $allOk
$allOk = (Check-Command -CommandName "openssl" -DisplayName "OpenSSL") -and $allOk
$allOk = (Check-Command -CommandName "python" -DisplayName "Python 3") -and $allOk
$allOk = (Check-Command -CommandName "ansible" -DisplayName "Ansible") -and $allOk

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "✅ Installation terminée avec succès !" -ForegroundColor Green
} else {
    Write-Host "⚠️  Certaines installations ont échoué" -ForegroundColor Yellow
    Write-Host "Vérifiez les erreurs ci-dessus" -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "1. Configurez l'inventaire Ansible (inventory.ini)" -ForegroundColor White
Write-Host "2. Modifiez les variables dans group_vars/all.yml si nécessaire" -ForegroundColor White
Write-Host "3. Installez les collections : ansible-galaxy collection install community.crypto" -ForegroundColor White
Write-Host "4. Lancez le déploiement : ansible-playbook -i inventory.ini playbook.yml" -ForegroundColor White
Write-Host ""

# Note sur WSL
Write-Host "💡 Note : Pour une meilleure compatibilité, vous pouvez utiliser WSL (Windows Subsystem for Linux)" -ForegroundColor Yellow
Write-Host "   et exécuter le script deploy.sh à la place." -ForegroundColor Yellow
Write-Host ""

