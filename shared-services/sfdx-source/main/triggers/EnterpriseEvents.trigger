/**
 * @description Trigger for EnterpriseEvent__e platform events
 * This trigger handles the distribution of enterprise events to their appropriate handlers
 * using the AT4DX PlatformEventDistributor framework.
 */
trigger EnterpriseEvents on EnterpriseEvent__e (after insert) {
    // Delegate to the PlatformEventDistributor to route events to registered consumers
    PlatformEventDistributor.triggerHandler();
}