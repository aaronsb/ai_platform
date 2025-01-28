# NPM Package MCP Server Implementation

This guide covers implementing an MCP server as an NPM package with MCP-Bridge.

## Overview

NPM package implementation is ideal for:
- Easy distribution
- Version management
- Dependency handling
- Quick installation

## Implementation Steps

1. **Prepare Package.json**
   ```json
   {
     "name": "@username/mcp-server",
     "version": "1.0.0",
     "description": "MCP Server Implementation",
     "main": "build/index.js",
     "bin": {
       "mcp-server": "./build/index.js"
     },
     "scripts": {
       "build": "tsc && chmod +x build/index.js",
       "prepublishOnly": "npm run build"
     },
     "type": "module",
     "dependencies": {
       "@modelcontextprotocol/sdk": "^1.0.0"
     }
   }
   ```

2. **Publish to NPM**
   ```bash
   # Login to NPM
   npm login
   
   # Build and publish
   npm publish --access public
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
           "npm-server": {
               "command": "npx",
               "args": ["@username/mcp-server"],
               "env": {
                   "API_KEY": "your-api-key"
               }
           }
       }
   }
   ```

## Example: GSuite MCP Server as NPM Package

Here's a real-world example using a GSuite MCP server:

```json
{
    "mcp_servers": {
        "gsuite": {
            "command": "npx",
            "args": ["@aaronsb/gsuite-mcp"],
            "env": {
                "GOOGLE_CLIENT_ID": "your-client-id",
                "GOOGLE_CLIENT_SECRET": "your-client-secret",
                "GOOGLE_REFRESH_TOKEN": "your-refresh-token"
            }
        }
    }
}
```

## Package Development

1. **Project Structure**
   ```
   your-mcp-server/
   ├── src/
   │   └── index.ts
   ├── package.json
   ├── tsconfig.json
   └── README.md
   ```

2. **Entry Point (src/index.ts)**
   ```typescript
   #!/usr/bin/env node
   import { Server } from '@modelcontextprotocol/sdk/server/index.js';
   import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
   
   class YourMcpServer {
     private server: Server;
   
     constructor() {
       this.server = new Server(
         {
           name: 'your-mcp-server',
           version: '1.0.0',
         },
         {
           capabilities: {
             resources: {},
             tools: {},
           },
         }
       );
       
       // Setup handlers
       this.setupHandlers();
     }
   
     private setupHandlers() {
       // Implement your handlers
     }
   
     async run() {
       const transport = new StdioServerTransport();
       await this.server.connect(transport);
     }
   }
   
   const server = new YourMcpServer();
   server.run().catch(console.error);
   ```

## Best Practices

1. **Package Management**
   - Use semantic versioning
   - Document breaking changes
   - Keep dependencies updated
   - Test before publishing

2. **Distribution**
   - Use scoped packages (@username/package)
   - Include TypeScript types
   - Provide clear documentation
   - Include usage examples

3. **Security**
   - Audit dependencies
   - Handle sensitive data properly
   - Document security considerations
   - Use environment variables

## Common Issues

1. **Installation Issues**
   - Check npm registry access
   - Verify package name
   - Check dependencies
   - Validate permissions

2. **Runtime Issues**
   - Verify Node.js version
   - Check environment variables
   - Debug with verbose logging
   - Validate configuration

3. **Update Issues**
   - Follow semver guidelines
   - Document migrations
   - Test upgrades
   - Maintain changelog

## NPM Scripts

Useful scripts for package.json:

```json
{
  "scripts": {
    "build": "tsc && chmod +x build/index.js",
    "dev": "ts-node-dev --respawn src/index.ts",
    "lint": "eslint src/**/*.ts",
    "test": "jest",
    "prepublishOnly": "npm run build",
    "postversion": "git push && git push --tags"
  }
}
```

## Example GitHub Actions Workflow

```yaml
name: Publish Package

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      
      - run: npm ci
      - run: npm run build
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

See [Docker Implementation](../docker-mcp) for containerized deployment option.
