# Contributing

## Development Workflow

1. **Fork and Clone**
   ```bash
   git clone <your-fork>
   cd Azure-hubspoke-landingzone
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow Terraform best practices
   - Update documentation if needed
   - Test changes locally

4. **Validate Code**
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan -var-file="terraform-enterprise.tfvars"
   ```

5. **Submit Pull Request**
   - Clear description of changes
   - Reference any related issues
   - Ensure CI passes

## Code Standards

- Use consistent naming conventions
- Pin provider versions in `versions.tf`
- Include variable descriptions and validation
- Tag all resources consistently
- Follow security best practices

## Testing

- All changes must pass `terraform validate`
- Test with `terraform plan` before submitting
- Include integration tests for new modules

## Documentation

- Update README.md for user-facing changes
- Document new variables and outputs
- Include examples for complex configurations