public class FC_ContractCache {

    private static String[] CONTRACT_FIELDS = new String[]{
            'Id', 'FC_Price_Book__c', 'FC_Subscription_Number__c', 'FC_Subscription__c',
            'FC_Subscription__r.Zuora__CustomerAccount__c', 'FC_Subscription__r.Zuora__RenewalTerm__c',
            'FC_Subscription__r.Zuora__TermEndDate__c', 'FC_Subscription__r.Zuora__TermStartDate__c'
    };

    private static final Map<ID, Contract> BY_ID_MAP = new Map<ID, Contract>();
    private static final Map<String, Contract> BY_SUBSCRIPTION_NUMBER_MAP = new Map<String, Contract>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from Contract',
                new String[]{
                        String.join(CONTRACT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_SUBSCRIPTION_NUMBER_MAP.clear();
    }


    public static Map<ID, Contract> findByIds(Set<ID> recordIds) {
        Map<ID, Contract> results = new Map<ID, Contract>();
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
            for (Contract record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<String, Contract> findBySubscriptionNumbers(Set<String> subcriptionNumbers) {
        Map<String, Contract> results = new Map<String, Contract>();
        Set<String> recordNumbersToQuery = new Set<String>();
        for (String subscriptionNumber : subcriptionNumbers) {
            if (BY_SUBSCRIPTION_NUMBER_MAP.containsKey(subscriptionNumber)) {
                results.put(subscriptionNumber, BY_SUBSCRIPTION_NUMBER_MAP.get(subscriptionNumber));
            } else {
                recordNumbersToQuery.add(subscriptionNumber);
            }
        }
        if (!recordNumbersToQuery.isEmpty()) {
            String soql = SOQL_BASE + ' where FC_Subscription_Number__c in :recordNumbersToQuery';
            for (Contract record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                BY_SUBSCRIPTION_NUMBER_MAP.put(record.FC_Subscription_Number__c, record);
                results.put(record.FC_Subscription_Number__c, record);
            }
        }
        return results;


    }

}