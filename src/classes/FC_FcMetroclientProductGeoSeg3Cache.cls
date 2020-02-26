public class FC_FcMetroclientProductGeoSeg3Cache {

    private static String[] SELECT_FIELDS = new String[]{
            'Id', 'Accounting_Code__c', 'Charge_Type__c', 'Geography__c', 'Geography_Type__c', 'Product_Geography__c',
            'Product_Geography__r.Geography__c', 'Product_Geography__r.Geography__r.SalesRegion__c', 'Seg3__c',
            '(select Name, Type from Tags where Type = \'Public\') Tags'
    };

    private static final Map<Id, FC_Metroclient_Product_Geography_Seg3__c> BY_ID_MAP =
            new Map<Id, FC_Metroclient_Product_Geography_Seg3__c>();
    private static final Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>> BY_ACCOUNTING_CODE_MAP =
            new Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>>();
    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from FC_Metroclient_Product_Geography_Seg3__c',
                new String[]{
                        String.join(SELECT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_ACCOUNTING_CODE_MAP.clear();
    }

    public static Map<ID, FC_Metroclient_Product_Geography_Seg3__c> findByIds(Set<ID> recordIds) {
        Map<ID, FC_Metroclient_Product_Geography_Seg3__c> results = new Map<ID, FC_Metroclient_Product_Geography_Seg3__c>();
        Set<ID> recordIdsToQuery = new Set<ID>();
        for (ID recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (recordIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            FC_Metroclient_Product_Geography_Seg3__c[] records = Database.query(soql);
            BY_ID_MAP.putAll(records);
            results.putAll(records);
        }
        return results;
    }

    public static Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>> findByAccountingCodes(Set<String> accountingCodes) {
        Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>> results = new Map<String, Set<FC_Metroclient_Product_Geography_Seg3__c>>();
        Set<String> accountingCodesToQuery = new Set<String>();
        for (String accountingCode : accountingCodes) {
            if (BY_ACCOUNTING_CODE_MAP.containsKey(accountingCode)) {
                results.put(accountingCode, BY_ACCOUNTING_CODE_MAP.get(accountingCode));
            } else {
                accountingCodesToQuery.add(accountingCode);
            }
        }
        if (accountingCodesToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Accounting_Code__c in :accountingCodesToQuery';
            FC_Metroclient_Product_Geography_Seg3__c[] records = Database.query(soql);
            Integer recordCount = records.size();
            for (Integer i = 0; i < recordCount; i++) {
                FC_Metroclient_Product_Geography_Seg3__c record = records[i];
                Set<FC_Metroclient_Product_Geography_Seg3__c> recordsForAccountingCode = BY_ACCOUNTING_CODE_MAP.get(record.Accounting_Code__c);
                if (recordsForAccountingCode == null) {
                    recordsForAccountingCode = new Set<FC_Metroclient_Product_Geography_Seg3__c>();
                    BY_ACCOUNTING_CODE_MAP.put(record.Accounting_Code__c, recordsForAccountingCode);
                    results.put(record.Accounting_Code__c, recordsForAccountingCode);
                }
                recordsForAccountingCode.add(record);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

}