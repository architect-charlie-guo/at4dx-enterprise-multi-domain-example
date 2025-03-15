/**
 * @description Trigger for Account SObject
 * Routes trigger events to the Accounts domain class using the Application Factory
 */
trigger Accounts on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Create the domain class instance from the trigger records
    IAccounts accounts = (IAccounts) Application.Domain.newInstance(Trigger.new, Trigger.oldMap);
    
    // Route the trigger event to the domain class methods
    accounts.handleTriggerEvent();
}