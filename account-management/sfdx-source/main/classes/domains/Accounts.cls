/**
 * @description Domain class for Account SObject
 * Implements the business logic for the Account object
 */
public with sharing class Accounts extends ApplicationSObjectDomain implements IAccounts {
    
    /**
     * @description Constructor
     * @param records Account records
     */
    public Accounts(List<Account> records) {
        super(records);
    }
    
    /**
     * @description AT4DX constructor binding implementation
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new Accounts((List<Account>) records);
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
     * @param existingRecords Map of existing account records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validate();
        calculateDerivedFields();
    }
    
    /**
     * @description Handles the onAfterInsert trigger event
     */
    public override void onAfterInsert() {
        manageHierarchy();
        publishAccountChangeEvents();
    }
    
    /**
     * @description Handles the onAfterUpdate trigger event
     * @param existingRecords Map of existing account records
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        manageHierarchy();
        publishAccountChangeEvents();
    }
    
    /**
     * @description Set default values for newly created accounts
     */
    public void setDefaults() {
        for (Account account : (List<Account>) Records) {
            // Set default values if needed
            if (account.Industry == null) {
                account.Industry = 'Other';
            }
            
            if (account.AccountSource == null) {
                account.AccountSource = 'Other';
            }
        }
    }
    
    /**
     * @description Validate account data before insert or update
     */
    public void validate() {
        for (Account account : (List<Account>) Records) {
            // Phone number validation
            if (account.Phone != null && !isValidPhoneNumber(account.Phone)) {
                account.Phone.addError('Please enter a valid phone number.');
            }
            
            // Website validation
            if (account.Website != null && !isValidWebsite(account.Website)) {
                account.Website.addError('Please enter a valid website URL.');
            }
        }
    }
    
    /**
     * @description Calculate and set derived fields for accounts
     */
    public void calculateDerivedFields() {
        for (Account account : (List<Account>) Records) {
            // Example: Set naming convention for enterprise accounts
            if (account.AnnualRevenue != null && account.AnnualRevenue > 1000000 && 
                account.Type == 'Enterprise') {
                
                if (!account.Name.startsWith('Enterprise: ')) {
                    account.Name = 'Enterprise: ' + account.Name;
                }
            }
        }
    }
    
    /**
     * @description Update account hierarchy relationships
     */
    public void manageHierarchy() {
        Set<Id> parentIds = new Set<Id>();
        
        for (Account account : (List<Account>) Records) {
            if (account.ParentId != null) {
                parentIds.add(account.ParentId);
            }
        }
        
        // If there are parent accounts involved, we might need to 
        // process hierarchy calculations or updates, but we'll
        // keep this simple for the demonstration
    }
    
    /**
     * @description Publish events for account changes
     */
    public void publishAccountChangeEvents() {
        Set<Id> accountIds = new Set<Id>();
        Set<String> changedFields = new Set<String>();
        
        for (Account account : (List<Account>) Records) {
            accountIds.add(account.Id);
            // In a real implementation, we'd also track which fields changed
        }
        
        // Call the event publisher to publish the events
        EventPublisher.publish(
            'Account', 
            'ACCOUNT_UPDATED',
            new Map<String, Object> {
                'accountIds' => accountIds,
                'fields' => new List<String>(changedFields)
            }
        );
    }
    
    /**
     * @description Validate phone number format
     * @param phone Phone number to validate
     * @return Boolean True if valid
     */
    private Boolean isValidPhoneNumber(String phone) {
        // Basic validation - would be more comprehensive in a real implementation
        return phone.length() >= 10;
    }
    
    /**
     * @description Validate website format
     * @param website Website to validate
     * @return Boolean True if valid
     */
    private Boolean isValidWebsite(String website) {
        // Basic validation - would be more comprehensive in a real implementation
        return website.startsWith('http://') || website.startsWith('https://');
    }
}