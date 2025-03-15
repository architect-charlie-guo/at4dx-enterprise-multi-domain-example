/**
 * @description Event consumer for Product events in the Sales package
 * Demonstrates cross-package integration using AT4DX platform events
 */
public with sharing class SalesProductEventConsumer extends EnterpriseEventConsumer {
    
    /**
     * @description Process the events
     * This method is called by the PlatformEventDistributor
     */
    public override void runInProcess() {
        for (SObject sobj : events) {
            EnterpriseEvent__e evt = (EnterpriseEvent__e) sobj;
            
            try {
                // Handle different types of product events
                if (verifyEvent(evt, 'Product', 'PRODUCT_CREATED')) {
                    handleProductCreated(evt);
                } else if (verifyEvent(evt, 'Product', 'PRODUCT_UPDATED')) {
                    handleProductUpdated(evt);
                } else if (verifyEvent(evt, 'Product', 'PRODUCTS_DEACTIVATED')) {
                    handleProductsDeactivated(evt);
                } else if (verifyEvent(evt, 'Product', 'PRICEBOOK_ENTRY_CREATED') || 
                           verifyEvent(evt, 'Product', 'PRICEBOOK_ENTRY_UPDATED')) {
                    handlePricebookEntryEvent(evt);
                }
            } catch (Exception ex) {
                logEventError(evt, ex);
            }
        }
    }
    
    /**
     * @description Handle the PRODUCT_CREATED event
     * @param evt The event
     */
    private void handleProductCreated(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id productId = (Id) payload.get('productId');
        String productName = (String) payload.get('productName');
        String productCode = (String) payload.get('productCode');
        
        // Log the event
        System.debug('Sales package received PRODUCT_CREATED event for product: ' + productName);
        
        // In a real implementation, we might update product catalogs or create default price book entries
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Product Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed product creation event'
        );
    }
    
    /**
     * @description Handle the PRODUCT_UPDATED event
     * @param evt The event
     */
    private void handleProductUpdated(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id productId = (Id) payload.get('productId');
        List<String> updatedFields = (List<String>) payload.get('fields');
        
        // Log the event
        System.debug('Sales package received PRODUCT_UPDATED event for product ID: ' + productId);
        System.debug('Updated fields: ' + updatedFields);
        
        // In a real implementation, we might need to update opportunity line items
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Product Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed product update event'
        );
    }
    
    /**
     * @description Handle the PRODUCTS_DEACTIVATED event
     * @param evt The event
     */
    private void handleProductsDeactivated(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        List<Id> productIds = (List<Id>) payload.get('productIds');
        
        // Log the event
        System.debug('Sales package received PRODUCTS_DEACTIVATED event');
        System.debug('Deactivated products: ' + productIds);
        
        // In a real implementation, we might need to update open opportunities with these products
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Product Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed products deactivated event'
        );
    }
    
    /**
     * @description Handle price book entry events
     * @param evt The event
     */
    private void handlePricebookEntryEvent(EnterpriseEvent__e evt) {
        // Parse the payload
        Map<String, Object> payload = (Map<String, Object>) getPayloadAs(evt, Map<String, Object>.class);
        Id productId = (Id) payload.get('productId');
        Id pricebookId = (Id) payload.get('pricebookId');
        Id pricebookEntryId = (Id) payload.get('pricebookEntryId');
        Decimal unitPrice = (Decimal) payload.get('unitPrice');
        
        // Log the event
        System.debug('Sales package received ' + evt.EventName__c + ' event');
        System.debug('Product ID: ' + productId + ', Price: ' + unitPrice);
        
        // In a real implementation, we might need to update opportunity line items
        // For demonstration purposes, we'll just log the event
        LoggingService.logIntegration(
            'Sales-Product Integration',
            'Inbound',
            JSON.serialize(payload),
            'Success',
            'Sales package processed price book entry event'
        );
    }
}