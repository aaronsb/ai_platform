# AI Platform Deployment Tool

A deployment script for managing the AI Platform infrastructure, including MCP Bridge and associated MCP servers.

## Features

- **Clean Deployments**: Option to perform fresh deployments by removing existing volumes
- **Quiet Mode**: Redirect output to timestamped log files (useful for coding agents)
- **Resource Management**: Easy cleanup of containers and volumes
- **Configurable**: Customize MCP source directory, repository URL, and settings file location
- **Docker Permission Check**: Ensures proper setup for running docker commands without sudo
- **Dry Run Mode**: Preview deployment actions without making changes
- **Quick Deploy**: Use default values with simple confirmation flag

## Prerequisites

- Docker installed and configured for non-root usage
- Git for cloning repositories
- Access to required MCP servers and source code

## Usage

```bash
./deploy-ai-platform.sh [options]
```

### Options

- `--clean`: Perform a clean deployment (removes existing volumes)
- `--quiet`: Run in quiet mode, redirecting output to a timestamped log file
- `--dispose`: Remove all AI Platform containers and volumes without deploying
- `--confirm`: Use default values and proceed with deployment
- `--dry-run`: Show what would happen without making any changes
- `--mcp-src-dir DIR`: Directory containing MCP server source code
- `--repo-url URL`: URL of the MCP Bridge repository
- `--settings-file FILE`: Path to the MCP settings file
- `--help`: Display help message

### Default Values

- MCP Source Directory: `$HOME/Documents/Cline/MCP`
- Repository URL: `https://github.com/SecretiveShell/MCP-Bridge.git`
- Settings File: `$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

### Examples

```bash
# Standard deployment with defaults
./deploy-ai-platform.sh --confirm

# Show what would happen without making changes
./deploy-ai-platform.sh --dry-run

# Clean deployment with quiet mode for coding agents
./deploy-ai-platform.sh --clean --quiet

# Remove all AI Platform resources
./deploy-ai-platform.sh --dispose
```

## Logging

When running in quiet mode, all output is redirected to a timestamped log file in `/tmp`. The log file location is displayed at the start and end of the deployment process.

## Error Handling

- Validates required files and directories before proceeding
- Checks for proper docker permissions
- Handles in-use volumes during cleanup
- Provides clear error messages and guidance for common issues

## Docker Permission Setup

If you encounter permission issues, follow these steps:

1. Create the docker group: `sudo groupadd docker`
2. Add your user to the group: `sudo usermod -aG docker $USER`
3. Log out and back in for changes to take effect

For more details, see the [Docker post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/).
