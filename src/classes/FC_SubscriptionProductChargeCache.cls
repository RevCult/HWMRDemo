public class FC_SubscriptionProductChargeCache {

    private static String[] SUBSCRIPTION_PRODUCT_CHARGE_FIELDS = new String[]{
            'Id', 'FC_Lookup_Key__c', 'List_Price_Per_Period__c', 'Seg2_Description__c', 'Seg3_Record__c',
            'Zuora__BillingPeriod__c', 'Zuora__ChargeNumber__c', 'Zuora__ExtendedAmount__c', 'Zuora__External_Id__c',
            'Zuora__RatePlanId__c', 'Zuora__Subscription__c', 'Zuora__Subscription__r.Opportunity__c',
            'Zuora__Subscription__r.Zuora__CustomerAccount__c', 'Zuora__Subscription__r.Zuora__External_Id__c',
            'Zuora__Subscription__r.Zuora__TermSettingType__c', 'Zuora__SubscriptionChargeNumber__c', 'Zuora__Type__c'
    };

    private static final Map<ID, Set<Zuora__SubscriptionProductCharge__c>> BY_RATE_PLAN_ID_MAP = new Map<ID, Set<Zuora__SubscriptionProductCharge__c>>();
    private static final Map<ID, Zuora__SubscriptionProductCharge__c> BY_ID_MAP = new Map<ID, Zuora__SubscriptionProductCharge__c>();
    private static final Map<String, Zuora__SubscriptionProductCharge__c> BY_CHARGE_NUMBER_MAP = new Map<String, Zuora__SubscriptionProductCharge__c>();
    private static final Map<String, Set<Zuora__SubscriptionProductCharge__c>> BY_SUBSCRIPTION_ZUORA_ID_MAP = new Map<String, Set<Zuora__SubscriptionProductCharge__c>>();
    private static final Map<ID, Set<Zuora__SubscriptionProductCharge__c>> BY_BILLING_ACCOUNT_ID_MAP = new Map<ID, Set<Zuora__SubscriptionProductCharge__c>>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from Zuora__SubscriptionProductCharge__c',
                new String[]{
                        String.join(SUBSCRIPTION_PRODUCT_CHARGE_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_CHARGE_NUMBER_MAP.clear();
        BY_SUBSCRIPTION_ZUORA_ID_MAP.clear();
        BY_BILLING_ACCOUNT_ID_MAP.clear();
        BY_RATE_PLAN_ID_MAP.clear();
    }

    public static Map<ID, Set<Zuora__SubscriptionProductCharge__c>> findBySubscriptionIds(Set<ID> subscriptionIds) {
        Map<ID, Set<Zuora__SubscriptionProductCharge__c>> results = new Map<ID, Set<Zuora__SubscriptionProductCharge__c>>();
        Set<ID> subscriptionIdsToQuery = new Set<ID>();
        for (ID subscriptionId : subscriptionIds) {
            if (BY_RATE_PLAN_ID_MAP.containsKey(subscriptionId)) {
                results.put(subscriptionId, BY_RATE_PLAN_ID_MAP.get(subscriptionId));
            } else {
                subscriptionIdsToQuery.add(subscriptionId);
            }
        }
        if (subscriptionIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Zuora__Subscription__c in :subscriptionIdsToQuery';
            Zuora__SubscriptionProductCharge__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                Zuora__SubscriptionProductCharge__c record = records[i];
                Set<Zuora__SubscriptionProductCharge__c> recordsForSubscription = BY_RATE_PLAN_ID_MAP.get(record.Zuora__Subscription__c);
                if (recordsForSubscription == null) {
                    recordsForSubscription = new Set<Zuora__SubscriptionProductCharge__c>();
                    BY_RATE_PLAN_ID_MAP.put(record.Zuora__Subscription__c, recordsForSubscription);
                    results.put(record.Zuora__Subscription__c, recordsForSubscription);
                }
                recordsForSubscription.add(record);
            }
        }
        return results;
    }

    public static Map<ID, Zuora__SubscriptionProductCharge__c> findByIds(Set<ID> recordIds) {
        Map<ID, Zuora__SubscriptionProductCharge__c> results = new Map<ID, Zuora__SubscriptionProductCharge__c>();
        Set<ID> recordIdsToQuery = new Set<ID>();
        for (ID recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (!recordIdsToQuery.isEmpty()) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            Zuora__SubscriptionProductCharge__c[] records = Database.query(soql);
            BY_ID_MAP.putAll(records);
            results.putAll(records);
        }
        return results;
    }

    public static Map<String, Zuora__SubscriptionProductCharge__c> findByChargeNumbers(Set<String> chargeNumbers) {
        Map<String, Zuora__SubscriptionProductCharge__c> results = new Map<String, Zuora__SubscriptionProductCharge__c>();
        Set<String> chargeNumbersToQuery = new Set<String>();
        for (String chargeNumber : chargeNumbers) {
            if (BY_CHARGE_NUMBER_MAP.containsKey(chargeNumber)) {
                results.put(chargeNumber, BY_CHARGE_NUMBER_MAP.get(chargeNumber));
            } else {
                chargeNumbersToQuery.add(chargeNumber);
            }
        }
        if (!chargeNumbersToQuery.isEmpty()) {
            String soql = SOQL_BASE + ' where Zuora__SubscriptionChargeNumber__c in :chargeNumbersToQuery';
            Zuora__SubscriptionProductCharge__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                Zuora__SubscriptionProductCharge__c record = records[i];
                BY_CHARGE_NUMBER_MAP.put(record.Zuora__SubscriptionChargeNumber__c, record);
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Zuora__SubscriptionChargeNumber__c, record);
            }
        }
        return results;
    }

    public static Map<String, Set<Zuora__SubscriptionProductCharge__c>> findBySubscriptionZuoraIds(Set<String> subscriptionZuoraIds) {
        Map<String, Set<Zuora__SubscriptionProductCharge__c>> results = new Map<String, Set<Zuora__SubscriptionProductCharge__c>>();
        Set<String> subscriptionZuoraIdsToQuery = new Set<String>();
        for (String subscriptionZuoraId : subscriptionZuoraIds) {
            if (BY_SUBSCRIPTION_ZUORA_ID_MAP.containsKey(subscriptionZuoraId)) {
                results.put(subscriptionZuoraId, BY_SUBSCRIPTION_ZUORA_ID_MAP.get(subscriptionZuoraId));
            } else {
                subscriptionZuoraIdsToQuery.add(subscriptionZuoraId);
            }
        }
        if (subscriptionZuoraIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Zuora__Subscription__r.Zuora__External_Id__c in :subscriptionZuoraIdsToQuery';
            Zuora__SubscriptionProductCharge__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                Zuora__SubscriptionProductCharge__c record = records[i];
                Set<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges = results.get(record.Zuora__Subscription__r.Zuora__External_Id__c);
                if (subscriptionProductCharges == null) {
                    subscriptionProductCharges = new Set<Zuora__SubscriptionProductCharge__c>();
                    results.put(record.Zuora__Subscription__r.Zuora__External_Id__c, subscriptionProductCharges);
                }
                subscriptionProductCharges.add(record);
                BY_SUBSCRIPTION_ZUORA_ID_MAP.put(record.Zuora__Subscription__r.Zuora__External_Id__c, subscriptionProductCharges);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<ID, Set<Zuora__SubscriptionProductCharge__c>> findByBillingAccountIds(Set<ID> billingAccountIds) {
        Map<ID, Set<Zuora__SubscriptionProductCharge__c>> results = new Map<ID, Set<Zuora__SubscriptionProductCharge__c>>();
        Set<String> billingAccountIdsToQuery = new Set<String>();
        for (String billingAccountId : billingAccountIds) {
            if (BY_BILLING_ACCOUNT_ID_MAP.containsKey(billingAccountId)) {
                results.put(billingAccountId, BY_BILLING_ACCOUNT_ID_MAP.get(billingAccountId));
            } else {
                billingAccountIdsToQuery.add(billingAccountId);
            }
        }
        if (billingAccountIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Zuora__Subscription__r.Zuora__CustomerAccount__c in :billingAccountIdsToQuery';
            Zuora__SubscriptionProductCharge__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                Zuora__SubscriptionProductCharge__c record = records[i];
                Set<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges = results.get(record.Zuora__Subscription__r.Zuora__CustomerAccount__c);
                if (subscriptionProductCharges == null) {
                    subscriptionProductCharges = new Set<Zuora__SubscriptionProductCharge__c>();
                    results.put(record.Zuora__Subscription__r.Zuora__CustomerAccount__c, subscriptionProductCharges);
                }
                subscriptionProductCharges.add(record);
                BY_BILLING_ACCOUNT_ID_MAP.put(record.Zuora__Subscription__r.Zuora__CustomerAccount__c, subscriptionProductCharges);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

}