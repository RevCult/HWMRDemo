public class FC_OpportunityContractUtil {

    public static void associateOpportunitiesWithContracts(Map<Id, Id> opportunityIdToContractIdMap) {

        Map<Id, Contract> contractLookupMap = new Map<Id, Contract>([
                select Id, FC_Subscription__c, FC_Price_Book__c, FC_Subscription__r.Name,
                        FC_Subscription__r.Opportunity__c,
                        FC_Subscription__r.Zuora__AutoRenew__c,
                        FC_Subscription__r.Zuora__ContractEffectiveDate__c,
                        FC_Subscription__r.Zuora__CustomerAccount__c,
                        FC_Subscription__r.Zuora__CustomerAccount__r.Name,
                        FC_Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                        FC_Subscription__r.Zuora__InitialTerm__c,
                        FC_Subscription__r.Zuora__Notes__c,
                        FC_Subscription__r.Zuora__RenewalTerm__c,
                        FC_Subscription__r.Zuora__ServiceActivationDate__c,
                        FC_Subscription__r.Zuora__TermEndDate__c,
                        FC_Subscription__r.Zuora__TermStartDate__c,
                        FC_Subscription__r.Zuora__TermSettingType__c
                from Contract
                where Id in :opportunityIdToContractIdMap.values()
                and FC_Subscription__c != null
        ]);

        Map<Id, Opportunity> opportunityLookupMap = new Map<Id, Opportunity>([
                select Id, IsClosed, IsWon, MS_Segments__c, (select Id from OpportunityLineItems), (select Id from FC_Billing_Instruction_Sets__r)
                from Opportunity
                where Id in :opportunityIdToContractIdMap.keySet()
        ]);

        // Update opportunities.
        Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
        OpportunityLineItem[] opportunityLineItemsToDelete = new List<OpportunityLineItem>();
        FC_Billing_Instruction_Set__c[] billingInstructionSetsToDelete = new List<FC_Billing_Instruction_Set__c>();
        for (Id opportunityId : opportunityIdToContractIdMap.keySet()) {

            Opportunity opportunityRecord = opportunityLookupMap.get(opportunityId);
            Contract contractRecord = contractLookupMap.get(opportunityIdToContractIdMap.get(opportunityId));

            opportunityRecord.ContractId = contractRecord.Id;
            opportunityRecord.Pricebook2Id = contractRecord.FC_Price_Book__c;
            opportunityRecord.Skip_Validation__c = true;
            if (!(opportunityRecord.IsClosed && opportunityRecord.IsWon)) {

                Decimal initialTerm = null;
                Decimal renewalTerm = null;
                if (String.isNotBlank(contractRecord.FC_Subscription__r.Zuora__InitialTerm__c)) {
                    String initalTermString = contractRecord.FC_Subscription__r.Zuora__InitialTerm__c.replaceAll('[^0-9]', '');
                    if (String.isNotBlank(initalTermString)) {
                        initialTerm = Decimal.valueOf(initalTermString);
                    }
                }
                if (String.isNotBlank(contractRecord.FC_Subscription__r.Zuora__RenewalTerm__c)) {
                    String renewalTermString = contractRecord.FC_Subscription__r.Zuora__RenewalTerm__c.replaceAll('[^0-9]', '');
                    if (String.isNotBlank(renewalTermString)) {
                        renewalTerm = Decimal.valueOf(renewalTermString);
                    }
                }

                opportunityRecord.FC_Auto_Renew__c = contractRecord.FC_Subscription__r.Zuora__AutoRenew__c;
                opportunityRecord.FC_Contract_Effective_Date__c = contractRecord.FC_Subscription__r.Zuora__ContractEffectiveDate__c;
                opportunityRecord.FC_Initial_Term__c = initialTerm;
                opportunityRecord.FC_Renewal_Term__c = renewalTerm;
                opportunityRecord.FC_Service_Activation_Date__c = contractRecord.FC_Subscription__r.Zuora__ServiceActivationDate__c;
                opportunityRecord.FC_Subscription_Notes__c = String.isNotBlank(contractRecord.FC_Subscription__r.Zuora__Notes__c) ? contractRecord.FC_Subscription__r.Zuora__Notes__c.left(500) : '';
                opportunityRecord.FC_Term_Start_Date__c = contractRecord.FC_Subscription__r.Zuora__TermStartDate__c;
                opportunityRecord.FC_Term_End_Date__c = contractRecord.FC_Subscription__r.Zuora__TermEndDate__c;
                opportunityRecord.FC_Term_Type__c = contractRecord.FC_Subscription__r.Zuora__TermSettingType__c;
            }

            opportunitiesToUpdateMap.put(opportunityRecord.Id, opportunityRecord);

            if (opportunityRecord.OpportunityLineItems != null && !opportunityRecord.OpportunityLineItems.isEmpty()) {
                for (OpportunityLineItem opportunityLineItemRecord : opportunityRecord.OpportunityLineItems) {
                    opportunityLineItemsToDelete.add(new OpportunityLineItem(Id = opportunityLineItemRecord.Id));
                }
            }

            if (opportunityRecord.FC_Billing_Instruction_Sets__r != null && !opportunityRecord.FC_Billing_Instruction_Sets__r.isEmpty()) {
                for (FC_Billing_Instruction_Set__c billingInstructionSetRecord : opportunityRecord.FC_Billing_Instruction_Sets__r) {
                    billingInstructionSetsToDelete.add(new FC_Billing_Instruction_Set__c(Id = billingInstructionSetRecord.Id));
                }
            }
        }

        // Remove existing billing instruction sets.
        if (!billingInstructionSetsToDelete.isEmpty()) {
            delete billingInstructionSetsToDelete;
        }

        // Remove existing opportunity line items.
        if (!opportunityLineItemsToDelete.isEmpty()) {
            delete opportunityLineItemsToDelete;
        }

        // Collect subscription and pricebook IDs.
        Set<Id> contractSubscriptionIds = new Set<Id>();
        Set<Id> pricebookIdsToLookup = new Set<Id>();
        for (Contract contractRecord : contractLookupMap.values()) {
            if (contractRecord.FC_Subscription__c != null) {
                contractSubscriptionIds.add(contractRecord.FC_Subscription__c);
            }
            if (contractRecord.FC_Price_Book__c != null) {
                pricebookIdsToLookup.add(contractRecord.FC_Price_Book__c);
            }
        }

        // Retrieve charges for subscriptions.
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> subscriptionIdToSubscriptionProductChargesMap =
                new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        if (!contractSubscriptionIds.isEmpty()) {
            for (Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord : [
                    select Id, Name, ARR__c, Seg3_Record__c, Seg3_Record__r.Product__c, Seg3_Record__r.Product_Geography__c,
                            Seg3_Record__r.Product_Rate_Plan__c, Seg3_Record__r.Charge_Type__c,
                            Zuora__BillingPeriod__c, Zuora__Description__c, Zuora__SubscriptionChargeNumber__c, Zuora__EffectiveStartDate__c,
                            Zuora__Price__c, Zuora__Subscription__c, Zuora__Subscription__r.Name, Zuora__Subscription__r.Zuora__External_Id__c
                    from Zuora__SubscriptionProductCharge__c
                    where Zuora__Subscription__c in :contractSubscriptionIds
                    and Zuora__Type__c = 'Recurring'
            ]) {
                List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeRecords =
                        subscriptionIdToSubscriptionProductChargesMap.get(subscriptionProductChargeRecord.Zuora__Subscription__c);
                if (subscriptionProductChargeRecords == null) {
                    subscriptionProductChargeRecords = new List<Zuora__SubscriptionProductCharge__c>();
                    subscriptionIdToSubscriptionProductChargesMap.put(subscriptionProductChargeRecord.Zuora__Subscription__c, subscriptionProductChargeRecords);
                }
                subscriptionProductChargeRecords.add(subscriptionProductChargeRecord);
            }
        }

        // Build map of product IDs to pricebook entries
        Map<PricebookProductKey, PricebookEntry> pricebookProductKeyToPricebookEntryMap = new Map<PricebookProductKey, PricebookEntry>();
        Set<Id> productIdsToLookup = new Set<Id>();
        for (List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargesRecords : subscriptionIdToSubscriptionProductChargesMap.values()) {
            for (Zuora__SubscriptionProductCharge__c subscriptionProductChargesRecord : subscriptionProductChargesRecords) {
                if (subscriptionProductChargesRecord.Seg3_Record__r.Product__c != null) {
                    productIdsToLookup.add(subscriptionProductChargesRecord.Seg3_Record__r.Product__c);
                }
            }
        }
        if (!productIdsToLookup.isEmpty()) {
            for (PricebookEntry pricebookEntryRecord : [
                    select Id, Pricebook2Id, Product2Id
                    from PricebookEntry
                    where Product2Id in :productIdsToLookup
                    and Pricebook2Id in :pricebookIdsToLookup
            ]) {
                pricebookProductKeyToPricebookEntryMap.put(
                        new PricebookProductKey(pricebookEntryRecord.Pricebook2Id, pricebookEntryRecord.Product2Id),
                        pricebookEntryRecord);
            }
        }

        Map<String, String> billingPeriodToBillingFrequencyMap = new Map<String, String>{
                'Month' => 'Monthly',
                'Quarter' => 'Quarterly',
                'Semi_Annual' => 'Semi-Annually',
                'Annual' => 'Annually'
        };

        // Create opportunity line items based on contract subscription charges.
        OpportunityLineItem[] opportunityLineItemsToInsert = new List<OpportunityLineItem>();
        Zuora__SubscriptionProductCharge__c[] allSubscriptionProductChargeRecords = new List<Zuora__SubscriptionProductCharge__c>();
        for (Opportunity opportunityRecord : opportunityLookupMap.values()) {

            Contract contractRecord = contractLookupMap.get(opportunityIdToContractIdMap.get(opportunityRecord.Id));
            List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeRecords =
                    subscriptionIdToSubscriptionProductChargesMap.get(contractRecord.FC_Subscription__c);
            if (opportunityRecord != null && subscriptionProductChargeRecords != null) {
                for (Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord : subscriptionProductChargeRecords) {
                    PricebookEntry pricebookEntryRecord = pricebookProductKeyToPricebookEntryMap.get(
                            new PricebookProductKey(opportunityRecord.Pricebook2Id,
                                    subscriptionProductChargeRecord.Seg3_Record__r.Product__c));
                    if (pricebookEntryRecord != null) {
                        opportunityLineItemsToInsert.add(new OpportunityLineItem(
                                Billing_Frequency__c = billingPeriodToBillingFrequencyMap.get(subscriptionProductChargeRecord.Zuora__BillingPeriod__c),
                                Description = subscriptionProductChargeRecord.Zuora__Description__c,
                                FC_Effective_Date__c = subscriptionProductChargeRecord.Zuora__EffectiveStartDate__c,
                                FC_Original_Sale_Price__c = subscriptionProductChargeRecord.ARR__c,
                                FC_Product_Geography_Seg3__c = subscriptionProductChargeRecord.Seg3_Record__c,
                                FC_Zuora_Action__c = 'No Action',
                                MetroStudy_Product__c = true,
                                MS_Segment__c = opportunityRecord.MS_Segments__c,
                                OpportunityId = opportunityRecord.Id,
                                PricebookEntryId = pricebookEntryRecord.Id,
                                Quantity = 1,
                                FC_Sale_Price__c = subscriptionProductChargeRecord.ARR__c
                        ));
                        allSubscriptionProductChargeRecords.add(subscriptionProductChargeRecord);
                    }
                }
            }

        }

        if (!opportunityLineItemsToInsert.isEmpty()) {

            // Ensure all triggers run again.
            fcf.TriggerRunStatus.unblockAll();
            FC_OpportunityLineItemCache.clearCache();
            FC_FcBillingInstructionStepCache.clearCache();

            insert opportunityLineItemsToInsert;

            Map<Id, OpportunityLineItem> insertedOpportunityLineItemRecordsMap = new Map<Id, OpportunityLineItem>([
                    select Id, OpportunityId, FC_UUID__c
                    from OpportunityLineItem
                    where Id in :opportunityLineItemsToInsert
            ]);

            // Create a billing instruction set for each opportunity line item.
            FC_Billing_Instruction_Set__c[] billingInstructionSetsToInsert = new List<FC_Billing_Instruction_Set__c>();
            for (Integer i = 0; i < opportunityLineItemsToInsert.size(); i++) {
                OpportunityLineItem insertedOpportunityLineItemRecord = opportunityLineItemsToInsert[i];
                billingInstructionSetsToInsert.add(new FC_Billing_Instruction_Set__c(
                        Charge_Number__c = allSubscriptionProductChargeRecords[i].Zuora__SubscriptionChargeNumber__c,
                        Opportunity__c = insertedOpportunityLineItemRecord.OpportunityId,
                        Opportunity_Line_Item_ID__c = insertedOpportunityLineItemRecord.Id,
                        Opportunity_Line_Item_UUID__c = insertedOpportunityLineItemRecordsMap.get(opportunityLineItemsToInsert[i].Id).FC_UUID__c));
            }
            if (!billingInstructionSetsToInsert.isEmpty()) {
                insert billingInstructionSetsToInsert;

                // Update each opportunity line item with the billing instruction set ID.
                OpportunityLineItem[] opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
                for (Integer i = 0; i < billingInstructionSetsToInsert.size(); i++) {
                    opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemsToInsert[i].Id,
                            FC_Billing_Instruction_Set__c = billingInstructionSetsToInsert[i].Id));
                }
                if (!opportunityLineItemsToUpdate.isEmpty()) {
                    update opportunityLineItemsToUpdate;
                }
            }
        }

        if (!opportunitiesToUpdateMap.isEmpty()) {
            update opportunitiesToUpdateMap.values();
        }
    }

    @testVisible
    private class PricebookProductKey {

        public Id pricebookId;
        public Id productId;

        public PricebookProductKey(Id pricebookId, Id productId) {
            this.pricebookId = pricebookId;
            this.productId = productId;
        }

        public Boolean equals(Object otherObject) {
            if (otherObject instanceof PricebookProductKey) {
                PricebookProductKey other = (PricebookProductKey) otherObject;
                return (this === other) || (other != null &&
                        this.pricebookId == other.pricebookId && this.productId == other.productId);
            }
            return false;
        }

        public Integer hashCode() {
            final Integer PRIME = 31;
            Integer result = 1;
            result = PRIME * result + (pricebookId == null ? 0 : String.valueOf(pricebookId).hashCode());
            result = PRIME * result + (productId == null ? 0 : String.valueOf(productId).hashCode());
            return result;
        }

    }
}