global without sharing class FC_FcChargeMonthlyRevenueHandler extends fcf.TriggerAdapter {

    private Map<String, Zuora__SubscriptionProductCharge__c> chargeLookupMap =
            new Map<String, Zuora__SubscriptionProductCharge__c>();

    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<String> chargeNumbersToLookup = new Set<String>();
            for (SObject so : Trigger.new) {
                FC_Charge_Monthly_Revenue__c chargeMonthlyRevenueRecord = (FC_Charge_Monthly_Revenue__c) so;
                if (String.isNotBlank(chargeMonthlyRevenueRecord.Charge_Number__c)) {
                    chargeNumbersToLookup.add(chargeMonthlyRevenueRecord.Charge_Number__c);
                }
            }
            if (!chargeNumbersToLookup.isEmpty()) {
                chargeLookupMap.putAll(FC_SubscriptionProductChargeCache.findByChargeNumbers(chargeNumbersToLookup));
            }
        }
    }

    global override void beforeInsert(SObject so) {
        FC_Charge_Monthly_Revenue__c newChargeMonthlyRevenueRecord = (FC_Charge_Monthly_Revenue__c) so;
        populateFields(newChargeMonthlyRevenueRecord);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        FC_Charge_Monthly_Revenue__c newChargeMonthlyRevenueRecord = (FC_Charge_Monthly_Revenue__c) so;
        populateFields(newChargeMonthlyRevenueRecord);
    }

    private void populateFields(FC_Charge_Monthly_Revenue__c chargeMonthlyRevenueRecord) {
        chargeMonthlyRevenueRecord.Rate_Plan_Charge__c = null;
        if (String.isNotBlank(chargeMonthlyRevenueRecord.Charge_Number__c) &&
                chargeLookupMap.containsKey(chargeMonthlyRevenueRecord.Charge_Number__c)) {
            chargeMonthlyRevenueRecord.Rate_Plan_Charge__c =
                    chargeLookupMap.get(chargeMonthlyRevenueRecord.Charge_Number__c).Id;
        }
    }

}