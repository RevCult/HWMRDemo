global without sharing class FC_OpportunityLineItemHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_OpportunityLineItemHandler';

    private final static Set<String> ACT_ONLY_FOR_OPPORTUNITY_RECORD_TYPES = new Set<String>{
            'Metrostudy_Renewal_Oppty_Record_Type',
            'Metrostudy_Opportunity_Record_Type_Consult',
            'Metrostudy_Opportunity_Record_Type_Admin',
            'Metrostudy_Opportunity_REE',
            'Market_Intelligence_Opportunity_Record_Type',
            'MS_Opportunity_BPM',
            'Network_Opportunity',
            'MS_Opportunity_Zuora_Duplicates'
    };

    // Before and after phase
    private static Map<Id, Opportunity> opportunityLookupMap = new Map<Id, Opportunity>();

    // Before phase
    private Map<Id, FC_Metroclient_Product_Geography_Seg3__c> fcMetroclientProductGeographySeg3LookupMap =
            new Map<Id, FC_Metroclient_Product_Geography_Seg3__c>();
    private Map<Id, FC_Billing_Instruction_Set__c> fcBillingInstructionSetLookupMap = new Map<Id, FC_Billing_Instruction_Set__c>();
    private Map<Id, FC_Billing_Instruction_Set__c> opportunityLineItemIdToFcBillingInstructionSetMap =
            new Map<Id, FC_Billing_Instruction_Set__c>();
    private Map<Id, Set<FC_Billing_Instruction_Step__c>> fcBillingInstructionSetIdToFcBillingInstructionStepsMap =
            new Map<Id, Set<FC_Billing_Instruction_Step__c>>();
    private Map<Id, Set<String>> fcBillingInstructionStepIdToTagsMap = new Map<Id, Set<String>>();
    private Map<Id, Set<MetrostudySalesRegionAssignment__c>> salesRegionIdToSalesRegionAssignmentsMap =
            new Map<Id, Set<MetrostudySalesRegionAssignment__c>>();
    private Map<Id, Integer> opportunityLineItemIdToSubscribeBillingStepCountMap = new Map<Id, Integer>();

    // After phase
    private Set<Id> billingInstructionSetIdsToDelete = new Set<Id>();
    private Set<Opportunity> opportunitiesToUpdate = new Set<Opportunity>();

    global override void bulkBefore() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<Id> fcMetroclientProductGeographySeg3IdsToLookup = new Set<Id>();
            Set<Id> opportunityIdsToLookup = new Set<Id>();
            Set<Id> fcBillingInstructionSetIdsToLookup = new Set<Id>();
            for (SObject so : Trigger.new) {
                OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
                if (opportunityLineItemRecord.FC_Product_Geography_Seg3__c != null) {
                    fcMetroclientProductGeographySeg3IdsToLookup.add(opportunityLineItemRecord.FC_Product_Geography_Seg3__c);
                }
                if (opportunityLineItemRecord.OpportunityId != null) {
                    opportunityIdsToLookup.add(opportunityLineItemRecord.OpportunityId);
                }
                if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
                    fcBillingInstructionSetIdsToLookup.add(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
                }
            }

            fcMetroclientProductGeographySeg3LookupMap.putAll(FC_FcMetroclientProductGeoSeg3Cache.findByIds(fcMetroclientProductGeographySeg3IdsToLookup));
            opportunityLookupMap.putAll(FC_OpportunityCache.findByIds(opportunityIdsToLookup));
            fcBillingInstructionSetLookupMap.putAll(FC_FcBillingInstructionSetCache.findByIds(fcBillingInstructionSetIdsToLookup));
            fcBillingInstructionSetIdToFcBillingInstructionStepsMap.putAll(FC_FcBillingInstructionStepCache.findByBillingInstructionSetIds(fcBillingInstructionSetIdsToLookup));

            // Populate Billing Instruction Step Tags map
            for (Set<FC_Billing_Instruction_Step__c> fcBillingInstructionStepRecords : fcBillingInstructionSetIdToFcBillingInstructionStepsMap.values()) {
                for (FC_Billing_Instruction_Step__c fcBillingInstructionStepRecord : fcBillingInstructionStepRecords) {
                    Set<String> fcBillingInstructionSetTags = fcBillingInstructionStepIdToTagsMap.get(fcBillingInstructionStepRecord.Id);
                    if (fcBillingInstructionSetTags == null) {
                        fcBillingInstructionSetTags = new Set<String>();
                        fcBillingInstructionStepIdToTagsMap.put(fcBillingInstructionStepRecord.Id, fcBillingInstructionSetTags);
                    }
                    for (FC_Billing_Instruction_Step__Tag tagRecord : fcBillingInstructionStepRecord.Tags) {
                        fcBillingInstructionSetTags.add(tagRecord.Name);
                    }
                }
            }

            Set<Id> salesRegionIdsToLookup = new Set<Id>();
            for (FC_Metroclient_Product_Geography_Seg3__c seg3Record : fcMetroclientProductGeographySeg3LookupMap.values()) {
                if (seg3Record.Product_Geography__r.Geography__r.SalesRegion__c != null) {
                    salesRegionIdsToLookup.add(seg3Record.Product_Geography__r.Geography__r.SalesRegion__c);
                }
            }
            salesRegionIdToSalesRegionAssignmentsMap.putAll(FC_MetrostudySalesRegionAssignmentCache.findBySalesRegionIds(salesRegionIdsToLookup));

        }


        if (Trigger.isUpdate) {
            opportunityLineItemIdToFcBillingInstructionSetMap.putAll(FC_FcBillingInstructionSetCache.findByOpportunityLineItemIds(Trigger.newMap.keySet()));

            // Calculate subscribe billing step counts for each opportunity line item.
            for (SObject so : Trigger.new) {
                opportunityLineItemIdToSubscribeBillingStepCountMap.put(so.Id, 0);
            }
            for (SObject so : Trigger.new) {
                OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
                FC_Billing_Instruction_Set__c billingInstructionSetRecord = opportunityLineItemIdToFcBillingInstructionSetMap.get(opportunityLineItemRecord.Id);
                if (billingInstructionSetRecord != null) {
                    Set<FC_Billing_Instruction_Step__c> billingInstructionSteps = fcBillingInstructionSetIdToFcBillingInstructionStepsMap.get(billingInstructionSetRecord.Id);
                    Integer subscribeCount = 0;
                    if (billingInstructionSteps != null) {
                        for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : billingInstructionSteps) {
                            if (billingInstructionStepRecord.RecordType.DeveloperName == 'Subscribe') {
                                subscribeCount++;
                            }
                        }
                    }
                    opportunityLineItemIdToSubscribeBillingStepCountMap.put(opportunityLineItemRecord.Id, subscribeCount);
                }
            }

        }


    }

    global override void beforeInsert(SObject so) {
        OpportunityLineItem newOpportunityLineItem = (OpportunityLineItem) so;
        populateFields(newOpportunityLineItem);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        OpportunityLineItem newOpportunityLineItem = (OpportunityLineItem) so;
        populateFields(newOpportunityLineItem);
    }

    global override void finallyBefore() {

        // Initialize fields
        Set<Id> billingInstructionSetIdsToSummarize = new Set<Id>();
        for (SObject so : Trigger.new) {
            OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
            opportunityLineItemRecord.FC_Deal_Length__c = 1;
            if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
                billingInstructionSetIdsToSummarize.add(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
            }
        }


        Map<Id, AggregateResult> billingInstructionSetIdToSummaryMap = new Map<Id, AggregateResult>();
        if (Trigger.isUpdate && !billingInstructionSetIdsToSummarize.isEmpty()) {
            for (AggregateResult row : [
                    select Billing_Instruction_Set__c, min(Contract_Effective_Date__c) minContractEffectiveDate,
                            max(Contract_Effective_Date__c) maxContractEffectiveDate
                    from FC_Billing_Instruction_Step__c
                    where Billing_Instruction_Set__c in :billingInstructionSetIdsToSummarize
                    group by Billing_Instruction_Set__c
            ]) {
                Id billingInstructionSetId = (Id) row.get('Billing_Instruction_Set__c');
                billingInstructionSetIdToSummaryMap.put(billingInstructionSetId, row);
            }
        }

        for (SObject so : Trigger.new) {
            OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
            if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
                AggregateResult ar = billingInstructionSetIdToSummaryMap.get(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
                if (ar != null) {
                    Date minContractEffectiveDate = (Date) ar.get('minContractEffectiveDate');
                    Date maxContractEffectiveDate = (Date) ar.get('maxContractEffectiveDate');
                    opportunityLineItemRecord.FC_Deal_Length__c = Math.max(1, minContractEffectiveDate.monthsBetween(maxContractEffectiveDate));
                }
            }
        }

    }

    global override void afterInsert(SObject so) {
        OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
        prepareOpportunityRecordForUpdate(opportunityLineItemRecord);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
        prepareOpportunityRecordForUpdate(opportunityLineItemRecord);
    }

    global override void afterDelete(SObject so) {

        OpportunityLineItem opportunityLineItemRecord = (OpportunityLineItem) so;
        if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
            billingInstructionSetIdsToDelete.add(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
        }

        prepareOpportunityRecordForUpdate(opportunityLineItemRecord);

    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (Trigger.isDelete) {

            if (!billingInstructionSetIdsToDelete.isEmpty()) {
                Database.delete(new List<Id>(billingInstructionSetIdsToDelete));
                billingInstructionSetIdsToDelete.clear();
            }

        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update new List<Opportunity>(opportunitiesToUpdate);
            opportunitiesToUpdate.clear();
        }

    }

    private void prepareOpportunityRecordForUpdate(OpportunityLineItem opportunityLineItemRecord) {

        Opportunity opportunityRecord = opportunityLookupMap.get(opportunityLineItemRecord.OpportunityId);

        /* Do not continue if opportunity is not one of the record types listed in
         * ACT_ONLY_FOR_OPPORTUNITY_RECORD_TYPES.
         */
        if (!(opportunityRecord != null &&
                ACT_ONLY_FOR_OPPORTUNITY_RECORD_TYPES.contains(opportunityRecord.RecordType.DeveloperName))) {
            return;
        }

        opportunitiesToUpdate.add(new Opportunity(Id = opportunityLineItemRecord.OpportunityId, Skip_Validation__c = true));
    }

    private void populateFields(OpportunityLineItem opportunityLineItemRecord) {

        // Assign AdBook Start and End Date fields to local Double Click fields
        AdBookIntegration.handleOpportunityLineItemTriggerPopulateFields(opportunityLineItemRecord);

        Opportunity opportunityRecord = opportunityLookupMap.get(opportunityLineItemRecord.OpportunityId);

        /* Do not continue if opportunity is not one of the record types listed in
         * ACT_ONLY_FOR_OPPORTUNITY_RECORD_TYPES.
         */
        if (!(opportunityRecord != null &&
                ACT_ONLY_FOR_OPPORTUNITY_RECORD_TYPES.contains(opportunityRecord.RecordType.DeveloperName))) {
            return;
        }

        opportunityLineItemRecord.FC_Line_Description__c = null;
        FC_Metroclient_Product_Geography_Seg3__c fcMetroclientProductGeographySeg3Record =
                fcMetroclientProductGeographySeg3LookupMap.get(opportunityLineItemRecord.FC_Product_Geography_Seg3__c);

        if (opportunityRecord != null) {

            opportunityLineItemRecord.FC_Annualize_New_Revenue__c = opportunityRecord.FC_Annualize_New_Revenue__c;

            // Populate Opportunity Renewal
            opportunityLineItemRecord.FC_Opportunity_Renewal__c = opportunityRecord.FC_Renew__c;

            if (opportunityLineItemRecord.FC_Product_Geography_Seg3__c != null &&
                    fcMetroclientProductGeographySeg3Record != null) {

                opportunityLineItemRecord.FC_Seg3_Text__c = fcMetroclientProductGeographySeg3Record.Seg3__c;

                opportunityLineItemRecord.FC_RD_Assignment__c = null;
                Set<MetrostudySalesRegionAssignment__c> possibleSalesRegionAssignments =
                        salesRegionIdToSalesRegionAssignmentsMap.get(fcMetroclientProductGeographySeg3Record.Product_Geography__r.Geography__r.SalesRegion__c);
                if (possibleSalesRegionAssignments != null) {
                    for (MetrostudySalesRegionAssignment__c salesRegionAssignmentRecord : possibleSalesRegionAssignments) {
                        if (salesRegionAssignmentRecord.Role__c == 'RD') {
                            opportunityLineItemRecord.FC_RD_Assignment__c = salesRegionAssignmentRecord.Id;
                            break;
                        }
                    }
                }

                if (opportunityLineItemRecord.FC_Effective_Date__c != null && opportunityLineItemRecord.FC_Zuora_Action__c != 'Remove') {
                    if (fcMetroclientProductGeographySeg3Record.Charge_Type__c == 'Recurring') {
                        if (opportunityRecord.FC_Initial_Term__c != null &&
                                ((opportunityRecord.ContractId == null && opportunityRecord.FC_Term_Type__c == 'TERMED') ||
                                        (opportunityRecord.ContractId != null &&
                                                opportunityRecord.Contract.FC_Subscription__r.Zuora__TermSettingType__c == 'TERMED'))) {
                            opportunityLineItemRecord.FC_End_Date__c =
                                    opportunityLineItemRecord.FC_Effective_Date__c.addMonths(
                                            Integer.valueOf(opportunityRecord.FC_Initial_Term__c));
                        } else {
                            opportunityLineItemRecord.FC_End_Date__c = opportunityLineItemRecord.FC_Effective_Date__c.addMonths(12);
                        }
                    } else {
                        opportunityLineItemRecord.FC_End_Date__c = opportunityLineItemRecord.FC_Effective_Date__c;
                    }
                }

                opportunityLineItemRecord.FC_Line_Description__c = String.format('{0} | {1} | {2} | {3}',
                        new String[]{
                                fcMetroclientProductGeographySeg3Record.Geography_Type__c,
                                fcMetroclientProductGeographySeg3Record.Geography__c,
                                fcMetroclientProductGeographySeg3Record.Charge_Type__c == 'Recurring' ?
                                        opportunityLineItemRecord.Billing_Frequency__c : 'One-Time',
                                fcMetroclientProductGeographySeg3Record.Seg3__c
                        });
            }

            if (String.isBlank(opportunityLineItemRecord.FC_UUID__c)) {
                opportunityLineItemRecord.FC_UUID__c = FC_UuidUtil.uuidV4();
            }

            if (String.isNotBlank(opportunityLineItemRecord.FC_Zuora_Action__c)) {

                Decimal lessThan12MonthsMultiplier = 1;
                if (opportunityRecord.FC_Term_Type__c == 'TERMED' && opportunityRecord.FC_Initial_Term__c != null &&
                        opportunityRecord.FC_Initial_Term__c < 12 && opportunityLineItemRecord.Billing_Frequency__c != 'One-Time') {
                    lessThan12MonthsMultiplier = opportunityRecord.FC_Initial_Term__c / 12;
                } else if (opportunityRecord.FC_Term_Type__c == 'EVERGREEN' && opportunityLineItemRecord.FC_Do_Not_Annualize__c) {
                    Map<String, Decimal> billingFrequencyToMultiplierMap = new Map<String, Decimal>{
                            'Monthly' => 1.0 / 12.0,
                            'Quarterly' => 3.0 / 12.0,
                            'Semi-Annually' => 6.0 / 12.0,
                            'Annually' => 12.0 / 12.0
                    };
                    if (String.isNotBlank(opportunityLineItemRecord.Billing_Frequency__c) &&
                            billingFrequencyToMultiplierMap.containsKey(opportunityLineItemRecord.Billing_Frequency__c)) {
                        lessThan12MonthsMultiplier = billingFrequencyToMultiplierMap.get(opportunityLineItemRecord.Billing_Frequency__c);
                    }
                }

                if (opportunityLineItemRecord.FC_Zuora_Action__c == 'Remove') {
                    opportunityLineItemRecord.FC_New_Revenue__c = 0;
                    opportunityLineItemRecord.FC_Renewal_Revenue__c = 0;
                    opportunityLineItemRecord.FC_Cancellation_Revenue__c = opportunityLineItemRecord.FC_Original_Sale_Price__c * -1;
                    opportunityLineItemRecord.UnitPrice = opportunityLineItemRecord.FC_Sale_Price__c * lessThan12MonthsMultiplier * -1;
                    opportunityLineItemRecord.Quantity = 1;
                    if (opportunityLineItemRecord.FC_Purchase_Type__c == 'Restructure') {
                        opportunityLineItemRecord.UnitPrice = 0;
                    }
                } else if (opportunityLineItemRecord.FC_Zuora_Action__c == 'No Action') {
                    opportunityLineItemRecord.FC_New_Revenue__c = 0;
                    opportunityLineItemRecord.FC_Renewal_Revenue__c = opportunityRecord.Renewal__c ? opportunityLineItemRecord.FC_Original_Sale_Price__c : 0;
                    opportunityLineItemRecord.FC_Cancellation_Revenue__c = 0;
                    opportunityLineItemRecord.UnitPrice = opportunityRecord.Renewal__c ? opportunityLineItemRecord.FC_Sale_Price__c * lessThan12MonthsMultiplier : 0;
                    opportunityLineItemRecord.Quantity = 1;
                } else if (opportunityLineItemRecord.FC_Zuora_Action__c == 'Add') {
                    opportunityLineItemRecord.FC_New_Revenue__c = opportunityLineItemRecord.FC_Sale_Price__c;
                    opportunityLineItemRecord.FC_Renewal_Revenue__c = 0;
                    opportunityLineItemRecord.FC_Cancellation_Revenue__c = 0;
                    opportunityLineItemRecord.UnitPrice = opportunityLineItemRecord.FC_Sale_Price__c * lessThan12MonthsMultiplier;
                    opportunityLineItemRecord.Quantity = 1;
                } else if (opportunityLineItemRecord.FC_Zuora_Action__c == 'Update') {
                    Decimal deltaPrice = opportunityLineItemRecord.FC_Sale_Price__c - opportunityLineItemRecord.FC_Original_Sale_Price__c;
                    opportunityLineItemRecord.FC_New_Revenue__c = deltaPrice;
                    opportunityLineItemRecord.FC_Renewal_Revenue__c = 0;
                    opportunityLineItemRecord.FC_Cancellation_Revenue__c = 0;
                    if (opportunityRecord.Renewal__c) {
                        if (deltaPrice > 0) {
                            opportunityLineItemRecord.FC_New_Revenue__c = 0;
                            opportunityLineItemRecord.FC_Renewal_Revenue__c = opportunityLineItemRecord.FC_Original_Sale_Price__c;
                            opportunityLineItemRecord.FC_Cancellation_Revenue__c = 0;
                        } else if (deltaPrice < 0) {
                            opportunityLineItemRecord.FC_New_Revenue__c = 0;
                            opportunityLineItemRecord.FC_Renewal_Revenue__c = opportunityLineItemRecord.FC_Original_Sale_Price__c + deltaPrice;
                            opportunityLineItemRecord.FC_Cancellation_Revenue__c = deltaPrice;
                        } else {
                            opportunityLineItemRecord.FC_New_Revenue__c = 0;
                            opportunityLineItemRecord.FC_Renewal_Revenue__c = opportunityLineItemRecord.FC_Original_Sale_Price__c;
                            opportunityLineItemRecord.FC_Cancellation_Revenue__c = 0;
                        }
                    }
                    opportunityLineItemRecord.UnitPrice = (opportunityLineItemRecord.FC_Sale_Price__c - (opportunityRecord.Renewal__c ? 0 : opportunityLineItemRecord.FC_Original_Sale_Price__c)) * lessThan12MonthsMultiplier;
                    opportunityLineItemRecord.Quantity = 1;
                    if (!opportunityLineItemRecord.FC_Override_Purchase_Type__c) {
                        opportunityLineItemRecord.FC_Purchase_Type__c = opportunityRecord.Renewal__c ? 'Renewal' : 'Price Change';
                    }
                }
            }
        }

        if (Trigger.isUpdate) {
            if (opportunityLineItemIdToFcBillingInstructionSetMap.containsKey(opportunityLineItemRecord.Id)) {
                opportunityLineItemRecord.FC_Billing_Instruction_Set__c = opportunityLineItemIdToFcBillingInstructionSetMap.get(opportunityLineItemRecord.Id).Id;
            }
        }

        FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord = null;
        if (opportunityLineItemRecord.FC_Billing_Instruction_Set__c != null) {
            if (fcBillingInstructionSetLookupMap.containsKey(opportunityLineItemRecord.FC_Billing_Instruction_Set__c)) {
                fcBillingInstructionSetRecord = fcBillingInstructionSetLookupMap.get(opportunityLineItemRecord.FC_Billing_Instruction_Set__c);
            } else if (Trigger.isUpdate && opportunityLineItemIdToFcBillingInstructionSetMap.containsKey(opportunityLineItemRecord.Id)) {
                fcBillingInstructionSetRecord = opportunityLineItemIdToFcBillingInstructionSetMap.get(opportunityLineItemRecord.Id);
            }
        }


        Map<String, Object> parsedInstructionParameters = null;
        String billCaseString = '';
        if (fcBillingInstructionSetRecord != null) {

            // Bill Case should default to Billing Instruction Set Template Name
            billCaseString = fcBillingInstructionSetRecord.Template__r.Name;

            // Parse Instruction Parameters if possible
            if (String.isNotBlank(fcBillingInstructionSetRecord.Instruction_Parameters__c)) {
                try {
                    parsedInstructionParameters = (Map<String, Object>) JSON.deserializeUntyped(fcBillingInstructionSetRecord.Instruction_Parameters__c);
                } catch (JSONException e) {
                    // Do nothing.
                }
            }
        }

        if ((opportunityLineItemIdToSubscribeBillingStepCountMap.get(opportunityLineItemRecord.Id) != null &&
                opportunityLineItemIdToSubscribeBillingStepCountMap.get(opportunityLineItemRecord.Id) > 0) ||
                opportunityRecord.ContractId == null) {

            /* If this opportunity is for a new subscription and the billing instruction set is using a Free Months
             * template, then extend the End Date by the number of free months.
             */
            if (fcBillingInstructionSetRecord != null) {

                if (fcBillingInstructionSetRecord.Template__r.Name == 'Free Months') {

                    if (parsedInstructionParameters != null && parsedInstructionParameters.containsKey('numberOfFreeMonths')) {
                        String numberOfFreeMonthsString = (String) parsedInstructionParameters.get('numberOfFreeMonths');
                        if (String.isNotBlank(numberOfFreeMonthsString)) {
                            opportunityLineItemRecord.FC_End_Date__c = opportunityLineItemRecord.FC_End_Date__c.addMonths(Integer.valueOf(numberOfFreeMonthsString));
                        }
                    }

                } else if (fcBillingInstructionSetRecord.Template__r.Name == 'Opt Out') {

                    if (parsedInstructionParameters != null && parsedInstructionParameters.containsKey('duration')) {
                        String durationString = (String) parsedInstructionParameters.get('duration');
                        if (String.isNotBlank(durationString)) {
                            opportunityLineItemRecord.FC_End_Date__c = opportunityLineItemRecord.FC_End_Date__c.addMonths(Integer.valueOf(durationString));
                        }
                    }

                }

            }

        } else {

            // If this opportunity is for an existing subscription, default the Bill Case to the Zuora Action.
            if (opportunityLineItemRecord.FC_Zuora_Action__c == 'No Action') {
                billCaseString = 'No Change';
            } else {
                billCaseString = String.format('Amend ({0})', new String[]{
                        opportunityLineItemRecord.FC_Zuora_Action__c
                });
            }
        }

        /* If the Billing Instruction Set is using a Template of Free Months or Opt Out, then the Bill Case is set
         * to the template name followed by the number of free months or opt out duration, respectively.
         */
        if (fcBillingInstructionSetRecord != null) {
            if (fcBillingInstructionSetRecord.Template__r.Name == 'Free Months') {

                if (parsedInstructionParameters != null && parsedInstructionParameters.containsKey('numberOfFreeMonths')) {
                    String numberOfFreeMonthsString = (String) parsedInstructionParameters.get('numberOfFreeMonths');
                    if (String.isNotBlank(numberOfFreeMonthsString)) {
                        billCaseString = String.format('{0} ({1})', new String[]{
                                fcBillingInstructionSetRecord.Template__r.Name,
                                (String) parsedInstructionParameters.get('numberOfFreeMonths')
                        });
                    }
                }

            } else if (fcBillingInstructionSetRecord.Template__r.Name == 'Opt Out') {

                if (parsedInstructionParameters != null && parsedInstructionParameters.containsKey('duration')) {
                    billCaseString = String.format('{0} ({1})', new String[]{
                            fcBillingInstructionSetRecord.Template__r.Name,
                            (String) parsedInstructionParameters.get('duration')
                    });
                }

            }
        }
        opportunityLineItemRecord.FC_Bill_Case__c = billCaseString;


        if (fcMetroclientProductGeographySeg3Record != null &&
                fcMetroclientProductGeographySeg3Record.Seg3__c == 'CONS' &&
                fcBillingInstructionSetRecord != null &&
                fcBillingInstructionSetIdToFcBillingInstructionStepsMap.containsKey(fcBillingInstructionSetRecord.Id)) {

            Set<FC_Billing_Instruction_Step__c> fcBillingInstructionStepRecords =
                    fcBillingInstructionSetIdToFcBillingInstructionStepsMap.get(fcBillingInstructionSetRecord.Id);

            for (FC_Billing_Instruction_Step__c fcBillingInstructionStepRecord : fcBillingInstructionStepRecords) {
                Set<String> fcBillingInstructionStepTags = fcBillingInstructionStepIdToTagsMap.get(fcBillingInstructionStepRecord.Id);
                if (fcBillingInstructionStepTags != null && fcBillingInstructionStepTags.contains('Expenses')) {
                    opportunityLineItemRecord.FC_Consulting_Expenses__c = fcBillingInstructionStepRecord.Price__c;
                    break;
                }
            }

        }

    }

}