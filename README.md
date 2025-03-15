**Disclaimer:** This is a work-in-progress *Hello World* application generated by Anthropic Sonnet 3.7, accompanied by an [AT4DX document](https://github.com/architect-charlie-guo/sample-modular-application-with-at4dx/blob/main/docs/Advanced-Techniques-for-DX.md) created by OpenAI o1 pro. My goal is to explore the capabilities of AI models in understanding frameworks and generating code using them. Please use with caution, and I welcome any feedback on potential inaccuracies or hallucinations. -- [Charlie](https://www.linkedin.com/in/charlieguo/)

# AT4DX Enterprise Multi-Domain Example

This project demonstrates a sophisticated enterprise implementation of Salesforce development using the [AT4DX framework](https://github.com/apex-enterprise-patterns/at4dx). It showcases how to build a modular, loosely-coupled architecture across multiple business domains using unlocked packages.

## Architecture Overview

The implementation spans multiple business domains, each implemented as a separate 2nd generation package:

1. **Shared Services** (`AT4DX-SharedServices`) - Core utilities and cross-cutting concerns
2. **Account Management** (`AT4DX-AccountManagement`) - Customer master data and account relationships
3. **Product Management** (`AT4DX-ProductManagement`) - Product catalog and product master data
4. **Marketing** (`AT4DX-Marketing`) - Campaign management and customer segmentation
5. **Sales** (`AT4DX-Sales`) - Opportunity management and sales processes

Plus a "happy soup" directory for components that can't be packaged or span multiple packages.

## Key AT4DX Patterns Demonstrated

This implementation showcases the key patterns that make AT4DX powerful for enterprise development:

### 1. Domain Process Injection

The Marketing package injects behavior into the Account domain without modifying the Account code:

- `HighValueAccountCriteria` - Identifies accounts with revenue > $1M
- `AssignMarketingSegmentAction` - Assigns marketing segments to high-value accounts
- Custom metadata bindings connect these to Account trigger events

This pattern enables true modularity where different teams can extend object behavior without coordinating code changes.

### 2. Platform Event Distribution

The Sales package listens for events from both Account and Product packages:

- `SalesAccountEventConsumer` - Processes account-related events
- `SalesProductEventConsumer` - Processes product-related events
- Custom metadata bindings subscribe these to specific event categories

This pattern enables loose coupling between packages, where interaction happens through events rather than direct references.

### 3. Selector Field Injection

The Marketing package extends Account queries from any package:

- `MarketingFields` fieldset defines the fields needed by Marketing
- `SelectorConfig_FieldSetInclusion` metadata connects this to Account queries
- Account selectors automatically include these fields in all queries

This pattern allows packages to ensure their fields are available without modifying selector code.

### 4. Application Factory Injection

All packages use dependency injection for creating domain, selector, and service instances:

- `ApplicationFactory_DomainBinding` - Maps SObjects to domain classes
- `ApplicationFactory_SelectorBinding` - Maps SObjects to selector classes
- `ApplicationFactory_ServiceBinding` - Maps interfaces to service implementations
- `ApplicationFactory_UnitOfWorkBinding` - Configures Unit of Work registration

This pattern provides a consistent approach to object creation while enabling substitution for testing.

## Package Dependencies

```
AT4DX-SharedServices
    ↑
    ├── AT4DX-AccountManagement
    │       ↑
    │       ├── AT4DX-Marketing
    │       │
    │       └── AT4DX-Sales ←
    │
    └── AT4DX-ProductManagement
            ↑
            └── AT4DX-Sales
```

## Setup Instructions

### Prerequisites

- Salesforce CLI
- DevHub org with packages enabled
- fflib-apex-common and fflib-apex-mocks
- force-di
- AT4DX core framework

### Deployment

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/at4dx-enterprise-multi-domain-example.git
   cd at4dx-enterprise-multi-domain-example
   ```

2. Authorize your DevHub:
   ```bash
   sf org login web -d
   ```

3. Create a scratch org:
   ```bash
   sf org create scratch -f config/project-scratch-def.json -a at4dx-enterprise
   ```

4. Install prerequisites:
   ```bash
   # Install fflib-apex-common
   sf project deploy start -d deps/fflib-apex-common -o scratch-org
   
   # Install fflib-apex-mocks
   sf project deploy start -d deps/fflib-apex-mocks -o scratch-org
   
   # Install force-di
   sf project deploy start -d deps/force-di -o scratch-org
   
   # Install AT4DX core
   sf project deploy start -d deps/at4dx -o scratch-org
   ```

5. Deploy the packages in dependency order using the deployment script:
   ```bash
   ./scripts/deploy-packages.sh --all
   ```

### Creating Package Versions

To create versioned packages for distribution:

```bash
# Create shared-services package version
sf package version create -p "AT4DX-SharedServices" -w 60 -v DevHub --skip-validation

# Create account-management package version
sf package version create -p "AT4DX-AccountManagement" -w 60 -v DevHub --skip-validation

# Create product-management package version
sf package version create -p "AT4DX-ProductManagement" -w 60 -v DevHub --skip-validation

# Create marketing package version
sf package version create -p "AT4DX-Marketing" -w 60 -v DevHub --skip-validation

# Create sales package version
sf package version create -p "AT4DX-Sales" -w 60 -v DevHub --skip-validation
```

## Project Structure

```
at4dx-enterprise-multi-domain-example/
├── shared-services/               # Core utilities and cross-cutting concerns
├── account-management/            # Account domain implementation
├── product-management/            # Product domain implementation
├── marketing/                     # Marketing extension package
├── sales/                         # Sales package
├── happy-soup/                    # Non-packageable components
├── deps/                          # Dependencies
├── scripts/                       # Deployment scripts
├── config/                        # Configuration files
└── .github/                       # GitHub Actions workflows
```

## Development Guidelines

### Adding New Features

1. Identify which package the feature belongs in
2. Create appropriate domain, selector, and service classes
3. Register classes via Custom Metadata
4. For cross-package interaction, use events or domain process injection
5. Run tests to ensure all integrations work correctly

### Making Cross-Package Changes

1. Identify all affected packages
2. Update the lower-level packages first
3. Use platform events for communication where possible
4. Update consuming packages to handle any changes
5. Deploy packages in dependency order

## CI/CD Integration

This project includes GitHub Actions workflows for continuous integration:

- **Automated deployment**: Changes to package directories trigger deployment of those packages and their dependencies
- **Package creation**: Changes to the main branch trigger creation of new package versions
- **Automated testing**: Tests are run automatically after deployment

## Conclusion

This implementation demonstrates how AT4DX enables true modular development in Salesforce. By leveraging patterns like domain process injection, platform events, and selector field injection, teams can work independently while still creating a cohesive application.

The architecture shown here can scale to support large enterprise implementations with multiple teams, complex business logic, and evolving requirements—all while maintaining clean separation of concerns and reducing the risk of changes.
