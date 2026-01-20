# 🚀 Guide Rapide - Tout Automatique

## ✅ Ce qui est déjà configuré

- ✅ Nom local gratuit : `monsite.local`
- ✅ Configuration prête à l'emploi
- ✅ Ansible fait tout automatiquement

## 📝 Vous devez juste faire ça :

### 1. Modifier l'IP de votre site (si nécessaire)

Éditez `group_vars/all.yml` :
```yaml
backend_server: "192.168.200.20"  # Mettez l'IP de votre site web
```

**Si votre site est déjà sur `192.168.200.20`, vous n'avez rien à changer !**

### 2. Lancer le déploiement

```bash
./deploy.sh
ansible-galaxy collection install community.crypto
ansible-playbook -i inventory.ini playbook.yml
```

**Ansible fait TOUT automatiquement :**
- ✅ Installe Nginx
- ✅ Génère le certificat SSL pour `monsite.local`
- ✅ Configure le reverse proxy
- ✅ Démarre tout

### 3. Configurer pfSense (1 seule fois)

À la fin du déploiement, Ansible vous affiche l'IP à utiliser.

1. **pfSense** → Services → DNS Resolver → Host Overrides
2. **Add** :
   - **Host** : `monsite`
   - **Domain** : `local`
   - **IP Address** : L'IP affichée par Ansible
3. **Sauvegardez**

### 4. C'est prêt !

Ouvrez : **https://monsite.local**

🎉 Tous les PC du réseau peuvent y accéder !

---

## 💡 Résumé

- **Nom** : `monsite.local` (gratuit, déjà configuré)
- **Ansible** : Fait tout automatiquement
- **Vous** : Juste configurer pfSense (1 fois)
- **Résultat** : Site accessible en HTTPS sur tout le réseau

C'est tout ! 🚀

