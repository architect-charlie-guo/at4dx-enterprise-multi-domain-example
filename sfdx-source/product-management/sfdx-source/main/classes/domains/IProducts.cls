/**
 * @description Interface for the Products domain class
 * Provides the contract for product-related business logic
 */
public interface IProducts extends IApplicationSObjectDomain {
    
    /**
     * @description Set default values for newly created products
     */
    void setDefaults();
    
    /**
     * @description Validate product data before insert or update
     */
    void validate();
    
    /**
     * @description Calculate and set derived fields for products
     */
    void calculateDerivedFields();
    
    /**
     * @description Publish events for product changes
     */
    void publishProductChangeEvents();
    
    /**
     * @description Handle product activation/deactivation
     * @param productIds Set of product IDs
     * @param isActive Whether to activate or deactivate
     */
    void setProductActiveStatus(Set<Id> productIds, Boolean isActive);
}