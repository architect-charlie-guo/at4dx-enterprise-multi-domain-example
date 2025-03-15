/**
 * @description Event consumer for Account events in the Sales package
 * Demonstrates cross-package integration using AT4DX platform events
 */
public with sharing class SalesAccountEventConsumer extends EnterpriseEventConsumer {
    
    /**
     * @description Process the events
     * This method is called by the PlatformEventDistributor
     */
    public override void runInProcess() {
        for (SObject sobj : events) {
            EnterpriseEvent__e evt = (EnterpriseEvent__e) sobj;
            
            try {
                // Handle different types of account events
                if (verifyEvent(evt, 'Account', 'ACCOUNT_CREATED')) {
                    handleAccountCreated(evt);
                } else if (verifyEvent(evt, 'Account', 'ACCOUNT_UPDATED')) {
                    handleAccountUpdated(evt);
                } else if (verifyEvent(evt, 'Account', 'ACCOUNTS_MERGED')) {
                    handleAccountsMerged(evt);
                }
            } catch (Exception ex) {
                logEventError(evt, ex);
            }
        }
    }
    
    /**
     * @description Handle the ACCOUNT_CREATED event
     * @param evt The event
     */
    private void handleAccountCreated(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id accountId = (Id) payload.get('accountId');
        String accountName = (String) payload.get('accountName');
        
        // Log the event
        System.debug('Sales package received ACCOUNT_CREATED event for account: ' + accountName);
        
        // In a real implementation, we might create a default opportunity or update related sales data
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Account Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed account creation event'
        );
    }
    
    /**
     * @description Handle the ACCOUNT_UPDATED event
     * @param evt The event
     */
    private void handleAccountUpdated(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id accountId = (Id) payload.get('accountId');
        List<String> updatedFields = (List<String>) payload.get('updatedFields');
        
        // Log the event
        System.debug('Sales package received ACCOUNT_UPDATED event for account ID: ' + accountId);
        System.debug('Updated fields: ' + updatedFields);
        
        // In a real implementation, we might update related opportunities or sales forecasts
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Account Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed account update event'
        );
        
        // Check if important fields were updated that would affect opportunities
        Set<String> salesRelevantFields = new Set<String>{'Industry', 'AnnualRevenue', 'Rating'};
        Boolean salesRelevantFieldsChanged = false;
        
        for (String field : updatedFields) {
            if (salesRelevantFields.contains(field)) {
                salesRelevantFieldsChanged = true;
                break;
            }
        }
        
        if (salesRelevantFieldsChanged) {
            // In a real implementation, we might update opportunities or recalculate forecasts
            System.debug('Sales-relevant fields changed on account. Would update related sales data.');
        }
    }
    
    /**
     * @description Handle the ACCOUNTS_MERGED event
     * @param evt The event
     */
    private void handleAccountsMerged(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id masterAccountId = (Id) payload.get('masterAccountId');
        List<Id> mergedAccountIds = (List<Id>) payload.get('mergedAccountIds');
        
        // Log the event
        System.debug('Sales package received ACCOUNTS_MERGED event. Master account: ' + masterAccountId);
        System.debug('Merged accounts: ' + mergedAccountIds);
        
        // In a real implementation, we might need to update any orphaned opportunities
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Account Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed accounts merged event'
        );
    }
}