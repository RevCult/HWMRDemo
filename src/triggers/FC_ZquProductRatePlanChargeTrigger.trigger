trigger FC_ZquProductRatePlanChargeTrigger on zqu__ProductRatePlanCharge__c (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_ZquProductRatePlanChargeHandler');
}