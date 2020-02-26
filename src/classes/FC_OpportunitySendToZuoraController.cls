public with sharing class FC_OpportunitySendToZuoraController {

    private final Opportunity OPPORTUNITY_RECORD;
    private final FC_ZuoraClient ZUORA_CLIENT;

    private FC_Billing_Instruction_Step__c[] subscribeBillingInstructionSteps = new List<FC_Billing_Instruction_Step__c>();
    private FC_Billing_Instruction_Step__c[] amendBillingInstructionSteps = new List<FC_Billing_Instruction_Step__c>();

    public Integer amendmentBatchSize = 3;

    public Boolean hasAmendBillingInstructionSteps {

        get {
            return amendBillingInstructionSteps != null && !amendBillingInstructionSteps.isEmpty();
        }

        private set;

    }

    public Boolean shouldRenew {

        get {
            return this.OPPORTUNITY_RECORD.FC_Renew__c && this.OPPORTUNITY_RECORD.FC_Renewal_Processed_On__c == null;
        }

        private set;

    }


    public FC_OpportunitySendToZuoraController(ApexPages.StandardController standardController) {
        this.OPPORTUNITY_RECORD = (Opportunity) standardController.getRecord();
        this.ZUORA_CLIENT = new FC_ZuoraClient(this.OPPORTUNITY_RECORD.Id);
    }

    public PageReference sendToZuora() {

        OpportunityTeamMember[] opportunityTeamMembersToInsert = new List<OpportunityTeamMember>();

        // Group billing instructions based on record type
        for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : [
                select Id, RecordType.DeveloperName, Bill_Cycle_Day__c, Bill_Cycle_Type__c,
                        Billing_Instruction_Description__c, Billing_Instruction_Set__c,
                        Billing_Period__c, Billing_Period_Alignment__c,
                        Contract_Effective_Date__c, Description__c,
                        End_Date_Condition__c, Execute_Immediately__c, List_Price__c,
                        Metrostudy_Product_Geography_Seg3__c,
                        Metrostudy_Product_Geography_Seg3__r.Charge_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Geography_Type__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__c,
                        Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name,
                        Metrostudy_Product_Geography_Seg3__r.Seg3__c, Price__c,
                        Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZuoraId__c, Quantity__c, RecordTypeId, Specific_Billing_Period__c,
                        Specific_End_Date__c, Status__c, Trigger_Date__c, Trigger_Event__c, Up_To_Periods__c,
                        Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c
                from FC_Billing_Instruction_Step__c
                where Billing_Instruction_Set__r.Opportunity__c = :OPPORTUNITY_RECORD.Id
                and Status__c != 'Executed'
                and Execute_Immediately__c = true
        ]) {
            if (billingInstructionStepRecord.RecordType.DeveloperName == 'Subscribe') {
                subscribeBillingInstructionSteps.add(billingInstructionStepRecord);
            } else {
                amendBillingInstructionSteps.add(billingInstructionStepRecord);
            }
        }

        // Validate
        if (!isValid()) {
            return null;
        }

        Boolean runProvisioning = false;
        Boolean subscribeInvoked = false;
        Boolean subscribeSuccess = true;
        FC_ZuoraClient.SubscribeResult subscribeResult = null;
        try {

            // Prepare subscribe request
            if (!subscribeBillingInstructionSteps.isEmpty()) {
                FC_ZuoraClient.SubscribeActionResponse[] subscribeActionResponses =
                        ZUORA_CLIENT.subscribe(FC_ZuoraUtil.buildSubscribeActionRequest(subscribeBillingInstructionSteps, this.OPPORTUNITY_RECORD));
                for (FC_ZuoraClient.SubscribeActionResponse subscribeActionResponse : subscribeActionResponses) {
                    if (subscribeActionResponse instanceof FC_ZuoraClient.SubscribeResult) {
                        subscribeResult = (FC_ZuoraClient.SubscribeResult) subscribeActionResponse;
                        if (subscribeResult.Success) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                                    String.format('Subscription {0} created successfully.',
                                            new String[]{
                                                    subscribeResult.SubscriptionNumber
                                            })));
                            subscribeSuccess = true;
                            subscribeInvoked = true;
                            runProvisioning = amendBillingInstructionSteps.isEmpty();
                        } else {
                            for (FC_ZuoraClient.ZuoraError error : subscribeResult.Errors) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                        String.format('{0} - {1}', new String[]{
                                                String.valueOf(error.Code), error.Message
                                        })));
                                subscribeSuccess = false;
                            }
                        }
                    } else if (subscribeActionResponse instanceof FC_ZuoraClient.SubscribeError) {
                        FC_ZuoraClient.SubscribeError subscribeError = (FC_ZuoraClient.SubscribeError) subscribeActionResponse;
                        for (FC_ZuoraClient.ZuoraError error : subscribeError.Errors) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                    String.format('{0} - {1}', new String[]{
                                            String.valueOf(error.Code), error.Message
                                    })));
                            subscribeSuccess = false;
                        }
                    }
                }
            }

            if (subscribeSuccess) {

                // Create Terms and Conditions amendment if necessary
                Boolean termsAndConditionsSuccess = true;
                if (this.OPPORTUNITY_RECORD.FC_T_C_Term_Start_Date__c != null &&
                        this.OPPORTUNITY_RECORD.FC_T_C_Term_Start_Date__c != this.OPPORTUNITY_RECORD.FC_Contract_Effective_Date__c) {
                    FC_ZuoraClient.UpdateSubscriptionResponse updateTermsAndConditionsResponse =
                            this.ZUORA_CLIENT.updateSubscription(FC_ZuoraUtil.buildUpdateSubscriptionRequest(this.OPPORTUNITY_RECORD.FC_T_C_Term_Start_Date__c, this.OPPORTUNITY_RECORD, false),
                                    subscribeResult.SubscriptionNumber);
                    if (updateTermsAndConditionsResponse.success) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                                String.format('The Term Start Date was updated to {0} for subscription {1}.',
                                        new String[]{
                                                this.OPPORTUNITY_RECORD.FC_T_C_Term_Start_Date__c.format(),
                                                subscribeResult.SubscriptionNumber
                                        })));
                        termsAndConditionsSuccess = true;
                        runProvisioning = amendBillingInstructionSteps.isEmpty();
                    } else {
                        termsAndConditionsSuccess = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                String.format('The Term Start Date could not be updated for subscription {0}.',
                                        new String[]{
                                                subscribeResult.SubscriptionNumber
                                        })));
                        for (FC_ZuoraClient.ZuoraError error : updateTermsAndConditionsResponse.reasons) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                    String.format('{0} - {1}', new String[]{
                                            String.valueOf(error.Code), error.Message
                                    })));
                            subscribeSuccess = false;
                        }
                    }
                }

                // Create Renewal amendment if necessary
                Boolean renewalSuccess = true;

                String termType = this.OPPORTUNITY_RECORD.ContractId != null ?
                        this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Zuora__TermSettingType__c :
                        this.OPPORTUNITY_RECORD.FC_Term_Type__c;
                if (termsAndConditionsSuccess && this.OPPORTUNITY_RECORD.FC_Renew__c && termType == 'TERMED') {
                    String subscriptionKey = subscribeResult != null ? subscribeResult.SubscriptionNumber : this.OPPORTUNITY_RECORD.Contract.FC_Subscription_Number__c;

                    FC_ZuoraClient.RenewSubscriptionResponse renewSubscriptionResponse =
                            this.ZUORA_CLIENT.renewSubscription(FC_ZuoraUtil.buildRenewSubscriptionRequest(this.OPPORTUNITY_RECORD), subscriptionKey);
                    if (renewSubscriptionResponse.success) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                                String.format('Subscription {0} has been renewed successfully.',
                                        new String[]{
                                                subscriptionKey
                                        })));
                        renewalSuccess = true;
                        runProvisioning = amendBillingInstructionSteps.isEmpty();
                        this.OPPORTUNITY_RECORD.FC_Renewal_Processed_On__c = DateTime.now();
                    } else {
                        renewalSuccess = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                String.format('Subscription {0} could not be renewed.',
                                        new String[]{
                                                subscriptionKey
                                        })));
                        for (FC_ZuoraClient.ZuoraError error : renewSubscriptionResponse.reasons) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                    String.format('{0} - {1}', new String[]{
                                            String.valueOf(error.Code), error.Message
                                    })));
                        }
                        subscribeSuccess = false;
                    }
                }

