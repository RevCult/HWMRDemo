public class FC_FcBillingInstructionSetCache {

    private static final String[] SELECT_FIELDS = new String[]{
            'Id', 'Opportunity__c', 'Opportunity__r.FC_Initial_Term__c', 'Opportunity__r.FC_Term_End_Date__c',
            'Opportunity_Line_Item_ID__c', 'Instruction_Parameters__c', 'Template__c', 'Template__r.Name'
    };

    private static final Map<ID, FC_Billing_Instruction_Set__c> BY_ID_MAP = new Map<ID, FC_Billing_Instruction_Set__c>();
    private static final Map<ID, FC_Billing_Instruction_Set__c> BY_OPPORTUNITY_LINE_ITEM_ID_MAP = new Map<ID, FC_Billing_Instruction_Set__c>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from FC_Billing_Instruction_Set__c',
                new String[]{
                        String.join(SELECT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_OPPORTUNITY_LINE_ITEM_ID_MAP.clear();
    }

    public static Map<ID, FC_Billing_Instruction_Set__c> findByIds(Set<ID> recordIds) {
        Map<ID, FC_Billing_Instruction_Set__c> results = new Map<ID, FC_Billing_Instruction_Set__c>();
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
            for (FC_Billing_Instruction_Set__c record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<ID, FC_Billing_Instruction_Set__c> findByOpportunityLineItemIds(Set<ID> opportunityLineItemIds) {
        Map<ID, FC_Billing_Instruction_Set__c> results = new Map<ID, FC_Billing_Instruction_Set__c>();
        Set<ID> opportunityLineItemIdsToQuery = new Set<ID>();
        for (ID opportunityLineItemId : opportunityLineItemIds) {
            if (BY_OPPORTUNITY_LINE_ITEM_ID_MAP.containsKey(opportunityLineItemId)) {
                results.put(opportunityLineItemId, BY_OPPORTUNITY_LINE_ITEM_ID_MAP.get(opportunityLineItemId));
            } else {
                opportunityLineItemIdsToQuery.add(opportunityLineItemId);
            }
        }
        if (opportunityLineItemIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Opportunity_Line_Item_ID__c in :opportunityLineItemIdsToQuery';
            for (FC_Billing_Instruction_Set__c record : Database.query(soql)) {
                try {
                    ID opportunityLineItemId = Id.valueOf(record.Opportunity_Line_Item_ID__c);
                    BY_OPPORTUNITY_LINE_ITEM_ID_MAP.put(opportunityLineItemId, record);
                    results.put(opportunityLineItemId, record);
                    BY_ID_MAP.put(record.Id, record);
                } catch (Exception e) {
                    // Do nothing
                }
            }
        }
        return results;
    }

}