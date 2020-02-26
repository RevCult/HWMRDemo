trigger FC_SubscriptionProductChargeTrigger on Zuora__SubscriptionProductCharge__c (before insert, before update,
        after insert, after update, after delete, after undelete) {
    fcf.TriggerFactory.createHandler('FC_SubscriptionProductChargeHandler');
}