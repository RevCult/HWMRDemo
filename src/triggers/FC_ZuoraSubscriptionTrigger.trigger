trigger FC_ZuoraSubscriptionTrigger on Zuora__Subscription__c (before insert, before update, after insert, after update,
        after delete, after undelete) {
    fcf.TriggerFactory.createHandler('FC_ZuoraSubscriptionHandler');
}