/**
 * @description Manages batch process execution based on configuration settings
 * This class handles batch process scheduling and execution according to BatchProcessControl__c settings
 */
public with sharing class BatchProcessManager {
    
    /**
     * @description Check if a batch process is active
     * @param processName The name of the batch process
     * @return Boolean True if the process is active
     */
    public static Boolean isProcessActive(String processName) {
        BatchProcessControl__c process = getBatchProcessControl(processName);
        return process.IsActive__c;
    }
    
    /**
     * @description Get the batch size for a process
     * @param processName The name of the batch process
     * @return Integer The batch size to use
     */
    public static Integer getBatchSize(String processName) {
        BatchProcessControl__c process = getBatchProcessControl(processName);
        return (Integer)process.BatchSize__c;
    }
    
    /**
     * @description Get the schedule cron expression for a process
     * @param processName The name of the batch process
     * @return String The cron expression
     */
    public static String getScheduleCron(String processName) {
        BatchProcessControl__c process = getBatchProcessControl(processName);
        return process.ScheduleCron__c;
    }
    
    /**
     * @description Get a batch process control record, creating it if it doesn't exist
     * @param processName The name of the batch process
     * @return BatchProcessControl__c The process control record
     */
    private static BatchProcessControl__c getBatchProcessControl(String processName) {
        // Try to get the existing record
        List<BatchProcessControl__c> controls = [
            SELECT Id, Name, IsActive__c, BatchSize__c, ScheduleCron__c
            FROM BatchProcessControl__c
            WHERE Name = :processName
            LIMIT 1
        ];
        
        // If it exists, return it
        if (!controls.isEmpty()) {
            return controls[0];
        }
        
        // Otherwise, create a default record
        BatchProcessControl__c newControl = new BatchProcessControl__c(
            Name = processName,
            IsActive__c = true,
            BatchSize__c = 200,
            ScheduleCron__c = '0 0 0 * * ?'  // Default: midnight every day
        );
        
        insert newControl;
        return newControl;
    }
    
    /**
     * @description Executes a batch process if it's active
     * @param batchable The batchable instance to execute
     * @param processName The name of the batch process
     * @return Id The batch job ID if executed, null otherwise
     */
    public static Id executeBatchIfActive(Database.Batchable<SObject> batchable, String processName) {
        if (!isProcessActive(processName)) {
            return null;
        }
        
        Integer batchSize = getBatchSize(processName);
        return Database.executeBatch(batchable, batchSize);
    }
}