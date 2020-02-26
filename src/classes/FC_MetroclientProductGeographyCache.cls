public class FC_MetroclientProductGeographyCache {

    private static String[] SELECT_FIELDS = new String[]{
            'Id', 'Name', 'ProductGeographyType__c', 'ProductGeographyType__r.Name',
            'ProductGeographyType__r.Product__c',
            'ProductGeographyType__r.Product__r.SubscriptionOnly__c',
            'ProductGeographyType__r.Product__r.ZuoraSku__c'
    };

    private static final Map<Id, MetroclientProductGeography__c> BY_ID_MAP =
            new Map<Id, MetroclientProductGeography__c>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from MetroclientProductGeography__c',
                new String[]{
                        String.join(SELECT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
    }

    public static Map<Id, MetroclientProductGeography__c> findByIds(Set<Id> recordIds) {
        Map<Id, MetroclientProductGeography__c> results = new Map<Id, MetroclientProductGeography__c>();
        Set<Id> recordIdsToQuery = new Set<ID>();
        for (Id recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (recordIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            for (MetroclientProductGeography__c record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

}