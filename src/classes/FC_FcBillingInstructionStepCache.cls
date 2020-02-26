public class FC_FcBillingInstructionStepCache {

    private static final String[] SELECT_FIELDS = new String[]{
            'Id', 'Billing_Instruction_Set__c', 'Billing_Instruction_Set__r.Opportunity__c', 'Price__c',
            'RecordTypeId', 'RecordType.DeveloperName',
            '(select Name, Type from Tags where Type = \'Public\') Tags'
    };

    private static final Map<Id, FC_Billing_Instruction_Step__c> BY_ID_MAP = new Map<Id, FC_Billing_Instruction_Step__c>();
    private static final Map<Id, Set<FC_Billing_Instruction_Step__c>> BY_OPPORTUNITY_ID_MAP = new Map<Id, Set<FC_Billing_Instruction_Step__c>>();
    private static final Map<Id, Set<FC_Billing_Instruction_Step__c>> BY_BILLING_INSTRUCTION_SET_ID_MAP = new Map<Id, Set<FC_Billing_Instruction_Step__c>>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from FC_Billing_Instruction_Step__c',
                new String[]{
                        String.join(SELECT_FIELDS, ', ')
                });
    }

    public static voId clearCache() {
        BY_ID_MAP.clear();
        BY_OPPORTUNITY_ID_MAP.clear();
        BY_BILLING_INSTRUCTION_SET_ID_MAP.clear();
    }

    public static Map<Id, FC_Billing_Instruction_Step__c> findByIds(Set<Id> recordIds) {
        Map<Id, FC_Billing_Instruction_Step__c> results = new Map<Id, FC_Billing_Instruction_Step__c>();
        Set<Id> recordIdsToQuery = new Set<Id>();
        for (Id recordId : recordIds) {
            if (BY_ID_MAP.containsKey(recordId)) {
                results.put(recordId, BY_ID_MAP.get(recordId));
            } else {
                recordIdsToQuery.add(recordId);
            }
        }
        if (recordIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :recordIdsToQuery';
            for (FC_Billing_Instruction_Step__c record : Database.query(soql)) {
                BY_ID_MAP.put(record.Id, record);
                results.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<Id, Set<FC_Billing_Instruction_Step__c>> findByOpportunityIds(Set<Id> opportunityIds) {
        Map<Id, Set<FC_Billing_Instruction_Step__c>> results = new Map<Id, Set<FC_Billing_Instruction_Step__c>>();
        Set<Id> opportunityIdsToQuery = new Set<Id>();
        for (Id opportunityId : opportunityIds) {
            if (BY_OPPORTUNITY_ID_MAP.containsKey(opportunityId)) {
                results.put(opportunityId, BY_OPPORTUNITY_ID_MAP.get(opportunityId));
            } else {
                opportunityIdsToQuery.add(opportunityId);
            }
        }
        if (opportunityIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Billing_Instruction_Set__r.Opportunity__c in :opportunityIdsToQuery';
            for (FC_Billing_Instruction_Step__c record : Database.query(soql)) {
                Set<FC_Billing_Instruction_Step__c> records = results.get(record.Billing_Instruction_Set__r.Opportunity__c);
                if (records == null) {
                    records = new Set<FC_Billing_Instruction_Step__c>();
                    results.put(record.Billing_Instruction_Set__r.Opportunity__c, records);
                }
                records.add(record);
                BY_OPPORTUNITY_ID_MAP.put(record.Billing_Instruction_Set__r.Opportunity__c, records);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

    public static Map<Id, Set<FC_Billing_Instruction_Step__c>> findByBillingInstructionSetIds(Set<Id> billingInstructionSetIds) {
        Map<Id, Set<FC_Billing_Instruction_Step__c>> results = new Map<Id, Set<FC_Billing_Instruction_Step__c>>();
        Set<Id> billingInstructionSetIdsToQuery = new Set<Id>();
        for (Id billingInstructionSetId : billingInstructionSetIds) {
            if (BY_BILLING_INSTRUCTION_SET_ID_MAP.containsKey(billingInstructionSetId)) {
                results.put(billingInstructionSetId, BY_BILLING_INSTRUCTION_SET_ID_MAP.get(billingInstructionSetId));
            } else {
                billingInstructionSetIdsToQuery.add(billingInstructionSetId);
            }
        }
        if (billingInstructionSetIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Billing_Instruction_Set__c in :billingInstructionSetIdsToQuery';
            for (FC_Billing_Instruction_Step__c record : Database.query(soql)) {
                Set<FC_Billing_Instruction_Step__c> records = results.get(record.Billing_Instruction_Set__c);
                if (records == null) {
                    records = new Set<FC_Billing_Instruction_Step__c>();
                    results.put(record.Billing_Instruction_Set__c, records);
                }
                records.add(record);
                BY_BILLING_INSTRUCTION_SET_ID_MAP.put(record.Billing_Instruction_Set__c, records);
                BY_ID_MAP.put(record.Id, record);
            }
        }
        return results;
    }

}