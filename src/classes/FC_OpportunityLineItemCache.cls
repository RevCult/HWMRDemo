public with sharing class FC_OpportunityLineItemCache {

    private static String[] OPPORTUNITY_LINE_ITEM_FIELDS = new String[]{
            'Id', 'Billing_Frequency__c', 'FC_Bill_Case__c', 'FC_Billing_Instruction_Set__c',
            'FC_Product_Geography_Seg3__c', 'FC_Product_Geography_Seg3__r.Seg3__c', 'FC_UUID__c', 'OpportunityId',
            'Opportunity.Proof_of_Delivery_attached__c', 'Opportunity.Proof_Of_Delivery_Delivered_Date__c',
            'Opportunity.Scheduled_Delivery_Date__c'
    };

    private static final Map<ID, OpportunityLineItem> BY_ID_MAP = new Map<ID, OpportunityLineItem>();
    private static final Map<ID, OpportunityLineItem> BY_BILLING_INSTRUCTION_SET_ID_MAP = new Map<ID, OpportunityLineItem>();
    private static final Map<String, OpportunityLineItem> BY_UUID_MAP = new Map<String, OpportunityLineItem>();
    private static final Map<Id, Set<OpportunityLineItem>> BY_OPPORTUNITY_ID_MAP = new Map<Id, Set<OpportunityLineItem>>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from OpportunityLineItem',
                new String[]{
                        String.join(OPPORTUNITY_LINE_ITEM_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_BILLING_INSTRUCTION_SET_ID_MAP.clear();
        BY_UUID_MAP.clear();
        BY_OPPORTUNITY_ID_MAP.clear();
    }

    public static Map<ID, OpportunityLineItem> findByIds(Set<ID> opportunityLineItemIds) {
        Map<ID, OpportunityLineItem> results = new Map<ID, OpportunityLineItem>();
        Set<ID> opportunityLineItemIdsToQuery = new Set<ID>();
        for (ID opportunityLineItemId : opportunityLineItemIds) {
            if (BY_ID_MAP.containsKey(opportunityLineItemId)) {
                results.put(opportunityLineItemId, BY_ID_MAP.get(opportunityLineItemId));
            } else {
                opportunityLineItemIdsToQuery.add(opportunityLineItemId);
            }
        }
        if (opportunityLineItemIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :opportunityLineItemIdsToQuery';
            for (OpportunityLineItem record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<String, OpportunityLineItem> findByUuids(Set<String> opportunityLineItemUuids) {
        Map<String, OpportunityLineItem> results = new Map<String, OpportunityLineItem>();
        Set<String> opportunityLineItemUuidsToQuery = new Set<STRING>();
        for (String opportunityLineItemUuid : opportunityLineItemUuids) {
            if (BY_UUID_MAP.containsKey(opportunityLineItemUuid)) {
                results.put(opportunityLineItemUuid, BY_UUID_MAP.get(opportunityLineItemUuid));
            } else {
                opportunityLineItemUuidsToQuery.add(opportunityLineItemUuid);
            }
        }
        if (opportunityLineItemUuidsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where FC_UUID__c in :opportunityLineItemUuidsToQuery';
            for (OpportunityLineItem record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                BY_UUID_MAP.put(record.FC_UUID__c, record);
                results.put(record.FC_UUID__c, record);
            }
        }
        return results;
    }

    public static Map<ID, OpportunityLineItem> findByBillingInstructionSetIds(Set<ID> billingInstructionSetIds) {
        Map<ID, OpportunityLineItem> results = new Map<ID, OpportunityLineItem>();
        Set<ID> billingInstructionSetIdsToQuery = new Set<ID>();
        for (ID billingInstructionSetId : billingInstructionSetIds) {
            if (BY_BILLING_INSTRUCTION_SET_ID_MAP.containsKey(billingInstructionSetId)) {
                results.put(billingInstructionSetId, BY_BILLING_INSTRUCTION_SET_ID_MAP.get(billingInstructionSetId));
            } else {
                billingInstructionSetIdsToQuery.add(billingInstructionSetId);
            }
        }
        if (billingInstructionSetIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where FC_Billing_Instruction_Set__c in :billingInstructionSetIdsToQuery';
            for (OpportunityLineItem record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                BY_BILLING_INSTRUCTION_SET_ID_MAP.put(record.FC_Billing_Instruction_Set__c, record);
                results.put(record.FC_Billing_Instruction_Set__c, record);
            }
        }
        return results;
    }

    public static Map<Id, Set<OpportunityLineItem>> findByOpportunityIds(Set<Id> opportunityIds) {
        Map<Id, Set<OpportunityLineItem>> results = new Map<Id, Set<OpportunityLineItem>>();
        Set<Id> opportunityIdsToQuery = new Set<Id>();
        for (Id opportunityId : opportunityIds) {
            if (BY_OPPORTUNITY_ID_MAP.containsKey(opportunityId)) {
                results.put(opportunityId, BY_OPPORTUNITY_ID_MAP.get(opportunityId));
            } else {
                opportunityIdsToQuery.add(opportunityId);
            }
        }
        if (opportunityIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where OpportunityId in :opportunityIdsToQuery';
            for (OpportunityLineItem record : Database.query(soql)) {
                Set<OpportunityLineItem> records = results.get(record.OpportunityId);
                if (records == null) {
                    records = new Set<OpportunityLineItem>();
                    results.put(record.OpportunityId, records);
                }
                records.add(record);
                BY_OPPORTUNITY_ID_MAP.put(record.OpportunityId, records);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

}