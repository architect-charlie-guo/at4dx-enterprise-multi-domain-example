# Happy Soup Components

This directory contains components that cannot be included in the modular packages for various reasons. These might include:

1. Components that inherently span multiple domains
2. Standard object customizations that have circular dependencies
3. Components that need to be deployed last to avoid validation errors
4. Components that require special permissions during deployment

In a true AT4DX implementation, you should strive to minimize the components in this directory and keep as much as possible within the structured packages.

## What's Included

- **Global custom fields**: Custom fields on standard objects that are used across multiple packages
- **Cross-domain processes**: Workflows, processes, or flows that span multiple domains
- **Permission set assignments**: Final permission assignments that need all packages deployed
- **Integration settings**: Settings for external system integrations that need to be aware of all packages

## Deployment Instructions

These components should always be deployed **after** all other packages:

```bash
# Deploy all packages first
./scripts/deploy-packages.sh --all

# Then deploy the happy soup components
sf project deploy start -d happysoup
```

## Best Practices

When adding components to the happy soup:

1. Document why they can't be included in a package
2. Note which packages depend on these components
3. Consider if redesigning could allow moving to a package
4. Keep these components to an absolute minimum
