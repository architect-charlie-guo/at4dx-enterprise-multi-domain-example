/**
 * @description Domain process action for assigning marketing segments to accounts
 * This is used for domain process injection into the Account domain
 */
public with sharing class AssignMarketingSegmentAction extends DomainProcessAbstractAction {
    
    /**
     * @description Run the action
     * This method is called after the criteria has filtered the records
     */
    public override void runInProcess() {
        // In a real implementation, the Marketing package would add custom fields
        // like MarketingSegment__c to the Account object.
        // For this example, we'll use the built-in Description field.
        
        for (SObject record : this.records) {
            Account account = (Account)record;
            
            // Determine the marketing segment based on account data
            String segment = determineMarketingSegment(account);
            
            // Update the account with the segment information
            String description = account.Description;
            if (description == null) {
                description = '';
            }
            
            // Only add the segment information if it's not already there
            if (!description.contains('Marketing Segment:')) {
                description = 'Marketing Segment: ' + segment + '\n\n' + description;
                account.Description = description;
            }
        }
        
        // Log for demonstration purposes
        System.debug('Marketing package assigned segments to ' + this.records.size() + ' high-value accounts');
    }
    
    /**
     * @description Determine the marketing segment for an account
     * @param account The account to evaluate
     * @return String The marketing segment
     */
    private String determineMarketingSegment(Account account) {
        // Simplified segment determination logic
        if (account.AnnualRevenue > 5000000) {
            return 'Enterprise';
        } else if (account.AnnualRevenue > 1000000) {
            return 'Mid-Market';
        } else {
            return 'Small Business';
        }
    }
}