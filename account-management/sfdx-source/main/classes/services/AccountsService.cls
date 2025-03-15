/**
 * @description Service implementation for Account operations
 * Provides business operations for Account records
 */
public with sharing class AccountsService implements IAccountsService {
    
    /**
     * @description Create a new account
     * @param name Account name
     * @param type Account type
     * @param industry Account industry
     * @return Id The ID of the created account
     */
    public Id createAccount(String name, String type, String industry) {
        // Create a new account record
        Account newAccount = new Account(
            Name = name,
            Type = type,
            Industry = industry
        );
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Register the new account
        uow.registerNew(newAccount);
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the new account
        EventPublisher.publish(
            'Account',
            'ACCOUNT_CREATED',
            new Map<String, Object> {
                'accountId' => newAccount.Id,
                'accountName' => name
            }
        );
        
        return newAccount.Id;
    }
    
    /**
     * @description Update account details
     * @param accountId Account ID
     * @param fields Map of field names to values
     */
    public void updateAccount(Id accountId, Map<String, Object> fields) {
        // Get the account selector
        IAccountsSelector accountsSelector = AccountsSelector.newInstance();
        
        // Get the account by ID
        List<Account> accounts = accountsSelector.selectById(new Set<Id>{ accountId });
        
        if (accounts.isEmpty()) {
            throw new AccountsServiceException('Account not found: ' + accountId);
        }
        
        Account account = accounts[0];
        
        // Update the fields
        for (String fieldName : fields.keySet()) {
            Object value = fields.get(fieldName);
            account.put(fieldName, value);
        }
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Register the dirty account
        uow.registerDirty(account);
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the updated account
        EventPublisher.publish(
            'Account',
            'ACCOUNT_UPDATED',
            new Map<String, Object> {
                'accountId' => accountId,
                'updatedFields' => new List<String>(fields.keySet())
            }
        );
    }
    
    /**
     * @description Merge duplicate accounts
     * @param masterAccountId The account to keep
     * @param duplicateAccountIds Accounts to merge
     */
    public void mergeAccounts(Id masterAccountId, List<Id> duplicateAccountIds) {
        // Validate the account IDs
        if (duplicateAccountIds.contains(masterAccountId)) {
            throw new AccountsServiceException('Master account cannot be in the duplicate list');
        }
        
        // Get the account selector
        IAccountsSelector accountsSelector = AccountsSelector.newInstance();
        
        // Get all accounts involved in the merge
        Set<Id> allAccountIds = new Set<Id>{ masterAccountId };
        allAccountIds.addAll(duplicateAccountIds);
        
        List<Account> accounts = accountsSelector.selectWithContactsById(allAccountIds);
        
        Map<Id, Account> accountsById = new Map<Id, Account>();
        for (Account account : accounts) {
            accountsById.put(account.Id, account);
        }
        
        // Validate that all accounts exist
        if (accountsById.size() != allAccountIds.size()) {
            throw new AccountsServiceException('One or more accounts not found');
        }
        
        // Perform the merges
        Account masterAccount = accountsById.get(masterAccountId);
        
        try {
            for (Id duplicateId : duplicateAccountIds) {
                Account duplicate = accountsById.get(duplicateId);
                
                Database.merge(masterAccount, duplicate);
            }
            
            // Publish an event about the merged accounts
            EventPublisher.publish(
                'Account',
                'ACCOUNTS_MERGED',
                new Map<String, Object> {
                    'masterAccountId' => masterAccountId,
                    'mergedAccountIds' => duplicateAccountIds
                }
            );
            
        } catch (Exception ex) {
            throw new AccountsServiceException('Error merging accounts: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Calculate account rating based on internal metrics
     * @param accountId Account ID
     * @return String The calculated rating
     */
    public String calculateAccountRating(Id accountId) {
        // Get the account selector
        IAccountsSelector accountsSelector = AccountsSelector.newInstance();
        
        // Get the account by ID
        List<Account> accounts = accountsSelector.selectById(new Set<Id>{ accountId });
        
        if (accounts.isEmpty()) {
            throw new AccountsServiceException('Account not found: ' + accountId);
        }
        
        Account account = accounts[0];
        
        // Calculate the rating based on revenue and other factors
        String rating;
        
        if (account.AnnualRevenue == null) {
            rating = 'Not Rated';
        } else if (account.AnnualRevenue > 1000000) {
            rating = 'Hot';
        } else if (account.AnnualRevenue > 500000) {
            rating = 'Warm';
        } else {
            rating = 'Cold';
        }
        
        // Update the account with the new rating if different
        if (account.Rating != rating) {
            // Get a Unit of Work instance
            IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            
            account.Rating = rating;
            
            // Register the dirty account
            uow.registerDirty(account);
            
            // Commit the work
            uow.commitWork();
            
            // Publish an event about the rating change
            EventPublisher.publish(
                'Account',
                'ACCOUNT_RATING_CHANGED',
                new Map<String, Object> {
                    'accountId' => accountId,
                    'newRating' => rating
                }
            );
        }
        
        return rating;
    }
    
    /**
     * @description Transfer accounts between owners
     * @param accountIds Accounts to transfer
     * @param newOwnerId New owner ID
     */
    public void transferAccounts(Set<Id> accountIds, Id newOwnerId) {
        // Get the account selector
        IAccountsSelector accountsSelector = AccountsSelector.newInstance();
        
        // Get the accounts by ID
        List<Account> accounts = accountsSelector.selectById(accountIds);
        
        if (accounts.isEmpty()) {
            throw new AccountsServiceException('No accounts found for the provided IDs');
        }
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Update the owner for each account
        for (Account account : accounts) {
            account.OwnerId = newOwnerId;
            uow.registerDirty(account);
        }
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the ownership change
        EventPublisher.publish(
            'Account',
            'ACCOUNT_OWNERSHIP_CHANGED',
            new Map<String, Object> {
                'accountIds' => new List<Id>(accountIds),
                'newOwnerId' => newOwnerId
            }
        );
    }
    
    /**
     * @description Custom exception class for AccountsService
     */
    public class AccountsServiceException extends Exception {}
}