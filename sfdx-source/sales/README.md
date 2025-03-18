# Sales Package

This package demonstrates cross-package integration through platform events in the AT4DX framework. It consumes events from both the Account Management and Product Management packages without requiring direct code dependencies.

## Key Components

### Event Consumers

- **SalesAccountEventConsumer** - Consumes Account-related events
- **SalesProductEventConsumer** - Consumes Product-related events

### Event Subscriptions

The package subscribes to events via Custom Metadata:

- `PlatformEvents_Subscription.SalesAccountEventConsumer` - Subscribes to all Account events
- `PlatformEvents_Subscription.SalesProductEventConsumer` - Subscribes to all Product events

## Events Consumed

### Account Events

| Event Name | Source Package | Description | Reaction |
|------------|---------------|------------|----------|
| ACCOUNT_CREATED | Account Management | New account created | Log integration event |
| ACCOUNT_UPDATED | Account Management | Account updated | Check for sales-relevant field changes |
| ACCOUNTS_MERGED | Account Management | Accounts merged | Process related sales data |

### Product Events

| Event Name | Source Package | Description | Reaction |
|------------|---------------|------------|----------|
| PRODUCT_CREATED | Product Management | New product created | Log integration event |
| PRODUCT_UPDATED | Product Management | Product updated | Check for impacts on opportunities |
| PRODUCTS_DEACTIVATED | Product Management | Products deactivated | Flag open opportunities with deactivated products |
| PRICEBOOK_ENTRY_CREATED | Product Management | Price added to product | Update opportunity line items |
| PRICEBOOK_ENTRY_UPDATED | Product Management | Price changed | Update opportunity line items |

## How It Works

### Event Flow

1. Account or Product events are published by their respective packages
2. The platform event trigger (`EnterpriseEvents`) fires
3. The `PlatformEventDistributor` routes events to the appropriate consumers
4. The Sales consumers process events based on their type and payload
5. Actions are taken in response to the events

## Cross-Package Integration Benefits

This implementation demonstrates several AT4DX advantages:

1. **Loose Coupling** - The Sales package doesn't directly reference classes from Account or Product packages
2. **Event-Driven Architecture** - Communication happens through events, not direct method calls
3. **Scalable Design** - New event types can be added without changing existing code
4. **Resilience** - Event consumers handle errors gracefully without impacting the source package
5. **Asynchronous Processing** - Events are processed asynchronously, preventing transaction limits

## Usage Example

In a real implementation, the Sales package would define its own domain objects (Opportunity, Quote, etc.) and respond to events by updating these objects:

```java
// Example of what would happen in a real implementation
private void handleProductsDeactivated(EnterpriseEvent__e evt) {
    Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
    List<Id> deactivatedProductIds = (List<Id>) payload.get('productIds');
    
    // Find open opportunities with these products
    List<OpportunityLineItem> affectedItems = [
        SELECT Id, OpportunityId 
        FROM OpportunityLineItem 
        WHERE Product2Id IN :deactivatedProductIds
        AND Opportunity.IsClosed = false
    ];
    
    // Notify opportunity owners
    for (OpportunityLineItem item : affectedItems) {
        // Create notification or task for opportunity owner
    }
}
```

## Dependencies

This package depends on:

- Shared Services Package
- Account Management Package
- Product Management Package
- fflib-apex-common
- fflib-apex-mocks
- AT4DX Framework
