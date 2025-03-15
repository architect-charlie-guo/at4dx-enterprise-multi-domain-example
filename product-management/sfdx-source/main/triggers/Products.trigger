/**
 * @description Trigger for Product2 SObject
 * Routes trigger events to the Products domain class using the Application Factory
 */
trigger Products on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Create the domain class instance from the trigger records
    IProducts products = (IProducts) Application.Domain.newInstance(Trigger.new, Trigger.oldMap);
    
    // Route the trigger event to the domain class methods
    products.handleTriggerEvent();
}