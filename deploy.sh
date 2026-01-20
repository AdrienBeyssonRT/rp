#!/bin/bash
# Script de déploiement automatique du Reverse Proxy
# Installe toutes les dépendances nécessaires

set -e  # Arrêter en cas d'erreur

echo "=========================================="
echo "  Déploiement Reverse Proxy HTTPS"
echo "=========================================="
echo ""

# Détecter le système d'exploitation
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
else
    OS="unknown"
fi

echo "📦 Détection du système : $OS"
echo ""

# Fonction pour installer sur Debian/Ubuntu
install_debian() {
    echo "🔧 Installation des dépendances (Debian/Ubuntu)..."
    
    sudo apt-get update
    sudo apt-get install -y \
        nginx \
        openssl \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        git
    
    # Installer Ansible
    if ! command -v ansible &> /dev/null; then
        echo "📦 Installation d'Ansible..."
        sudo apt-get install -y software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
    fi
    
    echo "✅ Dépendances installées"
}

# Fonction pour installer sur RedHat/CentOS
install_redhat() {
    echo "🔧 Installation des dépendances (RedHat/CentOS)..."
    
    sudo yum update -y
    sudo yum install -y \
        nginx \
        openssl \
        python3 \
        python3-pip \
        curl \
        git
    
    # Installer Ansible
    if ! command -v ansible &> /dev/null; then
        echo "📦 Installation d'Ansible..."
        sudo yum install -y epel-release
        sudo yum install -y ansible
    fi
    
    echo "✅ Dépendances installées"
}

# Fonction pour installer sur macOS
install_macos() {
    echo "🔧 Installation des dépendances (macOS)..."
    
    # Vérifier si Homebrew est installé
    if ! command -v brew &> /dev/null; then
        echo "📦 Installation de Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Installer les dépendances
    brew install nginx openssl python3 ansible
    
    echo "✅ Dépendances installées"
}

# Fonction pour installer sur Windows (via WSL ou Git Bash)
install_windows() {
    echo "⚠️  Windows détecté"
    echo "Pour Windows, veuillez installer manuellement :"
    echo "  - Nginx : https://nginx.org/en/download.html"
    echo "  - OpenSSL : https://slproweb.com/products/Win32OpenSSL.html"
    echo "  - Python 3 : https://www.python.org/downloads/"
    echo "  - Ansible : pip install ansible"
    echo ""
    echo "Ou utilisez WSL (Windows Subsystem for Linux) pour une meilleure compatibilité."
    exit 1
}

# Installation selon l'OS
case $OS in
    linux)
        # Détecter la distribution Linux
        if [ -f /etc/debian_version ]; then
            install_debian
        elif [ -f /etc/redhat-release ]; then
            install_redhat
        else
            echo "❌ Distribution Linux non supportée automatiquement"
            echo "Veuillez installer manuellement : nginx, openssl, python3, ansible"
            exit 1
        fi
        ;;
    macos)
        install_macos
        ;;
    windows)
        install_windows
        ;;
    *)
        echo "❌ Système d'exploitation non supporté"
        exit 1
        ;;
esac

# Vérifier les installations
echo ""
echo "🔍 Vérification des installations..."
echo ""

check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 : $(command -v $1) ($($1 --version 2>&1 | head -n 1))"
        return 0
    else
        echo "❌ $1 : Non installé"
        return 1
    fi
}

check_command nginx
check_command openssl
check_command python3
check_command ansible

echo ""
echo "=========================================="
echo "✅ Installation terminée !"
echo "=========================================="
echo ""
echo "📋 Prochaines étapes :"
echo "1. Configurez l'inventaire Ansible (inventory.ini)"
echo "2. Modifiez les variables dans group_vars/all.yml si nécessaire"
echo "3. Lancez le déploiement : ansible-playbook -i inventory.ini playbook.yml"
echo ""

