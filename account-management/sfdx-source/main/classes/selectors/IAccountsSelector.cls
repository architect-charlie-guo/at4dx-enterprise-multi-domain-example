/**
 * @description Interface for the Accounts selector
 * Defines the contract for querying Account records
 */
public interface IAccountsSelector extends IApplicationSObjectSelector {
    
    /**
     * @description Select accounts by ID
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records
     */
    List<Account> selectById(Set<Id> accountIds);
    
    /**
     * @description Select accounts by name
     * @param names Set of account names
     * @return List<Account> List of account records
     */
    List<Account> selectByName(Set<String> names);
    
    /**
     * @description Select accounts with their parent account
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records with parent
     */
    List<Account> selectWithParentById(Set<Id> accountIds);
    
    /**
     * @description Select accounts with their related contacts
     * @param accountIds Set of account IDs
     * @return List<Account> List of account records with contacts
     */
    List<Account> selectWithContactsById(Set<Id> accountIds);
    
    /**
     * @description Select accounts by type
     * @param types Set of account types
     * @param limitCount Maximum number of records to return
     * @return List<Account> List of account records
     */
    List<Account> selectByType(Set<String> types, Integer limitCount);
}