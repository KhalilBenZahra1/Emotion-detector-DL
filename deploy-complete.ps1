# Script de déploiement complet sur GCP avec DuckDNS
# Assurez-vous d'avoir kubectl et gcloud configurés

$PROJECT_ID = "emotion-detection-k8s"
$REGION = "us-central1"
$ZONE = "us-central1-a"
$NAMESPACE = "emotion-prod"
$CLUSTER_NAME = "emotion-cluster"

Write-Host "🚀 Déploiement Emotion Detection sur GCP" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Étape 1 : Configurer gcloud
Write-Host "1️⃣ Configuration de gcloud..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID
Write-Host "✅ Projet défini: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Étape 2 : Se connecter au cluster
Write-Host "2️⃣ Connexion au cluster GKE..." -ForegroundColor Yellow
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
Write-Host "✅ Connecté au cluster: $CLUSTER_NAME" -ForegroundColor Green
Write-Host ""

# Étape 3 : Créer le namespace
Write-Host "3️⃣ Création du namespace..." -ForegroundColor Yellow
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
Write-Host "✅ Namespace créé: $NAMESPACE" -ForegroundColor Green
Write-Host ""

# Étape 4 : Créer le certificat managé
Write-Host "4️⃣ Création du certificat SSL managé..." -ForegroundColor Yellow
Write-Host "⏳ Cela peut prendre 15-20 minutes..." -ForegroundColor Yellow
kubectl apply -f k8s/prod/managed-certificate.yaml
Write-Host "✅ Certificat créé" -ForegroundColor Green
Write-Host ""

# Étape 5 : Vérifier le certificat
Write-Host "5️⃣ Vérification de l'état du certificat..." -ForegroundColor Yellow
Write-Host "Statut attendu: ACTIVE (peut prendre 15-20 minutes)" -ForegroundColor Cyan
kubectl get managedcertificate emotion-certificate -n $NAMESPACE

Write-Host ""
Write-Host "⏳ Note: Le certificat peut prendre 15-20 minutes à être provisionné" -ForegroundColor Yellow
Write-Host "Continuons avec le déploiement des ressources pendant ce temps..." -ForegroundColor Yellow
Write-Host ""

# Étape 6 : Déployer les ressources
Write-Host ""
Write-Host "6️⃣ Déploiement des ressources..." -ForegroundColor Yellow
kubectl apply -f k8s/prod/volume.yaml
kubectl apply -f k8s/prod/backend-deployment.yaml
kubectl apply -f k8s/prod/backend-service.yaml
kubectl apply -f k8s/prod/frontend-deployment.yaml
kubectl apply -f k8s/prod/frontend-service.yaml
kubectl apply -f k8s/prod/ingress.yaml
Write-Host "✅ Ressources déployées" -ForegroundColor Green
Write-Host ""

# Étape 7 : Afficher le statut
Write-Host "7️⃣ Statut du déploiement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n $NAMESPACE
Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
kubectl get svc -n $NAMESPACE
Write-Host ""
Write-Host "Ingress:" -ForegroundColor Cyan
kubectl get ingress -n $NAMESPACE
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Déploiement terminé !" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Attendre que le certificat passe à ACTIVE (15-20 min)"
Write-Host "2. Attendre que l'Ingress ait une IP publique (2-5 min)"
Write-Host "3. Lancer: .\update-duckdns.ps1"
Write-Host "4. Attendre 5-10 minutes que le DNS se propage"
Write-Host "5. Ouvrir: https://emotion-detection.duckdns.org"
Write-Host ""
