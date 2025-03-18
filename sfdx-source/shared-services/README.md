# Shared Services Package

This package provides core cross-cutting utility services and objects that are used by all other packages in the enterprise application. It's designed to be a dependency for all other packages.

## Key Components

### Custom Objects

- **IntegrationLog__c** - Records integration events with external systems
- **BatchProcessControl__c** - Controls batch process execution throughout the org
- **ErrorLog__c** - Tracks errors that occur in the system

### Platform Events

- **EnterpriseEvent__e** - Generic platform event for cross-package communication
  - Uses category, event name, and payload pattern for flexible routing

### Services

- **EventPublisher** - Central service for publishing enterprise events
- **LoggingService** - Provides standardized logging capabilities
- **BatchProcessManager** - Controls batch processes based on configuration

### Extension Points

This package provides several extension points for other packages:

1. **Platform Event Distribution** - Other packages can subscribe to events using Custom Metadata
2. **Custom Selector methods** - Base selectors can be extended by other packages 

## Usage Guidelines

### Event Publishing

To publish an event from any package:

```java
// Publish an event
EventPublisher.publish(
    'Account',                   // Category
    'ACCOUNT_UPDATED',           // Event name
    new Map<String, Object> {    // Payload
        'accountId' => accountId,
        'fields' => changedFields
    }
);
```

### Event Subscription

To subscribe to events, create a subclass of EnterpriseEventConsumer and register it via Custom Metadata:

```java
public class MyAccountEventConsumer extends EnterpriseEventConsumer {
    public override void runInProcess() {
        for (SObject sobj : events) {
            EnterpriseEvent__e evt = (EnterpriseEvent__e) sobj;
            
            if (verifyEvent(evt, 'Account', 'ACCOUNT_UPDATED')) {
                Map<String, Object> payload = (Map<String, Object>)getPayloadAs(evt, Map<String, Object>.class);
                processAccountUpdate((Id)payload.get('accountId'), (List<String>)payload.get('fields'));
            }
        }
    }
    
    private void processAccountUpdate(Id accountId, List<String> changedFields) {
        // Process the account update
    }
}
```

Then register with Custom Metadata:

```xml
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>My Account Event Consumer</label>
    <values>
        <field>Consumer__c</field>
        <value>MyAccountEventConsumer</value>
    </values>
    <field>EventBus__c</field>
    <value>EnterpriseEvent__e</value>
    </values>
    <values>
        <field>EventCategory__c</field>
        <value>Account</value>
    </values>
    <values>
        <field>Event__c</field>
        <value>ACCOUNT_UPDATED</value>
    </values>
    <values>
        <field>MatcherRule__c</field>
        <value>MatchEventBusAndCategoryAndEventName</value>
    </values>
</CustomMetadata>
```

### Error Logging

For standardized error logging:

```java
try {
    // Some operation that might fail
} catch (Exception ex) {
    LoggingService.logError('MyClass.myMethod', ex);
}
```

### Batch Process Management

Control batch processes with configuration:

```java
public class MyBatchProcess implements Database.Batchable<SObject> {
    // Batch implementation...
    
    // To execute:
    public static void execute() {
        BatchProcessManager.executeBatchIfActive(new MyBatchProcess(), 'MyBatchProcess');
    }
}
```

## Testing

When testing components that depend on this package:

1. Mock the EventPublisher for testing event publications
2. Create test implementations of EnterpriseEventConsumer for testing event handling
3. Use dependency injection to mock selectors and services

## Dependencies

This package has no package dependencies but requires:

- fflib-apex-common
- fflib-apex-mocks
- AT4DX Framework
