public class FC_AccountCache {

    private static String[] ACCOUNT_FIELDS = new String[]{
            'Id', 'FC_Ultimate_Parent_Account_ID_Formula__c', 'ParentId', 'Parent.ParentId', 'Parent.Parent.ParentId',
            'Parent.Parent.Parent.ParentId', 'Parent.Parent.Parent.Parent.ParentId',
            'Parent.Parent.Parent.Parent.Parent.ParentId'
    };

    private static final Map<ID, Account> BY_ID_MAP = new Map<ID, Account>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from Account',
                new String[]{
                        String.join(ACCOUNT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
    }

    public static Map<ID, Account> findByIds(Set<ID> recordIds) {
        Map<ID, Account> results = new Map<ID, Account>();
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
            for (Account record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

}