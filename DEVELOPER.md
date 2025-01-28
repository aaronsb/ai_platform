# Developer Guidelines

This document provides guidelines and best practices for developers working on the AI Platform project. These guidelines incorporate and extend the AI-specific development practices defined in our `.clinerules` file.

## AI Development Practices

This project follows specific guidelines optimized for AI coding agents while maintaining compatibility with human developer workflows. These practices are defined in our `.clinerules` file and prioritize:

- Clarity and predictability in code contributions
- Consistent commit message structure
- Clear documentation of decisions and trade-offs
- Efficient code organization patterns

For detailed AI-specific guidelines, refer to the `.clinerules` file in the project root.

## Development Environment Setup

1. **Prerequisites**
   - Docker and Docker Compose
   - Git
   - Node.js (latest LTS version)
   - A code editor (VS Code recommended)
   - NVIDIA drivers and CUDA toolkit (for GPU support)

2. **Local Development Setup**
   ```bash
   git clone <repository-url>
   cd ai-platform
   ./deploy-ai-platform.sh --confirm
   ```

## Code Style Guidelines

### General

- Use meaningful variable and function names
- Write self-documenting code
- Keep functions small and focused
- Follow the Single Responsibility Principle
- Add comments only when necessary to explain complex logic

### Shell Scripts

- Use shellcheck for linting
- Add error handling for critical operations
- Use functions for reusable code
- Add logging for important operations
- Include usage documentation
- Make scripts idempotent when possible

### Docker

- Follow Docker best practices
- Use multi-stage builds when applicable
- Minimize image layers
- Use specific version tags for base images
- Include health checks
- Document exposed ports and volumes

## Testing

1. **Local Testing**
   - Test deployment script with different flags
   - Verify container health and logs
   - Check volume persistence
   - Test GPU access where applicable

2. **Integration Testing**
   - Test inter-service communication
   - Verify MCP Bridge functionality
   - Test with different MCP servers
   - Validate Watchtower updates

## Documentation

Following our `.clinerules` standards:

### Code Comments
- Purpose comments at file level
- Interface documentation for public APIs
- Decision records for non-obvious implementation choices
- Example usage in doc comments for complex functions

Example:
```python
def retry_with_backoff(max_attempts: int, base_delay: float) -> Callable:
    """
    Implements exponential backoff retry logic.
    
    Chosen approach:
    - Uses exponential backoff to prevent thundering herd
    - Adds jitter to avoid synchronization
    - Caps maximum delay to prevent excessive waits
    
    Example:
        @retry_with_backoff(max_attempts=3, base_delay=1.0)
        def fetch_data():
            return api.get_data()
    """
```

### Change Documentation
Each significant change should include:
- Clear explanation of the problem being solved
- Rationale for the chosen approach
- Performance implications if relevant
- Migration steps if breaking existing patterns

## Git Workflow

1. **Branching**
   - `main` - stable production code
   - `develop` - integration branch
   - `feature/*` - new features
   - `fix/*` - bug fixes
   - `release/*` - release preparation

2. **Commit Messages**
   Following our `.clinerules` standards:
   ```
   [scope] Action: detailed description

   - Context about the change
   - Reasoning for the approach taken
   - Any notable trade-offs considered
   ```
   Example:
   ```
   [auth] Add OAuth2 token refresh mechanism

   - Implements RFC 6749 compliant refresh flow
   - Chose synchronous refresh over background due to simplicity
   - Considered but rejected token caching for initial implementation
   ```

3. **Pull Requests**
   - Include description of changes
   - Add test results
   - Update documentation
   - Request review from maintainers

## Release Process

1. **Preparation**
   - Update version numbers
   - Update changelog
   - Test all components
   - Update documentation

2. **Release**
   - Tag release in git
   - Update release notes
   - Deploy to staging
   - Verify deployment
   - Deploy to production

## Security

- Keep dependencies updated
- Follow security best practices
- Use environment variables for sensitive data
- Implement proper access controls
- Regular security audits

## Performance

- Monitor resource usage
- Optimize container configurations
- Profile code when necessary
- Document performance requirements
- Regular performance testing

## Error Handling

Following our `.clinerules` standards:
```python
try:
    result = process_data(input_data)
except ValidationError as e:
    logger.error(f"Data validation failed: {e.details}")
    raise BusinessError("Invalid input format", context=e.details)
except ProcessingError as e:
    logger.error(f"Processing failed: {e}")
    raise
```

## Performance Considerations

Following our `.clinerules` standards:
```python
# Performance notes:
# - Current implementation: O(n log n)
# - Memory usage: O(n)
# - Benchmarked with 1M records: 1.2s processing time
# - Alternative approaches considered:
#   * Hash-based: O(n) time but O(n) space
#   * Stream processing: O(n) time but higher latency
```

## Support

- Join our Discord community
- Check existing issues before creating new ones
- Provide detailed information when reporting issues
- Help others in the community

Remember to always test your changes thoroughly before submitting them for review.
