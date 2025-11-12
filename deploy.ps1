# Production Deployment Script for JSON Processor

param(
    [string]$Action = "deploy",
    [string]$JsonPath = "/app/json"
)

function Start-ProductionDeployment {
    Write-Host "[DEPLOY] Starting Production Deployment..." -ForegroundColor Green
    
    # Build production image
    Write-Host "Building production image..." -ForegroundColor Yellow
    docker build -t json-processor:latest .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Build failed!" -ForegroundColor Red
        exit 1
    }
    
    # Stop existing containers
    Write-Host "Stopping existing containers..." -ForegroundColor Yellow
    docker-compose down
    
    # Start production containers
    Write-Host "Starting production containers..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Production deployment successful!" -ForegroundColor Green
        
        # Wait a moment for container to start
        Start-Sleep -Seconds 5
        
        # Show status
        Write-Host "`n[STATUS] Container Status:" -ForegroundColor Cyan
        docker-compose ps
        
        # Show health check
        Write-Host "`n[HEALTH] Health Check:" -ForegroundColor Cyan
        docker inspect json-processor-prod --format='{{.State.Health.Status}}'
        
        # Show recent logs
        Write-Host "`n[LOGS] Recent Logs:" -ForegroundColor Cyan
        docker-compose logs --tail=20
        
    } else {
        Write-Host "[ERROR] Deployment failed!" -ForegroundColor Red
        exit 1
    }
}

function Stop-Production {
    Write-Host "[STOP] Stopping Production Containers..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "[SUCCESS] Production containers stopped." -ForegroundColor Green
}

function Show-Status {
    Write-Host "[STATUS] Production Status:" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host "`n[HEALTH] Health Status:" -ForegroundColor Cyan
    $healthStatus = docker inspect json-processor-prod --format='{{.State.Health.Status}}' 2>$null
    if ($healthStatus) {
        Write-Host "Health: $healthStatus" -ForegroundColor $(if ($healthStatus -eq "healthy") { "Green" } else { "Red" })
    } else {
        Write-Host "Container not running" -ForegroundColor Red
    }
    
    Write-Host "`n[RESOURCES] Resource Usage:" -ForegroundColor Cyan
    docker stats json-processor-prod --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
}

function Show-Logs {
    Write-Host "[LOGS] Production Logs:" -ForegroundColor Cyan
    docker-compose logs -f --tail=50
}

# Main script logic
switch ($Action.ToLower()) {
    "deploy" { Start-ProductionDeployment }
    "stop" { Stop-Production }
    "status" { Show-Status }
    "logs" { Show-Logs }
    default {
        Write-Host "[HELP] Usage: .\deploy.ps1 -Action [deploy|stop|status|logs]" -ForegroundColor Yellow
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\deploy.ps1                    # Deploy to production"
        Write-Host "  .\deploy.ps1 -Action deploy     # Deploy to production"
        Write-Host "  .\deploy.ps1 -Action stop       # Stop production containers"
        Write-Host "  .\deploy.ps1 -Action status     # Show production status"
        Write-Host "  .\deploy.ps1 -Action logs       # Show production logs"
    }
}