trigger FC_FcChargeMonthlyRevenueTrigger on FC_Charge_Monthly_Revenue__c (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_FcChargeMonthlyRevenueHandler');
}