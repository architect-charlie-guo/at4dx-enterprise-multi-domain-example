/**
 * @description Selector for Integration Log records
 * Implementation of the Integration Logs selector interface
 */
public with sharing class IntegrationLogsSelector 
    extends ApplicationSObjectSelector
    implements IIntegrationLogsSelector 
{
    /**
     * @description Factory method to create a new instance
     * @return IIntegrationLogsSelector A new instance of the selector
     */
    public static IIntegrationLogsSelector newInstance() {
        return (IIntegrationLogsSelector) Application.Selector.newInstance(IntegrationLog__c.SObjectType);
    }
    
    /**
     * @description Get the SObject type this selector is responsible for
     * @return Schema.SObjectType The SObject type
     */
    public Schema.SObjectType getSObjectType() {
        return IntegrationLog__c.SObjectType;
    }
    
    /**
     * @description Get the list of fields to query
     * @return List<Schema.SObjectField> List of fields
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IntegrationLog__c.Id,
            IntegrationLog__c.Name,
            IntegrationLog__c.System__c,
            IntegrationLog__c.Direction__c,
            IntegrationLog__c.Status__c,
            IntegrationLog__c.Payload__c,
            IntegrationLog__c.ErrorMessage__c,
            IntegrationLog__c.CreatedDate,
            IntegrationLog__c.CreatedById,
            IntegrationLog__c.LastModifiedDate,
            IntegrationLog__c.LastModifiedById
        };
    }
    
    /**
     * @description Select Integration Logs by Id
     * @param idSet Set of Integration Log Ids
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    public List<IntegrationLog__c> selectById(Set<Id> idSet) {
        return (List<IntegrationLog__c>) selectSObjectsById(idSet);
    }
    
    /**
     * @description Select Integration Logs by status
     * @param status The status to filter by
     * @param limitCount Optional limit on the number of records
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    public List<IntegrationLog__c> selectByStatus(String status, Integer limitCount) {
        fflib_QueryFactory qf = newQueryFactory();
        
        qf.setCondition('Status__c = :status');
        qf.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        
        if (limitCount != null) {
            qf.setLimit(limitCount);
        }
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select Integration Logs by system and date range
     * @param system The external system
     * @param startDate The start date
     * @param endDate The end date
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    public List<IntegrationLog__c> selectBySystemAndDateRange(String system, DateTime startDate, DateTime endDate) {
        fflib_QueryFactory qf = newQueryFactory();
        
        qf.setCondition('System__c = :system AND CreatedDate >= :startDate AND CreatedDate <= :endDate');
        qf.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        
        return Database.query(qf.toSOQL());
    }
}