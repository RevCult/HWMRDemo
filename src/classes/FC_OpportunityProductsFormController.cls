public with sharing class FC_OpportunityProductsFormController {

    public final Opportunity OPPORTUNITY_RECORD;

    public ID defaultBillingInstructionTemplateId {

        get {
            if (defaultBillingInstructionTemplateId == null) {
                FC_Billing_Instruction_Settings__c config = FC_Billing_Instruction_Settings__c.getOrgDefaults();
                defaultBillingInstructionTemplateId = config.Default_Billing_Instruction_Template_ID__c;
            }
            return defaultBillingInstructionTemplateId;
        }

        private set;

    }

    public FC_Billing_Instruction_Template__c[] billingInstructionTemplates {

        get {
            if (billingInstructionTemplates == null) {
                billingInstructionTemplates = [
                        select Id, Name, Custom_Javascript_Visualforce_Page__c
                        from FC_Billing_Instruction_Template__c
                        where Custom_Javascript_Visualforce_Page__c != ''
                        and Custom_Javascript_Visualforce_Page__c != null
                ];
            }
            return billingInstructionTemplates;
        }

        private set;

    }

    public SelectOption[] pricebook2Options {

        get {
            if (pricebook2Options == null) {
                pricebook2Options = new List<SelectOption>{
                        new SelectOption('', '-- Choose One --')
                };
                for (Pricebook2 pricebook2Record : [select Id, Name from Pricebook2 where IsActive = true order by Name]) {
                    pricebook2Options.add(new SelectOption(pricebook2Record.Id, pricebook2Record.Name));
                }
            }
            return pricebook2Options;
        }

        private set;

    }

    public FC_OpportunityProductsFormController(ApexPages.StandardController controller) {
        this.OPPORTUNITY_RECORD = (Opportunity) controller.getRecord();
    }

    public void saveOpportunityRecord() {
        update this.OPPORTUNITY_RECORD;
    }

    @RemoteAction
    @ReadOnly
    public static String getOpportunityLineItemsJson(Id opportunityId) {
        OpportunityLineItem[] results = [
                select Id, Billing_Frequency__c, FC_Bill_Case__c, FC_Billing_Instruction_Set__c, FC_Effective_Date__c,
                        FC_Geography__c, FC_Geography_Type__c, FC_Metrostudy_Product__c, FC_Original_Sale_Price__c,
                        FC_Product_Geography_Seg3__c, FC_Sale_Price__c, FC_Seg3__c, FC_UUID__c, FC_Zuora_Action__c,
                        MS_Segment__c, OpportunityId, PricebookEntryId, Product2Id, UnitPrice
                from OpportunityLineItem
                where OpportunityId = :opportunityId
                limit 2000
        ];
        return JSON.serialize(results, false);
    }

    @RemoteAction
    @ReadOnly
    public static ZquProductRatePlanQueryResult queryProductRatePlans(RemoteQueryParameters queryParameters) {

        Map<String, String> fieldTemplateMap = new Map<String, String>{
                'Name' => '{0} like \'\'%{1}%\'\''
        };

        String soqlBase = 'select Id, Name, Product_Name__c from zqu__ProductRatePlan__c ';
        String soqlCountBase = 'select count() from zqu__ProductRatePlan__c ';

        String[] filterCriteria = new List<String>{
                'zqu__Deleted__c = false'
        };

        Integer pos = 0;
        Integer limitValue = 50;
        if (queryParameters != null) {
            if (queryParameters.filter != null) {
                for (String filterKey : queryParameters.filter.keySet()) {
                    if (fieldTemplateMap.containsKey(filterKey)) {

                        // If Name filter contains a valid ID, then search by ID instead.
                        Id filteredId = null;
                        if (filterKey == 'Name') {
                            try {
                                filteredId = Id.valueOf(queryParameters.filter.get(filterKey));
                            } catch (Exception e) {
                                // Do nothing
                            }
                        }
                        if (filteredId == null) {
                            filterCriteria.add(String.format(fieldTemplateMap.get(filterKey), new String[]{
                                    filterKey, String.escapeSingleQuotes(queryParameters.filter.get(filterKey))
                            }));
                        } else {
                            filterCriteria.add(String.format('Id = \'\'{0}\'\'', new String[]{
                                    filteredId
                            }));
                        }

                    }
                }
            }
            if (queryParameters.count != null) {
                limitValue = queryParameters.count;
            }
            if (queryParameters.start != null) {
                pos = queryParameters.start;
            }
        }

        String limitOffsetClause = String.format(' limit {0} offset {1} ', new String[]{
                String.valueOf(limitValue),
                String.valueOf(pos)
        });

        String whereClause = '';
        String[] orCriteria = new List<String>();
        if (!filterCriteria.isEmpty()) {
            orCriteria.add(String.format('({0})', new String[]{
                    String.join(filterCriteria, ' and ')
            }));
        }
        if (!orCriteria.isEmpty()) {
            whereClause = String.format('where {0}', new String[]{
                    String.join(orCriteria, ' or ')
            });
        }


        String soql = soqlBase + whereClause + ' order by Name ' + limitOffsetClause ;
        String soqlCount = soqlCountBase + whereClause;

        return new ZquProductRatePlanQueryResult(Database.query(soql), pos,
                Math.min(Database.countQuery(soqlCount), 2000));
    }

    @RemoteAction
    @ReadOnly
    public static RemoteOption[] getFcMetroclientProductGeographySeg3sByIdsAndOpportunityId(Id[] seg3RecordIds, Id opportunityId) {
        Set<RemoteOption> resultSet = new Set<RemoteOption>();

        for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                select Id, Metrostudy_Product_Geography_Seg3__c,
                        Metrostudy_Product_Geography_Seg3__r.Metrostudy_Product__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :opportunityId
        ]) {
            if (billingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c != null) {
                resultSet.add(new RemoteOption(billingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c,
                        billingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__r.Metrostudy_Product__c));
            }
        }
        for (FC_Metroclient_Product_Geography_Seg3__c seg3Record : [
                select Id, Metrostudy_Product__c
                from FC_Metroclient_Product_Geography_Seg3__c
                where Id in :seg3RecordIds
        ]) {
            resultSet.add(new RemoteOption(seg3Record.Id, seg3Record.Metrostudy_Product__c));
        }

        return new List<RemoteOption>(resultSet);
    }

    @RemoteAction
    @ReadOnly
    public static FcMetroclientProductGeographySeg3QueryResult queryFcMetroclientProductGeographySeg3(
            RemoteQueryParameters queryParameters, Boolean showExcludedRecords, Id pricebook2Id) {

        Map<String, String> fieldTemplateMap = new Map<String, String>{
                'Metrostudy_Product__c' => '{0} like \'\'%{1}%\'\'',
                'Geography__c' => '{0} like \'\'%{1}%\'\'',
                'Product_Rate_Plan_Name__c' => '{0} like \'\'%{1}%\'\''
        };
        Set<String> selectableCriteriaFields = new Set<String>{
                'Geography_Type__c', 'Seg3__c', 'Charge_Type__c'
        };

        String soqlBase = 'select Id, Annual_List_Price__c, Accounting_Code__c, Charge_Type__c, Default_Billing_Instruction_Template__c, ' +
                'Dependent_Seg3__c, Exclude_From_Product_Selector__c, Execute_Immediately__c, Geography__c,' +
                'Geography_Type__c, Metrostudy_Product__c, Monthly_List_Price__c, One_Time_List_Price__c, Product__c, ' +
                'Product_Geography__c, Product_Rate_Plan__c, Quarterly_List_Price__c, ' +
                'Product_Rate_Plan_Name__c, Seg3__c, Semi_Annual_List_Price__c, (select Name from Tags where Type = \'Public\') Tags ' +
                'from FC_Metroclient_Product_Geography_Seg3__c ';
        String soqlCountBase = 'select count() from FC_Metroclient_Product_Geography_Seg3__c ';

        String[] filterCriteria = new List<String>();

        if (pricebook2Id != null) {
            filterCriteria.add('Product__c in (select Product2Id from PricebookEntry where Pricebook2Id = :pricebook2Id)');
        }

        if (!showExcludedRecords) {
            filterCriteria.add('Exclude_From_Product_Selector__c = false');
        }

        Integer pos = 0;
        Integer limitValue = 50;
        if (queryParameters != null) {
            if (queryParameters.filter != null) {
                for (String filterKey : queryParameters.filter.keySet()) {
                    if (fieldTemplateMap.containsKey(filterKey)) {

                        // If Metrostudy_Product__c filter contains a valid ID, then search by ID instead.
                        Id filteredId = null;
                        if (filterKey == 'Metrostudy_Product__c') {
                            try {
                                filteredId = Id.valueOf(queryParameters.filter.get(filterKey));
                            } catch (Exception e) {
                                // Do nothing
                            }
                        }
                        if (filteredId == null) {
                            filterCriteria.add(String.format(fieldTemplateMap.get(filterKey), new String[]{
                                    filterKey, String.escapeSingleQuotes(queryParameters.filter.get(filterKey))
                            }));
                        } else {
                            filterCriteria.add(String.format('Id = \'\'{0}\'\'', new String[]{
                                    filteredId
                            }));
                        }

                    }

                    if (selectableCriteriaFields.contains(filterKey) &&
                            String.isNotBlank(queryParameters.filter.get(filterKey))) {

                        // Split values on comma
                        String[] criteriaValues = queryParameters.filter.get(filterKey).split(',');
                        String[] quotedCriteriaValues = new List<String>();
                        for (String criteriaValue : criteriaValues) {
                            quotedCriteriaValues.add(String.format('\'\'{0}\'\'', new String[]{
                                    String.escapeSingleQuotes(criteriaValue)
                            }));
                        }
                        filterCriteria.add(String.format('{0} in ({1})', new String[]{
                                filterKey, String.join(quotedCriteriaValues, ', ')
                        }));
                    }
                }
            }
            if (queryParameters.count != null) {
                limitValue = queryParameters.count;
            }
            if (queryParameters.start != null) {
                pos = queryParameters.start;
            }
        }

        String limitOffsetClause = String.format(' limit {0} offset {1} ', new String[]{
                String.valueOf(limitValue),
                String.valueOf(pos)
        });

        String whereClause = '';
        String[] orCriteria = new List<String>();
        if (!filterCriteria.isEmpty()) {
            orCriteria.add(String.format('({0})', new String[]{
                    String.join(filterCriteria, ' and ')
            }));
        }

        if (!orCriteria.isEmpty()) {
            whereClause = String.format('where {0}', new String[]{
                    String.join(orCriteria, ' or ')
            });
        }
        String soql = soqlBase + whereClause + ' order by Metrostudy_Product__c ' + limitOffsetClause ;
        String soqlCount = soqlCountBase + whereClause;

        return new FcMetroclientProductGeographySeg3QueryResult(Database.query(soql), pos,
                Math.min(Database.countQuery(soqlCount), 2000));
    }

    @RemoteAction
    public static RemoteSaveResult[] saveOpportunityLineItems(OpportunityLineItem[] opportunityLineItemsToSave,
            List<List<String>> opportunityLineItemsFieldsToNull,
            String[] opportunityLineItemRowIds, FC_Billing_Instruction_Set__c[] billingInstructionSetsToSave,
            FC_Billing_Instruction_Step__c[] billingInstructionStepsToSave,
            List<List<String>> billingInstructionStepsFieldsToNull,
            OpportunityLineItem[] opportunityLineItemsToDelete, Id opportunityId) {

        System.debug('OPPORTUNITY LINE ITEMS TO SAVE ' + opportunityLineItemsToSave);
        System.debug('OPPORTUNITY LINE ITEM ROW IDS ' + opportunityLineItemRowIds);
        System.debug('BILLING INSTRUCTION SETS TO SAVE ' + billingInstructionSetsToSave);
        System.debug('BILLING INSTRUCTION STEPS TO SAVE ' + billingInstructionStepsToSave);
        System.debug('OPPORTUNITY LINE ITEMS TO DELETE ' + opportunityLineItemsToDelete);

        RemoteSaveResult[] results = new List<RemoteSaveResult>();

        // Delete opportunity line items
        if (opportunityLineItemsToDelete != null && !opportunityLineItemsToDelete.isEmpty()) {
            Database.DeleteResult[] opportunityLineItemDeleteResults = Database.delete(opportunityLineItemsToDelete, true);

            // Build remote save results.
            for (Integer i = 0; i < opportunityLineItemDeleteResults.size(); i++) {
                Database.DeleteResult opportunityLineItemDeleteResult = opportunityLineItemDeleteResults[i];
                if (opportunityLineItemDeleteResult.isSuccess()) {
                    results.add(new RemoteSaveResult(opportunityLineItemDeleteResult.getId(), 'delete', null));
                } else {
                    results.add(new RemoteSaveResult(opportunityLineItemDeleteResult.getId(), 'error', null));
                }
            }
        }

        if (opportunityLineItemsToSave != null && !opportunityLineItemsToSave.isEmpty()) {

            // Set specified opportunity line item fields to null
            if (opportunityLineItemsFieldsToNull != null && !opportunityLineItemsFieldsToNull.isEmpty() &&
                    opportunityLineItemsFieldsToNull.size() == opportunityLineItemsToSave.size()) {
                for (Integer i = 0; i < opportunityLineItemsToSave.size(); i++) {
                    OpportunityLineItem opportunityLineItemToSave = opportunityLineItemsToSave[i];
                    opportunityLineItemToSave.MetroStudy_Product__c = true;
                    String[] fieldsToNull = opportunityLineItemsFieldsToNull[i];
                    if (fieldsToNull != null && !fieldsToNull.isEmpty()) {
                        for (String fieldToNull : fieldsToNull) {
                            opportunityLineItemToSave.put(fieldToNull, null);
                        }
                    }
                }
            }

            // Upsert opportunity line items
            Database.UpsertResult[] opportunityLineItemUpsertResults = Database.upsert(opportunityLineItemsToSave,
                    OpportunityLineItem.Fields.FC_UUID__c, true);

            // Upsert billing instruction sets
            upsert billingInstructionSetsToSave Opportunity_Line_Item_UUID__c;

            // Delete all billing instruction steps for upserted opportunity line items
            Set<String> upsertedOpportunityLineItemUuids = new Set<String>();
            for (OpportunityLineItem opportunityLineItemToSave : opportunityLineItemsToSave) {
                if (String.isNotBlank(opportunityLineItemToSave.FC_UUID__c)) {
                    upsertedOpportunityLineItemUuids.add(opportunityLineItemToSave.FC_UUID__c);
                }
            }
            delete [
                    select Id
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__r.Opportunity_Line_Item_UUID__c in :upsertedOpportunityLineItemUuids
                    and Status__c = 'New'
            ];

            // Set specified billing instruction step fields to null
            if (billingInstructionStepsFieldsToNull != null && !billingInstructionStepsFieldsToNull.isEmpty() &&
                    billingInstructionStepsFieldsToNull.size() == billingInstructionStepsToSave.size()) {
                for (Integer i = 0; i < billingInstructionStepsToSave.size(); i++) {
                    FC_Billing_Instruction_Step__c billingInstructionStepToSave = billingInstructionStepsToSave[i];
                    String[] fieldsToNull = billingInstructionStepsFieldsToNull[i];
                    if (fieldsToNull != null && !fieldsToNull.isEmpty()) {
                        for (String fieldToNull : fieldsToNull) {
                            billingInstructionStepToSave.put(fieldToNull, null);
                        }
                    }
                }
            }

            // Upsert billing instruction steps
            upsert billingInstructionStepsToSave;

            // Determine date of earliest billing instruction step;
            Date opportunityContractEffectiveDate = null;
            for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                    select Id, Contract_Effective_Date__c
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__r.Opportunity__c = :opportunityId
                    order by Contract_Effective_Date__c ASC
                    limit 1
            ]) {
                opportunityContractEffectiveDate = billingInstructionStepRecord.Contract_Effective_Date__c;
            }

            // Determine date of earliest recurring billing instruction step;
            Integer opportunityBillCycleDayValue = 1;
            for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                    select Id, Contract_Effective_Date__c
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__r.Opportunity__c = :opportunityId
                    and Metrostudy_Product_Geography_Seg3__r.Charge_Type__c = 'Recurring'
                    order by Contract_Effective_Date__c ASC
                    limit 1
            ]) {
                opportunityBillCycleDayValue = billingInstructionStepRecord.Contract_Effective_Date__c.day();
            }

            // Determine earliest T&C Term Start Date
            Date opportunityTCTermStartDate = null;
            for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                    select Id, T_C_Term_Start_Date__c
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__r.Opportunity__c = :opportunityId
                    and T_C_Term_Start_Date__c != null
                    and Metrostudy_Product_Geography_Seg3__r.Charge_Type__c = 'Recurring'
                    and Billing_Instruction_Set__r.Opportunity__r.ContractId = null
                    order by T_C_Term_Start_Date__c ASC
                    limit 1
            ]) {
                opportunityTCTermStartDate = billingInstructionStepRecord.T_C_Term_Start_Date__c;
            }

            // Update opportunity
            Opportunity opportunityToUpdate = new Opportunity(Id = opportunityId,
                    FC_Bill_Cycle_Day__c = opportunityBillCycleDayValue,
                    FC_Contract_Effective_Date__c = opportunityContractEffectiveDate,
                    FC_T_C_Term_Start_Date__c = opportunityTCTermStartDate,
                    Skip_Validation__c = true);
            update opportunityToUpdate;

            Opportunity updatedOpportunityRecord = null;
            for (Opportunity opportunityRecord : [
                    select Id, FC_Contract_Effective_Date__c, ContractId
                    from Opportunity
                    where Id = :opportunityId
                    limit 1
            ]) {
                updatedOpportunityRecord = opportunityRecord;
            }

            Set<Id> billingInstructionSetIdsWithZuoraActionAdd = new Set<Id>();
            for (OpportunityLineItem opportunityLineItemRecord : [
                    select Id, FC_Billing_Instruction_Set__c
                    from OpportunityLineItem
                    where OpportunityId = :opportunityId and FC_Zuora_Action__c = 'Add'
            ]) {
                if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
                    billingInstructionSetIdsWithZuoraActionAdd.add(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
                }
            }

            // Correct record types of existing billing instruction steps with a Zuora Action of "Add"
            FC_Billing_Instruction_Step__c[] billingInstructionStepsToUpdate = new List<FC_Billing_Instruction_Step__c>();
            for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                    select Id, RecordType.DeveloperName, Contract_Effective_Date__c
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__r.Opportunity__c = :opportunityId
                    and Billing_Instruction_Set__c in :billingInstructionSetIdsWithZuoraActionAdd
                    and Status__c = 'New'
            ]) {
                FC_Billing_Instruction_Step__c billingInstructionStepToUpdate = new FC_Billing_Instruction_Step__c(Id = billingInstructionStepRecord.Id);
                if (updatedOpportunityRecord.ContractId == null) {
                    if (billingInstructionStepRecord.Contract_Effective_Date__c == updatedOpportunityRecord.FC_Contract_Effective_Date__c) {
                        billingInstructionStepToUpdate.RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Subscribe').Id;
                    } else {
                        if (billingInstructionStepRecord.RecordType.DeveloperName == 'Subscribe') {
                            billingInstructionStepToUpdate.RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id;
                        }
                    }
                } else {
                    if (billingInstructionStepRecord.RecordType.DeveloperName == 'Subscribe') {
                        billingInstructionStepToUpdate.RecordTypeId = fcf.RecordTypeUtil.findByName('FC_Billing_Instruction_Step__c.Amend_Add').Id;
                    }
                }
                billingInstructionStepsToUpdate.add(billingInstructionStepToUpdate);
            }
            update billingInstructionStepsToUpdate;

            // Build remote save results
            for (Integer i = 0; i < opportunityLineItemUpsertResults.size(); i++) {
                Database.UpsertResult opportunityLineItemUpsertResult = opportunityLineItemUpsertResults[i];
                Id createdId = null;
                String status = 'update';
                if (opportunityLineItemUpsertResult.isSuccess()) {
                    if (opportunityLineItemUpsertResult.isCreated()) {
                        createdId = opportunityLineItemUpsertResult.getId();
                        status = 'insert';
                    }
                } else {
                    status = 'error';
                }

                results.add(new RemoteSaveResult(opportunityLineItemRowIds[i], status, createdId));
            }
        }

        return results;
    }

    public class RemoteSaveResult {

        public String id;
        public String status;
        public Id newId;

        public RemoteSaveResult(String id, String status, Id newId) {
            this.id = id;
            this.status = status;
            this.newId = newId;
        }

    }

    public class RemoteQueryParameters {

        public Integer count;
        public Map<String, String> filter;
        public Integer start;

    }

