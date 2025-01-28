# Docker-based MCP Server Implementation

This guide covers implementing an MCP server using Docker with MCP-Bridge.

## Overview

Docker-based implementation is recommended for:
- Production deployments
- Consistent environments
- Easy distribution
- Scalable deployments

## Implementation Steps

1. **Create Dockerfile**
   ```dockerfile
   FROM node:18-slim
   
   WORKDIR /app
   
   # Copy package files
   COPY package*.json ./
   
   # Install dependencies
   RUN npm install
   
   # Copy source code
   COPY . .
   
   # Build the application
   RUN npm run build
   
   # Set executable permissions
   RUN chmod +x build/index.js
   
   # Command to run the server
   CMD ["node", "build/index.js"]
   ```

2. **Build and Push Docker Image**
   ```bash
   # Build the image
   docker build -t username/mcp-server:latest .
   
   # Push to registry (optional)
   docker push username/mcp-server:latest
   ```

3. **Configure MCP-Bridge**
   ```json
   {
       "inference_server": {
           "base_url": "http://localhost:8000/v1",
           "api_key": "None"
       },
       "sampling": {
           "models": [
               {
                   "model": "gpt-4",
                   "intelligence": 0.8,
                   "cost": 0.9,
                   "speed": 0.3
               }
           ]
       },
       "mcp_servers": {
           "docker-server": {
               "image": "username/mcp-server:latest",
               "env": {
                   "API_KEY": "your-api-key"
               }
           }
       }
   }
   ```

## Example: GitHub-hosted MCP Server

Here's a real-world example using a GitHub-hosted MCP server:

```json
{
    "mcp_servers": {
        "gsuite": {
            "image": "aaronsb/gsuite-mcp:latest",
            "env": {
                "GOOGLE_CLIENT_ID": "your-client-id",
                "GOOGLE_CLIENT_SECRET": "your-client-secret",
                "GOOGLE_REFRESH_TOKEN": "your-refresh-token"
            }
        }
    }
}
```

## Docker Compose Integration

For more complex setups, use Docker Compose:

```yaml
version: '3.8'

services:
  mcp-bridge:
    image: mcp-bridge:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config.json:/app/config.json
    environment:
      - MCP_BRIDGE__CONFIG__FILE=config.json

  mcp-server:
    image: username/mcp-server:latest
    environment:
      - API_KEY=your-api-key
```

## Best Practices

1. **Image Management**
   - Use specific version tags
   - Implement multi-stage builds
   - Keep images minimal
   - Regular security updates

2. **Environment Variables**
   - Use Docker secrets for sensitive data
   - Document all required variables
   - Provide example values

3. **Networking**
   - Configure proper network isolation
   - Use Docker networks
   - Implement health checks

4. **Security**
   - Scan images for vulnerabilities
   - Run as non-root user
   - Implement proper access controls

## Common Issues

1. **Image Pull Issues**
   - Check registry authentication
   - Verify image name and tag
   - Check network connectivity

2. **Container Startup**
   - Check logs for errors
   - Verify environment variables
   - Check file permissions

3. **Network Issues**
   - Verify port mappings
   - Check Docker network configuration
   - Validate service discovery

## Production Considerations

1. **Monitoring**
   - Implement health checks
   - Set up container monitoring
   - Configure log aggregation

2. **Scaling**
   - Use container orchestration
   - Implement load balancing
   - Configure resource limits

3. **Updates**
   - Plan update strategy
   - Version control images
   - Test updates in staging

## Example GitHub Actions Workflow

```yaml
name: Build and Push MCP Server

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: username/mcp-server:latest
```

See [NPM Implementation](../npm-mcp) for alternative distribution method.
