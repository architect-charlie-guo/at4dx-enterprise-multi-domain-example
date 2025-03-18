/**
 * @description Interface for the Accounts domain class
 * Provides the contract for account-related business logic
 */
public interface IAccounts extends IApplicationSObjectDomain {
    
    /**
     * @description Set default values for newly created accounts
     */
    void setDefaults();
    
    /**
     * @description Validate account data before insert or update
     */
    void validate();
    
    /**
     * @description Calculate and set derived fields for accounts
     */
    void calculateDerivedFields();
    
    /**
     * @description Update account hierarchy relationships
     */
    void manageHierarchy();
    
    /**
     * @description Publish events for account changes
     */
    void publishAccountChangeEvents();
}