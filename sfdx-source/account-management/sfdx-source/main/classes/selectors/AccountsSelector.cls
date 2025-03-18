/**
 * @description Selector for Account SObject
 * Implements querying logic for Account records
 */
public with sharing class AccountsSelector extends ApplicationSObjectSelector implements IAccountsSelector {
    
    /**
     * @description Constructor for dependency injection
     */
    public AccountsSelector() {
        super();
    }
    
    /**
     * @description Factory method to create a new instance
     * @return IAccountsSelector New instance of the selector
     */
    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }
    
    /**
     * @description Get the SObject type for this selector
     * @return Schema.SObjectType The Account SObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }
    
    /**
     * @description Get the list of fields to query
     * @return List<Schema.SObjectField> List of fields
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name,
            Account.AccountNumber,
            Account.Type,
            Account.Industry,
            Account.AnnualRevenue,
            Account.Website,
            Account.Phone,
            Account.BillingStreet,
            Account.BillingCity,
            Account.BillingState,
            Account.BillingPostalCode,
            Account.BillingCountry,
            Account.ShippingStreet,
            Account.ShippingCity,
            Account.ShippingState,
            Account.ShippingPostalCode,
            Account.ShippingCountry,
            Account.Description,
            Account.OwnerId,
            Account.CreatedDate,
            Account.CreatedById,
            Account.LastModifiedDate,
            Account.LastModifiedById,
            Account.ParentId
        };
    }
    
    /**
     * @description Select accounts by ID
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records
     */
    public List<Account> selectById(Set<Id> accountIds) {
        return (List<Account>) selectSObjectsById(accountIds);
    }
    
    /**
     * @description Select accounts by name
     * @param names Set of account names
     * @return List<Account> List of account records
     */
    public List<Account> selectByName(Set<String> names) {
        fflib_QueryFactory qf = newQueryFactory();
        
        qf.setCondition('Name IN :names');
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select accounts with their parent account
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records with parent
     */
    public List<Account> selectWithParentById(Set<Id> accountIds) {
        fflib_QueryFactory qf = newQueryFactory();
        
        // Add fields from parent account relationship
        qf.selectField('Parent.Id');
        qf.selectField('Parent.Name');
        qf.selectField('Parent.Industry');
        qf.selectField('Parent.Type');
        
        qf.setCondition('Id IN :accountIds');
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select accounts with their related contacts
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records with contacts
     */
    public List<Account> selectWithContactsById(Set<Id> accountIds) {
        fflib_QueryFactory qf = newQueryFactory();
        
        // Add subquery for contacts
        fflib_QueryFactory contactsQF = new fflib_QueryFactory(Contact.SObjectType);
        contactsQF.selectField('Id');
        contactsQF.selectField('FirstName');
        contactsQF.selectField('LastName');
        contactsQF.selectField('Email');
        contactsQF.selectField('Phone');
        
        // Add the contact subquery to the main query
        qf.subselectQuery(contactsQF);
        
        qf.setCondition('Id IN :accountIds');
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select accounts by type
     * @param types Set of account types
     * @param limitCount Maximum number of records to return
     * @return List<Account> List of account records
     */
    public List<Account> selectByType(Set<String> types, Integer limitCount) {
        fflib_QueryFactory qf = newQueryFactory();
        
        qf.setCondition('Type IN :types');
        qf.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        if (limitCount != null) {
            qf.setLimit(limitCount);
        }
        
        // Apply field set inclusions (this enables selector field injection from other packages)
        for (FieldSet fs : this.sObjectFieldSetList) {
            qf.selectFieldSet(fs);
        }
        
        return Database.query(qf.toSOQL());
    }
}