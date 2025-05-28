# Contributing to IaC Module Library for Azure

Thank you for your interest in contributing to our Infrastructure as Code (IaC) module library! This guide will help you understand how to contribute effectively to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Development Guidelines](#module-development-guidelines)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.30.0
- [Git](https://git-scm.com/downloads)
- An Azure subscription for testing

### Environment Setup

1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/your-username/iac-module-library-azure.git
   cd iac-module-library-azure
   ```

2. **Install Dependencies**
   ```bash
   # Install Terraform (Windows)
   winget install HashiCorp.Terraform
   
   # Install Azure CLI (Windows)
   winget install Microsoft.AzureCLI
   ```

3. **Azure Authentication**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

4. **Set Up Pre-commit Hooks** (Optional but recommended)
   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Development Workflow

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch for new features
- `feature/*`: Feature development branches
- `bugfix/*`: Bug fix branches
- `hotfix/*`: Critical fixes for production

### Creating a Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

## Module Development Guidelines

### Module Structure

Each module should follow this structure:

```
modules/
├── module-name/
│   ├── main.tf          # Main resource definitions
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   ├── versions.tf      # Provider requirements
│   ├── README.md        # Module documentation
│   └── examples/        # Usage examples
│       └── basic/
│           ├── main.tf
│           └── README.md
```

### Terraform Best Practices

1. **Resource Naming**
   - Use descriptive resource names
   - Follow Azure naming conventions
   - Use consistent naming patterns across modules

2. **Variables**
   - Include comprehensive descriptions
   - Add validation rules where appropriate
   - Use appropriate default values
   - Mark sensitive variables as `sensitive = true`

3. **Outputs**
   - Provide all relevant resource attributes
   - Include descriptions for all outputs
   - Mark sensitive outputs as `sensitive = true`

4. **Code Style**
   - Follow [Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
   - Use `terraform fmt` to format code
   - Run `terraform validate` before committing

### Example Variable Definition

```hcl
variable "name" {
  description = "Name of the resource (must be unique within resource group)"
  type        = string
  
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 80
    error_message = "Name must be between 1 and 80 characters."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
```

### Security Guidelines

1. **Sensitive Data**
   - Never hardcode secrets in Terraform files
   - Use Azure Key Vault for secrets management
   - Mark sensitive outputs appropriately

2. **Network Security**
   - Implement network isolation by default
   - Use private endpoints where applicable
   - Follow principle of least privilege

3. **Access Control**
   - Use managed identities when possible
   - Implement RBAC with minimal required permissions
   - Document required permissions in README

## Testing Requirements

### Validation Tests

All modules must pass the following validation tests:

```bash
# Format check
terraform fmt -check -recursive

# Validation check
terraform validate

# Security scan (if available)
tfsec .
```

### Integration Tests

1. **Basic Deployment Test**
   - Deploy module with minimal configuration
   - Verify all outputs are correct
   - Clean up resources

2. **Advanced Configuration Test**
   - Deploy with complex configuration
   - Test all optional parameters
   - Verify integration between resources

### Testing Checklist

- [ ] Module validates successfully
- [ ] All examples deploy without errors
- [ ] No security issues identified
- [ ] Documentation is accurate and complete
- [ ] Outputs match expected values
- [ ] Resources are properly tagged
- [ ] Clean-up completes successfully

## Documentation Standards

### Module README

Each module must include a comprehensive README with:

1. **Description**: Clear explanation of what the module does
2. **Features**: List of key capabilities
3. **Usage Examples**: Multiple examples from basic to advanced
4. **Requirements**: Terraform and provider version requirements
5. **Inputs**: Table of all input variables
6. **Outputs**: Table of all outputs
7. **Best Practices**: Security and cost optimization tips

### Code Comments

- Use meaningful comments for complex logic
- Document any Azure-specific limitations or requirements
- Include links to Azure documentation where relevant

### Changelog

Update `CHANGELOG.md` for all changes:

```markdown
## [1.2.0] - 2024-01-15
### Added
- Support for private endpoints in storage account module
- New validation rules for resource naming

### Changed
- Updated azurerm provider requirement to >= 3.50.0

### Fixed
- Issue with network rule configuration in storage module
```

## Pull Request Process

### Before Submitting

1. **Code Quality**
   - [ ] Code is formatted (`terraform fmt`)
   - [ ] Code validates (`terraform validate`)
   - [ ] No security issues (`tfsec`)
   - [ ] Documentation is updated

2. **Testing**
   - [ ] All existing tests pass
   - [ ] New functionality is tested
   - [ ] Examples work correctly

3. **Documentation**
   - [ ] README is updated
   - [ ] Changelog is updated
   - [ ] Commit messages are clear

### PR Template

Use this template for pull requests:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Terraform validate passes
- [ ] Examples deploy successfully
- [ ] Security scan passes

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Tests are added/updated
- [ ] Changelog is updated
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Code Review**: At least one maintainer reviews the code
3. **Testing**: Changes are tested in development environment
4. **Approval**: Approved by project maintainer
5. **Merge**: Squash and merge to target branch

## Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Prepare Release**
   - Update version numbers
   - Update changelog
   - Create release branch

2. **Testing**
   - Full integration testing
   - Documentation review
   - Security scan

3. **Release**
   - Create GitHub release
   - Tag version
   - Update main branch

## Getting Help

### Resources

- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)

### Support Channels

- **Issues**: Create GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Documentation**: Check existing documentation and examples

### Questions?

If you have questions about contributing, please:

1. Check existing documentation and issues
2. Search GitHub Discussions
3. Create a new discussion or issue
4. Contact project maintainers

Thank you for contributing to our IaC module library!
