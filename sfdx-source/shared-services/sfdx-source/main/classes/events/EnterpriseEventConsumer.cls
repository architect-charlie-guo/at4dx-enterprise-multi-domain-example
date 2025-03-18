/**
 * @description Base class for all Enterprise Event consumers
 * Extends the AT4DX PlatformEventAbstractConsumer for our enterprise-specific event handling
 */
public abstract class EnterpriseEventConsumer extends PlatformEventAbstractConsumer {
    
    /**
     * @description Get the payload from an event as a specific type
     * @param event The EnterpriseEvent__e record
     * @param type The Apex type to deserialize to
     * @return Object The deserialized payload
     */
    protected Object getPayloadAs(EnterpriseEvent__e event, Type type) {
        return JSON.deserialize(event.Payload__c, type);
    }
    
    /**
     * @description Log an event processing error
     * @param event The event that caused the error
     * @param ex The exception that was thrown
     */
    protected void logEventError(EnterpriseEvent__e event, Exception ex) {
        String context = 'Event Consumer: ' + this.getClass().getName();
        String message = 'Error processing event ' + event.Category__c + '.' + event.EventName__c;
        
        LoggingService.logError(context, message, ex.getStackTraceString());
    }
    
    /**
     * @description Verify an event matches expected category and name
     * @param event The event to check
     * @param expectedCategory The expected category
     * @param expectedEventName The expected event name
     * @return Boolean True if the event matches
     */
    protected Boolean verifyEvent(EnterpriseEvent__e event, String expectedCategory, String expectedEventName) {
        return event.Category__c == expectedCategory && event.EventName__c == expectedEventName;
    }
}