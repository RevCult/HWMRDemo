global without sharing class FC_ZuoraSubscriptionHandler extends fcf.TriggerAdapter {

    private static final String TRIGGER_RUN_STATUS_ID = 'FC_ZuoraSubscriptionHandler';

    // Before phase
    private Map<String, Contract> subscriptionNumberToContractMap = new Map<String, Contract>();
    private Map<ID, Opportunity> opportunityLookupMap = new Map<ID, Opportunity>();

    // After phase
    private Map<ID, Account> accountsToUpdateMap = new Map<ID, Account>();
    //private Map<ID, Opportunity> opportunitiesToUpdateMap = new Map<ID, Opportunity>();
    private Map<ID, Contract> contractsToUpdateMap = new Map<ID, Contract>();

    global override void bulkBefore() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<Id> opportunityIdsToLookup = new Set<Id>();

            for (SObject so : Trigger.new) {
                Zuora__Subscription__c subscriptionRecord = (Zuora__Subscription__c) so;
                if (String.isNotBlank(subscriptionRecord.OpportunityID__c)) {
                    try {
                        opportunityIdsToLookup.add(Id.valueOf(subscriptionRecord.OpportunityID__c));
                    } catch (Exception e) {
                        // Ignore invalid opportunity IDs
                    }
                }
            }

            opportunityLookupMap.putAll(FC_OpportunityCache.findByIds(opportunityIdsToLookup));

        }

    }

    global override void beforeInsert(SObject so) {
        Zuora__Subscription__c newSubscriptionRecord = (Zuora__Subscription__c) so;

        populateFields(newSubscriptionRecord);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        Zuora__Subscription__c newSubscriptionRecord = (Zuora__Subscription__c) so;

        populateFields(newSubscriptionRecord);
    }

    global override void finallyBefore() {

        // Initialize aggregate fields
        for (SObject so : Trigger.new) {
            Zuora__Subscription__c subscriptionRecord = (Zuora__Subscription__c) so;
            subscriptionRecord.FC_One_Time_Charge_Count__c = 0;
            subscriptionRecord.FC_Recurring_Charge_Count__c = 0;
            subscriptionRecord.FC_Latest_Charge_Effective_Date__c = null;
            if (!subscriptionRecord.FC_Override_Eligible_to_Cancel_Dates__c) {
                subscriptionRecord.FC_Eligible_to_Cancel_Start_Date__c = null;
                subscriptionRecord.FC_Eligible_to_Cancel_End_Date__c = null;
            }
        }

        // Aggregate charge records
        if (Trigger.isUpdate) {

            for (AggregateResult ar : [
                    select Zuora__Subscription__c,
                            sum(FC_One_If_One_Time_Charge__c) countOneTimeCharges,
                            sum(FC_One_If_Recurring_Charge__c) countRecurringCharges,
                            max(Zuora__EffectiveStartDate__c) latestEffectiveStartDate,
                            min(FC_Eligible_to_Cancel_Start_Date__c) earliestEligibleToCancelDate,
                            max(FC_Eligible_to_Cancel_End_Date__c) latestEligibleToCancelDate
                    from Zuora__SubscriptionProductCharge__c
                    where Zuora__Subscription__c in :Trigger.newMap.keySet()
                    group by Zuora__Subscription__c
            ]) {
                Zuora__Subscription__c subscriptionRecord =
                        (Zuora__Subscription__c) Trigger.newMap.get((Id) ar.get('Zuora__Subscription__c'));
                subscriptionRecord.FC_One_Time_Charge_Count__c = (Decimal) ar.get('countOneTimeCharges');
                subscriptionRecord.FC_Recurring_Charge_Count__c = (Decimal) ar.get('countRecurringCharges');
                subscriptionRecord.FC_Latest_Charge_Effective_Date__c = (Date) ar.get('latestEffectiveStartDate');
                if (!subscriptionRecord.FC_Override_Eligible_to_Cancel_Dates__c) {
                    subscriptionRecord.FC_Eligible_to_Cancel_Start_Date__c = (Date) ar.get('earliestEligibleToCancelDate');
                    subscriptionRecord.FC_Eligible_to_Cancel_End_Date__c = (Date) ar.get('latestEligibleToCancelDate');
                }
            }

        }

    }

    global override void bulkAfter() {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {

            Set<String> subscriptionNumberToLookup = new Set<String>();
            for (SObject so : Trigger.new) {
                Zuora__Subscription__c subscriptionRecord = (Zuora__Subscription__c) so;
                subscriptionNumberToLookup.add(subscriptionRecord.Name);
            }
            subscriptionNumberToContractMap.putAll(FC_ContractCache.findBySubscriptionNumbers(subscriptionNumberToLookup));
        }
    }

    global override void afterInsert(SObject so) {
        Zuora__Subscription__c newSubscriptionRecord = (Zuora__Subscription__c) so;

        includeAccountForUpdate(newSubscriptionRecord);
        includeContractForUpdate(newSubscriptionRecord);
        //includeOpportunityForUpdate(newSubscriptionRecord);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        Zuora__Subscription__c newSubscriptionRecord = (Zuora__Subscription__c) so;

        includeAccountForUpdate(newSubscriptionRecord);
        includeContractForUpdate(newSubscriptionRecord);
        //includeOpportunityForUpdate(newSubscriptionRecord);
    }

    global override void afterDelete(SObject so) {
        Zuora__Subscription__c oldSubscriptionRecord = (Zuora__Subscription__c) so;

        includeAccountForUpdate(oldSubscriptionRecord);
    }

    global override void afterUndelete(SObject so) {
        Zuora__Subscription__c newSubscriptionRecord = (Zuora__Subscription__c) so;

        includeAccountForUpdate(newSubscriptionRecord);
        includeContractForUpdate(newSubscriptionRecord);
        //includeOpportunityForUpdate(newSubscriptionRecord);
    }

    global override void finallyAfter() {

        fcf.TriggerRunStatusItem fcfTriggerRunStatusItem =
                new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID);
        if (!fcf.TriggerRunStatus.isRunnable(fcfTriggerRunStatusItem)) {
            return;
        }
        fcf.TriggerRunStatus.block(fcfTriggerRunStatusItem);

        if (!accountsToUpdateMap.isEmpty()) {
            update accountsToUpdateMap.values();
            accountsToUpdateMap.clear();
        }

        if (!contractsToUpdateMap.isEmpty()) {
            update contractsToUpdateMap.values();
            contractsToUpdateMap.clear();
        }

