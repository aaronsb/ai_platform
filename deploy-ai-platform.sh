#!/bin/bash

# Check if docker can be run without sudo
check_docker_permissions() {
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Unable to run docker commands without sudo"
        echo "Please follow the post-installation steps to run Docker without sudo:"
        echo "https://docs.docker.com/engine/install/linux-postinstall/"
        echo
        echo "The key steps are:"
        echo "1. Create the docker group: sudo groupadd docker"
        echo "2. Add your user: sudo usermod -aG docker $USER"
        echo "3. Log out and back in for changes to take effect"
        exit 1
    fi
}

# Function to handle logging
log() {
    if [ "$QUIET_MODE" = true ]; then
        echo "$@" >> "$LOG_FILE"
    else
        echo "$@"
    fi
}

# Function to cleanup containers and volumes
cleanup_deployment() {
    log "Stopping MCP Bridge related containers..."
    docker compose down || true
    
    log "Removing MCP volume..."
    # Try normal removal first
    if ! docker volume rm mcp-bridge-mcps 2>/dev/null; then
        log "Volume in use, forcing removal..."
        # Get container IDs using the volume
        containers=$(docker ps -a --filter volume=mcp-bridge-mcps --format "{{.ID}}")
        if [ -n "$containers" ]; then
            log "Stopping containers using the volume..."
            echo "$containers" | xargs docker rm -f
        fi
        # Try volume removal again
        docker volume rm mcp-bridge-mcps || true
    fi
}

# Function to show deployment plan
show_plan() {
    echo "Deployment Plan:"
    echo "---------------"
    echo "MCP Source Directory: $MCP_SRC_DIR"
    echo "Repository URL: $REPO_URL"
    echo "Settings File: $SETTINGS_FILE"
    echo "Clean Deployment: $([ "$CLEAN_DEPLOY" = true ] && echo "Yes" || echo "No")"
    echo "Quiet Mode: $([ "$QUIET_MODE" = true ] && echo "Yes" || echo "No")"
    echo
    if [ "$CLEAN_DEPLOY" = true ]; then
        echo "Actions to be performed:"
        echo "1. Stop and remove existing containers"
        echo "2. Remove existing MCP volume"
    else
        echo "Actions to be performed:"
        echo "1. Reuse existing volume if present"
    fi
    echo "2. Clone repository from: $REPO_URL"
    echo "3. Copy MCP files from: $MCP_SRC_DIR"
    echo "4. Use settings from: $SETTINGS_FILE"
    echo "5. Build and start containers"
    echo
}

# Function to show usage
show_usage() {
    echo "Deploy and manage AI Platform infrastructure including MCP Bridge and servers"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --clean              Perform a clean deployment (removes existing volumes)"
    echo "  --quiet             Run in quiet mode, redirecting all output to a timestamped log file"
    echo "                      This is useful for coding agents to avoid verbose output"
    echo "                      Default: Display all output to terminal"
    echo "  --dispose           Remove all MCP Bridge containers and volumes without deploying"
    echo "  --confirm           Use default values and proceed with deployment"
    echo "  --dry-run           Show what would happen without making any changes"
    echo "  --mcp-src-dir DIR   Directory containing MCP server source code"
    echo "                      Default: \$HOME/Documents/Cline/MCP"
    echo "  --repo-url URL      URL of the MCP Bridge repository"
    echo "                      Default: https://github.com/SecretiveShell/MCP-Bridge.git"
    echo "  --settings-file FILE Path to the MCP settings file"
    echo "                      Default: ~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
    echo "  --help              Display this help message"
    echo
    echo "Examples:"
    echo "  # Standard deployment with defaults"
    echo "  $0 --confirm"
    echo
    echo "  # Show what would happen without making changes"
    echo "  $0 --dry-run"
    echo
    echo "  # Clean deployment with quiet mode for coding agents"
    echo "  $0 --clean --quiet"
    echo
    echo "  # Remove all MCP Bridge resources"
    echo "  $0 --dispose"
    echo
    exit 1
}

