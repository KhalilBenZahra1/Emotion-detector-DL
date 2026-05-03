#!/bin/bash

# Variables à configurer
DOMAIN="votre-domaine.com"  # REMPLACER
PROJECT_ID="emotion-detection-k8s"
REGION="us-central1"
NAMESPACE="emotion-prod"

# Étape 1: Créer le namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Étape 2: Mettre à jour le domaine dans les fichiers
sed -i "s/votre-domaine.com/$DOMAIN/g" managed-certificate.yaml
sed -i "s/votre-domaine.com/$DOMAIN/g" ingress.yaml

# Étape 3: Créer le certificat managé
kubectl apply -f managed-certificate.yaml

# Étape 4: Attendre la création du certificat (peut prendre 15-20 minutes)
echo "⏳ Attente de la provision du certificat (cela peut prendre 15-20 minutes)..."
kubectl get managedcertificate emotion-certificate -n $NAMESPACE --watch

# Étape 5: Déployer les ressources
kubectl apply -f namespace.yaml
kubectl apply -f volume.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f ingress.yaml

# Étape 6: Vérifier le statut
echo "✅ Vérification du statut du déploiement..."
kubectl get all -n $NAMESPACE

# Étape 7: Afficher l'IP publique
echo ""
echo "📍 Adresse IP publique (peut prendre quelques minutes):"
kubectl get ingress emotion-ingress -n $NAMESPACE -w
