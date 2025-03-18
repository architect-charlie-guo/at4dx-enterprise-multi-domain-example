# Marketing Package

This package demonstrates how AT4DX enables cross-package customization without direct dependencies. It extends the Account Management package by injecting marketing-specific behavior into Account objects.

## Key Components

### Domain Process Injection

This package demonstrates the Domain Process Injection pattern with two key components:

1. **HighValueAccountCriteria** - Criteria class that identifies high-value accounts (revenue > $1M)
2. **AssignMarketingSegmentAction** - Action class that assigns marketing segments to accounts

These are injected into the Account domain via Custom Metadata:

- `DomainProcessBinding.HighValueAccountCriteria` - Binds the criteria to Account triggers
- `DomainProcessBinding.AssignMarketingSegmentAction` - Binds the action to Account triggers

This allows the Marketing package to extend Account behavior without modifying the Account domain class in the Account Management package.

### Selector Field Injection

This package demonstrates the Selector Field Injection pattern by:

1. Adding a field set `MarketingFields` to the Account object
2. Registering it via `SelectorConfig_FieldSetInclusion.AccountMarketingFields`

This ensures that when any package queries Accounts using the Account selector, the marketing fields are included automatically.

## How It Works

### Domain Process Injection Flow

1. When an Account is updated (After Update trigger):
   - The `HighValueAccountCriteria` executes and identifies accounts with revenue > $1M
   - For qualifying accounts, the `AssignMarketingSegmentAction` assigns a marketing segment
   - The segment is stored in the Description field (in a real implementation, it would use a custom field)

### Selector Field Injection Flow

1. The `MarketingFields` field set defines which fields the Marketing package needs included
2. The `SelectorConfig_FieldSetInclusion` metadata binds this field set to the Account SObject
3. The AT4DX framework automatically adds these fields to all Account queries that use the selector

## Usage Examples

### Querying Accounts with Marketing Fields

```java
// From any package:
IAccountsSelector accountsSelector = AccountsSelector.newInstance();

// The query will automatically include marketing fields
List<Account> accounts = accountsSelector.selectByType(
    new Set<String>{'Customer'}, 
    10
);

// We can now access marketing-related fields
for (Account account : accounts) {
    String description = account.Description;  // Contains marketing segment
    Decimal annualRevenue = account.AnnualRevenue;
}
```

## Cross-Package Integration

This package demonstrates the power of AT4DX for cross-package integration:

- No direct code dependencies between Marketing and Account Management packages
- All integration is done through configuration (Custom Metadata)
- Changes to marketing logic can be deployed without modifying the Account Management package
- Account Management package can be upgraded independently

## Dependencies

This package depends on:

- Shared Services Package
- Account Management Package
- fflib-apex-common
- fflib-apex-mocks
- AT4DX Framework
