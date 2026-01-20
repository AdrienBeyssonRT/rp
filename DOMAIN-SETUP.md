# 🌐 Configuration avec Nom de Domaine

Oui, vous pouvez utiliser un nom de domaine au lieu de l'IP ! Voici toutes les options disponibles.

## ✅ Option 1 : Service DDNS Gratuit (RECOMMANDÉ - Aucune config client)

Utilisez un service gratuit qui vous donne un nom de domaine :

### DuckDNS (Gratuit et Simple)
- **Site** : https://www.duckdns.org
- **Exemple** : `monsite.duckdns.org`
- **Avantages** :
  - ✅ Gratuit
  - ✅ Aucune configuration sur les PC clients
  - ✅ Fonctionne depuis Internet
  - ✅ Mise à jour automatique de l'IP

**Configuration :**
1. Créez un compte sur DuckDNS
2. Choisissez un sous-domaine (ex: `monsite`)
3. Configurez votre IP publique (ou utilisez leur script de mise à jour)
4. Dans `group_vars/all.yml`, mettez : `domain_name: "monsite.duckdns.org"`

### No-IP (Gratuit)
- **Site** : https://www.noip.com
- **Exemple** : `monsite.ddns.net`
- Même principe que DuckDNS

### Cloudflare (Gratuit avec votre propre domaine)
- Si vous avez déjà un nom de domaine
- Configuration DNS gratuite via Cloudflare

## ✅ Option 2 : DNS Local (Pour réseau privé uniquement)

Si vous contrôlez votre routeur/réseau :

### Configuration sur le Routeur
1. Accédez à l'interface admin de votre routeur
2. Allez dans les paramètres DNS/DHCP
3. Ajoutez une entrée : `monsite.local` → `192.168.200.20` (IP du reverse proxy)
4. Tous les PC du réseau résoudront automatiquement le nom

**Dans `group_vars/all.yml` :**
```yaml
domain_name: "monsite.local"
```

## ✅ Option 3 : DNS Local via Routeur (Pour réseau privé)

Si vous contrôlez votre routeur, configurez directement le DNS local :
1. Accédez à l'interface admin de votre routeur
2. Ajoutez une entrée DNS : `monsite.local` → IP du reverse proxy
3. Tous les PC du réseau résoudront automatiquement le nom

## 📝 Configuration dans Ansible

Une fois que vous avez choisi votre nom de domaine, modifiez simplement :

**Fichier : `group_vars/all.yml`**
```yaml
domain_name: "monsite.duckdns.org"  # Remplacez par votre nom de domaine
```

Le playbook Ansible générera automatiquement :
- ✅ Certificat SSL pour ce nom de domaine
- ✅ Configuration Nginx avec le bon `server_name`
- ✅ Tout fonctionnera avec `https://monsite.duckdns.org`

## 🔒 Certificat SSL avec Nom de Domaine

### Certificat Auto-signé (Avertissement navigateur)
Le playbook génère automatiquement un certificat auto-signé pour votre nom de domaine.

### Certificat Valide avec Let's Encrypt (Recommandé)
Pour un certificat valide sans avertissement :

1. Installez Certbot :
```bash
sudo apt install certbot python3-certbot-nginx
```

2. Obtenez le certificat :
```bash
sudo certbot --nginx -d monsite.duckdns.org
```

3. Le certificat sera renouvelé automatiquement

## 🚀 Exemple Complet : DuckDNS

### Étape 1 : Créer le domaine DuckDNS
1. Allez sur https://www.duckdns.org
2. Connectez-vous avec votre compte (Google, GitHub, etc.)
3. Créez un sous-domaine : `monsite`
4. Votre domaine sera : `monsite.duckdns.org`
5. Notez votre token API

### Étape 2 : Mettre à jour l'IP (si IP publique)
Si votre reverse proxy a une IP publique, mettez-la à jour :
```
https://www.duckdns.org/update?domains=monsite&token=VOTRE_TOKEN&ip=
```

### Étape 3 : Configurer Ansible
**`group_vars/all.yml` :**
```yaml
domain_name: "monsite.duckdns.org"
backend_server: "192.168.200.20"
backend_port: 80
```

### Étape 4 : Déployer
```bash
ansible-playbook -i inventory.ini playbook.yml
```

### Étape 5 : Accéder
Ouvrez votre navigateur : **https://monsite.duckdns.org**

## 📋 Résumé des Options

| Option | DNS nécessaire ? | Config client ? | Accès Internet ? |
|--------|------------------|-----------------|------------------|
| **DuckDNS/No-IP** | ✅ Public (automatique) | ❌ Non | ✅ Oui |
| **DNS Local (Routeur)** | ✅ Local (routeur) | ❌ Non | ❌ Non (réseau local) |
| **DNSmasq** | ✅ Local (serveur) | ❌ Non | ❌ Non (réseau local) |
| **IP directe** | ❌ Non | ❌ Non | ⚠️ Si IP publique |

## 💡 Recommandation

Pour un usage **sans configuration client** et **accessible facilement** :
- Utilisez **DuckDNS** (gratuit, simple, fonctionne partout)
- Configurez `domain_name: "votresite.duckdns.org"` dans `group_vars/all.yml`
- Déployez avec Ansible
- C'est tout ! 🎉