//                /* Check if we need to run provisioning now.  Otherwise, the next time it runs will be with the
//                 * amendment processor.
//                 */
//                if (runProvisioning) {
//
//                    // Provision subscription IDs
//                    FC_MetroclientAccountProvisioningUtil.buildProvisioningRecords(new Id[]{
//                            this.OPPORTUNITY_RECORD.AccountId
//                    }, this.OPPORTUNITY_RECORD.Id);
//
//                }

                // Update Billing Instruction Sets based on newly created subscription rate plan charges
                Map<Id, FC_Billing_Instruction_Set__c> billingInstructionSetToUpdateMap = new Map<Id, FC_Billing_Instruction_Set__c>();
                if (!subscribeBillingInstructionSteps.isEmpty()) {
                    FC_ZuoraClient.GetSubscriptionResponse subscription = this.ZUORA_CLIENT.getSubscriptionByKey(subscribeResult.SubscriptionNumber);
                    if (subscription != null && subscription.ratePlans != null && !subscription.ratePlans.isEmpty()) {
                        for (FC_ZuoraClient.GetSubscriptionResponseRatePlan ratePlan : subscription.ratePlans) {
                            if (ratePlan.ratePlanCharges != null && !ratePlan.ratePlanCharges.isEmpty()) {
                                for (FC_ZuoraClient.GetSubscriptionResponseRatePlanCharge ratePlanCharge : ratePlan.ratePlanCharges) {
                                    if (ratePlanCharge.BillingInstructionSetId_c != null) {
                                        billingInstructionSetToUpdateMap.put(ratePlanCharge.BillingInstructionSetId_c,
                                                new FC_Billing_Instruction_Set__c(Id = ratePlanCharge.BillingInstructionSetId_c,
                                                        Charge_Number__c = ratePlanCharge.number_x));
                                    }
                                }
                            }
                        }
                    }
                }
                if (!billingInstructionSetToUpdateMap.isEmpty()) {
                    update billingInstructionSetToUpdateMap.values();
                }

                FC_Billing_Instruction_Step__c[] subscribeBillingInstructionStepToUpdate = new List<FC_Billing_Instruction_Step__c>();
                for (FC_Billing_Instruction_Step__c subscribeBillingInstructionStep : subscribeBillingInstructionSteps) {
                    subscribeBillingInstructionStepToUpdate.add(new FC_Billing_Instruction_Step__c(
                            Id = subscribeBillingInstructionStep.Id, Status__c = 'Executed'));
                }
                if (!subscribeBillingInstructionStepToUpdate.isEmpty()) {
                    update subscribeBillingInstructionStepToUpdate;

                    Contract contractToCreate = new Contract(AccountId = this.OPPORTUNITY_RECORD.AccountId,
                            FC_Subscription_Number__c = subscribeResult.SubscriptionNumber,
                            FC_Price_Book__c = this.OPPORTUNITY_RECORD.Pricebook2Id);
                    insert contractToCreate;

                    this.OPPORTUNITY_RECORD.FC_Send_Provisioning_Notification__c = subscribeInvoked &&
                            subscribeSuccess &&
                            new Set<String>{
                                    'Database Access', 'Internet Sales', 'Membership'
                            }.contains(this.OPPORTUNITY_RECORD.One_time_Sale_Type__c) &&
                            this.OPPORTUNITY_RECORD.Purchase_Type__c != 'Price Increase Only';
                    this.OPPORTUNITY_RECORD.ContractId = contractToCreate.Id;
                    this.OPPORTUNITY_RECORD.Contract = contractToCreate;
                    this.OPPORTUNITY_RECORD.FC_Last_Sent_To_Zuora__c = DateTime.now();
                    this.OPPORTUNITY_RECORD.Skip_Validation__c = true;
                    update this.OPPORTUNITY_RECORD;
                }

                if (termsAndConditionsSuccess && renewalSuccess) {
                    // Invoke asynchronous amendment processor
                    FC_Billing_Instruction_Step__c[] amendBillingInstructionStepsToUpdate = new List<FC_Billing_Instruction_Step__c>();
                    for (FC_Billing_Instruction_Step__c amendBillingInstructionStep : amendBillingInstructionSteps) {
                        amendBillingInstructionStepsToUpdate.add(new FC_Billing_Instruction_Step__c(Id = amendBillingInstructionStep.Id, Status__c = 'Pending'));
                    }
                    if (!amendBillingInstructionStepsToUpdate.isEmpty()) {
                        update amendBillingInstructionStepsToUpdate;

                        Id asyncJobId = Database.executeBatch(new FC_ZuoraAmendmentProcessorBatchable(this.OPPORTUNITY_RECORD.Id, subscribeInvoked), this.amendmentBatchSize);
                        this.OPPORTUNITY_RECORD.FC_Async_Amend_Job_Id__c = asyncJobId;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                String.format('Amendments for subscription {0} have been submitted and are being processed. ' +
                                        'You may monitor the amendment status either here or on the opportunity detail page.',
                                        new String[]{
                                                this.OPPORTUNITY_RECORD.Contract.FC_Subscription_Number__c
                                        })));

                    }
                }

            }

            if (subscribeSuccess) {
                this.OPPORTUNITY_RECORD.StageName = 'Closed Won';

                // Add opportunity team members
                if (String.isNotBlank(this.OPPORTUNITY_RECORD.Metrostudy_Lead__c)) {
                    String[] metrostudyLeadNames = this.OPPORTUNITY_RECORD.Metrostudy_Lead__c.split(';');
                    for (User metrostudyLeadUser : [select Id from User where Name in :metrostudyLeadNames]) {
                        opportunityTeamMembersToInsert.add(new OpportunityTeamMember(
                                OpportunityId = this.OPPORTUNITY_RECORD.Id,
                                TeamMemberRole = 'Salesperson', UserId = metrostudyLeadUser.Id,
                                OpportunityAccessLevel = 'Edit'));
                    }
                }

                for (OpportunityLineItem opportunityLineItem : [
                        select Id, FC_RD_Assignment__c, FC_RD_Assignment__r.User__c
                        from OpportunityLineItem
                        where OpportunityId = :this.OPPORTUNITY_RECORD.Id
                        and FC_RD_Assignment__c != null and FC_RD_Assignment__r.User__c != null and FC_Seg3__c != 'BPMS'
                ]) {
                    opportunityTeamMembersToInsert.add(new OpportunityTeamMember(
                            OpportunityId = this.OPPORTUNITY_RECORD.Id,
                            TeamMemberRole = 'Regional Directors',
                            UserId = opportunityLineItem.FC_RD_Assignment__r.User__c,
                            OpportunityAccessLevel = 'Edit'));
                }

                if (!opportunityTeamMembersToInsert.isEmpty()) {
                    Database.SaveResult[] opportunityTeamMembersSaveResult = Database.insert(opportunityTeamMembersToInsert, false);
                    for (Database.SaveResult saveResult : opportunityTeamMembersSaveResult) {
                        System.debug('***** SR: ' + saveResult);
                        if (!saveResult.isSuccess()) {
                            for (Database.Error error : saveResult.getErrors()) {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                                        String.format('Cannot add opportunity team member: {0} - {1}',
                                                new String[]{
                                                        error.getStatusCode().name(), error.getMessage()
                                                })));
                            }
                        }
                    }
                }

                /* Check if we need to run provisioning.
                 */
                if (runProvisioning) {

                    FC_MetroclientAccountProvisionBatchable batchable = new FC_MetroclientAccountProvisionBatchable(new Set<Id>{
                            this.OPPORTUNITY_RECORD.AccountId
                    });
                    batchable.parentTransactionId = this.OPPORTUNITY_RECORD.Id;
                    Database.executeBatch(batchable);

                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Exception Type: ' + e.getTypeName()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Exception Message: ' + e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Exception Stack Trace: ' + e.getStackTraceString()));
            subscribeSuccess = false;
        } finally {
            this.OPPORTUNITY_RECORD.Skip_Validation__c = true;
            update this.OPPORTUNITY_RECORD;
//            FC_MetroclientAccountProvisioningUtil.commitProvisioningRecords();
            ZUORA_CLIENT.flushTransactions();
        }
        return null;
    }


    private Boolean isValid() {
        Boolean success = true;

        String[] errorMessages = new List<String>();

        if (this.OPPORTUNITY_RECORD.FC_Contract_Effective_Date__c == null) {
            errorMessages.add('Contract Effective Date is required.');
            success = false;
        }

        if (!subscribeBillingInstructionSteps.isEmpty()) {

            if (this.OPPORTUNITY_RECORD.FC_Billing_Account__r == null) {

                if (this.OPPORTUNITY_RECORD.FC_Bill_To_Contact__c == null) {
                    errorMessages.add('Bill To Contact is required.');
                    success = false;
                } else {

                    String[] contactErrorMessages = validateContact(this.OPPORTUNITY_RECORD.FC_Bill_To_Contact__r, 'Bill To Contact');
                    if (!contactErrorMessages.isEmpty()) {
                        errorMessages.addAll(contactErrorMessages);
                        success = false;
                    }

                }

                if (this.OPPORTUNITY_RECORD.FC_Sold_To_Contact__c != null) {

                    String[] contactErrorMessages = validateContact(this.OPPORTUNITY_RECORD.FC_Bill_To_Contact__r, 'Sold To Contact');
                    if (!contactErrorMessages.isEmpty()) {
                        errorMessages.addAll(contactErrorMessages);
                        success = false;
                    }

                }

                if (String.isBlank(this.OPPORTUNITY_RECORD.FC_Batch__c)) {
                    errorMessages.add('Batch is required.');
                    success = false;
                }

                if (this.OPPORTUNITY_RECORD.FC_Bill_Cycle_Day__c == null) {
                    errorMessages.add('Bill Cycle Day is required.');
                    success = false;
                }

                if (String.isBlank(this.OPPORTUNITY_RECORD.FC_Currency__c)) {
                    errorMessages.add('Currency is required.');
                    success = false;
                }

                if (String.isBlank(this.OPPORTUNITY_RECORD.FC_Payment_Term__c)) {
                    errorMessages.add('Payment Term is required.');
                    success = false;
                }

                if (String.isBlank(this.OPPORTUNITY_RECORD.FC_Term_Type__c)) {
                    errorMessages.add('Term Type is required');
                    success = false;
                }

            }
        }

        if (!this.shouldRenew && subscribeBillingInstructionSteps.isEmpty() && amendBillingInstructionSteps.isEmpty()) {
            errorMessages.add('There are no available Billing Instruction Steps to send to Zuora.');
            success = false;
        }

        if (this.OPPORTUNITY_RECORD.ContractId != null && this.OPPORTUNITY_RECORD.Contract.FC_Subscription__c == null) {
            errorMessages.add('There is no subscription record associated to the selected contract.');
            success = false;
        }

        for (String errorMessage : errorMessages) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }

        return success;
    }

    private String[] validateContact(Contact contactRecord, String contactTypeLabel) {

        String[] errorMessages = new List<String>();

        if (String.isBlank(contactRecord.FirstName)) {
            errorMessages.add(String.format('{0} First Name is required.', new String[]{
                    contactTypeLabel
            }));
        }

//        if (String.isBlank(contactRecord.LastName)) {
//            errorMessages.add(String.format('{0} Last Name is required.', new String[]{
//                    contactTypeLabel
//            }));
//        }

        if (String.isBlank(contactRecord.MailingStreet)) {
            errorMessages.add(String.format('{0} Mailing Street is required.', new String[]{
                    contactTypeLabel
            }));
        }

        if (String.isBlank(contactRecord.MailingCity)) {
            errorMessages.add(String.format('{0} Mailing City is required.', new String[]{
                    contactTypeLabel
            }));
        }

        if (String.isBlank(contactRecord.MailingCountryCode)) {
            errorMessages.add(String.format('{0} Mailing Country is required.', new String[]{
                    contactTypeLabel
            }));
        } else if ((contactRecord.MailingCountryCode == 'US' || contactRecord.MailingCountryCode == 'CA') &&
                String.isBlank(contactRecord.MailingStateCode)) {
            errorMessages.add(String.format('{0} Mailing State is required.', new String[]{
                    contactTypeLabel
            }));
        }

        return errorMessages;
    }

}