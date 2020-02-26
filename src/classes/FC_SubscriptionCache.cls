public class FC_SubscriptionCache {

    private static String[] SUBSCRIPTION_FIELDS = new String[]{
            'Id', 'Opportunity__c', 'Zuora__Account__c', 'Zuora__CustomerAccount__c', 'Zuora__NextChargeDate__c',
            'Zuora__SubscriptionNumber__c', 'Zuora__SubscriptionStartDate__c', 'Zuora__TermSettingType__c', 'Zuora__TermStartDate__c'
    };

    private static final Map<ID, Zuora__Subscription__c> BY_ID_MAP = new Map<ID, Zuora__Subscription__c>();
    private static final Map<ID, Set<Zuora__Subscription__c>> BY_ACCOUNT_ID_MAP = new Map<ID, Set<Zuora__Subscription__c>>();
    private static final Map<String, Zuora__Subscription__c> BY_SUBSCRIPTION_NUMBER_MAP = new Map<String, Zuora__Subscription__c>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from Zuora__Subscription__c',
                new String[]{
                        String.join(SUBSCRIPTION_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_ACCOUNT_ID_MAP.clear();
        BY_SUBSCRIPTION_NUMBER_MAP.clear();
    }

    public static Map<ID, Zuora__Subscription__c> findByIds(Set<ID> recordIds) {
        Map<ID, Zuora__Subscription__c> results = new Map<ID, Zuora__Subscription__c>();
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
            for (Zuora__Subscription__c record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<String, Zuora__Subscription__c> findBySubscriptionNumber(Set<String> subscriptionNumbers) {
        Map<String, Zuora__Subscription__c> results = new Map<String, Zuora__Subscription__c>();
        Set<String> recordNumbersToQuery = new Set<String>();
        for (String subscriptionNumber : subscriptionNumbers) {
            if (BY_SUBSCRIPTION_NUMBER_MAP.containsKey(subscriptionNumber)) {
                results.put(subscriptionNumber, BY_SUBSCRIPTION_NUMBER_MAP.get(subscriptionNumber));
            } else {
                recordNumbersToQuery.add(subscriptionNumber);
            }
        }
        if (!recordNumbersToQuery.isEmpty()) {
            String soql = SOQL_BASE + ' where Zuora__SubscriptionNumber__c in :recordNumbersToQuery';
            for (Zuora__Subscription__c record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                BY_SUBSCRIPTION_NUMBER_MAP.put(record.Zuora__SubscriptionNumber__c, record);
                results.put(record.Zuora__SubscriptionNumber__c, record);
            }
        }
        return results;
    }


    public static Map<ID, Set<Zuora__Subscription__c>> findByAccountIds(Set<ID> accountIds) {
        Map<ID, Set<Zuora__Subscription__c>> results = new Map<ID, Set<Zuora__Subscription__c>>();
        Set<ID> accountIdsToQuery = new Set<ID>();
        for (String accountId : accountIds) {
            if (BY_ACCOUNT_ID_MAP.containsKey(accountId)) {
                results.put(accountId, BY_ACCOUNT_ID_MAP.get(accountId));
            } else {
                accountIdsToQuery.add(accountId);
            }
        }
        if (accountIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Zuora__Account__c in :accountIdsToQuery';
            for (Zuora__Subscription__c subscriptionRecord : Database.query(soql)) {
                Set<Zuora__Subscription__c> subscriptions = results.get(subscriptionRecord.Zuora__Account__c);
                if (subscriptions == null) {
                    subscriptions = new Set<Zuora__Subscription__c>();
                    results.put(subscriptionRecord.Zuora__Account__c, subscriptions);
                }
                subscriptions.add(subscriptionRecord);
                BY_ACCOUNT_ID_MAP.put(subscriptionRecord.Zuora__Account__c, subscriptions);
                BY_ID_MAP.put(subscriptionRecord.Id, subscriptionRecord);
            }
        }
        return results;
    }

}