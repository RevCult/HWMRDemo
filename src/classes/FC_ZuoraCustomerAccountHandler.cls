global without sharing class FC_ZuoraCustomerAccountHandler extends fcf.TriggerAdapter {

//    private static final String TRIGGER_RUN_STATUS_ID = 'FC_ZuoraCustomerAccountHandler';

    // Before-phase variables
    private Map<ID, Set<Zuora__SubscriptionProductCharge__c>> billingAccountIdToSubscriptionProductChargesMap =
            new Map<ID, Set<Zuora__SubscriptionProductCharge__c>>();

//    // After-phase variables
//    private Set<String> customerAccountZuoraIds = new Set<String>();

    global override void bulkBefore() {
        if (Trigger.isUpdate) {
            billingAccountIdToSubscriptionProductChargesMap.putAll(
                    FC_SubscriptionProductChargeCache.findByBillingAccountIds(Trigger.newMap.keySet()));
        }
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        Zuora__CustomerAccount__c newCustomerAccount = (Zuora__CustomerAccount__c) so;

        populateFields(newCustomerAccount);
    }

//    global override void afterInsert(SObject so) {
//        Zuora__CustomerAccount__c newCustomerAccount = (Zuora__CustomerAccount__c) so;
//
//        if (String.isNotBlank(newCustomerAccount.Zuora__External_Id__c)) {
//            customerAccountZuoraIds.add(newCustomerAccount.Zuora__External_Id__c);
//        }
//    }
//
//    global override void afterUpdate(SObject oldSo, SObject so) {
//        Zuora__CustomerAccount__c newCustomerAccount = (Zuora__CustomerAccount__c) so;
//
//        if (String.isNotBlank(newCustomerAccount.Zuora__External_Id__c)) {
//            customerAccountZuoraIds.add(newCustomerAccount.Zuora__External_Id__c);
//        }
//    }
//
//    global override void finallyAfter() {
//
//        // Prevent after phase from recursively executing
//        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
//            return;
//        }
//        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));
//
//        if (Trigger.isInsert || Trigger.isUpdate) {
//
//            // Update related quotes
//            zqu__Quote__c[] quotesToUpdate = new List<zqu__Quote__c>();
//            Map<String, Set<zqu__Quote__c>> customerAccountZuoraIdsToQuotesMap = FC_ZquQuoteCache.findByZuoraAccountIds(customerAccountZuoraIds);
//            for (String customerAccountZuoraId : customerAccountZuoraIdsToQuotesMap.keySet()) {
//                for (zqu__Quote__c quoteRecord : customerAccountZuoraIdsToQuotesMap.get(customerAccountZuoraId)) {
//                    quotesToUpdate.add(new zqu__Quote__c(Id = quoteRecord.Id));
//                }
//            }
//            if (!quotesToUpdate.isEmpty()) {
//                update quotesToUpdate;
//            }
//
//        }
//
//    }

    private void populateFields(Zuora__CustomerAccount__c customerAccountRecord) {
        if (billingAccountIdToSubscriptionProductChargesMap.containsKey(customerAccountRecord.Id)) {
            Set<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges =
                    billingAccountIdToSubscriptionProductChargesMap.get(customerAccountRecord.Id);
            Set<String> seg2DescriptionSet = new Set<String>();
            for (Zuora__SubscriptionProductCharge__c subscriptionProductCharge : subscriptionProductCharges) {
                if (String.isNotBlank(subscriptionProductCharge.Seg2_Description__c)) {
                    seg2DescriptionSet.add(subscriptionProductCharge.Seg2_Description__c);
                }
            }
            customerAccountRecord.Seg2_Description__c = String.join(new List<String>(seg2DescriptionSet), ';');
        }
    }

}