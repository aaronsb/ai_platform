#!/bin/bash

# Function to display a title card
show_title() {
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "           $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    sleep 2
}

# Function to simulate typing
type_out() {
    text="$1"
    echo -n "$ "
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.05
    done
    echo
    sleep 0.5
}

# Function to run a command with typing simulation
run_command() {
    type_out "$1"
    eval "$1"
    echo
    sleep 6
}

# Help Section
show_title "SHOWING HELP INFORMATION"
run_command "../deploy-ai-platform.sh --help"

# Dry Run Section
show_title "PERFORMING DRY RUN"
run_command "../deploy-ai-platform.sh --dry-run"

# Clean Deploy Section
show_title "PERFORMING CLEAN DEPLOYMENT"
run_command "../deploy-ai-platform.sh --clean --confirm"

# Standard Deploy Section
show_title "PERFORMING STANDARD DEPLOYMENT"
run_command "../deploy-ai-platform.sh --confirm"

# Dispose Section
show_title "DISPOSING ALL RESOURCES"
run_command "../deploy-ai-platform.sh --dispose"
