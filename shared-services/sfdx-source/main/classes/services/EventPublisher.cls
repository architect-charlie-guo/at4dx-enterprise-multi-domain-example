/**
 * @description Service class that provides methods for publishing enterprise events
 * This class is the central point for all event publishing in the application
 */
public with sharing class EventPublisher {
    
    /**
     * @description Publishes an enterprise event
     * @param category The category of the event (e.g., Account, Opportunity)
     * @param eventName The specific event name (e.g., CREATED, UPDATED)
     * @param payload The event payload as a serializable object
     * @return Id The ID of the published event
     */
    public static Id publish(String category, String eventName, Object payload) {
        // Create a new enterprise event
        EnterpriseEvent__e event = new EnterpriseEvent__e(
            Category__c = category,
            EventName__c = eventName,
            Payload__c = JSON.serialize(payload)
        );
        
        // Publish the event
        Database.SaveResult result = EventBus.publish(event);
        
        // Log errors if the event failed to publish
        if (!result.isSuccess()) {
            logEventError(category, eventName, result.getErrors());
            return null;
        }
        
        return result.getId();
    }
    
    /**
     * @description Log errors that occur when publishing events
     * @param category The event category
     * @param eventName The event name
     * @param errors The errors that occurred
     */
    private static void logEventError(String category, String eventName, List<Database.Error> errors) {
        ErrorLog__c log = new ErrorLog__c(
            Context__c = 'Event Publishing: ' + category + '.' + eventName,
            Message__c = 'Failed to publish event'
        );
        
        String stackTrace = '';
        for (Database.Error error : errors) {
            stackTrace += 'Error: ' + error.getStatusCode() + ' - ' + error.getMessage() + '\n';
        }
        log.StackTrace__c = stackTrace;
        
        insert log;
    }
}