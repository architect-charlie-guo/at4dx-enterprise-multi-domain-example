/**
 * @description Interface for the Integration Logs selector
 * This interface defines the contract for querying Integration Log records
 */
public interface IIntegrationLogsSelector extends IApplicationSObjectSelector {
    /**
     * @description Select Integration Logs by Id
     * @param idSet Set of Integration Log Ids
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    List<IntegrationLog__c> selectById(Set<Id> idSet);
    
    /**
     * @description Select Integration Logs by status
     * @param status The status to filter by
     * @param limitCount Optional limit on the number of records
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    List<IntegrationLog__c> selectByStatus(String status, Integer limitCount);
    
    /**
     * @description Select Integration Logs by system and date range
     * @param system The external system
     * @param startDate The start date
     * @param endDate The end date
     * @return List<IntegrationLog__c> List of Integration Log records
     */
    List<IntegrationLog__c> selectBySystemAndDateRange(String system, DateTime startDate, DateTime endDate);
}