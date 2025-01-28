#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check if docker can be run without sudo
check_docker_permissions() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Error: Unable to run docker commands without sudo${NC}"
        echo -e "${CYAN}Please follow the post-installation steps to run Docker without sudo:${NC}"
        echo -e "${CYAN}https://docs.docker.com/engine/install/linux-postinstall/${NC}"
        echo
        echo -e "${BOLD}The key steps are:${NC}"
        echo -e "${CYAN}1. Create the docker group: ${NC}sudo groupadd docker"
        echo -e "${CYAN}2. Add your user: ${NC}sudo usermod -aG docker \$USER"
        echo -e "${CYAN}3. Log out and back in for changes to take effect${NC}"
        exit 1
    fi
}

# Function to handle logging
log() {
    local msg="$1"
    local type="${2:-info}" # default to info if no type specified
    
    # Strip color codes if in quiet mode
    if [ "$QUIET_MODE" = true ]; then
        echo -e "$msg" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
    else
        case $type in
            "error")
                echo -e "${RED}Error: $msg${NC}"
                ;;
            "success")
                echo -e "${GREEN}$msg${NC}"
                ;;
            "warning")
                echo -e "${YELLOW}WARNING: $msg${NC}"
                ;;
            "header")
                echo -e "${BOLD}$msg${NC}"
                ;;
            "info")
                echo -e "${CYAN}$msg${NC}"
                ;;
            *)
                echo -e "$msg"
                ;;
        esac
    fi
}

# Function to show warning and wait for confirmation
show_warning_and_confirm() {
    local action="$1"
    log "⚠️  WARNING: You are about to perform a destructive action!" "warning"
    log "Action: $action" "warning"
    log "This operation cannot be undone." "warning"
    echo
    log "Press any key to continue or wait 10 seconds..." "info"
    
    # Start countdown in background
    local pid
    (
        for i in {10..1}; do
            echo -ne "\r${YELLOW}Continuing in $i seconds...${NC}"
            sleep 1
        done
        echo
    ) & pid=$!
    
    # Wait for either keypress or countdown completion
    read -t 10 -n 1
    local status=$?
    
    # Kill countdown if key was pressed
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    echo
    
    # Clear the countdown line
    echo -ne "\r\033[K"
    
    if [ $status -eq 0 ]; then
        log "Proceeding with $action..." "info"
    else
        log "Countdown completed. Proceeding with $action..." "info"
    fi
    echo
}

# Function to cleanup containers and volumes
cleanup_deployment() {
    local clean_type="$1"
    show_warning_and_confirm "cleanup"
    
    log "Stopping MCP Bridge related containers..." "info"
    docker compose down || true
    
    # Remove the external volume
    log "Removing external volume..." "info"
    docker volume rm mcp-bridge-mcps || true
    
    if [ "$clean_type" = "dispose" ]; then
        # Full disposal - remove everything including downloaded files
        log "Removing all MCP Bridge resources..." "info"
        rm -rf MCP-Bridge Dockerfile bridge-config mcp-staging
    fi
    
}

# Function to show deployment plan
show_plan() {
    log "Deployment Plan:" "header"
    log "---------------" "header"
    log "MCP Source Directory: $MCP_SRC_DIR" "info"
    log "Repository URL: $REPO_URL" "info"
    log "Settings File: $SETTINGS_FILE" "info"
    log "Clean Deployment: $([ "$CLEAN_DEPLOY" = true ] && echo "Yes" || echo "No")" "info"
    log "Quiet Mode: $([ "$QUIET_MODE" = true ] && echo "Yes" || echo "No")" "info"
    echo
    log "Actions to be performed:" "header"
    if [ "$CLEAN_DEPLOY" = true ]; then
        log "1. Stop and remove existing containers" "info"
    fi
    log "2. Clone repository from: $REPO_URL" "info"
    log "3. Set up bridge configuration" "info"
    log "4. Stage MCP configurations from: $MCP_SRC_DIR" "info"
    log "5. Build and start containers" "info"
    echo
}

