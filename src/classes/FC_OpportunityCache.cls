public class FC_OpportunityCache {

    private static String[] OPPORTUNITY_FIELDS = new String[]{
            'Id', 'Amount', 'ContractId', 'Contract.FC_Subscription__c',
            'Contract.FC_Subscription__r.Zuora__TermSettingType__c', 'Channel_Type__c', 'FC_Annualize_New_Revenue__c',
            'FC_Initial_Term__c', 'FC_Renew__c', 'FC_Term_Type__c', 'Purchase_Type__c', 'Reason_For_Postponement__c',
            'MS_Segments__c', 'Pricebook2Id', 'RecordTypeId', 'RecordType.DeveloperName', 'RecordType.Name',
            'Renewal__c', 'StageName',
            '(select Id, echosign_dev1__Status__c from echosign_dev1__R00N70000001hM2REAU__r where echosign_dev1__Status__c = \'Signed\')',
            '(select Id from zqu__Quotes__r where Approval_Status__c = \'Approved\')'
    };

    private static final Map<ID, Opportunity> BY_ID_MAP = new Map<ID, Opportunity>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from Opportunity',
                new String[]{
                        String.join(OPPORTUNITY_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
    }

    public static Map<ID, Opportunity> findByIds(Set<ID> opportunityIds) {
        Map<ID, Opportunity> results = new Map<ID, Opportunity>();
        Set<ID> opportunityIdsToQuery = new Set<ID>();
        for (ID opportunityId : opportunityIds) {
            if (BY_ID_MAP.containsKey(opportunityId)) {
                results.put(opportunityId, BY_ID_MAP.get(opportunityId));
            } else {
                opportunityIdsToQuery.add(opportunityId);
            }
        }
        if (opportunityIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :opportunityIdsToQuery';
            for (Opportunity opportunityRecord : Database.query(soql)) {
                BY_ID_MAP.put(opportunityRecord.Id, opportunityRecord);
                results.put(opportunityRecord.Id, opportunityRecord);
            }
        }
        return results;
    }

}