global without sharing class FC_OpportunityHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_OpportunityHandler';

    // Before phase variables
    private Map<ID, Contract> contractLookupMap = new Map<ID, Contract>();

    // After phase variables
    private Map<ID, Set<FC_Billing_Instruction_Step__c>> opportunityIdToFcBillingInstructionStepMap =
            new Map<ID, Set<FC_Billing_Instruction_Step__c>>();
    private Set<FC_Billing_Instruction_Step__c> billingInstructionStepsToUpdate =
            new Set<FC_Billing_Instruction_Step__c>();
    private Set<OpportunityLineItem> opportunityLineItemsToUpdate =
            new Set<OpportunityLineItem>();
    private Set<Commission_Split__c> commissionSplitsToInsert = new Set<Commission_Split__c>();

    // Before and after phase variables
    private static Map<Id, Set<OpportunityLineItem>> opportunityIdToOpportunityLineItemsMap = new Map<Id, Set<OpportunityLineItem>>();

    global override void bulkBefore() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<ID> contractIdsToLookup = new Set<ID>();
            for (SObject so : Trigger.new) {
                Opportunity opportunityRecord = (Opportunity) so;
                if (opportunityRecord.ContractId != null) {
                    contractIdsToLookup.add(opportunityRecord.ContractId);
                }
            }

            contractLookupMap.putAll(FC_ContractCache.findByIds(contractIdsToLookup));
        }

        if (Trigger.isUpdate) {

            opportunityIdToOpportunityLineItemsMap.putAll(
                    FC_OpportunityLineItemCache.findByOpportunityIds(Trigger.newMap.keySet()));

        }

    }

    global override void beforeInsert(SObject so) {
        Opportunity newOpportunity = (Opportunity) so;
        populateFields(null, newOpportunity);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        Opportunity oldOpportunity = (Opportunity) oldSo;
        Opportunity newOpportunity = (Opportunity) so;

        populateFields(oldOpportunity, newOpportunity);

    }

    global override void finallyBefore() {

        // Initialize DBD Revenue Summary
        for (SObject so : Trigger.new) {
            Opportunity opportunityRecord = (Opportunity) so;
            opportunityRecord.FC_DBD_Revenue_Summary__c = opportunityRecord.Amount;
        }

        if (Trigger.isUpdate) {

            for (AggregateResult row : [
                    select OpportunityId, MIN(FC_Effective_Date__c) earliestEffectiveDate,
                            MAX(FC_End_Date__c) latestEndDate,
                            SUM(FC_One_If_One_Time_Charge__c) oneTimeChargeCount,
                            SUM(FC_One_If_Recurring_Charge__c) recurringChargeCount,
                            SUM(FC_New_Business_for_RD__c) sumNewBusinessForRd,
                            SUM(FC_Upsell_Revenue_Formula__c) sumUpsellRevenue,

                            SUM(FC_One_If_Pay_DBD__c) sumOneIfPayDbd,
                            SUM(FC_New_Revenue_Formula__c) sumNewRevenue,
                            SUM(FC_Price_Increase_Decrease_Formula__c) sumPriceIncreaseDecrease,
                            SUM(FC_Cancellation_Revenue_Formula__c) sumCancellationRevenue

                    from OpportunityLineItem
                    where OpportunityId in :Trigger.newMap.keySet()
                    group by OpportunityId
            ]) {
                Opportunity opportunityRecord = (Opportunity) Trigger.newMap.get((Id) row.get('OpportunityId'));
                Date earliestEffectiveDate = (Date) row.get('earliestEffectiveDate');
                Date latestEndDate = (Date) row.get('latestEndDate');
                Decimal recurringChargeCount = (Decimal) row.get('recurringChargeCount');
                Decimal oneTimeChargeCount = (Decimal) row.get('oneTimeChargeCount');
                opportunityRecord.FC_New_Business_for_RD__c = (Decimal) row.get('sumNewBusinessForRd');
                opportunityRecord.FC_Upsell_Revenue__c = (Decimal) row.get('sumUpsellRevenue');
                opportunityRecord.FC_Contract_Effective_Date__c = earliestEffectiveDate;
                opportunityRecord.FC_Service_Activation_Date__c = earliestEffectiveDate;
                opportunityRecord.FC_Target_Date__c = earliestEffectiveDate;
                if (opportunityRecord.ContractId == null) {
                    opportunityRecord.FC_Term_End_Date__c = latestEndDate;
                    if (recurringChargeCount == 0 && oneTimeChargeCount > 0) {
                        if (opportunityRecord.FC_Term_Type__c == 'TERMED') {

                            if (opportunityRecord.FC_Initial_Term__c != null) {
                                opportunityRecord.FC_Term_End_Date__c = opportunityRecord.FC_Contract_Effective_Date__c
                                        .addMonths(Integer.valueOf(opportunityRecord.FC_Initial_Term__c));
                            }

                        } else if (opportunityRecord.FC_Term_Type__c == 'EVERGREEN') {

                            opportunityRecord.FC_Term_End_Date__c = opportunityRecord.FC_Contract_Effective_Date__c
                                    .addMonths(12);
                        }
                    }
                }

                Decimal sumOneIfPayDbd = (Decimal) row.get('sumOneIfPayDbd');
                Decimal sumNewRevenue = (Decimal) row.get('sumNewRevenue');
                Decimal sumUpsellRevenue = (Decimal) row.get('sumUpsellRevenue');
                Decimal sumPriceIncreaseDecrease = (Decimal) row.get('sumPriceIncreaseDecrease');
                Decimal sumCancellationRevenue = (Decimal) row.get('sumCancellationRevenue');
                if (sumOneIfPayDbd == 0) {
                    opportunityRecord.FC_DBD_Revenue_Summary__c = sumNewRevenue + sumUpsellRevenue +
                            sumPriceIncreaseDecrease +
                            (sumNewRevenue > 0 || sumUpsellRevenue > 0 || sumPriceIncreaseDecrease > 0 ?
                                    sumCancellationRevenue : 0);
                }
            }

            for (AggregateResult row : [
                    select OpportunityId, SUM(FC_One_If_Pay_DBD__c) sumOneIfPayDbd, SUM(FC_DBD_Revenue__c) sumDbdRevenue
                    from OpportunityLineItem
                    where OpportunityId in :Trigger.newMap.keySet() and FC_Pay_DBD__c = true
                    group by OpportunityId
            ]) {
                Opportunity opportunityRecord = (Opportunity) Trigger.newMap.get((Id) row.get('OpportunityId'));
                Decimal sumOneIfPayDbd = (Decimal) row.get('sumOneIfPayDbd');
                Decimal sumDbdRevenue = (Decimal) row.get('sumDbdRevenue');
                if (sumOneIfPayDbd != 0) {
                    opportunityRecord.FC_DBD_Revenue_Summary__c = sumDbdRevenue;
                }
            }

            for (AggregateResult row : [
                    select Opportunity__c, SUM(fziiss__ChargeAmount__c) sumChargeAmount
                    from fziiss__Invoice_Item__c
                    where Opportunity__c in :Trigger.newMap.keySet()
                    and Opportunity__r.StageName = 'Closed Won'
                    and Opportunity__r.One_Time_Sale_Type__c = 'Consulting/Engagement'
                    and (not Name like '%Expenses%')
                    and fziiss__Rate_Plan_Charge__r.Seg3_Record__r.Seg3__c = 'CONS'
                    group by Opportunity__c
            ]) {
                Opportunity opportunityRecord = (Opportunity) Trigger.newMap.get((Id) row.get('Opportunity__c'));
                Decimal sumChargeAmount = (Decimal) row.get('sumChargeAmount');
                opportunityRecord.FC_Consulting_Balance__c = opportunityRecord.Amount - sumChargeAmount;
            }
        }

    }

    global override void bulkAfter() {

        if (Trigger.isUpdate) {

            opportunityIdToFcBillingInstructionStepMap.putAll(
                    FC_FcBillingInstructionStepCache.findByOpportunityIds(Trigger.newMap.keySet()));

        }

    }

    global override void afterInsert(SObject so) {

        Opportunity newOpportunity = (Opportunity) so;

        prepareRecordsForDml(newOpportunity);

    }

    global override void afterUpdate(SObject oldSo, SObject so) {

        Opportunity oldOpportunity = (Opportunity) oldSo;
        Opportunity newOpportunity = (Opportunity) so;

        prepareRecordsForDml(newOpportunity);

    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (Trigger.isInsert) {

            // Insert commission splits
            if (!commissionSplitsToInsert.isEmpty()) {
                insert new List<Commission_Split__c>(commissionSplitsToInsert);
                commissionSplitsToInsert.clear();
            }

        }

        if (Trigger.isUpdate) {

            // Update billing instruction steps
            if (!billingInstructionStepsToUpdate.isEmpty()) {
                update new List<FC_Billing_Instruction_Step__c>(billingInstructionStepsToUpdate);
                billingInstructionStepsToUpdate.clear();
            }

            // Update opportunity line items
            if (!opportunityLineItemsToUpdate.isEmpty()) {
                update new List<OpportunityLineItem>(opportunityLineItemsToUpdate);
                opportunityLineItemsToUpdate.clear();
            }

        }

    }

    private void prepareRecordsForDml(Opportunity newOpportunityRecord) {

        Set<String> recordTypeNamesToProcess = new Set<String>{
                'MS_Opportunity_BPM', 'Market_Intelligence_Opportunity_Record_Type', 'Network_Opportunity',
                'Metrostudy_Opportunity_REE', 'Metrostudy_Opportunity_Record_Type_Admin',
                'Metrostudy_Renewal_Oppty_Record_Type', 'Metrostudy_Opportunity_Record_Type_Consult',
                'MS_Opportunity_Zuora_Duplicates'
        };

        if (newOpportunityRecord.RecordTypeId != null &&
                recordTypeNamesToProcess.contains(Opportunity.sObjectType.getDescribe()
                        .getRecordTypeInfosById().get(newOpportunityRecord.RecordTypeId).getDeveloperName())) {

            if (Trigger.isInsert) {

                commissionSplitsToInsert.add(new Commission_Split__c(Opportunity__c = newOpportunityRecord.Id,
                        Role__c = 'DBD', Commission_Percentage__c = 100, Team_Member__c = newOpportunityRecord.OwnerId,
                        Comments__c = 'PLS IGNORE, For DBD Reports'));

            } else if (Trigger.isUpdate) {

                // Prepare opportunity billing instruction steps for update
                if (opportunityIdToFcBillingInstructionStepMap.containsKey(newOpportunityRecord.Id)) {
                    for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : opportunityIdToFcBillingInstructionStepMap.get(newOpportunityRecord.Id)) {
                        billingInstructionStepsToUpdate.add(new FC_Billing_Instruction_Step__c(Id = billingInstructionStepRecord.Id));
                    }
                }

                // Prepare opportunity line items for update
                if (opportunityIdToOpportunityLineItemsMap.containsKey(newOpportunityRecord.Id)) {
                    for (OpportunityLineItem opportunityLineItemRecord : opportunityIdToOpportunityLineItemsMap.get(newOpportunityRecord.Id)) {
                        opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemRecord.Id));
                    }
                }

            }

        }

    }

    private void populateFields(Opportunity oldOpportunityRecord, Opportunity newOpportunityRecord) {
        if (newOpportunityRecord.ContractId == null) {
            newOpportunityRecord.FC_Term_Start_Date__c = newOpportunityRecord.FC_Contract_Effective_Date__c;
        } else if (newOpportunityRecord.ContractId != null && contractLookupMap.containsKey(newOpportunityRecord.ContractId)) {
            Contract contractRecord = contractLookupMap.get(newOpportunityRecord.ContractId);
            if (Trigger.isInsert || (Trigger.isUpdate && contractRecord.FC_Price_Book__c != oldOpportunityRecord.Pricebook2Id && newOpportunityRecord.FC_Opportunity_Line_Item_Count__c == 0)) {
                newOpportunityRecord.Pricebook2Id = contractRecord.FC_Price_Book__c;
            }
            if (contractRecord.FC_Subscription__c != null) {
                newOpportunityRecord.FC_Billing_Account__c = contractRecord.FC_Subscription__r.Zuora__CustomerAccount__c;
                newOpportunityRecord.FC_Term_Start_Date__c = contractRecord.FC_Subscription__r.Zuora__TermStartDate__c;
                newOpportunityRecord.FC_Term_End_Date__c = contractRecord.FC_Subscription__r.Zuora__TermEndDate__c;
                if (newOpportunityRecord.FC_Term_Type__c == 'TERMED' && newOpportunityRecord.FC_Renew__c && newOpportunityRecord.FC_Renewal_Processed_On__c == null) {
                    newOpportunityRecord.FC_Term_Start_Date__c = contractRecord.FC_Subscription__r.Zuora__TermEndDate__c;
                    Integer renewalTerm = String.isNotBlank(contractRecord.FC_Subscription__r.Zuora__RenewalTerm__c) ?
                            Integer.valueOf(contractRecord.FC_Subscription__r.Zuora__RenewalTerm__c.replaceAll('[^0-9]', '')) : 12;
                    newOpportunityRecord.FC_Term_End_Date__c = newOpportunityRecord.FC_Term_Start_Date__c.addMonths(renewalTerm);
                }
            }
        }

        if (newOpportunityRecord.Purchase_Type__c == 'One-time' && newOpportunityRecord.FC_Last_Sent_To_Zuora__c != null &&
                (oldOpportunityRecord == null || oldOpportunityRecord.FC_Last_Sent_To_Zuora__c != newOpportunityRecord.FC_Last_Sent_To_Zuora__c)) {
            newOpportunityRecord.FC_Notify_Accounting_Generate_Invoice__c = true;
        }

        newOpportunityRecord.FC_Consulting_Balance__c = 0;

        AdBookIntegration.handleOpportunityTriggerPopulateFields(oldOpportunityRecord, newOpportunityRecord);

        if (Trigger.isUpdate) {
            Set<String> opportunityLineItemBillCases = new Set<String>();
            Set<OpportunityLineItem> opportunityLineItems = opportunityIdToOpportunityLineItemsMap.get(newOpportunityRecord.Id);
            if (opportunityLineItems != null) {
                for (OpportunityLineItem opportunityLineItemRecord : opportunityLineItems) {
                    if (String.isNotBlank(opportunityLineItemRecord.FC_Bill_Case__c)) {
                        opportunityLineItemBillCases.add(opportunityLineItemRecord.FC_Bill_Case__c);
                    }
                }
            }
            newOpportunityRecord.FC_Bill_Case__c = String.join(new List<String>(opportunityLineItemBillCases), '; ');
        }

    }

}