//    public class RemoteValidateTask {
//
//        public Map<String, RemoteValidateOpportunityLineItem> opportunityLineItemMap;
//
//    }
//
//    public class RemoteValidateOpportunityLineItem {
//
//        public String rowId;
//        public OpportunityLineItem opportunityLineItem;
//        public Boolean success;
//        public RemoteValidateError[] errors;
//        public Map<String, RemoteValidateBillingInstructionStep> billingInstructionStepMap;
//
//    }
//
//    public class RemoteValidateBillingInstructionStep {
//
//        public String rowId;
//        public String opportunityLineItemRowId;
//        public FC_Billing_Instruction_Step__c billingInstructionStep;
//        public Boolean success;
//        public RemoteValidateError[] errors;
//
//    }
//
//    public class RemoteValidateError {
//
//        public String code;
//        public String message;
//        public String field;
//
//    }

    public class ZquProductRatePlanQueryResult {

        public zqu__ProductRatePlan__c[] data;
        public Integer pos;
        public Integer total_count;

        public ZquProductRatePlanQueryResult(zqu__ProductRatePlan__c[] data,
                Integer pos, Integer total_count) {
            this.data = data;
            this.pos = pos;
            this.total_count = total_count;
        }

    }

    public class FcMetroclientProductGeographySeg3QueryResult {

        public FC_Metroclient_Product_Geography_Seg3__c[] data;
        public Integer pos;
        public Integer total_count;

        public FcMetroclientProductGeographySeg3QueryResult(FC_Metroclient_Product_Geography_Seg3__c[] data,
                Integer pos, Integer total_count) {
            this.data = data;
            this.pos = pos;
            this.total_count = total_count;
        }

    }

    public class RemoteOption {

        public Id id;
        public String value;

        public RemoteOption(Id id, String value) {
            this.id = id;
            this.value = value;
        }

        public Boolean equals(Object otherObject) {
            if (otherObject instanceof RemoteOption) {
                RemoteOption other = (RemoteOption) otherObject;
                return (this === other) ||
                        (other != null && this.id == other.id);
            }
            return false;
        }

        public Integer hashCode() {
            final Integer prime = 31;
            Integer result = 1;
            result = prime * result + (id == null ? 0 : String.valueOf(id).hashCode());
            return result;
        }

    }

}