# Function to show usage
show_usage() {
    log "Deploy and manage AI Platform infrastructure including MCP Bridge and servers" "header"
    echo
    log "Usage: $0 [options]" "header"
    echo
    log "Options:" "header"
    log "  --clean              Perform a clean deployment (stops containers and rebuilds)" "info"
    log "  --quiet             Run in quiet mode, redirecting all output to a timestamped log file" "info"
    log "                      This is useful for coding agents to avoid verbose output" "info"
    log "                      Default: Display all output to terminal" "info"
    log "  --dispose           Remove all MCP Bridge resources without deploying" "info"
    log "  --confirm           Use default values and proceed with deployment" "info"
    log "  --dry-run           Show what would happen without making any changes" "info"
    log "  --mcp-src-dir DIR   Directory containing MCP server source code" "info"
    log "                      Default: \$HOME/Documents/Cline/MCP" "info"
    log "  --repo-url URL      URL of the MCP Bridge repository" "info"
    log "                      Default: https://github.com/SecretiveShell/MCP-Bridge.git" "info"
    log "  --settings-file FILE Path to the MCP settings file" "info"
    log "                      Default: ~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json" "info"
    log "  --help              Display this help message" "info"
    echo
    log "Examples:" "header"
    log "  # Standard deployment with defaults" "info"
    log "  $0 --confirm" "info"
    echo
    log "  # Show what would happen without making changes" "info"
    log "  $0 --dry-run" "info"
    echo
    log "  # Clean deployment with quiet mode for coding agents" "info"
    log "  $0 --clean --quiet" "info"
    echo
    log "  # Remove all MCP Bridge resources" "info"
    log "  $0 --dispose" "info"
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
                log "--mcp-src-dir requires a directory path" "error"
                exit 1
            fi
            ;;
        --repo-url)
            if [ -n "$2" ]; then
                REPO_URL="$2"
                shift
            else
                log "--repo-url requires a URL" "error"
                exit 1
            fi
            ;;
        --settings-file)
            if [ -n "$2" ]; then
                SETTINGS_FILE="$2"
                shift
            else
                log "--settings-file requires a file path" "error"
                exit 1
            fi
            ;;
        --help) show_usage ;;
        *) log "Unknown parameter: $1" "error"; exit 1 ;;
    esac
    shift
done

# Validate required files/directories
if [ ! -d "$MCP_SRC_DIR" ]; then
    log "MCP source directory not found: $MCP_SRC_DIR" "error"
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    log "MCP settings file not found: $SETTINGS_FILE" "error"
    exit 1
fi

# Show plan for dry run
if [ "$DRY_RUN" = true ]; then
    show_plan
    exit 0
fi

if [ "$QUIET_MODE" = true ]; then
    exec 1>>$LOG_FILE 2>&1
    log "MCP deployment log started at $(date)" "header"
    log "Log file location: $LOG_FILE" "info"
fi

# Function to check deployment health
check_deployment_health() {
    # Check if containers are running properly
    if ! docker compose ps | grep -q "Up" || ! docker ps | grep -q "mcp-bridge"; then
        log "Deployment appears to be unhealthy!" "error"
        log "Try running with --clean flag to perform a fresh deployment" "info"
        exit 1
    fi
}

# Handle dispose flag
if [ "$DISPOSE_ONLY" = true ]; then
    show_warning_and_confirm "disposal of all MCP Bridge resources"
    cleanup_deployment "dispose"
    log "MCP Bridge disposal complete!" "success"
    exit 0
fi

# Handle clean deployment
if [ "$CLEAN_DEPLOY" = true ]; then
    show_warning_and_confirm "clean deployment (stopping containers and rebuilding from scratch)"
    cleanup_deployment "clean"
elif docker ps -a | grep -q "mcp-bridge.*Exited"; then
    log "Previous deployment appears to have failed!" "error"
    log "It is recommended to run with --clean flag for a fresh deployment" "info"
    exit 1
fi

log "Cleaning up old repository..." "info"
rm -rf MCP-Bridge

log "Cloning fresh repository..." "info"
git clone $REPO_URL

log "Copying Dockerfile..." "info"
cp MCP-Bridge/Dockerfile .

log "Cleaning up existing bridge configuration..." "info"
rm -rf bridge-config

log "Setting up bridge configuration..." "info"
if [ -d "bridge-config/config.json" ]; then
    log "Removing incorrectly created config.json directory..." "info"
    rm -rf bridge-config/config.json
fi
mkdir -p bridge-config
log "Creating default bridge configuration..." "info"
cat > bridge-config/config.json << EOF
{
  "inference_server": {
    "base_url": "http://localhost:11434/v1",
    "api_key": "None"
  }
}
EOF

# Create external volume
log "Creating external volume..." "info"
docker volume create mcp-bridge-mcps || true

log "Setting up MCP staging area..." "info"
mkdir -p mcp-staging
if [ -d "$MCP_SRC_DIR" ] && [ -n "$(ls -A "$MCP_SRC_DIR")" ]; then
    log "Copying MCP configurations from $MCP_SRC_DIR..." "info"
    rm -rf mcp-staging/*
    cp -r "$MCP_SRC_DIR"/* mcp-staging/
else
    log "No MCP configurations found in $MCP_SRC_DIR" "warning"
    log "You can add MCP configurations to mcp-staging/ and load them via REST interface" "info"
fi

# Build and start the stack
log "Building and starting the stack..." "info"
docker compose build --no-cache mcp-bridge
docker compose up -d

# Restart just the bridge container if stack was already running
if docker ps | grep -q "mcp-bridge"; then
    log "Restarting MCP Bridge container..." "info"
    docker restart mcp-bridge
else
    log "MCP Bridge container not running. Starting it..." "info"
    docker compose up -d mcp-bridge
fi

# Final health check
check_deployment_health
log "MCP Bridge deployment complete!" "success"

# Cleanup
log "Cleaning up temporary files..." "info"

if [ "$QUIET_MODE" = true ]; then
    log "Deployment complete. Log file is available at: $LOG_FILE" "success"
fi
rm -rf MCP-Bridge Dockerfile
log "Note: MCP configurations are available in mcp-staging/ for loading via REST interface" "info"
