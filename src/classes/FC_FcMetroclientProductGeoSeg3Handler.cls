global without sharing class FC_FcMetroclientProductGeoSeg3Handler extends fcf.TriggerAdapter {

    private Map<String, Set<zqu__ProductRatePlanCharge__c>> accountingCodeToProductRatePlanChargesMap = new Map<String, Set<zqu__ProductRatePlanCharge__c>>();
    private Map<Id, MetroclientProductGeography__c> metroclientProductGeographyLookupMap = new Map<Id, MetroclientProductGeography__c>();

    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<String> accountingCodesToLookup = new Set<String>();
            Set<Id> metroclientProductGeographyIdsToLookup = new Set<Id>();

            for (SObject so : Trigger.new) {
                FC_Metroclient_Product_Geography_Seg3__c seg3Record = (FC_Metroclient_Product_Geography_Seg3__c) so;
                if (String.isNotBlank(seg3Record.Accounting_Code__c)) {
                    accountingCodesToLookup.add(seg3Record.Accounting_Code__c.toUpperCase());
                }
                if (seg3Record.Product_Geography__c != null) {
                    metroclientProductGeographyIdsToLookup.add(seg3Record.Product_Geography__c);
                }
            }
            accountingCodeToProductRatePlanChargesMap.putAll(FC_ProductRatePlanChargeCache.findWithActiveRatePlanByRecognizedRevenueAccount(accountingCodesToLookup));
            metroclientProductGeographyLookupMap.putAll(FC_MetroclientProductGeographyCache.findByIds(metroclientProductGeographyIdsToLookup));

        }
    }

    global override void beforeInsert(SObject so) {
        FC_Metroclient_Product_Geography_Seg3__c newSeg3Record = (FC_Metroclient_Product_Geography_Seg3__c) so;
        populateFields(newSeg3Record);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        FC_Metroclient_Product_Geography_Seg3__c newSeg3Record = (FC_Metroclient_Product_Geography_Seg3__c) so;
        populateFields(newSeg3Record);
    }

    private void populateFields(FC_Metroclient_Product_Geography_Seg3__c seg3Record) {
        seg3Record.Charge_Type__c = null;
        seg3Record.Seg3__c = null;
        seg3Record.Product__c = null;
        seg3Record.Product_Rate_Plan__c = null;
        MetroclientProductGeography__c metroclientProductGeographyRecord = metroclientProductGeographyLookupMap.get(seg3Record.Product_Geography__c);
        if (metroclientProductGeographyRecord != null &&
                String.isNotBlank(metroclientProductGeographyRecord.ProductGeographyType__r.Product__r.ZuoraSku__c) &&
                String.isNotBlank(seg3Record.Accounting_Code__c) &&
                accountingCodeToProductRatePlanChargesMap.containsKey(seg3Record.Accounting_Code__c.toUpperCase())) {
            for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : accountingCodeToProductRatePlanChargesMap.get(seg3Record.Accounting_Code__c.toUpperCase())) {
                if (metroclientProductGeographyRecord.ProductGeographyType__r.Product__r.ZuoraSku__c ==
                        productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) {
                    seg3Record.Product__c = productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__Product__c;
                    seg3Record.Product_Rate_Plan__c = productRatePlanChargeRecord.zqu__ProductRatePlan__c;
                    seg3Record.Charge_Type__c = productRatePlanChargeRecord.zqu__Type__c == 'One-Time' ? 'OneTime' : productRatePlanChargeRecord.zqu__Type__c;
                    seg3Record.Seg3__c = productRatePlanChargeRecord.zqu__ProductRatePlan__r.Segment3__c;
                    break;
                }
            }
        }
    }

}