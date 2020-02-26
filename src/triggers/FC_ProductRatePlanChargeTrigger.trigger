trigger FC_ProductRatePlanChargeTrigger on zqu__ProductRatePlanCharge__c (before insert, before update) {
	fcf.TriggerFactory.createHandler('FC_ProductRatePlanChargeHandler');
}