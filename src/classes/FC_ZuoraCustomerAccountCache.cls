public class FC_ZuoraCustomerAccountCache {

    private static final String[] SELECT_FIELDS = new String[] { 'Id', 'Zuora__External_Id__c' };

    private static final Map<ID, Zuora__CustomerAccount__c> BY_ID_MAP = new Map<ID, Zuora__CustomerAccount__c>();
    private static final Map<String, Zuora__CustomerAccount__c> BY_ZUORA_ID_MAP = new Map<String, Zuora__CustomerAccount__c>();

    private static final String SELECT_CLAUSE;
    private static final String SOQL_BASE;

    static {
        SELECT_CLAUSE = 'select ' + String.join(SELECT_FIELDS, ',');
        SOQL_BASE = SELECT_CLAUSE + ' from Zuora__CustomerAccount__c ';
    }

    public static Map<ID, Zuora__CustomerAccount__c> findByIds(Set<ID> recordIds) {
        Map<ID, Zuora__CustomerAccount__c> results = new Map<ID, Zuora__CustomerAccount__c>();
        Set<ID> recordIdsToQuery = new Set<ID>();
        for (ID recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (!recordIdsToQuery.isEmpty() && Limits.getQueries() < Limits.getLimitQueries()) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            for (Zuora__CustomerAccount__c record : Database.query(soql)) {
                results.put(record.Id, record);
                BY_ID_MAP.put(record.Id, record);
                BY_ZUORA_ID_MAP.put(record.Zuora__External_Id__c, record);
            }
        }
        return results;
    }

    public static Map<String, Zuora__CustomerAccount__c> findByZuoraIds(Set<String> zuoraIds) {
        Map<String, Zuora__CustomerAccount__c> results = new Map<String, Zuora__CustomerAccount__c>();
        Set<String> zuoraIdsToQuery = new Set<String>();
        for (String zuoraId : zuoraIds) {
            if (BY_ZUORA_ID_MAP.containsKey(zuoraId)) {
                results.put(zuoraId, BY_ZUORA_ID_MAP.get(zuoraId));
            } else {
                zuoraIdsToQuery.add(zuoraId);
            }
        }
        if (!zuoraIdsToQuery.isEmpty() && Limits.getQueries() < Limits.getLimitQueries()) {
            String soql = SOQL_BASE + ' where Zuora__External_Id__c in :zuoraIdsToQuery';
            for (Zuora__CustomerAccount__c record : Database.query(soql)) {
                results.put(record.Zuora__External_Id__c, record);
                BY_ID_MAP.put(record.Id, record);
                BY_ZUORA_ID_MAP.put(record.Zuora__External_Id__c, record);
            }
        }
        return results;
    }

}