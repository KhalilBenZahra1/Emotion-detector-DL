# 🚀 Guide de déploiement complet avec DuckDNS

## 📋 Informations de votre configuration

- **Domaine** : emotion-detection.duckdns.org
- **Token DuckDNS** : 918b0b65-f264-4ecb-bd01-1736a2163c4b
- **Projet GCP** : emotion-detection-k8s
- **Namespace** : emotion-prod

---

## ⚙️ Prérequis

Assurez-vous d'avoir :
- ✅ `gcloud CLI` installé et configuré
- ✅ `kubectl` installé
- ✅ Accès à un cluster GKE sur GCP
- ✅ PowerShell

Vérifiez :
```powershell
gcloud --version
kubectl version --client
```

---

## 🎯 Étapes de déploiement

### **Étape 1 : Configurer votre cluster GCP** (5 minutes)

```powershell
# Se connecter à GCP
gcloud auth login

# Définir le projet
gcloud config set project emotion-detection-k8s

# Se connecter au cluster GKE
gcloud container clusters get-credentials emotion-cluster --zone us-central1-a
```

**Si le cluster n'existe pas**, créez-le :
```powershell
gcloud container clusters create emotion-cluster `
  --zone us-central1-a `
  --num-nodes 2 `
  --machine-type n1-standard-1
```

---

### **Étape 2 : Lancer le déploiement automatique** (30 minutes)

```powershell
cd c:\Users\GIGABYTE\Desktop\2GL-A\semestre2\DL\Emotion_Detection-main\Emotion_Detection-main

# Lancer le script de déploiement complet
.\deploy-complete.ps1
```

**Qu'est-ce que ce script fait :**
1. ✅ Configure gcloud et kubectl
2. ✅ Crée le namespace
3. ✅ Crée le certificat SSL managé (15-20 minutes)
4. ✅ Déploie frontend et backend
5. ✅ Crée l'Ingress

---

### **Étape 3 : Attendre l'IP de l'Ingress** (5-10 minutes)

Pendant ce temps, vérifiez l'état :

```powershell
# Vérifier le certificat (doit passer à ACTIVE)
kubectl describe managedcertificate emotion-certificate -n emotion-prod

# Voir l'IP de l'Ingress
kubectl get ingress emotion-ingress -n emotion-prod -o wide --watch
```

**Attendez jusqu'à voir une IP** comme `34.120.45.67`

---

### **Étape 4 : Mettre à jour DuckDNS** (2 minutes)

Une fois l'IP obtenue, lancez le script de mise à jour :

```powershell
.\update-duckdns.ps1
```

**Résultat attendu** :
```
✅ IP trouvée: 34.120.45.67
✅ DuckDNS mis à jour avec succès !
📍 Accédez à: https://emotion-detection.duckdns.org
⏳ Attendez 5-10 minutes que le DNS se propage...
```

---

### **Étape 5 : Attendre la propagation DNS** (5-10 minutes)

Le DNS prend du temps à se propager. Pendant ce temps, vous pouvez :

```powershell
# Vérifier quand le DNS est prêt
nslookup emotion-detection.duckdns.org

# Ou tester directement
curl -v https://emotion-detection.duckdns.org
```

**DNS prêt quand vous voyez** :
```
Name:    emotion-detection.duckdns.org
Address: 34.120.45.67
```

---

### **Étape 6 : Tester l'application** ✨

1. Ouvrez un navigateur
2. Allez à : **https://emotion-detection.duckdns.org**
3. Cliquez sur "Démarrer la caméra"
4. Acceptez les permissions de caméra
5. La caméra devrait s'ouvrir ! 🎉

---

## 🔧 Commandes utiles

### Voir les logs
```powershell
# Frontend
kubectl logs -f deployment/emotion-frontend -n emotion-prod

# Backend
kubectl logs -f deployment/emotion-backend -n emotion-prod
```

### Redémarrer les pods
```powershell
kubectl rollout restart deployment/emotion-frontend -n emotion-prod
kubectl rollout restart deployment/emotion-backend -n emotion-prod
```

### Supprimer complètement
```powershell
kubectl delete namespace emotion-prod
```

### Vérifier les certificats
```powershell
kubectl get managedcertificate -n emotion-prod
kubectl describe managedcertificate emotion-certificate -n emotion-prod
```

---

## 🐛 Troubleshooting

### ❌ Le certificat reste en "PROVISIONING"
**Solution** : Attendez 15-20 minutes. C'est normal, Google doit valider le domaine.

### ❌ L'Ingress n'a pas d'IP
**Solution** : 
```powershell
kubectl describe ingress emotion-ingress -n emotion-prod
```
Vérifiez les événements.

### ❌ DNS ne fonctionne pas
**Solution** :
```powershell
# Mettre à jour DuckDNS manuellement
$TOKEN = "918b0b65-f264-4ecb-bd01-1736a2163c4b"
$IP = "VOTRE_IP_ICI"
Invoke-WebRequest -Uri "https://www.duckdns.org/update?domains=emotion-detection&token=$TOKEN&ip=$IP"
```

### ❌ La caméra ne marche toujours pas
**Vérifications** :
1. ✅ Accédez via HTTPS (pas HTTP)
2. ✅ Acceptez les permissions de caméra
3. ✅ Vérifiez les logs du frontend
4. ✅ Redémarrez les pods

---

## 📞 Support

Si quelque chose ne fonctionne pas, lancez ce diagnostic :

```powershell
# État complet
kubectl get all -n emotion-prod

# Détails des erreurs
kubectl describe pod -n emotion-prod

# Accédez à un pod
kubectl exec -it POD_NAME -n emotion-prod -- sh
```

---

## ✅ Timeline estimée

| Étape | Temps |
|-------|-------|
| Configuration gcloud | 5 min |
| Déploiement initial | 5 min |
| Création du certificat | 15-20 min |
| IP de l'Ingress | 5-10 min |
| Mise à jour DuckDNS | 2 min |
| Propagation DNS | 5-10 min |
| **Total** | **40-55 min** |

---

**Bon déploiement ! 🚀**
