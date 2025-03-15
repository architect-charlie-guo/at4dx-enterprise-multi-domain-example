/**
 * @description Service for centralized logging throughout the application
 * Provides methods for logging errors, integration events, and application events
 */
public with sharing class LoggingService {
    
    /**
     * @description Log an error
     * @param context The context in which the error occurred
     * @param message The error message
     * @param stackTrace The stack trace (optional)
     */
    public static void logError(String context, String message, String stackTrace) {
        ErrorLog__c errorLog = new ErrorLog__c(
            Context__c = context,
            Message__c = message,
            StackTrace__c = stackTrace
        );
        
        insert errorLog;
    }
    
    /**
     * @description Log an error from an exception
     * @param context The context in which the error occurred
     * @param ex The exception that was thrown
     */
    public static void logError(String context, Exception ex) {
        ErrorLog__c errorLog = new ErrorLog__c(
            Context__c = context,
            Message__c = ex.getMessage(),
            StackTrace__c = ex.getStackTraceString()
        );
        
        insert errorLog;
    }
    
    /**
     * @description Log an integration
     * @param system The external system
     * @param direction Inbound or Outbound
     * @param payload The data payload
     * @param status The status of the integration
     * @param errorMessage Error message if applicable
     * @return IntegrationLog__c The created log record
     */
    public static IntegrationLog__c logIntegration(
        String system, 
        String direction, 
        String payload, 
        String status, 
        String errorMessage
    ) {
        IntegrationLog__c integrationLog = new IntegrationLog__c(
            System__c = system,
            Direction__c = direction,
            Payload__c = payload,
            Status__c = status,
            ErrorMessage__c = errorMessage
        );
        
        insert integrationLog;
        return integrationLog;
    }
    
    /**
     * @description Update an existing integration log
     * @param logId The ID of the log to update
     * @param status The new status
     * @param errorMessage Error message if applicable
     * @return IntegrationLog__c The updated log record
     */
    public static IntegrationLog__c updateIntegrationLog(
        Id logId,
        String status,
        String errorMessage
    ) {
        IntegrationLog__c log = new IntegrationLog__c(
            Id = logId,
            Status__c = status,
            ErrorMessage__c = errorMessage
        );
        
        update log;
        return log;
    }
}