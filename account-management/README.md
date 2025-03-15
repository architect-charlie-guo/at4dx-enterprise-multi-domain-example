# Account Management Package

This package provides the core Account domain implementation for the enterprise application. It's a foundation package that other packages depend on for customer-related functionality.

## Key Components

### Domain Layer

- **Accounts** - Domain class implementing business logic for Account objects
- **IAccounts** - Interface defining the Account domain contract

### Selector Layer 

- **AccountsSelector** - Selector for querying Account records
- **IAccountsSelector** - Interface defining the Account selector contract

### Service Layer

- **AccountsService** - Service providing business operations for Accounts
- **IAccountsService** - Interface defining the Account service contract

## Extension Points

The Account Management package provides several extension points for other packages:

1. **Domain Process Injection** - Other packages can inject behavior into Account domain operations
2. **Selector Field Injection** - Other packages can add fields to Account queries
3. **Event Publishing** - Other packages can subscribe to Account events

## Events Published

This package publishes the following events that other packages can subscribe to:

| Category | Event Name | Description | Payload |
|----------|------------|-------------|---------|
| Account | ACCOUNT_CREATED | Published when a new account is created | accountId, accountName |
| Account | ACCOUNT_UPDATED | Published when an account is updated | accountId, updatedFields |
| Account | ACCOUNTS_MERGED | Published when accounts are merged | masterAccountId, mergedAccountIds |
| Account | ACCOUNT_RATING_CHANGED | Published when an account's rating changes | accountId, newRating |
| Account | ACCOUNT_OWNERSHIP_CHANGED | Published when accounts change owner | accountIds, newOwnerId |

## Usage Examples

### Creating an Account

```java
// Get the accounts service
IAccountsService accountsService = (IAccountsService) Application.Service.newInstance(IAccountsService.class);

// Create a new account
Id newAccountId = accountsService.createAccount(
    'Acme Corporation',
    'Customer',
    'Technology'
);
```

### Querying Accounts

```java
// Get the accounts selector
IAccountsSelector accountsSelector = AccountsSelector.newInstance();

// Get accounts by type
List<Account> accounts = accountsSelector.selectByType(
    new Set<String>{'Customer', 'Partner'},
    100
);
```

### Updating an Account

```java
// Get the accounts service
IAccountsService accountsService = (IAccountsService) Application.Service.newInstance(IAccountsService.class);

// Update an account
accountsService.updateAccount(
    accountId,
    new Map<String, Object>{
        'Industry' => 'Healthcare',
        'Rating' => 'Hot',
        'Website' => 'https://acme.example.com'
    }
);
```

## Testing

When testing components that depend on this package:

1. Mock the AccountsSelector for testing account queries
2. Mock the AccountsService for testing account operations
3. Use dependency injection to replace implementations with test doubles

## Dependencies

This package depends on:

- Shared Services Package
- fflib-apex-common
- fflib-apex-mocks
- AT4DX Framework
