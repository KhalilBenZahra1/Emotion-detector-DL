# Script de deploiement complet sur GCP avec DuckDNS

$PROJECT_ID = "emotion-detection-k8s"
$REGION = "us-central1"
$ZONE = "us-central1-c"
$NAMESPACE = "emotion-prod"
$CLUSTER_NAME = "emotion-cluster"

Write-Host "Deploiement Emotion Detection sur GCP" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Etape 1 : Configurer gcloud
Write-Host "1. Configuration de gcloud..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID
Write-Host "OK - Projet defini: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Etape 2 : Se connecter au cluster
Write-Host "2. Connexion au cluster GKE..." -ForegroundColor Yellow
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID
Write-Host "OK - Connecte au cluster: $CLUSTER_NAME" -ForegroundColor Green
Write-Host ""

# Etape 3 : Creer le namespace
Write-Host "3. Creation du namespace..." -ForegroundColor Yellow
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
Write-Host "OK - Namespace cree: $NAMESPACE" -ForegroundColor Green
Write-Host ""

# Etape 4 : Creer le certificat manage
Write-Host "4. Creation du certificat SSL..." -ForegroundColor Yellow
Write-Host "Peut prendre 15-20 minutes..." -ForegroundColor Yellow
kubectl apply -f k8s/prod/managed-certificate.yaml
Write-Host "OK - Certificat cree" -ForegroundColor Green
Write-Host ""

# Etape 5 : Verifier le certificat
Write-Host "5. Verification de l'etat du certificat..." -ForegroundColor Yellow
Write-Host "Statut attendu: ACTIVE" -ForegroundColor Cyan
kubectl get managedcertificate emotion-certificate -n $NAMESPACE
Write-Host ""

# Etape 6 : Deployer les ressources
Write-Host "6. Deploiement des ressources..." -ForegroundColor Yellow
kubectl apply -f k8s/prod/volume.yaml
kubectl apply -f k8s/prod/backend-deployment.yaml
kubectl apply -f k8s/prod/backend-service.yaml
kubectl apply -f k8s/prod/frontend-deployment.yaml
kubectl apply -f k8s/prod/frontend-service.yaml
kubectl apply -f k8s/prod/ingress.yaml
Write-Host "OK - Ressources deployees" -ForegroundColor Green
Write-Host ""

# Etape 7 : Afficher le statut
Write-Host "7. Statut du deploiement..." -ForegroundColor Yellow
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
Write-Host "OK - Deploiement termine !" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. Attendre le certificat ACTIVE (15-20 minutes)"
Write-Host "2. Attendre l'IP publique de l'Ingress (2-5 minutes)"
Write-Host "3. Lancer: update-duckdns.ps1"
Write-Host "4. Attendre la propagation DNS (5-10 minutes)"
Write-Host "5. Ouvrir: https://emotion-detection.duckdns.org"
Write-Host ""
