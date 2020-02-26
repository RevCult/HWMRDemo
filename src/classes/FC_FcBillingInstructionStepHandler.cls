global without sharing class FC_FcBillingInstructionStepHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_FcBillingInstructionStepHandler';

    // Before and after phase variables
    private static Map<Id, Set<String>> fcBillingInstructionStepToTagsMap = new Map<Id, Set<String>>();
    private static Map<Id, FC_Billing_Instruction_Set__c> fcBillingInstructionSetLookupMap = new Map<Id, FC_Billing_Instruction_Set__c>();
    private static Map<Id, OpportunityLineItem> fcBillingInstructionSetIdToOpportunityLineItemMap = new Map<Id, OpportunityLineItem>();

    // Before phase variables
    private Map<Id, FC_Billing_Instruction_Step__c> fcBillingInstructionStepLookupMap = new Map<Id, FC_Billing_Instruction_Step__c>();

    // After phase variables
    private Map<Id, FC_Metroclient_Product_Geography_Seg3__c> fcMetroclientProductGeographySeg3LookupMap = new Map<Id, FC_Metroclient_Product_Geography_Seg3__c>();
    private Map<Id, Set<String>> fcMetroclientProductGeographySeg3ToTagsMap = new Map<Id, Set<String>>();
    private Set<FC_Billing_Instruction_Step__Tag> fcBillingInstructionStepTagsToCreate = new Set<FC_Billing_Instruction_Step__Tag>();
    private Set<FC_Billing_Instruction_Step__c> fcBillingInstructionStepsToUpdate = new Set<FC_Billing_Instruction_Step__c>();
    private Set<Opportunity> opportunitiesToUpdate = new Set<Opportunity>();

    global override void bulkBefore() {

        if (Trigger.isUpdate) {

            fcBillingInstructionStepLookupMap.putAll(FC_FcBillingInstructionStepCache.findByIds(Trigger.newMap.keySet()));
            for (Id fcBillingInstructionStepRecordId : fcBillingInstructionStepLookupMap.keySet()) {
                Set<String> fcBillingInstructionSetTags = fcBillingInstructionStepToTagsMap.get(fcBillingInstructionStepRecordId);
                if (fcBillingInstructionSetTags == null) {
                    fcBillingInstructionSetTags = new Set<String>();
                    fcBillingInstructionStepToTagsMap.put(fcBillingInstructionStepRecordId, fcBillingInstructionSetTags);
                }
                for (FC_Billing_Instruction_Step__Tag tagRecord : fcBillingInstructionStepLookupMap.get(fcBillingInstructionStepRecordId).Tags) {
                    fcBillingInstructionSetTags.add(tagRecord.Name);
                }
            }

        }

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<Id> fcBillingInstructionSetIdsToLookup = new Set<Id>();
            for (SObject so : Trigger.new) {
                FC_Billing_Instruction_Step__c fcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
                fcBillingInstructionSetIdsToLookup.add(fcBillingInstructionStepRecord.Billing_Instruction_Set__c);
            }
            fcBillingInstructionSetLookupMap.putAll(FC_FcBillingInstructionSetCache.findByIds(fcBillingInstructionSetIdsToLookup));
            fcBillingInstructionSetIdToOpportunityLineItemMap.putAll(FC_OpportunityLineItemCache.findByBillingInstructionSetIds(fcBillingInstructionSetIdsToLookup));

        }

    }

    global override void beforeInsert(SObject so) {
        FC_Billing_Instruction_Step__c newFcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
        populateFields(newFcBillingInstructionStepRecord);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        FC_Billing_Instruction_Step__c newFcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
        populateFields(newFcBillingInstructionStepRecord);
    }

    global override void bulkAfter() {

        if (Trigger.isInsert) {

            Set<Id> fcMetroclientProductGeographySeg3IdsToLookup = new Set<Id>();
            for (SObject so : Trigger.new) {
                FC_Billing_Instruction_Step__c billingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
                if (billingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c != null) {
                    fcMetroclientProductGeographySeg3IdsToLookup.add(billingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c);
                }
            }
            fcMetroclientProductGeographySeg3LookupMap.putAll(FC_FcMetroclientProductGeoSeg3Cache.findByIds(fcMetroclientProductGeographySeg3IdsToLookup));

            for (Id fcMetroclientProductGeographySeg3RecordId : fcMetroclientProductGeographySeg3LookupMap.keySet()) {
                Set<String> fcMetroclientProductGeographySeg3Tags = fcMetroclientProductGeographySeg3ToTagsMap.get(fcMetroclientProductGeographySeg3RecordId);
                if (fcMetroclientProductGeographySeg3Tags == null) {
                    fcMetroclientProductGeographySeg3Tags = new Set<String>();
                    fcMetroclientProductGeographySeg3ToTagsMap.put(fcMetroclientProductGeographySeg3RecordId, fcMetroclientProductGeographySeg3Tags);
                }
                for (FC_Metroclient_Product_Geography_Seg3__Tag tagRecord : fcMetroclientProductGeographySeg3LookupMap.get(fcMetroclientProductGeographySeg3RecordId).Tags) {
                    fcMetroclientProductGeographySeg3Tags.add(tagRecord.Name);
                }
            }

        }

    }

    global override void afterInsert(SObject so) {
        FC_Billing_Instruction_Step__c newFcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
        prepareTagRecordsForInsert(newFcBillingInstructionStepRecord);
//        prepareOpportunityRecordsForUpdate(null, newFcBillingInstructionStepRecord);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        FC_Billing_Instruction_Step__c oldFcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) oldSo;
        FC_Billing_Instruction_Step__c newFcBillingInstructionStepRecord = (FC_Billing_Instruction_Step__c) so;
//        prepareOpportunityRecordsForUpdate(oldFcBillingInstructionStepRecord, newFcBillingInstructionStepRecord);
    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (Trigger.isInsert) {

            if (!fcBillingInstructionStepTagsToCreate.isEmpty()) {
                insert new List<FC_Billing_Instruction_Step__Tag>(fcBillingInstructionStepTagsToCreate);
                fcBillingInstructionStepTagsToCreate.clear();
            }
            if (!fcBillingInstructionStepsToUpdate.isEmpty()) {
                update new List<FC_Billing_Instruction_Step__c>(fcBillingInstructionStepsToUpdate);
                fcBillingInstructionStepsToUpdate.clear();
            }

        }

        if (Trigger.isUpdate) {
            if (!opportunitiesToUpdate.isEmpty()) {
                update new List<Opportunity>(opportunitiesToUpdate);
                opportunitiesToUpdate.clear();
            }
        }

    }

