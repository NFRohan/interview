# Makefile for JSON Processor Production Deployment

.PHONY: help deploy stop status logs build clean

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE_FILE := docker-compose.yml
IMAGE_NAME := json-processor:latest
CONTAINER_NAME := json-processor-prod

# Help target
help: ## Show this help message
	@echo "JSON Processor Production Deployment"
	@echo "====================================="
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make deploy    # Deploy to production"
	@echo "  make status    # Check deployment status"
	@echo "  make logs      # View container logs"
	@echo "  make stop      # Stop production containers"

# Check if required files exist
check-env:
	@if [ ! -f .env ]; then \
		echo "❌ .env file not found!"; \
		echo "Please copy .env.example to .env and configure your API key:"; \
		echo "  cp .env.example .env"; \
		exit 1; \
	fi

# Deploy to production
deploy: check-env ## Deploy application to production
	@echo "🚀 Deploying to production..."
	@docker build -t $(IMAGE_NAME) .
	@docker-compose -f $(COMPOSE_FILE) down || true
	@docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Deployment complete!"
	@sleep 3
	@make status

# Build Docker image
build: ## Build Docker image
	@echo "🏗️  Building Docker image..."
	@docker build -t $(IMAGE_NAME) .
	@echo "✅ Build complete!"

# Stop production containers
stop: ## Stop production containers
	@echo "🛑 Stopping production containers..."
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ Containers stopped!"

# Show deployment status
status: ## Show production deployment status
	@echo "📊 Production Status:"
	@docker-compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker inspect $(CONTAINER_NAME) --format='Health: {{.State.Health.Status}}' 2>/dev/null || echo "Container not running"
	@echo ""
	@echo "💾 Resource Usage:"
	@docker stats $(CONTAINER_NAME) --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null || echo "Container not running"

# Show container logs
logs: ## Show production container logs
	@echo "📝 Production Logs:"
	@docker-compose -f $(COMPOSE_FILE) logs -f --tail=50

# Clean up Docker resources
clean: ## Clean up unused Docker resources
	@echo "🧹 Cleaning up Docker resources..."
	@docker system prune -f
	@docker volume prune -f
	@echo "✅ Cleanup complete!"

# Restart production deployment
restart: stop deploy ## Restart production deployment

# Update deployment (pull latest and redeploy)
update: ## Update and redeploy application
	@echo "🔄 Updating deployment..."
	@git pull 2>/dev/null || echo "Not a git repository, skipping git pull"
	@make deploy