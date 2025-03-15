# AT4DX Enterprise Example

This project demonstrates a sophisticated enterprise implementation of Salesforce development using the [AT4DX framework](https://github.com/apex-enterprise-patterns/at4dx). It showcases how to build a modular, loosely-coupled architecture across multiple business domains using unlocked packages.

## Architecture Overview

The implementation spans multiple business domains, each implemented as a separate 2nd generation package:

1. **Shared Services** - Core utilities and cross-cutting concerns
2. **Account Management** - Customer master data and account relationships
3. **Product Management** - Product catalog and product master data
4. **Marketing** - Campaign management and customer segmentation
5. **Sales** - Opportunity management and sales processes
6. **Service** - Case management and customer support
7. **Operations** - Order fulfillment and supply chain
8. **Finance** - Billing, invoicing, and financial operations
9. **Legal** - Contract management and compliance

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
SharedServices
    ↑
    ├── AccountManagement
    │       ↑
    │       ├── Marketing
    │       ├── Legal
    │       │
    │       └── Sales ← Finance
    │             ↑
    │             └── Operations
    │
    └── ProductManagement
            ↑
            ├── Sales
            └── Service
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
   git clone https://github.com/yourusername/at4dx-enterprise-example.git
   cd at4dx-enterprise-example
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
   sf project deploy start -d deps/fflib-apex-common
   
   # Install fflib-apex-mocks
   sf project deploy start -d deps/fflib-apex-mocks
   
   # Install force-di
   sf project deploy start -d deps/force-di
   
   # Install AT4DX core
   sf project deploy start -d deps/at4dx
   ```

5. Deploy the packages in dependency order:
   ```bash
   # Deploy Shared Services
   sf project deploy start -d shared-services
   
   # Deploy Account Management
   sf project deploy start -d account-management
   
   # Deploy Product Management
   sf project deploy start -d product-management
   
   # Deploy Marketing
   sf project deploy start -d marketing
   
   # Deploy Sales
   sf project deploy start -d sales
   
   # Deploy Service
   sf project deploy start -d service
   
   # Deploy Operations
   sf project deploy start -d operations
   
   # Deploy Finance
   sf project deploy start -d finance
   
   # Deploy Legal
   sf project deploy start -d legal
   
   # Deploy happy soup components
   sf project deploy start -d happysoup
   ```

## Project Structure

```
at4dx-enterprise-example/
├── shared-services/               # Core utilities and cross-cutting concerns
├── account-management/            # Account domain implementation
├── product-management/            # Product domain implementation
├── marketing/                     # Marketing extension package
├── sales/                         # Sales package
├── service/                       # Service package
├── operations/                    # Operations package
├── finance/                       # Finance package
├── legal/                         # Legal package
├── happysoup/                     # Non-packageable components
├── deps/                          # Dependencies
├── scripts/                       # Deployment scripts
└── config/                        # Configuration files
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

## Conclusion

This implementation demonstrates how AT4DX enables true modular development in Salesforce. By leveraging patterns like domain process injection, platform events, and selector field injection, teams can work independently while still creating a cohesive application.

The architecture shown here can scale to support large enterprise implementations with multiple teams, complex business logic, and evolving requirements—all while maintaining clean separation of concerns and reducing the risk of changes.
