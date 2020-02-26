global without sharing class FC_ZquProductRatePlanChargeHandler extends fcf.TriggerAdapter {

    global override void beforeInsert(SObject so) {
        zqu__ProductRatePlanCharge__c newProductRatePlanChargeRecord = (zqu__ProductRatePlanCharge__c) so;
        populateFields(newProductRatePlanChargeRecord);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        zqu__ProductRatePlanCharge__c newProductRatePlanChargeRecord = (zqu__ProductRatePlanCharge__c) so;
        populateFields(newProductRatePlanChargeRecord);
    }

    private void populateFields(zqu__ProductRatePlanCharge__c productRatePlanChargeRecord) {
        productRatePlanChargeRecord.FC_Recognized_Revenue_Account__c = null;
        if (String.isNotBlank(productRatePlanChargeRecord.zqu__RecognizedRevenueAccount__c)) {
            productRatePlanChargeRecord.FC_Recognized_Revenue_Account__c = productRatePlanChargeRecord.zqu__RecognizedRevenueAccount__c.toUpperCase();
        }
    }

}