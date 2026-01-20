# 🔒 Reverse Proxy HTTPS - Déploiement Automatique

Solution complète et automatisée pour déployer un reverse proxy HTTPS avec Nginx, configuré via Ansible.

## 🎯 Objectif

Transformer votre site web accessible via `http://192.168.200.20` en site HTTPS accessible via un nom de domaine ou directement par IP, **sans aucune configuration sur les PC clients**.

## 🚀 Démarrage Rapide

### 1. Configuration

Éditez `group_vars/all.yml` :
```yaml
backend_server: "192.168.200.20"  # IP de votre serveur backend
domain_name: "monsite.com"        # Votre nom de domaine ou IP
```

### 2. Installation des dépendances

**Linux/macOS :**
```bash
./deploy.sh
```

**Windows :**
```powershell
.\deploy.ps1
```

### 3. Déploiement Ansible

```bash
ansible-galaxy collection install community.crypto
ansible-playbook -i inventory.ini playbook.yml
```

Ansible fait **tout automatiquement** :
- ✅ Installe Nginx
- ✅ Génère le certificat SSL
- ✅ Configure le reverse proxy
- ✅ Démarre Nginx

### 4. Configuration pfSense (À FAIRE MANUELLEMENT)

1. **pfSense** → Services → DNS Resolver → Host Overrides
2. Cliquez sur **"Add"**
3. Remplissez :
   - **Host** : `monsite` (sans le .com)
   - **Domain** : `com`
   - **IP Address** : L'IP de la machine reverse proxy (affichée à la fin du déploiement)
4. **Sauvegardez**

### 5. Test

Ouvrez : **https://monsite.com**

⚠️ Avertissement de sécurité normal (certificat auto-signé). Cliquez sur "Avancé" puis "Continuer".

## 📁 Structure du Projet

```
.
├── deploy.sh                    # Script d'installation (Linux/macOS)
├── deploy.ps1                   # Script d'installation (Windows)
├── ansible.cfg                  # Configuration Ansible
├── inventory.ini                # Inventaire des serveurs
├── playbook.yml                 # Playbook principal Ansible
├── requirements.yml             # Dépendances Ansible
├── group_vars/
│   └── all.yml                  # Variables de configuration
└── templates/
    └── nginx-reverse-proxy.conf.j2  # Template Nginx
```

## ⚙️ Configuration

### Variables principales

Éditez `group_vars/all.yml` :

| Variable | Description | Défaut |
|----------|-------------|--------|
| `backend_server` | IP du serveur backend | `192.168.200.20` |
| `backend_port` | Port du serveur backend | `80` |
| `domain_name` | Nom de domaine ou IP | `192.168.200.20` |
| `ssl_enabled` | Activer HTTPS | `true` |
| `redirect_http_to_https` | Rediriger HTTP → HTTPS | `true` |

### Inventaire

Pour déploiement **local** (`inventory.ini`) :
```ini
[reverse_proxy]
localhost ansible_connection=local
```

Pour déploiement **distant** :
```ini
[reverse_proxy]
192.168.200.20 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

## 🔍 Vérification

```bash
# Statut Nginx
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# Logs
sudo tail -f /var/log/nginx/reverse-proxy-access.log
```

## 🌐 Configuration avec Nom de Domaine

Modifiez `group_vars/all.yml` :
```yaml
domain_name: "monsite.com"  # Votre nom de domaine ou IP
```

**Pour les tests locaux** : Configurez pfSense (Services → DNS Resolver → Host Overrides)  
**Pour la production Internet** : Configurez le DNS public chez votre registrar

Voir **DOMAIN-SETUP.md** pour plus de détails.

## 🎯 Résultat

Après le déploiement :
- ✅ Site accessible en HTTPS
- ✅ Redirection automatique HTTP → HTTPS
- ✅ Reverse proxy configuré
- ✅ Aucune configuration nécessaire sur les PC clients
- ✅ Certificat SSL auto-signé généré automatiquement

## 🛠️ Dépannage

### Nginx ne démarre pas
```bash
sudo nginx -t  # Vérifier la configuration
sudo journalctl -u nginx -n 50  # Voir les erreurs
```

### Port déjà utilisé
Modifiez dans `group_vars/all.yml` :
```yaml
proxy_http_port: 8080
proxy_https_port: 8443
```

## 🔒 Certificat SSL Valide (Optionnel)

Pour obtenir un certificat valide sans avertissement navigateur :

```bash
# Après le déploiement de base
ansible-playbook -i inventory.ini playbook-letsencrypt.yml
```

Nécessite un nom de domaine public (ex: `monsite.duckdns.org`).

## 📝 Notes

- Le certificat SSL est **auto-signé** par défaut (avertissement navigateur normal)
- Pour un certificat valide, utilisez `playbook-letsencrypt.yml` avec un nom de domaine public
- Compatible avec déploiement local et distant
- Supporte Linux, macOS et Windows (via WSL)

## 🔄 Mise à jour

Pour mettre à jour la configuration :
```bash
# Modifier group_vars/all.yml
ansible-playbook -i inventory.ini playbook.yml
```

## 📚 Documentation Complémentaire

- **DOMAIN-SETUP.md** : Guide pour configurer un nom de domaine (DuckDNS, DNS local, etc.)
