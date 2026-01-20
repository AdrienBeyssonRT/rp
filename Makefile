# Makefile pour faciliter le déploiement

.PHONY: help install deploy check clean

help:
	@echo "=========================================="
	@echo "  Reverse Proxy - Commandes disponibles"
	@echo "=========================================="
	@echo ""
	@echo "  make install    - Installer les dépendances"
	@echo "  make deploy     - Déployer le reverse proxy"
	@echo "  make check      - Vérifier la configuration"
	@echo "  make clean      - Nettoyer les fichiers temporaires"
	@echo ""

install:
	@echo "📦 Installation des dépendances..."
	@chmod +x deploy.sh
	@./deploy.sh

deploy:
	@echo "🚀 Déploiement du reverse proxy..."
	@ansible-galaxy collection install community.crypto -f
	@ansible-playbook -i inventory.ini playbook.yml

check:
	@echo "🔍 Vérification de la configuration..."
	@ansible-playbook -i inventory.ini playbook.yml --check --diff

clean:
	@echo "🧹 Nettoyage des fichiers temporaires..."
	@rm -f *.retry
	@rm -f ansible.log
	@find . -name "*.swp" -delete
	@find . -name "*~" -delete
	@echo "✅ Nettoyage terminé"

