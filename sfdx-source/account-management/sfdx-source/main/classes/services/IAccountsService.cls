/**
 * @description Interface for the Accounts service
 * Defines business operations for Account records
 */
public interface IAccountsService {
    
    /**
     * @description Create a new account
     * @param name Account name
     * @param type Account type
     * @param industry Account industry
     * @return Id The ID of the created account
     */
    Id createAccount(String name, String type, String industry);
    
    /**
     * @description Update account details
     * @param accountId Account ID
     * @param fields Map of field names to values
     */
    void updateAccount(Id accountId, Map<String, Object> fields);
    
    /**
     * @description Merge duplicate accounts
     * @param masterAccountId The account to keep
     * @param duplicateAccountIds Accounts to merge
     */
    void mergeAccounts(Id masterAccountId, List<Id> duplicateAccountIds);
    
    /**
     * @description Calculate account rating based on internal metrics
     * @param accountId Account ID
     * @return String The calculated rating
     */
    String calculateAccountRating(Id accountId);
    
    /**
     * @description Transfer accounts between owners
     * @param accountIds Accounts to transfer
     * @param newOwnerId New owner ID
     */
    void transferAccounts(Set<Id> accountIds, Id newOwnerId);
}