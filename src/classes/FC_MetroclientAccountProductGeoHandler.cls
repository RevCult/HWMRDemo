global without sharing class FC_MetroclientAccountProductGeoHandler extends fcf.TriggerAdapter {

    Map<String, Zuora__SubscriptionProductCharge__c> chargeLookupMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<ID, Account> accountLookupMap = new Map<ID, Account>();

    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<String> chargeNumbersToLookup = new Set<String>();
            Set<ID> accountIdsToLookup = new Set<ID>();
            for (SObject so : Trigger.new) {
                MetroclientAccountProductGeography__c metroclientAccountProductGeographyRecord =
                        (MetroclientAccountProductGeography__c) so;
                if (String.isNotBlank(metroclientAccountProductGeographyRecord.ChargeNumber__c)) {
                    chargeNumbersToLookup.add(metroclientAccountProductGeographyRecord.ChargeNumber__c);
                }
                if (metroclientAccountProductGeographyRecord.Account__c != null) {
                    accountIdsToLookup.add(metroclientAccountProductGeographyRecord.Account__c);
                }
            }
            if (!chargeNumbersToLookup.isEmpty()) {
                chargeLookupMap.putAll(FC_SubscriptionProductChargeCache.findByChargeNumbers(chargeNumbersToLookup));
            }
            if (!accountIdsToLookup.isEmpty()) {
                accountLookupMap.putAll(FC_AccountCache.findByIds(accountIdsToLookup));
            }
        }
    }

    global override void beforeInsert(SObject so) {
        MetroclientAccountProductGeography__c newMetroclientAccountProductGeography =
                (MetroclientAccountProductGeography__c) so;
        populateFields(newMetroclientAccountProductGeography);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        MetroclientAccountProductGeography__c newMetroclientAccountProductGeography =
                (MetroclientAccountProductGeography__c) so;
        populateFields(newMetroclientAccountProductGeography);
    }

    private void populateFields(MetroclientAccountProductGeography__c metroclientAccountProductGeographyRecord) {
        metroclientAccountProductGeographyRecord.Charge__c = null;
        if (String.isNotBlank(metroclientAccountProductGeographyRecord.ChargeNumber__c)) {
            if (chargeLookupMap.containsKey(metroclientAccountProductGeographyRecord.ChargeNumber__c)) {
                metroclientAccountProductGeographyRecord.Charge__c = chargeLookupMap.get(metroclientAccountProductGeographyRecord.ChargeNumber__c).Id;
                metroclientAccountProductGeographyRecord.Subscription_Term_Type__c = chargeLookupMap.get(metroclientAccountProductGeographyRecord.ChargeNumber__c).Zuora__Subscription__r.Zuora__TermSettingType__c;
            }
        }

        Account accountRecord = accountLookupMap.get(metroclientAccountProductGeographyRecord.Account__c);
        if (accountRecord != null) {
            if (String.isNotBlank(accountRecord.FC_Ultimate_Parent_Account_ID_Formula__c)) {
                try {
                    metroclientAccountProductGeographyRecord.FC_Ultimate_Parent_Account__c = Id.valueOf(accountRecord.FC_Ultimate_Parent_Account_ID_Formula__c);
                } catch (Exception e) {
                    // Do nothing.
                }
            }
        }
    }

}