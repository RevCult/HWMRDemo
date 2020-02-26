public class FC_MetrostudySalesRegionAssignmentCache {

    private static String[] METROSTUDY_SALES_REGION_ASSIGNMENT_FIELDS = new String[]{
            'Id', 'SalesRegion__c', 'Role__c', 'User__c'
    };

    private static final Map<Id, MetrostudySalesRegionAssignment__c> BY_ID_MAP =
            new Map<Id, MetrostudySalesRegionAssignment__c>();
    private static final Map<Id, Set<MetrostudySalesRegionAssignment__c>> BY_SALES_REGION_ID_MAP =
            new Map<Id, Set<MetrostudySalesRegionAssignment__c>>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from MetrostudySalesRegionAssignment__c',
                new String[]{
                        String.join(METROSTUDY_SALES_REGION_ASSIGNMENT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_SALES_REGION_ID_MAP.clear();
    }

    public static Map<Id, MetrostudySalesRegionAssignment__c> findByIds(Set<Id> recordIds) {
        Map<Id, MetrostudySalesRegionAssignment__c> results = new Map<Id, MetrostudySalesRegionAssignment__c>();
        Set<Id> recordIdsToQuery = new Set<Id>();
        for (Id recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (!recordIdsToQuery.isEmpty()) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            MetrostudySalesRegionAssignment__c[] records = Database.query(soql);
            BY_ID_MAP.putAll(records);
            results.putAll(records);
        }
        return results;
    }

    public static Map<Id, Set<MetrostudySalesRegionAssignment__c>> findBySalesRegionIds(Set<Id> salesRegionIds) {
        Map<Id, Set<MetrostudySalesRegionAssignment__c>> results = new Map<Id, Set<MetrostudySalesRegionAssignment__c>>();
        Set<Id> salesRegionIdsToQuery = new Set<Id>();
        for (Id salesRegionId : salesRegionIds) {
            if (BY_SALES_REGION_ID_MAP.containsKey(salesRegionId)) {
                results.put(salesRegionId, BY_SALES_REGION_ID_MAP.get(salesRegionId));
            } else {
                salesRegionIdsToQuery.add(salesRegionId);
            }
        }
        if (salesRegionIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where SalesRegion__c in :salesRegionIdsToQuery';
            MetrostudySalesRegionAssignment__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                MetrostudySalesRegionAssignment__c record = records[i];
                Set<MetrostudySalesRegionAssignment__c> recordsForSalesRegion = results.get(record.SalesRegion__c);
                if (recordsForSalesRegion == null) {
                    recordsForSalesRegion = new Set<MetrostudySalesRegionAssignment__c>();
                    results.put(record.SalesRegion__c, recordsForSalesRegion);
                }
                recordsForSalesRegion.add(record);
                BY_SALES_REGION_ID_MAP.put(record.SalesRegion__c, recordsForSalesRegion);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

}