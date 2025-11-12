#!/bin/bash

# Production Deployment Script for JSON Processor (Linux/macOS)

set -e  # Exit on any error

# Default action
ACTION="${1:-deploy}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${2}${1}${NC}"
}

# Deploy to production
deploy_production() {
    print_status "🚀 Starting Production Deployment..." "$GREEN"
    
    # Build production image
    print_status "Building production image..." "$YELLOW"
    docker build -t json-processor:latest .
    
    # Stop existing containers
    print_status "Stopping existing containers..." "$YELLOW"
    docker-compose down || true
    
    # Start production containers
    print_status "Starting production containers..." "$YELLOW"
    docker-compose up -d
    
    print_status "✅ Production deployment successful!" "$GREEN"
    
    # Wait a moment for container to start
    sleep 5
    
    # Show status
    print_status "\n📊 Container Status:" "$CYAN"
    docker-compose ps
    
    # Show health check
    print_status "\n🏥 Health Check:" "$CYAN"
    HEALTH_STATUS=$(docker inspect json-processor-prod --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        print_status "Health: $HEALTH_STATUS" "$GREEN"
    else
        print_status "Health: $HEALTH_STATUS" "$RED"
    fi
    
    # Show recent logs
    print_status "\n📝 Recent Logs:" "$CYAN"
    docker-compose logs --tail=20
}

# Stop production containers
stop_production() {
    print_status "🛑 Stopping Production Containers..." "$YELLOW"
    docker-compose down
    print_status "✅ Production containers stopped." "$GREEN"
}

# Show production status
show_status() {
    print_status "📊 Production Status:" "$CYAN"
    docker-compose ps
    
    print_status "\n🏥 Health Status:" "$CYAN"
    HEALTH_STATUS=$(docker inspect json-processor-prod --format='{{.State.Health.Status}}' 2>/dev/null || echo "not running")
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        print_status "Health: $HEALTH_STATUS" "$GREEN"
    elif [ "$HEALTH_STATUS" = "not running" ]; then
        print_status "Container not running" "$RED"
    else
        print_status "Health: $HEALTH_STATUS" "$RED"
    fi
    
    print_status "\n💾 Resource Usage:" "$CYAN"
    if docker ps --format "table {{.Names}}" | grep -q "json-processor-prod"; then
        docker stats json-processor-prod --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    else
        print_status "Container not running" "$RED"
    fi
}

# Show production logs
show_logs() {
    print_status "📝 Production Logs:" "$CYAN"
    docker-compose logs -f --tail=50
}

# Show help
show_help() {
    print_status "Usage: ./deploy.sh [ACTION]" "$YELLOW"
    print_status "Actions:" "$CYAN"
    echo "  deploy    Deploy to production (default)"
    echo "  stop      Stop production containers"
    echo "  status    Show production status"
    echo "  logs      Show production logs"
    echo "  help      Show this help message"
    echo ""
    print_status "Examples:" "$CYAN"
    echo "  ./deploy.sh                    # Deploy to production"
    echo "  ./deploy.sh deploy             # Deploy to production"
    echo "  ./deploy.sh stop               # Stop production containers"
    echo "  ./deploy.sh status             # Show production status"
    echo "  ./deploy.sh logs               # Show production logs"
}

# Check if Docker and Docker Compose are installed
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_status "❌ Docker is not installed!" "$RED"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_status "❌ Docker Compose is not installed!" "$RED"
        exit 1
    fi
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        print_status "⚠️  .env file not found! Please copy .env.example to .env and configure your API key." "$YELLOW"
        if [ -f ".env.example" ]; then
            print_status "Run: cp .env.example .env" "$CYAN"
        fi
        exit 1
    fi
}

# Main script logic
main() {
    # Check requirements first
    check_requirements
    
    case "${ACTION,,}" in  # Convert to lowercase
        "deploy")
            deploy_production
            ;;
        "stop")
            stop_production
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_status "❌ Unknown action: $ACTION" "$RED"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"