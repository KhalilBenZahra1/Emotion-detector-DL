# Script de mise a jour DuckDNS

$TOKEN = "918b0b65-f264-4ecb-bd01-1736a2163c4b"
$DOMAIN = "emotion-detection"
$NAMESPACE = "emotion-prod"

Write-Host "Recherche de l'IP de l'Ingress..." -ForegroundColor Cyan

# Obtenir l'IP de l'Ingress
$IP = kubectl get ingress emotion-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null

if ($IP) {
    Write-Host "OK - IP trouvee: $IP" -ForegroundColor Green
    
    Write-Host "Mise a jour de DuckDNS..." -ForegroundColor Cyan
    
    # Mettre a jour DuckDNS
    $response = Invoke-WebRequest -Uri "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$IP" -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        Write-Host "OK - DuckDNS mis a jour avec succes !" -ForegroundColor Green
        Write-Host "Acces: https://emotion-detection.duckdns.org" -ForegroundColor Green
        Write-Host ""
        Write-Host "Attendez 5-10 minutes pour la propagation DNS..." -ForegroundColor Yellow
    } else {
        Write-Host "ERREUR lors de la mise a jour de DuckDNS" -ForegroundColor Red
    }
} else {
    Write-Host "L'Ingress n'a pas encore d'IP publique" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Verification de l'etat du certificat:" -ForegroundColor Cyan
    kubectl describe managedcertificate emotion-certificate -n $NAMESPACE
    Write-Host ""
    Write-Host "Relancez ce script dans quelques minutes..." -ForegroundColor Yellow
}
