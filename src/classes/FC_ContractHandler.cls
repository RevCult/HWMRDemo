global without sharing class FC_ContractHandler extends fcf.TriggerAdapter {

    private Map<String, Zuora__Subscription__c> subscriptionNumberToSubscriptionMap = new Map<String, Zuora__Subscription__c>();

    global override void bulkBefore() {

        Set<String> subscriptionNumbersToLookup = new Set<String>();
        if (Trigger.isInsert || Trigger.isUpdate) {

            for (SObject so : Trigger.new) {
                Contract newContractRecord = (Contract) so;
                subscriptionNumbersToLookup.add(newContractRecord.FC_Subscription_Number__c);
            }

            subscriptionNumberToSubscriptionMap.putAll(FC_SubscriptionCache.findBySubscriptionNumber(subscriptionNumbersToLookup));

        }

    }

    global override void beforeInsert(Sobject so) {
        Contract newContractRecord = (Contract) so;
        populateFields(newContractRecord);
    }

    global override void beforeUpdate(SObject oldSo, Sobject so) {
        Contract newContractRecord = (Contract) so;
        populateFields(newContractRecord);
    }

    private void populateFields(Contract contractRecord) {
        contractRecord.FC_Subscription__c = null;
        if (String.isNotBlank(contractRecord.FC_Subscription_Number__c) &&
                subscriptionNumberToSubscriptionMap.containsKey(contractRecord.FC_Subscription_Number__c)) {
            contractRecord.FC_Subscription__c = subscriptionNumberToSubscriptionMap.get(contractRecord.FC_Subscription_Number__c).Id;
        }
    }

}