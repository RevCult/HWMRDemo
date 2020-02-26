global without sharing class FC_FcBillingInstructionSetHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_FcBillingInstructionSetHandler';

    // Before phase variables
    private Map<String, OpportunityLineItem> uuidToOpportunityLineItemsMap = new Map<String, OpportunityLineItem>();
    private Map<String, Zuora__SubscriptionProductCharge__c> chargeNumberToSubscriptionProductCharges =
            new Map<String, Zuora__SubscriptionProductCharge__c>();

    // After phase variables
    private Map<Id, OpportunityLineItem> opportunityLineItemLookupMap = new Map<Id, OpportunityLineItem>();
    private Set<OpportunityLineItem> opportunityLineItemsToUpdate = new Set<OpportunityLineItem>();

    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<String> opportunityLineItemUuidsToLookup = new Set<String>();
            Set<String> chargeNumbersToLookup = new Set<String>();
            for (SObject so : Trigger.new) {
                FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord = (FC_Billing_Instruction_Set__c) so;
                if (String.isNotBlank(fcBillingInstructionSetRecord.Opportunity_Line_Item_UUID__c)) {
                    opportunityLineItemUuidsToLookup.add(fcBillingInstructionSetRecord.Opportunity_Line_Item_UUID__c);
                }
                if (String.isNotBlank(fcBillingInstructionSetRecord.Charge_Number__c)) {
                    chargeNumbersToLookup.add(fcBillingInstructionSetRecord.Charge_Number__c);
                }
            }
            uuidToOpportunityLineItemsMap.putAll(FC_OpportunityLineItemCache.findByUuids(opportunityLineItemUuidsToLookup));
            chargeNumberToSubscriptionProductCharges.putAll(FC_SubscriptionProductChargeCache.findByChargeNumbers(chargeNumbersToLookup));
        }
    }

    global override void beforeInsert(SObject so) {
        FC_Billing_Instruction_Set__c newFcBillingInstructionSet = (FC_Billing_Instruction_Set__c) so;
        populateFields(newFcBillingInstructionSet);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        FC_Billing_Instruction_Set__c newFcBillingInstructionSet = (FC_Billing_Instruction_Set__c) so;
        populateFields(newFcBillingInstructionSet);
    }

    global override void bulkAfter() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<Id> opportunityLineItemIdsToLookup = new Set<Id>();
            for (SObject so : Trigger.new) {
                FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord = (FC_Billing_Instruction_Set__c) so;
                if (String.isNotBlank(fcBillingInstructionSetRecord.Opportunity_Line_Item_ID__c)) {
                    try {
                        opportunityLineItemIdsToLookup.add(Id.valueOf(fcBillingInstructionSetRecord.Opportunity_Line_Item_ID__c));
                    } catch (Exception e) {
                        // Do nothing.
                    }
                }
            }

            opportunityLineItemLookupMap.putAll(FC_OpportunityLineItemCache.findByIds(opportunityLineItemIdsToLookup));
        }

    }

    global override void afterInsert(SObject so) {
        FC_Billing_Instruction_Set__c newFcBillingInstructionSet = (FC_Billing_Instruction_Set__c) so;
        prepareOpportunityLineItemForUpdate(newFcBillingInstructionSet);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        FC_Billing_Instruction_Set__c newFcBillingInstructionSet = (FC_Billing_Instruction_Set__c) so;
        prepareOpportunityLineItemForUpdate(newFcBillingInstructionSet);
    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (Trigger.isInsert || Trigger.isUpdate) {

            if (!opportunityLineItemsToUpdate.isEmpty()) {
                update new List<OpportunityLineItem>(opportunityLineItemsToUpdate);
                opportunityLineItemsToUpdate.clear();
            }

        }

    }

    private void prepareOpportunityLineItemForUpdate(FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord) {
        try {
            if (String.isNotBlank(fcBillingInstructionSetRecord.Opportunity_Line_Item_ID__c)) {
                Id opportunityLineItemId = Id.valueOf(fcBillingInstructionSetRecord.Opportunity_Line_Item_ID__c);
                if (opportunityLineItemLookupMap.containsKey(opportunityLineItemId)) {
                    opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemId));
                }
            }
        } catch (Exception e) {
            // Do nothing.
        }
    }

    private void populateFields(FC_Billing_Instruction_Set__c fcBillingInstructionSetRecord) {

        if (String.isNotBlank(fcBillingInstructionSetRecord.Opportunity_Line_Item_UUID__c) &&
                uuidToOpportunityLineItemsMap.containsKey(fcBillingInstructionSetRecord.Opportunity_Line_Item_UUID__c)) {
            OpportunityLineItem opportunityLineItemRecord = uuidToOpportunityLineItemsMap.get(fcBillingInstructionSetRecord.Opportunity_Line_Item_UUID__c);
            fcBillingInstructionSetRecord.Opportunity_Line_Item_ID__c = opportunityLineItemRecord.Id;
            if (Trigger.isInsert) {
                fcBillingInstructionSetRecord.Opportunity__c = opportunityLineItemRecord.OpportunityId;
            }
        }

        fcBillingInstructionSetRecord.Charge__c = null;
        if (String.isNotBlank(fcBillingInstructionSetRecord.Charge_Number__c) &&
                chargeNumberToSubscriptionProductCharges.containsKey(fcBillingInstructionSetRecord.Charge_Number__c)) {
            fcBillingInstructionSetRecord.Charge__c = chargeNumberToSubscriptionProductCharges.get(fcBillingInstructionSetRecord.Charge_Number__c).Id;
        }

    }

}