# Default values
MCP_SRC_DIR="$HOME/Documents/Cline/MCP"
REPO_URL="https://github.com/SecretiveShell/MCP-Bridge.git"
SETTINGS_FILE="$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
CLEAN_DEPLOY=false
QUIET_MODE=false
DISPOSE_ONLY=false
DRY_RUN=false
CONFIRMED=false
LOG_FILE="/tmp/mcp-deploy-$(date +%Y%m%d-%H%M%S).log"

# Check docker permissions first
check_docker_permissions

# Show help by default if no arguments and not confirmed
if [ $# -eq 0 ] && [ "$CONFIRMED" = false ]; then
    show_usage
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --clean) CLEAN_DEPLOY=true ;;
        --quiet) QUIET_MODE=true ;;
        --dispose) DISPOSE_ONLY=true ;;
        --dry-run) DRY_RUN=true ;;
        --confirm) CONFIRMED=true ;;
        --mcp-src-dir) 
            if [ -n "$2" ]; then
                MCP_SRC_DIR="$2"
                shift
            else
                echo "Error: --mcp-src-dir requires a directory path"
                exit 1
            fi
            ;;
        --repo-url)
            if [ -n "$2" ]; then
                REPO_URL="$2"
                shift
            else
                echo "Error: --repo-url requires a URL"
                exit 1
            fi
            ;;
        --settings-file)
            if [ -n "$2" ]; then
                SETTINGS_FILE="$2"
                shift
            else
                echo "Error: --settings-file requires a file path"
                exit 1
            fi
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate required files/directories
if [ ! -d "$MCP_SRC_DIR" ]; then
    echo "Error: MCP source directory not found: $MCP_SRC_DIR"
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Error: MCP settings file not found: $SETTINGS_FILE"
    exit 1
fi

# Show plan for dry run
if [ "$DRY_RUN" = true ]; then
    show_plan
    exit 0
fi

if [ "$QUIET_MODE" = true ]; then
    exec 1>>$LOG_FILE 2>&1
    echo "MCP deployment log started at $(date)"
    echo "Log file location: $LOG_FILE"
fi

# Handle dispose flag
if [ "$DISPOSE_ONLY" = true ]; then
    cleanup_deployment
    log "MCP Bridge disposal complete!"
    exit 0
fi

# Handle clean deployment
if [ "$CLEAN_DEPLOY" = true ]; then
    cleanup_deployment
elif docker volume ls | grep -q "mcp-bridge-mcps"; then
    log "WARNING: MCP volume already exists!"
    log "This deployment will reuse the existing volume."
    log "Use --clean flag for a fresh deployment that removes existing volumes."
    log "Continuing in 10 seconds..."
    sleep 10
fi

log "Cleaning up old repository..."
rm -rf MCP-Bridge

log "Cloning fresh repository..."
git clone $REPO_URL

log "Copying Dockerfile..."
cp MCP-Bridge/Dockerfile .

log "Copying MCP settings file..."
cp "$SETTINGS_FILE" config.json

# Create volume and copy MCPs
log "Setting up MCP volume..."
docker volume create mcp-bridge-mcps
if [ "$CLEAN_DEPLOY" = true ] || ! docker run --rm -v mcp-bridge-mcps:/mcps alpine test -d /mcps/mcp_bridge; then
    log "Copying MCP files to volume..."
    docker run --rm -v mcp-bridge-mcps:/mcps alpine rm -rf /mcps/*
    docker cp "$MCP_SRC_DIR/." $(docker create --rm -v mcp-bridge-mcps:/mcps alpine):/mcps/
else
    log "Using existing MCP files in volume..."
fi

# Build and start the stack
log "Building and starting the stack..."
docker compose build --no-cache mcp-bridge
docker compose up -d

# Restart just the bridge container if stack was already running
if docker ps | grep -q "mcp-bridge"; then
    log "Restarting MCP Bridge container..."
    docker restart mcp-bridge
else
    log "MCP Bridge container not running. Starting it..."
    docker compose up -d mcp-bridge
fi

log "MCP Bridge deployment complete!"

# Cleanup
log "Cleaning up temporary files..."

if [ "$QUIET_MODE" = true ]; then
    echo "Deployment complete. Log file is available at: $LOG_FILE"
fi
rm -rf MCP-Bridge Dockerfile
