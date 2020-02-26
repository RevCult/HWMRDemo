public class FC_ProductRatePlanChargeCache {

    private static String[] PRODUCT_RATE_PLAN_CHARGE_FIELDS = new String[]{
            'Id', 'FC_Lookup_Key__c', 'FC_Recognized_Revenue_Account__c', 'zqu__ListPrice__c',
            'zqu__ProductRatePlan__c', 'zqu__RecurringPeriod__c', 'zqu__Type__c', 'zqu__ZuoraId__c',
            'zqu__ProductRatePlan__r.Is_Retainer_Rate_Plan__c',
            'zqu__ProductRatePlan__r.Record_Id__c', 'zqu__ProductRatePlan__r.Segment3__c',
            'zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c',
            'zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c',
            'zqu__ProductRatePlan__r.zqu__Product__c',
            'zqu__ProductRatePlan__r.zqu__ZProduct__r.Is_BPM_Product__c',
            'zqu__ProductRatePlan__r.zqu__ZProduct__r.Is_Consulting_Product__c',
            'zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c',
            'zqu__ProductRatePlan__r.zqu__ZuoraId__c'
    };

    private static final Map<ID, zqu__ProductRatePlanCharge__c> BY_ID_MAP = new Map<ID, zqu__ProductRatePlanCharge__c>();
    private static final Map<String, zqu__ProductRatePlanCharge__c> BY_ZUORA_ID_MAP = new Map<String, zqu__ProductRatePlanCharge__c>();
    private static final Map<String, zqu__ProductRatePlanCharge__c> BY_FC_LOOKUP_KEY_MAP = new Map<String, zqu__ProductRatePlanCharge__c>();
    private static final Map<String, Set<zqu__ProductRatePlanCharge__c>> BY_RECOGNIZED_REVENUE_ACCOUNT_MAP = new Map<String, Set<zqu__ProductRatePlanCharge__c>>();
    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from zqu__ProductRatePlanCharge__c',
                new String[]{
                        String.join(PRODUCT_RATE_PLAN_CHARGE_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_ZUORA_ID_MAP.clear();
        BY_FC_LOOKUP_KEY_MAP.clear();
        BY_RECOGNIZED_REVENUE_ACCOUNT_MAP.clear();
    }

    public static Map<ID, zqu__ProductRatePlanCharge__c> findByIds(Set<ID> productRatePlanChargeIds) {
        Map<ID, zqu__ProductRatePlanCharge__c> results = new Map<ID, zqu__ProductRatePlanCharge__c>();
        Set<ID> productRatePlanChargeIdsToQuery = new Set<ID>();
        for (ID productRatePlanChargeId : productRatePlanChargeIds) {
            if (BY_ID_MAP.containsKey(productRatePlanChargeId)) {
                results.put(productRatePlanChargeId, BY_ID_MAP.get(productRatePlanChargeId));
            } else {
                productRatePlanChargeIdsToQuery.add(productRatePlanChargeId);
            }
        }
        if (productRatePlanChargeIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :productRatePlanChargeIdsToQuery';
            for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : Database.query(soql)) {
                BY_FC_LOOKUP_KEY_MAP.put(productRatePlanChargeRecord.FC_Lookup_Key__c, productRatePlanChargeRecord);
                BY_ZUORA_ID_MAP.put(productRatePlanChargeRecord.zqu__ZuoraId__c, productRatePlanChargeRecord);
                BY_ID_MAP.put(productRatePlanChargeRecord.Id, productRatePlanChargeRecord);
                results.put(productRatePlanChargeRecord.Id, productRatePlanChargeRecord);
            }
        }
        return results;
    }

    public static Map<String, Set<zqu__ProductRatePlanCharge__c>> findWithActiveRatePlanByRecognizedRevenueAccount(Set<String> recognizedRevenueAccounts) {
        Map<String, Set<zqu__ProductRatePlanCharge__c>> results = new Map<String, Set<zqu__ProductRatePlanCharge__c>>();
        Set<String> recognizedRevenueAccountsToQuery = new Set<String>();
        for (String recognizedRevenueAccount : recognizedRevenueAccounts) {
            if (BY_RECOGNIZED_REVENUE_ACCOUNT_MAP.containsKey(recognizedRevenueAccount)) {
                results.put(recognizedRevenueAccount, BY_RECOGNIZED_REVENUE_ACCOUNT_MAP.get(recognizedRevenueAccount));
            } else {
                recognizedRevenueAccountsToQuery.add(recognizedRevenueAccount);
            }
        }
        if (recognizedRevenueAccountsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where FC_Recognized_Revenue_Account__c in :recognizedRevenueAccountsToQuery ' +
                    'and zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c <= TODAY ' +
                    'and zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c >= TODAY ' +
                    'and zqu__ProductRatePlan__r.zqu__Deleted__c = false and zqu__Deleted__c = false';
            for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : Database.query(soql)) {
                Set<zqu__ProductRatePlanCharge__c> productRatePlanCharges = BY_RECOGNIZED_REVENUE_ACCOUNT_MAP.get(productRatePlanChargeRecord.FC_Recognized_Revenue_Account__c);
                if (productRatePlanCharges == null) {
                    productRatePlanCharges = new Set<zqu__ProductRatePlanCharge__c>();
                    BY_RECOGNIZED_REVENUE_ACCOUNT_MAP.put(productRatePlanChargeRecord.FC_Recognized_Revenue_Account__c, productRatePlanCharges);
                    results.put(productRatePlanChargeRecord.FC_Recognized_Revenue_Account__c, productRatePlanCharges);
                }
                productRatePlanCharges.add(productRatePlanChargeRecord);
                BY_FC_LOOKUP_KEY_MAP.put(productRatePlanChargeRecord.FC_Lookup_Key__c, productRatePlanChargeRecord);
                BY_ZUORA_ID_MAP.put(productRatePlanChargeRecord.zqu__ZuoraId__c, productRatePlanChargeRecord);
                BY_ID_MAP.put(productRatePlanChargeRecord.Id, productRatePlanChargeRecord);
            }
        }
        return results;
    }


    public static Map<String, zqu__ProductRatePlanCharge__c> findByFcLookupKeys(Set<String> fcLookupKeys) {
        Map<String, zqu__ProductRatePlanCharge__c> results = new Map<String, zqu__ProductRatePlanCharge__c>();
        Set<String> fcLookupKeysToQuery = new Set<String>();
        for (String fcLookupKey : fcLookupKeys) {
            if (BY_FC_LOOKUP_KEY_MAP.containsKey(fcLookupKey)) {
                results.put(fcLookupKey, BY_FC_LOOKUP_KEY_MAP.get(fcLookupKey));
            } else {
                fcLookupKeysToQuery.add(fcLookupKey);
            }
        }
        if (fcLookupKeysToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where FC_Lookup_Key__c in :fcLookupKeysToQuery';
            for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : Database.query(soql)) {
                results.put(productRatePlanChargeRecord.FC_Lookup_Key__c, productRatePlanChargeRecord);
                BY_FC_LOOKUP_KEY_MAP.put(productRatePlanChargeRecord.FC_Lookup_Key__c, productRatePlanChargeRecord);
                BY_ZUORA_ID_MAP.put(productRatePlanChargeRecord.zqu__ZuoraId__c, productRatePlanChargeRecord);
                BY_ID_MAP.put(productRatePlanChargeRecord.Id, productRatePlanChargeRecord);
            }
        }
        return results;
    }

    public static Map<String, zqu__ProductRatePlanCharge__c> findByZuoraIds(Set<String> zuoraIds) {
        Map<String, zqu__ProductRatePlanCharge__c> results = new Map<String, zqu__ProductRatePlanCharge__c>();
        Set<String> zuoraIdsToQuery = new Set<String>();
        for (String zuoraId : zuoraIds) {
            if (BY_ZUORA_ID_MAP.containsKey(zuoraId)) {
                results.put(zuoraId, BY_ZUORA_ID_MAP.get(zuoraId));
            } else {
                zuoraIdsToQuery.add(zuoraId);
            }
        }
        if (zuoraIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where zqu__ZuoraId__c in :zuoraIdsToQuery';
            for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : Database.query(soql)) {
                results.put(productRatePlanChargeRecord.zqu__ZuoraId__c, productRatePlanChargeRecord);
                BY_FC_LOOKUP_KEY_MAP.put(productRatePlanChargeRecord.FC_Lookup_Key__c, productRatePlanChargeRecord);
                BY_ZUORA_ID_MAP.put(productRatePlanChargeRecord.zqu__ZuoraId__c, productRatePlanChargeRecord);
                BY_ID_MAP.put(productRatePlanChargeRecord.Id, productRatePlanChargeRecord);
            }
        }
        return results;
    }

}