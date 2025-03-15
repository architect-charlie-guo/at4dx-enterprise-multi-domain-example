/**
 * @description Domain process criteria for identifying high-value accounts
 * This is used for domain process injection into the Account domain
 */
public with sharing class HighValueAccountCriteria implements IDomainProcessCriteria {
    private List<Account> accounts = new List<Account>();
    
    /**
     * @description Set the records to evaluate
     * @param records Account records to evaluate
     * @return IDomainProcessCriteria This object for method chaining
     */
    public IDomainProcessCriteria setRecordsToEvaluate(List<SObject> records) {
        this.accounts.clear();
        this.accounts.addAll((List<Account>)records);
        return this;
    }
    
    /**
     * @description Run the criteria evaluation
     * @return List<SObject> List of accounts that match the criteria
     */
    public List<SObject> run() {
        List<Account> qualifiedAccounts = new List<Account>();
        
        // Define what constitutes a high-value account
        // In this case, any account with annual revenue > 1,000,000
        for (Account account : this.accounts) {
            if (account.AnnualRevenue != null && account.AnnualRevenue > 1000000) {
                qualifiedAccounts.add(account);
            }
        }
        
        // Log for demonstration purposes
        System.debug('Marketing package identified ' + qualifiedAccounts.size() + 
                    ' high-value accounts out of ' + this.accounts.size() + ' total accounts');
        
        return qualifiedAccounts;
    }
}