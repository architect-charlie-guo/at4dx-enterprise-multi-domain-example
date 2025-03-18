/**
 * @description Domain class for Product2 SObject
 * Implements the business logic for the Product object
 */
public with sharing class Products extends ApplicationSObjectDomain implements IProducts {
    
    /**
     * @description Constructor
     * @param records Product2 records
     */
    public Products(List<Product2> records) {
        super(records);
    }
    
    /**
     * @description AT4DX constructor binding implementation
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new Products((List<Product2>) records);
        }
    }
    
    /**
     * @description Sets up the domain configuration
     * @return fflib_SObjectDomain.Configuration Configuration for the domain
     */
    public override fflib_SObjectDomain.Configuration configuration() {
        return Configuration.newInstance()
            .enableTriggerEvents()
            .enableDomainProcessInjection();
    }
    
    /**
     * @description Handles the onBeforeInsert trigger event
     */
    public override void onBeforeInsert() {
        setDefaults();
        validate();
        calculateDerivedFields();
    }
    
    /**
     * @description Handles the onBeforeUpdate trigger event
     * @param existingRecords Map of existing product records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validate();
        calculateDerivedFields();
    }
    
    /**
     * @description Handles the onAfterInsert trigger event
     */
    public override void onAfterInsert() {
        publishProductChangeEvents();
    }
    
    /**
     * @description Handles the onAfterUpdate trigger event
     * @param existingRecords Map of existing product records
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        publishProductChangeEvents();
    }
    
    /**
     * @description Set default values for newly created products
     */
    public void setDefaults() {
        for (Product2 product : (List<Product2>) Records) {
            if (product.IsActive == null) {
                product.IsActive = false;
            }
            
            if (product.QuantityUnitOfMeasure == null) {
                product.QuantityUnitOfMeasure = 'Each';
            }
        }
    }
    
    /**
     * @description Validate product data before insert or update
     */
    public void validate() {
        for (Product2 product : (List<Product2>) Records) {
            // Ensure product code is not empty
            if (String.isBlank(product.ProductCode)) {
                product.ProductCode.addError('Product Code is required');
            }
            
            // Validate product name is not too long
            if (product.Name != null && product.Name.length() > 100) {
                product.Name.addError('Product Name must be 100 characters or less');
            }
            
            // Validate that active products have a description
            if (product.IsActive && String.isBlank(product.Description)) {
                product.Description.addError('Active products must have a description');
            }
        }
    }
    
    /**
     * @description Calculate and set derived fields for products
     */
    public void calculateDerivedFields() {
        for (Product2 product : (List<Product2>) Records) {
            // Example: Generate display name if not set
            if (String.isBlank(product.DisplayUrl)) {
                product.DisplayUrl = '/product/' + product.ProductCode;
            }
            
            // Example: Set family-based defaults
            if (product.Family == 'Hardware' && product.QuantityUnitOfMeasure == null) {
                product.QuantityUnitOfMeasure = 'Each';
            } else if (product.Family == 'Software' && product.QuantityUnitOfMeasure == null) {
                product.QuantityUnitOfMeasure = 'License';
            }
        }
    }
    
    /**
     * @description Publish events for product changes
     */
    public void publishProductChangeEvents() {
        Set<Id> productIds = new Set<Id>();
        Set<String> changedFields = new Set<String>();
        
        for (Product2 product : (List<Product2>) Records) {
            productIds.add(product.Id);
            // In a real implementation, we'd also track which fields changed
        }
        
        // Call the event publisher to publish the events
        EventPublisher.publish(
            'Product', 
            'PRODUCT_UPDATED',
            new Map<String, Object> {
                'productIds' => productIds,
                'fields' => new List<String>(changedFields)
            }
        );
    }
    
    /**
     * @description Handle product activation/deactivation
     * @param productIds Set of product IDs
     * @param isActive Whether to activate or deactivate
     */
    public void setProductActiveStatus(Set<Id> productIds, Boolean isActive) {
        // This would typically be called from a service layer
        List<Product2> productsToUpdate = new List<Product2>();
        
        for (Product2 product : (List<Product2>) Records) {
            if (productIds.contains(product.Id) && product.IsActive != isActive) {
                product.IsActive = isActive;
                productsToUpdate.add(product);
            }
        }
        
        if (!productsToUpdate.isEmpty()) {
            // Get a Unit of Work instance
            IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            
            // Register the products to update
            for (Product2 product : productsToUpdate) {
                uow.registerDirty(product);
            }
            
            // Commit the work
            uow.commitWork();
            
            // Publish an event about the status change
            EventPublisher.publish(
                'Product',
                isActive ? 'PRODUCTS_ACTIVATED' : 'PRODUCTS_DEACTIVATED',
                new Map<String, Object> {
                    'productIds' => productIds
                }
            );
        }
    }
}