//    private void prepareOpportunityRecordsForUpdate(FC_Billing_Instruction_Step__c oldFcBillingInstructionStepRecord,
//            FC_Billing_Instruction_Step__c newFcBillingInstructionStepRecord) {
//
//        Set<String> fcBillingInstructionStepTags =
//                fcBillingInstructionStepToTagsMap.get(newFcBillingInstructionStepRecord.Id);
//        FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord =
//                fcBillingInstructionSetLookupMap.get(newFcBillingInstructionStepRecord.Billing_Instruction_Set__c);
//
//        if (fcBillingInstructionStepTags != null && fcBillingInstructionStepTags.contains('Expenses') &&
//                fcBillingInstructionSetRecord != null &&
//                (oldFcBillingInstructionStepRecord == null || oldFcBillingInstructionStepRecord.Status__c != 'Executed') &&
//                newFcBillingInstructionStepRecord.Status__c == 'Executed' &&
//                newFcBillingInstructionStepRecord.Price__c > 0) {
//
//            OpportunityLineItem opportunityLineItemRecord =
//                    fcBillingInstructionSetIdToOpportunityLineItemMap.get(fcBillingInstructionSetRecord.Id);
//
//            if (opportunityLineItemRecord != null &&
//                    opportunityLineItemRecord.FC_Product_Geography_Seg3__r.Seg3__c == 'CONS') {
//                opportunitiesToUpdate.add(new Opportunity(Id = fcBillingInstructionSetRecord.Opportunity__c,
//                        Skip_Validation__c = true, FC_Notify_Accounting_Generate_Invoice__c = true));
//            }
//
//        }
//
//    }

    private void prepareTagRecordsForInsert(FC_Billing_Instruction_Step__c fcBillingInstructionStepRecord) {
        if (fcBillingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c != null &&
                fcMetroclientProductGeographySeg3ToTagsMap.containsKey(fcBillingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c)) {
            Set<String> fcMetroclientProductGeographySeg3TagNames =
                    fcMetroclientProductGeographySeg3ToTagsMap.get(fcBillingInstructionStepRecord.Metrostudy_Product_Geography_Seg3__c);
            for (String fcMetroclientProductGeographySeg3TagName : fcMetroclientProductGeographySeg3TagNames) {
                fcBillingInstructionStepTagsToCreate.add(
                        new FC_Billing_Instruction_Step__Tag(ItemId = fcBillingInstructionStepRecord.Id,
                                Name = fcMetroclientProductGeographySeg3TagName, Type = 'Public'));
                fcBillingInstructionStepsToUpdate.add(new FC_Billing_Instruction_Step__c(Id = fcBillingInstructionStepRecord.Id));
            }
        }
    }

    private void populateFields(FC_Billing_Instruction_Step__c fcBillingInstructionStepRecord) {

        // Initialize tag set in a "before insert"-safe manner.
        Set<String> fcBillingInstructionStepTags = new Set<String>();
        if (fcBillingInstructionStepRecord.Id != null) {
            fcBillingInstructionStepTags.addAll(fcBillingInstructionStepToTagsMap.get(fcBillingInstructionStepRecord.Id));
        }

        FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord = fcBillingInstructionSetLookupMap.get(fcBillingInstructionStepRecord.Billing_Instruction_Set__c);
        OpportunityLineItem opportunityLineItemRecord = fcBillingInstructionSetIdToOpportunityLineItemMap.get(fcBillingInstructionSetRecord.Id);

        Map<String, Integer> billingPeriodToMultiplerMap = new Map<String, Integer>{
                'Month' => 1, 'Monthly' => 1,
                'Quarter' => 3, 'Quarterly' => 3,
                'Semi_Annual' => 6, 'Semi-Annually' => 6,
                'Annual' => 12, 'Annually' => 12
        };

        // Populate End Date
        fcBillingInstructionStepRecord.End_Date__c = null;
        if (opportunityLineItemRecord != null) {

            if (fcBillingInstructionStepRecord.Contract_Effective_Date__c != null) {

                Integer billingPeriodMultiplier = 0;
                if ((String.isNotEmpty(fcBillingInstructionStepRecord.Billing_Period__c) &&
                        billingPeriodToMultiplerMap.containsKey(fcBillingInstructionStepRecord.Billing_Period__c)) ||
                        (String.isNotEmpty(opportunityLineItemRecord.Billing_Frequency__c) &&
                                billingPeriodToMultiplerMap.containsKey(opportunityLineItemRecord.Billing_Frequency__c))) {
                    billingPeriodMultiplier = String.isNotEmpty(fcBillingInstructionStepRecord.Billing_Period__c) ?
                            billingPeriodToMultiplerMap.get(fcBillingInstructionStepRecord.Billing_Period__c) :
                            billingPeriodToMultiplerMap.get(opportunityLineItemRecord.Billing_Frequency__c);
                }

                Integer upToPeriods = (fcBillingInstructionSetRecord.Opportunity__r.FC_Initial_Term__c != null ?
                        Integer.valueOf(fcBillingInstructionSetRecord.Opportunity__r.FC_Initial_Term__c) : 12) /
                        (billingPeriodMultiplier > 0 ? billingPeriodMultiplier : 1);
                if (fcBillingInstructionStepRecord.Up_To_Periods__c != null) {
                    upToPeriods = Integer.valueOf(fcBillingInstructionStepRecord.Up_To_Periods__c);
                }

                System.debug('******* TEMPLATE: ' + fcBillingInstructionSetRecord.Template__r.Name);
                if (fcBillingInstructionSetRecord.Template__r.Name == 'Ramp Up' || fcBillingInstructionSetRecord.Template__r.Name == 'Step Up') {
                    if (fcBillingInstructionStepRecord.Metadata_Is_Last__c) {
                        fcBillingInstructionStepRecord.End_Date__c = fcBillingInstructionSetRecord.Opportunity__r.FC_Term_End_Date__c;
                    } else {
                        Integer numberOfPeriods = 1;
                        if (fcBillingInstructionStepRecord.Metadata_Number_of_Periods__c != null) {
                            numberOfPeriods = Integer.valueOf(fcBillingInstructionStepRecord.Metadata_Number_of_Periods__c);
                        }
                        fcBillingInstructionStepRecord.End_Date__c = fcBillingInstructionStepRecord.Contract_Effective_Date__c.addMonths(
                                numberOfPeriods * billingPeriodMultiplier) - (billingPeriodMultiplier > 0 ? 1 : 0);
                    }
                } else {
                    fcBillingInstructionStepRecord.End_Date__c = fcBillingInstructionStepRecord.Contract_Effective_Date__c.addMonths(
                            upToPeriods * billingPeriodMultiplier) - (billingPeriodMultiplier > 0 ? 1 : 0);
                }

                if (fcBillingInstructionStepRecord.End_Date__c != null && fcBillingInstructionStepRecord.Price__c != null) {
                    fcBillingInstructionStepRecord.Total_Price__c = fcBillingInstructionStepRecord.Price__c *
                            (fcBillingInstructionStepRecord.Contract_Effective_Date__c.monthsBetween(fcBillingInstructionStepRecord.End_Date__c + (billingPeriodMultiplier > 0 ? 1 : 0))) /
                            (billingPeriodMultiplier > 0 ? billingPeriodMultiplier : 1);
                }
            }

            // Populate CONS specific data
            if (fcBillingInstructionStepRecord.Status__c == 'New' && opportunityLineItemRecord != null &&
                    opportunityLineItemRecord.FC_Product_Geography_Seg3__r.Seg3__c == 'CONS') {

                // Execute the CONS Balance Due instruction only if Proof of Delivery is attached.
                if (fcBillingInstructionStepTags.contains('Balance Due')) {
                    fcBillingInstructionStepRecord.Execute_Immediately__c = opportunityLineItemRecord.Opportunity.Proof_of_Delivery_attached__c;

                    if (opportunityLineItemRecord.Opportunity.Proof_Of_Delivery_Delivered_Date__c != null) {
                        fcBillingInstructionStepRecord.Contract_Effective_Date__c = opportunityLineItemRecord.Opportunity.Proof_Of_Delivery_Delivered_Date__c;
                    }
                }

                // Execute the CONS Expenses instruction only if the amount is a positive number.
                if (fcBillingInstructionStepTags.contains('Expenses')) {
                    fcBillingInstructionStepRecord.Execute_Immediately__c = fcBillingInstructionStepRecord.Price__c != null &&
                            fcBillingInstructionStepRecord.Price__c > 0;

                    if (opportunityLineItemRecord.Opportunity.Proof_Of_Delivery_Delivered_Date__c != null) {
                        fcBillingInstructionStepRecord.Contract_Effective_Date__c = opportunityLineItemRecord.Opportunity.Proof_Of_Delivery_Delivered_Date__c;
                    }
                }

            }

        }

    }

}