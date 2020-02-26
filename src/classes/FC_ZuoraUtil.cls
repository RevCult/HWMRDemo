public class FC_ZuoraUtil {

    public static FC_ZuoraClient.UpdateSubscriptionRequest buildGenerateInvoiceForSubscriptionRequest(Date targetDate) {

        // Build update subscription request
        FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = new FC_ZuoraClient.UpdateSubscriptionRequest();
        updateSubscriptionRequest.targetDate = targetDate;
        updateSubscriptionRequest.runBilling = true;

        return updateSubscriptionRequest;

    }

    public static FC_ZuoraClient.RenewSubscriptionRequest buildRenewSubscriptionRequest(Opportunity opportunityRecord) {

        FC_ZuoraClient.RenewSubscriptionRequest renewSubscriptionRequest = new FC_ZuoraClient.RenewSubscriptionRequest();
        renewSubscriptionRequest.runBilling = false;

        return renewSubscriptionRequest;

    }

    public static FC_ZuoraClient.SubscribeActionRequest buildSubscribeActionRequest(
            FC_Billing_Instruction_Step__c[] billingInstructionSteps, Opportunity opportunityRecord) {

        FC_Billing_Instruction_Settings__c billingInstructionSettings = FC_Billing_Instruction_Settings__c.getOrgDefaults();

        FC_ZuoraClient.SubscribeActionRequest request = new FC_ZuoraClient.SubscribeActionRequest();
        request.subscribes = new List<FC_ZuoraClient.Subscribe>();

        FC_ZuoraClient.Subscribe subscribe = new FC_ZuoraClient.Subscribe();

        subscribe.Account = new FC_ZuoraClient.ZuoraAccount();
        if (opportunityRecord.FC_Billing_Account__c != null) {
            subscribe.Account.Id = opportunityRecord.FC_Billing_Account__r.Zuora__External_Id__c;
        } else {
            subscribe.Account.AutoPay = false;
            subscribe.Account.Batch = opportunityRecord.FC_Batch__c;
            subscribe.Account.BillCycleDay = Integer.valueOf(opportunityRecord.FC_Bill_Cycle_Day__c);
            subscribe.Account.CrmId = opportunityRecord.AccountId;
            subscribe.Account.Currency_x = opportunityRecord.FC_Currency__c;
            subscribe.Account.DefaultPaymentMethodId = billingInstructionSettings.Check_Payment_Method_Zuora_ID__c;
            subscribe.Account.InvoiceDeliveryPrefsEmail = true;
            subscribe.Account.InvoiceDeliveryPrefsPrint = true;
            subscribe.Account.Name = opportunityRecord.Account.Name;
            subscribe.Account.PaymentTerm = opportunityRecord.FC_Payment_Term__c;
            subscribe.Account.SalesRepName = opportunityRecord.Owner.Name;

            subscribe.BillToContact = new FC_ZuoraClient.ZuoraContact();
            String[] billToAddressLines = opportunityRecord.FC_Bill_To_Contact__r.MailingStreet.split('\n');
            subscribe.BillToContact.Address1 = billToAddressLines[0];
            if (billToAddressLines.size() > 1) {
                subscribe.BillToContact.Address2 = billToAddressLines[1];
            }
            subscribe.BillToContact.City = opportunityRecord.FC_Bill_To_Contact__r.MailingCity;
            subscribe.BillToContact.Country = opportunityRecord.FC_Bill_To_Contact__r.MailingCountryCode;
            subscribe.BillToContact.Fax = opportunityRecord.FC_Bill_To_Contact__r.Fax;
            subscribe.BillToContact.FirstName = opportunityRecord.FC_Bill_To_Contact__r.FirstName;
            subscribe.BillToContact.LastName = opportunityRecord.FC_Bill_To_Contact__r.LastName;
            subscribe.BillToContact.PostalCode = opportunityRecord.FC_Bill_To_Contact__r.MailingPostalCode;
            subscribe.BillToContact.State = opportunityRecord.FC_Bill_To_Contact__r.MailingCountryCode == 'US' ||
                    opportunityRecord.FC_Bill_To_Contact__r.MailingCountryCode == 'CA' ?
                    opportunityRecord.FC_Bill_To_Contact__r.MailingStateCode :
                    opportunityRecord.FC_Bill_To_Contact__r.MailingState;
            subscribe.BillToContact.WorkEmail = opportunityRecord.FC_Bill_To_Contact__r.Billing_Email_Address__c;

            if (opportunityRecord.FC_Sold_To_Contact__c != null) {
                subscribe.SoldToContact = new FC_ZuoraClient.ZuoraContact();
                String[] soldToAddressLines = opportunityRecord.FC_Sold_To_Contact__r.MailingStreet.split('\n');
                subscribe.SoldToContact.Address1 = soldToAddressLines[0];
                if (soldToAddressLines.size() > 1) {
                    subscribe.SoldToContact.Address2 = soldToAddressLines[1];
                }
                subscribe.SoldToContact.City = opportunityRecord.FC_Sold_To_Contact__r.MailingCity;
                subscribe.SoldToContact.Country = opportunityRecord.FC_Sold_To_Contact__r.MailingCountryCode;
                subscribe.SoldToContact.Fax = opportunityRecord.FC_Sold_To_Contact__r.Fax;
                subscribe.SoldToContact.FirstName = opportunityRecord.FC_Sold_To_Contact__r.FirstName;
                subscribe.SoldToContact.LastName = opportunityRecord.FC_Sold_To_Contact__r.LastName;
                subscribe.SoldToContact.PostalCode = opportunityRecord.FC_Sold_To_Contact__r.MailingPostalCode;
                subscribe.SoldToContact.State = opportunityRecord.FC_Sold_To_Contact__r.MailingCountryCode == 'US' ||
                        opportunityRecord.FC_Sold_To_Contact__r.MailingCountryCode == 'CA' ?
                        opportunityRecord.FC_Sold_To_Contact__r.MailingStateCode :
                        opportunityRecord.FC_Sold_To_Contact__r.MailingState;
                subscribe.SoldToContact.WorkEmail = opportunityRecord.FC_Sold_To_Contact__r.Email;
            }
        }

        subscribe.PreviewOptions = new FC_ZuoraClient.PreviewOptions();
        subscribe.PreviewOptions.EnablePreviewMode = false;

        subscribe.SubscribeOptions = new FC_ZuoraClient.SubscribeOptions();
        subscribe.SubscribeOptions.GenerateInvoice = false;
        subscribe.SubscribeOptions.ProcessPayments = false;

        if (opportunityRecord.FC_Target_Date__c != null) {
            subscribe.SubscribeOptions.SubscribeInvoiceProcessingOptions = new FC_ZuoraClient.SubscribeInvoiceProcessingOptions();
            subscribe.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceTargetDate = opportunityRecord.FC_Target_Date__c;
        }

        subscribe.SubscriptionData = new FC_ZuoraClient.SubscriptionData();

        subscribe.SubscriptionData.Subscription = new FC_ZuoraClient.Subscription();
        subscribe.SubscriptionData.Subscription.AutoRenew = opportunityRecord.FC_Auto_Renew__c;
        subscribe.SubscriptionData.Subscription.BillCase_c = opportunityRecord.FC_Bill_Case__c;
        subscribe.SubscriptionData.Subscription.ContractEffectiveDate = opportunityRecord.FC_Contract_Effective_Date__c;
        subscribe.SubscriptionData.Subscription.InitialTerm = Integer.valueOf(opportunityRecord.FC_Initial_Term__c);
        subscribe.SubscriptionData.Subscription.IsInvoiceSeparate = opportunityRecord.FC_Invoice_Separately__c;
        subscribe.SubscriptionData.Subscription.Notes = String.isNotBlank(opportunityRecord.FC_Subscription_Notes__c) ? opportunityRecord.FC_Subscription_Notes__c.left(500) : '';
        subscribe.SubscriptionData.Subscription.OpportunityCloseDate_q = opportunityRecord.CloseDate;
        subscribe.SubscriptionData.Subscription.OpportunityID_c = opportunityRecord.Id;
        subscribe.SubscriptionData.Subscription.OpportunityName_q = opportunityRecord.Name.left(100);
        subscribe.SubscriptionData.Subscription.Region_c = opportunityRecord.Region__c;
        subscribe.SubscriptionData.Subscription.RenewalTerm = Integer.valueOf(opportunityRecord.FC_Renewal_Term__c);
        subscribe.SubscriptionData.Subscription.ServiceActivationDate = opportunityRecord.FC_Service_Activation_Date__c;
        subscribe.SubscriptionData.Subscription.TermStartDate = opportunityRecord.FC_Contract_Effective_Date__c;
        subscribe.SubscriptionData.Subscription.TermType = opportunityRecord.FC_Term_Type__c;

        subscribe.SubscriptionData.RatePlanData = new List<FC_ZuoraClient.RatePlanData>();

        Map<String, String> billingPeriodValueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult billingPeriodDescribe = FC_Billing_Instruction_Step__c.Billing_Period__c.getDescribe();
        Schema.PickListEntry[] billingPeriodPickListEntries = billingPeriodDescribe.getPicklistValues();
        for (Schema.PickListEntry pickListEntry : billingPeriodPickListEntries) {
            billingPeriodValueToLabelMap.put(pickListEntry.getValue(), pickListEntry.getLabel());
        }

        Map<String, String> chargeTypeValueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult chargeTypeDescribe = FC_Metroclient_Product_Geography_Seg3__c.Charge_Type__c.getDescribe();
        Schema.PickListEntry[] chargeTypePickListEntries = chargeTypeDescribe.getPicklistValues();
        for (Schema.PickListEntry pickListEntry : chargeTypePickListEntries) {
            chargeTypeValueToLabelMap.put(pickListEntry.getValue(), pickListEntry.getLabel());
        }

        Map<String, String> triggerEventMap = new Map<String, String>{
                'UCE' => 'ContractEffective',
                'USA' => 'ServiceActivationDate',
                'UCA' => 'CustomerAcceptance',
                'USD' => 'SpecificDate'
        };

        // Build map of product rate plan IDs to product rate plan charges
        Set<Id> productRatePlanIdsToLookup = new Set<Id>();
        for (FC_Billing_Instruction_Step__c billingInstructionStep : billingInstructionSteps) {
            if (billingInstructionStep.Metrostudy_Product_Geography_Seg3__c != null &&
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c != null) {
                productRatePlanIdsToLookup.add(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c);
            } else if (billingInstructionStep.Product_Rate_Plan__c != null) {
                productRatePlanIdsToLookup.add(billingInstructionStep.Product_Rate_Plan__c);
            }
        }
        Map<String, zqu__ProductRatePlanCharge__c> productRatePlanZuoraIdToProductRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
        for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : [
                select Id, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.zqu__ZuoraId__c, zqu__ZuoraId__c
                from zqu__ProductRatePlanCharge__c
                where zqu__ProductRatePlan__c in :productRatePlanIdsToLookup
        ]) {
            if (!productRatePlanZuoraIdToProductRatePlanChargeMap.containsKey(productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__ZuoraId__c)) {
                productRatePlanZuoraIdToProductRatePlanChargeMap.put(productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__ZuoraId__c, productRatePlanChargeRecord);
            }
        }

        for (FC_Billing_Instruction_Step__c billingInstructionStep : billingInstructionSteps) {

            FC_ZuoraClient.RatePlanData ratePlanData = new FC_ZuoraClient.RatePlanData();
            ratePlanData.RatePlan = new FC_ZuoraClient.RatePlan();

            if (billingInstructionStep.Metrostudy_Product_Geography_Seg3__c != null &&
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c != null &&
                    String.isNotBlank(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c)) {
                ratePlanData.RatePlan.ProductRatePlanId =
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c;
            } else if (billingInstructionStep.Product_Rate_Plan__c != null &&
                    String.isNotBlank(billingInstructionStep.Product_Rate_Plan__r.zqu__ZuoraId__c)) {
                ratePlanData.RatePlan.ProductRatePlanId = billingInstructionStep.Product_Rate_Plan__r.zqu__ZuoraId__c;
            } else {
                System.debug(LoggingLevel.WARN, 'PRODUCT RATE PLAN ID CANNOT BE DETERMINED: ' + billingInstructionStep);
                continue;
            }

            ratePlanData.RatePlanChargeData = new List<FC_ZuoraClient.RatePlanChargeData>();

            FC_ZuoraClient.RatePlanChargeData ratePlanChargeData = new FC_ZuoraClient.RatePlanChargeData();
            ratePlanChargeData.RatePlanCharge = new FC_ZuoraClient.RatePlanCharge();
            ratePlanChargeData.RatePlanCharge.BillCase_c = billingInstructionStep.Billing_Instruction_Description__c;
            ratePlanChargeData.RatePlanCharge.BillCycleDay =
                    String.isNotBlank(billingInstructionStep.Bill_Cycle_Day__c) ?
                            Integer.valueOf(billingInstructionStep.Bill_Cycle_Day__c) : null;
            ratePlanChargeData.RatePlanCharge.BillCycleType =
                    String.isNotBlank(billingInstructionStep.Bill_Cycle_Type__c) ?
                            billingInstructionStep.Bill_Cycle_Type__c : null;
            ratePlanChargeData.RatePlanCharge.BillingInstructionSetId_c =
                    billingInstructionStep.Billing_Instruction_Set__c;
            ratePlanChargeData.RatePlanCharge.BillingPeriod =
                    String.isNotBlank(billingInstructionStep.Billing_Period__c) ?
                            billingPeriodValueToLabelMap.get(billingInstructionStep.Billing_Period__c) : null;
            ratePlanChargeData.RatePlanCharge.BillingPeriodAlignment =
                    String.isNotBlank(billingInstructionStep.Billing_Period_Alignment__c) ?
                            billingInstructionStep.Billing_Period_Alignment__c : null;
            ratePlanChargeData.RatePlanCharge.Description = billingInstructionStep.Description__c;
            ratePlanChargeData.RatePlanCharge.EndDateCondition =
                    String.isNotBlank(billingInstructionStep.End_Date_Condition__c) ?
                            billingInstructionStep.End_Date_Condition__c.replace('_', '') : null;
            ratePlanChargeData.RatePlanCharge.GeographyName_c =
                    String.format('{0} | {1} | {2} | {3}', new String[]{
                            billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                            billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c,
                            billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Charge_Type__c == 'Recurring' ?
                                    billingPeriodValueToLabelMap.get(billingInstructionStep.Billing_Period__c) :
                                    chargeTypeValueToLabelMap.get(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Charge_Type__c),
                            billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c
                    });
            ratePlanChargeData.RatePlanCharge.geoName_c = String.format('{0} | {1}', new String[]{
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c
            });
            ratePlanChargeData.RatePlanCharge.ListPrice_c = billingInstructionStep.List_Price__c != null ? String.valueOf(billingInstructionStep.List_Price__c.setScale(2)) : null;
            ratePlanChargeData.RatePlanCharge.ProductName_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name;
            ratePlanChargeData.RatePlanCharge.ProductRatePlanChargeId =
                    productRatePlanZuoraIdToProductRatePlanChargeMap.get(ratePlanData.RatePlan.ProductRatePlanId).zqu__ZuoraId__c;
            ratePlanChargeData.RatePlanCharge.Price = billingInstructionStep.Price__c;
            ratePlanChargeData.RatePlanCharge.Quantity = billingInstructionStep.Quantity__c;
            ratePlanChargeData.RatePlanCharge.Record_Id_c =
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__c;
            ratePlanChargeData.RatePlanCharge.Segment2_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c;
            ratePlanChargeData.RatePlanCharge.Segment3_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c;
            ratePlanChargeData.RatePlanCharge.Seg3RecordID_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__c;
            ratePlanChargeData.RatePlanCharge.SpecificBillingPeriod = billingInstructionStep.Specific_Billing_Period__c != null ?
                    Integer.valueOf(billingInstructionStep.Specific_Billing_Period__c) : null;
            ratePlanChargeData.RatePlanCharge.SpecificEndDate = billingInstructionStep.Specific_End_Date__c;
            ratePlanChargeData.RatePlanCharge.TriggerDate = billingInstructionStep.Trigger_Date__c;
            ratePlanChargeData.RatePlanCharge.TriggerEvent =
                    String.isNotBlank(billingInstructionStep.Trigger_Event__c) ?
                            triggerEventMap.get(billingInstructionStep.Trigger_Event__c) : null;
            ratePlanChargeData.RatePlanCharge.UpToPeriods = billingInstructionStep.Up_To_Periods__c != null ?
                    Integer.valueOf(billingInstructionStep.Up_To_Periods__c) : null;
            ratePlanChargeData.RatePlanCharge.UpToPeriodsType =
                    String.isNotBlank(billingInstructionStep.Up_To_Periods_Type__c) ?
                            billingInstructionStep.Up_To_Periods_Type__c.replace('_', ' ') : null;
            ratePlanChargeData.RatePlanCharge.WeeklyBillCycleDay =
                    String.isNotBlank(billingInstructionStep.Weekly_Bill_Cycle_Day__c) ?
                            billingInstructionStep.Weekly_Bill_Cycle_Day__c : null;

            ratePlanData.RatePlanChargeData.add(ratePlanChargeData);
            subscribe.SubscriptionData.RatePlanData.add(ratePlanData);
        }

        request.subscribes.add(subscribe);

        return request;
    }

    public static FC_ZuoraClient.UpdateSubscriptionRequest buildUpdateSubscriptionRequest(String termType,
            Integer currentTerm, String currentTermPeriodType, String renewalSetting, Integer renewalTerm,
            String renewalTermPeriodType, Date termStartDate, Boolean autoRenew) {

        // Build update subscription request
        FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = new FC_ZuoraClient.UpdateSubscriptionRequest();
        updateSubscriptionRequest.termType = termType;
        updateSubscriptionRequest.currentTerm = currentTerm;
        updateSubscriptionRequest.currentTermPeriodType = currentTermPeriodType;
        updateSubscriptionRequest.renewalSetting = renewalSetting;
        updateSubscriptionRequest.renewalTerm = renewalTerm;
        updateSubscriptionRequest.renewalTermPeriodType = renewalTermPeriodType;
        updateSubscriptionRequest.termStartDate = termStartDate;
        updateSubscriptionRequest.autoRenew = autoRenew;

        return updateSubscriptionRequest;
    }

    public static FC_ZuoraClient.UpdateSubscriptionRequest buildUpdateSubscriptionRequest(
            Date termStartDate, Opportunity opportunityRecord, Boolean preview) {

        // Build update subscription request
        FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = new FC_ZuoraClient.UpdateSubscriptionRequest();
        updateSubscriptionRequest.OpportunityCloseDate_q = opportunityRecord.CloseDate;
        updateSubscriptionRequest.OpportunityID_c = opportunityRecord.Id;
        updateSubscriptionRequest.OpportunityName_q = opportunityRecord.Name.left(100);
        updateSubscriptionRequest.preview = preview;
        updateSubscriptionRequest.termStartDate = termStartDate;

        return updateSubscriptionRequest;
    }

    public static FC_ZuoraClient.UpdateSubscriptionRequest buildUpdateSubscriptionRequest(
            FC_Billing_Instruction_Step__c[] billingInstructionSteps, Opportunity opportunityRecord, Boolean preview) {

        FC_ZuoraClient zuoraClient = new FC_ZuoraClient(opportunityRecord.Id);

        // Map charge numbers to rate plan and rate plan charge Zuora IDs
        Map<String, String> chargeNumberToRatePlanZuoraIdMap = new Map<String, String>();
        Map<String, String> chargeNumberToRatePlanChargeZuoraIdMap = new Map<String, String>();
        FC_ZuoraClient.GetSubscriptionResponse subscription =
                zuoraClient.getSubscriptionByKey(opportunityRecord.Contract.FC_Subscription_Number__c);
        if (subscription != null && subscription.ratePlans != null && !subscription.ratePlans.isEmpty()) {
            for (FC_ZuoraClient.GetSubscriptionResponseRatePlan ratePlan : subscription.ratePlans) {
                if (ratePlan.ratePlanCharges != null && !ratePlan.ratePlanCharges.isEmpty()) {
                    for (FC_ZuoraClient.GetSubscriptionResponseRatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                        if (ratePlanCharge.number_x != null) {
                            chargeNumberToRatePlanZuoraIdMap.put(ratePlanCharge.number_x, ratePlan.id);
                            chargeNumberToRatePlanChargeZuoraIdMap.put(ratePlanCharge.number_x, ratePlanCharge.id);
                        }
                    }
                }
            }
        }

        // Build map of product rate plan IDs to product rate plan charges
        Set<Id> productRatePlanIdsToLookup = new Set<Id>();
        for (FC_Billing_Instruction_Step__c billingInstructionStep : billingInstructionSteps) {
            if (billingInstructionStep.Metrostudy_Product_Geography_Seg3__c != null &&
                    billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c != null) {
                productRatePlanIdsToLookup.add(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c);
            } else if (billingInstructionStep.Product_Rate_Plan__c != null) {
                productRatePlanIdsToLookup.add(billingInstructionStep.Product_Rate_Plan__c);
            }
        }
        Map<String, zqu__ProductRatePlanCharge__c> productRatePlanZuoraIdToProductRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
        for (zqu__ProductRatePlanCharge__c productRatePlanChargeRecord : [
                select Id, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.zqu__ZuoraId__c, zqu__ZuoraId__c
                from zqu__ProductRatePlanCharge__c
                where zqu__ProductRatePlan__c in :productRatePlanIdsToLookup
        ]) {
            if (!productRatePlanZuoraIdToProductRatePlanChargeMap.containsKey(productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__ZuoraId__c)) {
                productRatePlanZuoraIdToProductRatePlanChargeMap.put(productRatePlanChargeRecord.zqu__ProductRatePlan__r.zqu__ZuoraId__c, productRatePlanChargeRecord);
            }
        }

        // Build update subscription request
        FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = new FC_ZuoraClient.UpdateSubscriptionRequest();
        updateSubscriptionRequest.BillCase_c = opportunityRecord.FC_Bill_Case__c;
        updateSubscriptionRequest.notes = String.isNotBlank(opportunityRecord.FC_Subscription_Notes__c) ? opportunityRecord.FC_Subscription_Notes__c.left(500) : '';
        updateSubscriptionRequest.OpportunityCloseDate_q = opportunityRecord.CloseDate;
        updateSubscriptionRequest.OpportunityID_c = opportunityRecord.Id;
        updateSubscriptionRequest.OpportunityName_q = opportunityRecord.Name.left(100);
        updateSubscriptionRequest.preview = preview;

        FC_ZuoraClient.AddRatePlan[] ratePlansToAdd = new List<FC_ZuoraClient.AddRatePlan>();
        FC_ZuoraClient.UpdateRatePlan[] ratePlansToUpdate = new List<FC_ZuoraClient.UpdateRatePlan>();
        FC_ZuoraClient.RemoveRatePlan[] ratePlansToRemove = new List<FC_ZuoraClient.RemoveRatePlan>();

        Map<String, String> billingPeriodValueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult billingPeriodDescribe = FC_Billing_Instruction_Step__c.Billing_Period__c.getDescribe();
        Schema.PickListEntry[] billingPeriodPickListEntries = billingPeriodDescribe.getPicklistValues();
        for (Schema.PickListEntry pickListEntry : billingPeriodPickListEntries) {
            billingPeriodValueToLabelMap.put(pickListEntry.getValue(), pickListEntry.getLabel());
        }

        Map<String, String> chargeTypeValueToLabelMap = new Map<String, String>();
        Schema.DescribeFieldResult chargeTypeDescribe = FC_Metroclient_Product_Geography_Seg3__c.Charge_Type__c.getDescribe();
        Schema.PickListEntry[] chargeTypePickListEntries = chargeTypeDescribe.getPicklistValues();
        for (Schema.PickListEntry pickListEntry : chargeTypePickListEntries) {
            chargeTypeValueToLabelMap.put(pickListEntry.getValue(), pickListEntry.getLabel());
        }

        Map<Id, OpportunityLineItem> billingInstructionSetIdToOpportunityLineItemMap = new Map<Id, OpportunityLineItem>();
        Set<Id> billingSetIdsToLookup = new Set<Id>();
        for (FC_Billing_Instruction_Step__c billingInstructionStep : billingInstructionSteps) {
            billingSetIdsToLookup.add(billingInstructionStep.Billing_Instruction_Set__c);
        }
        for (OpportunityLineItem opportunityLineItemRecord : [
                select Id, FC_Billing_Instruction_Set__c, Billing_Frequency__c
                from OpportunityLineItem
                where FC_Billing_Instruction_Set__c in :billingSetIdsToLookup
        ]) {
            billingInstructionSetIdToOpportunityLineItemMap.put(opportunityLineItemRecord.FC_Billing_Instruction_Set__c, opportunityLineItemRecord);
        }

        Map<String, String> billingFrequencyToBillingPeriodMap = new Map<String, String>{
                'Monthly' => 'Month',
                'Quarterly' => 'Quarter',
                'Semi-Annually' => 'Semi_Annual',
                'Annually' => 'Annual'
        };


        for (FC_Billing_Instruction_Step__c billingInstructionStep : billingInstructionSteps) {
            if (billingInstructionStep.RecordType.DeveloperName == 'Amend_Add') {

                FC_ZuoraClient.AddRatePlan ratePlanToAdd = new FC_ZuoraClient.AddRatePlan();
                if (billingInstructionStep.Metrostudy_Product_Geography_Seg3__c != null &&
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c != null &&
                        String.isNotBlank(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c)) {
                    ratePlanToAdd.productRatePlanId =
                            billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c;
                } else if (billingInstructionStep.Product_Rate_Plan__c != null &&
                        String.isNotBlank(billingInstructionStep.Product_Rate_Plan__r.zqu__ZuoraId__c)) {
                    ratePlanToAdd.productRatePlanId = billingInstructionStep.Product_Rate_Plan__r.zqu__ZuoraId__c;
                } else {
                    System.debug(LoggingLevel.WARN, 'PRODUCT RATE PLAN ID CANNOT BE DETERMINED: ' + billingInstructionStep);
                    continue;
                }
                ratePlanToAdd.contractEffectiveDate = billingInstructionStep.Contract_Effective_Date__c;

                ratePlanToAdd.chargeOverrides = new List<FC_ZuoraClient.AddRatePlanChargeOverride>();
                FC_ZuoraClient.AddRatePlanChargeOverride chargeOverride = new FC_ZuoraClient.AddRatePlanChargeOverride();
                chargeOverride.BillCase_c = billingInstructionStep.Billing_Instruction_Description__c;
                chargeOverride.billCycleDay = String.isNotBlank(billingInstructionStep.Bill_Cycle_Day__c) ?
                        billingInstructionStep.Bill_Cycle_Day__c : null;
                chargeOverride.billCycleType = String.isNotBlank(billingInstructionStep.Bill_Cycle_Type__c) ?
                        billingInstructionStep.Bill_Cycle_Type__c : null;
                chargeOverride.BillingInstructionSetId_c = billingInstructionStep.Billing_Instruction_Set__c;
                chargeOverride.billingPeriod = String.isNotBlank(billingInstructionStep.Billing_Period__c) ?
                        billingInstructionStep.Billing_Period__c : null;
                chargeOverride.billingPeriodAlignment = String.isNotBlank(billingInstructionStep.Billing_Period_Alignment__c) ?
                        billingInstructionStep.Billing_Period_Alignment__c : null;
                chargeOverride.description = billingInstructionStep.Description__c;
                chargeOverride.endDateCondition = String.isNotBlank(billingInstructionStep.End_Date_Condition__c) ?
                        billingInstructionStep.End_Date_Condition__c : null;
                chargeOverride.GeographyName_c = String.format('{0} | {1} | {2} | {3}', new String[]{
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Charge_Type__c == 'Recurring' ?
                                billingPeriodValueToLabelMap.get(billingInstructionStep.Billing_Period__c) :
                                chargeTypeValueToLabelMap.get(billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Charge_Type__c),
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c
                });
                chargeOverride.geoName_c = String.format('{0} | {1}', new String[]{
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c
                });
                chargeOverride.ListPrice_c = billingInstructionStep.List_Price__c != null ? String.valueOf(billingInstructionStep.List_Price__c.setScale(2)) : null;
                chargeOverride.price = billingInstructionStep.Price__c;
                chargeOverride.ProductName_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name;
                chargeOverride.productRatePlanChargeId =
                        productRatePlanZuoraIdToProductRatePlanChargeMap.get(ratePlanToAdd.productRatePlanId).zqu__ZuoraId__c;
                chargeOverride.quantity = billingInstructionStep.Quantity__c;
                chargeOverride.Record_Id_c =
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__c;
                chargeOverride.Segment2_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c;
                chargeOverride.Segment3_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c;
                chargeOverride.Seg3RecordID_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__c;
                chargeOverride.specificBillingPeriod = billingInstructionStep.Specific_Billing_Period__c != null ?
                        Integer.valueOf(billingInstructionStep.Specific_Billing_Period__c) : null;
                chargeOverride.specificEndDate = billingInstructionStep.Specific_End_Date__c;
                chargeOverride.triggerDate = billingInstructionStep.Trigger_Date__c;
                chargeOverride.triggerEvent = String.isNotBlank(billingInstructionStep.Trigger_Event__c) ?
                        billingInstructionStep.Trigger_Event__c : null;
                chargeOverride.upToPeriods = billingInstructionStep.Up_To_Periods__c != null ?
                        Integer.valueOf(billingInstructionStep.Up_To_Periods__c) : null;
                chargeOverride.upToPeriodsType = String.isNotBlank(billingInstructionStep.Up_To_Periods_Type__c) ?
                        billingInstructionStep.Up_To_Periods_Type__c : null;
                ratePlanToAdd.chargeOverrides.add(chargeOverride);

                ratePlansToAdd.add(ratePlanToAdd);

            } else if (billingInstructionStep.RecordType.DeveloperName == 'Amend_Modify') {

                OpportunityLineItem opportunityLineItemRecord = billingInstructionSetIdToOpportunityLineItemMap.get(billingInstructionStep.Billing_Instruction_Set__c);
                String billingPeriod = '';
                if (opportunityLineItemRecord != null) {
                    billingPeriod = 'One-Time';
                    if (billingFrequencyToBillingPeriodMap.containsKey(opportunityLineItemRecord.Billing_Frequency__c)) {
                        billingPeriod = billingFrequencyToBillingPeriodMap.get(opportunityLineItemRecord.Billing_Frequency__c);
                    }
                }

                FC_ZuoraClient.UpdateRatePlan ratePlanToUpdate = new FC_ZuoraClient.UpdateRatePlan();
                ratePlanToUpdate.contractEffectiveDate = billingInstructionStep.Contract_Effective_Date__c;
                ratePlanToUpdate.ratePlanId =
                        chargeNumberToRatePlanZuoraIdMap.get(billingInstructionStep.Billing_Instruction_Set__r.Charge_Number__c);
                ratePlanToUpdate.chargeUpdateDetails = new List<FC_ZuoraClient.UpdateRatePlanChargeUpdateDetail>();

                FC_ZuoraClient.UpdateRatePlanChargeUpdateDetail chargeUpdateDetails = new FC_ZuoraClient.UpdateRatePlanChargeUpdateDetail();
                chargeUpdateDetails.BillCase_c = billingInstructionStep.Billing_Instruction_Description__c;
                chargeUpdateDetails.BillingInstructionSetId_c = billingInstructionStep.Billing_Instruction_Set__c;
                chargeUpdateDetails.billingPeriodAlignment = String.isNotBlank(billingInstructionStep.Billing_Period_Alignment__c) ?
                        billingInstructionStep.Billing_Period_Alignment__c : null;
                chargeUpdateDetails.description = String.isNotBlank(billingInstructionStep.Description__c) ?
                        billingInstructionStep.Description__c : null;
                chargeUpdateDetails.GeographyName_c = String.format('{0} | {1} | {2} | {3}', new String[]{
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c,
                        billingPeriod,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c
                });
                chargeUpdateDetails.geoName_c = String.format('{0} | {1}', new String[]{
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Geography__c
                });
                chargeUpdateDetails.ListPrice_c = billingInstructionStep.List_Price__c != null ? String.valueOf(billingInstructionStep.List_Price__c.setScale(2)) : null;
                chargeUpdateDetails.price = billingInstructionStep.Price__c;
                chargeUpdateDetails.ProductName_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name;
                chargeUpdateDetails.quantity = billingInstructionStep.Quantity__c;
                chargeUpdateDetails.ratePlanChargeId =
                        chargeNumberToRatePlanChargeZuoraIdMap.get(billingInstructionStep.Billing_Instruction_Set__r.Charge_Number__c);
                chargeUpdateDetails.Record_Id_c =
                        billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__c;
                chargeUpdateDetails.Segment2_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c;
                chargeUpdateDetails.Segment3_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__r.Seg3__c;
                chargeUpdateDetails.Seg3RecordID_c = billingInstructionStep.Metrostudy_Product_Geography_Seg3__c;
                chargeUpdateDetails.triggerDate = billingInstructionStep.Trigger_Date__c;
                chargeUpdateDetails.triggerEvent = String.isNotBlank(billingInstructionStep.Trigger_Event__c) ?
                        billingInstructionStep.Trigger_Event__c : null;
                ratePlanToUpdate.chargeUpdateDetails.add(chargeUpdateDetails);

                ratePlansToUpdate.add(ratePlanToUpdate);

            } else if (billingInstructionStep.RecordType.DeveloperName == 'Amend_Remove') {

                FC_ZuoraClient.RemoveRatePlan ratePlanToRemove = new FC_ZuoraClient.RemoveRatePlan();
                ratePlanToRemove.contractEffectiveDate = billingInstructionStep.Contract_Effective_Date__c;
                ratePlanToRemove.ratePlanId =
                        chargeNumberToRatePlanZuoraIdMap.get(billingInstructionStep.Billing_Instruction_Set__r.Charge_Number__c);
                ratePlansToRemove.add(ratePlanToRemove);

            }

        }

        if (!ratePlansToAdd.isEmpty()) {
            updateSubscriptionRequest.add = ratePlansToAdd;
        }
        if (!ratePlansToUpdate.isEmpty()) {
            updateSubscriptionRequest.update_x = ratePlansToUpdate;
        }
        if (!ratePlansToRemove.isEmpty()) {
            updateSubscriptionRequest.remove = ratePlansToRemove;
        }

        return updateSubscriptionRequest;
    }

}