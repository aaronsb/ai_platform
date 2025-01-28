# Local MCP Server Implementation

This guide covers implementing a locally developed MCP server with MCP-Bridge.

## Overview

Local MCP server implementation is ideal for:
- Development and testing
- Personal projects
- Quick prototyping
- Direct debugging

## Implementation Steps

1. **Prepare Your MCP Server**
   ```bash
   # Example for a Node.js MCP server
   cd /path/to/your/mcp
   npm install
   npm run build
   ```

2. **Create config.json**
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
           "your-local-server": {
               "command": "node",
               "args": ["/absolute/path/to/your/mcp/build/index.js"]
           }
       },
       "network": {
           "host": "0.0.0.0",
           "port": 9090
       }
   }
   ```

3. **Environment Variables**
   If your MCP server requires environment variables:
   ```bash
   export MCP_SERVER_VAR="value"
   # Or add to config.json:
   {
       "mcp_servers": {
           "your-local-server": {
               "command": "node",
               "args": ["/path/to/your/mcp/build/index.js"],
               "env": {
                   "MCP_SERVER_VAR": "value"
               }
           }
       }
   }
   ```

## Example: GSuite MCP Server

Here's a real-world example using a GSuite MCP server:

```json
{
    "mcp_servers": {
        "gsuite": {
            "command": "node",
            "args": ["/home/user/Documents/Cline/MCP/gsuite-mcp/build/index.js"],
            "env": {
                "GOOGLE_CLIENT_ID": "your-client-id",
                "GOOGLE_CLIENT_SECRET": "your-client-secret",
                "GOOGLE_REFRESH_TOKEN": "your-refresh-token"
            }
        }
    }
}
```

## Development Tips

1. **File Paths**
   - Always use absolute paths in config.json
   - Verify file permissions
   - Ensure build artifacts exist

2. **Debugging**
   - Set logging to DEBUG level
   ```json
   {
       "logging": {
           "log_level": "DEBUG"
       }
   }
   ```
   - Monitor server output
   - Check MCP-Bridge logs

3. **Testing**
   - Test tools individually
   - Verify environment variables
   - Check server connectivity

## Common Issues

1. **Path Issues**
   - Ensure paths are absolute
   - Verify file existence
   - Check file permissions

2. **Environment Variables**
   - Verify all required variables
   - Check variable naming
   - Validate variable values

3. **Build Issues**
   - Rebuild after changes
   - Check build output
   - Verify dependencies

## Next Steps

Once your local implementation is working:
1. Consider containerization for production
2. Implement proper error handling
3. Add monitoring and logging
4. Document API and tools

See [Docker Implementation](../docker-mcp) for production deployment.