//        if (!opportunitiesToUpdateMap.isEmpty()) {
//            update opportunitiesToUpdateMap.values();
//            opportunitiesToUpdateMap.clear();
//        }

    }

    private void populateFields(Zuora__Subscription__c subscriptionRecord) {

        // Populate Opportunity
        subscriptionRecord.Opportunity__c = null;
        try {
            if (String.isNotBlank(subscriptionRecord.OpportunityID__c) &&
                    opportunityLookupMap.containsKey(Id.valueOf(subscriptionRecord.OpportunityID__c))) {
                subscriptionRecord.Opportunity__c = Id.valueOf(subscriptionRecord.OpportunityID__c);
            }
        } catch (Exception e) {
            // Ignore invalid opportunity IDs
        }

    }

    private void includeAccountForUpdate(Zuora__Subscription__c subscriptionRecord) {
        if (subscriptionRecord.Zuora__Account__c != null) {
            accountsToUpdateMap.put(subscriptionRecord.Zuora__Account__c,
                    new Account(Id = subscriptionRecord.Zuora__Account__c));
        }
    }

//    private void includeOpportunityForUpdate(Zuora__Subscription__c subscriptionRecord) {
//        if (subscriptionRecord.Opportunity__c != null) {
//            opportunitiesToUpdateMap.put(subscriptionRecord.Opportunity__c,
//                    new Opportunity(Id = subscriptionRecord.Opportunity__c, Skip_Validation__c = true));
//        }
//    }

    private void includeContractForUpdate(Zuora__Subscription__c subscriptionRecord) {
        if (subscriptionNumberToContractMap.containsKey(subscriptionRecord.Name)) {
            contractsToUpdateMap.put(subscriptionNumberToContractMap.get(subscriptionRecord.Name).Id,
                    new Contract(Id = subscriptionNumberToContractMap.get(subscriptionRecord.Name).Id));
        }
    }

}