# 📋 Instructions de Déploiement

## 🚀 Étapes Rapides

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

Ansible va automatiquement :
- ✅ Installer Nginx (si pas déjà installé)
- ✅ Générer le certificat SSL
- ✅ Configurer le reverse proxy
- ✅ Démarrer Nginx

### 4. Configuration pfSense (À FAIRE MANUELLEMENT)

1. Connectez-vous à pfSense
2. **Services → DNS Resolver → Host Overrides**
3. Cliquez sur **"Add"**
4. Remplissez :
   - **Host** : `monsite` (sans le .com)
   - **Domain** : `com`
   - **IP Address** : L'IP de la machine où tourne le reverse proxy
5. **Sauvegardez**

### 5. Test

Ouvrez votre navigateur : `https://monsite.com`

⚠️ Un avertissement de sécurité peut apparaître (certificat auto-signé). C'est normal, cliquez sur "Avancé" puis "Continuer".

---

## 🎯 C'est tout !

Le reverse proxy est maintenant opérationnel. Tous les PC du réseau pourront accéder à `https://monsite.com` automatiquement.

