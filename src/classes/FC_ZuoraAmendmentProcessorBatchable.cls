public class FC_ZuoraAmendmentProcessorBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts,
        Database.Stateful {

    private static final String SOQL = 'select Id, Bill_Cycle_Day__c, Bill_Cycle_Type__c,' +
            'Billing_Instruction_Description__c, Billing_Instruction_Set__c, ' +
            'Billing_Instruction_Set__r.Charge_Number__c, ' +
            'Billing_Period__c, Billing_Period_Alignment__c, Contract_Effective_Date__c, ' +
            'Description__c, End_Date_Condition__c, Execute_Immediately__c, List_Price__c, ' +
            'Metrostudy_Product_Geography_Seg3__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Charge_Type__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Geography__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Geography_Type__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Geography__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Geography__r.Geography__r.Seg2__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZuoraId__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__c, ' +
            'Metrostudy_Product_Geography_Seg3__r.Product_Rate_Plan__r.zqu__ZProduct__r.Name, ' +
            'Metrostudy_Product_Geography_Seg3__r.Seg3__c, Price__c, ' +
            'Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZuoraId__c, Quantity__c, RecordTypeId, ' +
            'RecordType.DeveloperName, Specific_Billing_Period__c, Specific_End_Date__c, Status__c, Trigger_Date__c, ' +
            'Trigger_Event__c, Up_To_Periods__c, Up_To_Periods_Type__c, Weekly_Bill_Cycle_Day__c ' +
            'from FC_Billing_Instruction_Step__c ' +
            'where Billing_Instruction_Set__r.Opportunity__c = \'\'{0}\'\' ' +
            'and Status__c = \'\'Pending\'\' ' +
            'and RecordType.DeveloperName in (\'\'Amend_Add\'\', \'\'Amend_Modify\'\', \'\'Amend_Remove\'\') ' +
            'and Execute_Immediately__c = true';

    private Id opportunityId;

    private Boolean subscribeInvoked = false;

    private Boolean hasAmendAdd = false;

    private Boolean amendAddSuccess = false;

    private Opportunity opportunityRecord;

    private FC_ZuoraClient zuoraClient;

    public FC_ZuoraAmendmentProcessorBatchable(Id opportunityId, Boolean subscribeInvoked) {
        this.opportunityId = opportunityId;
        this.subscribeInvoked = subscribeInvoked;
        for (Opportunity queriedOpportunity : [
                select Id, AccountId, Name, CloseDate, ContractId, Contract.FC_Subscription_Number__c,
                        FC_Bill_Case__c, FC_Subscription_Notes__c, One_time_Sale_Type__c, Purchase_Type__c
                from Opportunity
                where Id = :opportunityId
                limit 1
        ]) {
            this.opportunityRecord = queriedOpportunity;
        }
        this.zuoraClient = new FC_ZuoraClient(this.opportunityId);
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(String.format(SOQL, new String[]{
                opportunityId
        }));
    }

    public void execute(Database.BatchableContext context, List<FC_Billing_Instruction_Step__c> scope) {
        if (scope != null && !scope.isEmpty()) {

            Boolean exceptionCaught = false;
            try {

                // Check if "Amend - Add" is present
                for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : scope) {
                    if (billingInstructionStepRecord.RecordType.DeveloperName == 'Amend_Add') {
                        this.hasAmendAdd = true;
                    }
                }
                // Get base subscription version.
//                FC_ZuoraClient.GetSubscriptionResponse baseSubscriptionDetail =
//                        this.zuoraClient.getSubscriptionByKey(this.opportunityRecord.Contract.FC_Subscription_Number__c);
//                FC_ZuoraClient.Subscription baseSubscriptionObject = this.zuoraClient.getSubscriptionObject(baseSubscriptionDetail.id);

                FC_ZuoraClient.UpdateSubscriptionResponse response = this.zuoraClient.updateSubscription(
                        FC_ZuoraUtil.buildUpdateSubscriptionRequest(scope, this.opportunityRecord, false),
                        this.opportunityRecord.Contract.FC_Subscription_Number__c);
                if (response.Success) {

                    if (this.hasAmendAdd) {
                        this.amendAddSuccess = true;
                    }

                    FC_Billing_Instruction_Step__c[] billingInstructionStepsToUpdate = new List<FC_Billing_Instruction_Step__c>();
                    for (FC_Billing_Instruction_Step__c billingInstructionStepRecord : scope) {
                        billingInstructionStepsToUpdate.add(new FC_Billing_Instruction_Step__c(
                                Id = billingInstructionStepRecord.Id, Status__c = 'Executed'));
                    }
                    if (!billingInstructionStepsToUpdate.isEmpty()) {
                        update billingInstructionStepsToUpdate;
                    }

                    Opportunity opportunityRecordToUpdate = new Opportunity(Id = this.opportunityRecord.Id,
                            FC_Last_Sent_To_Zuora__c = DateTime.now(), Skip_Validation__c = true);
                    update opportunityRecordToUpdate;

                } else {

                    String[] errorReasons = new List<String>();
                    if (response.reasons != null && !response.reasons.isEmpty()) {
                        for (FC_ZuoraClient.ZuoraError error : response.reasons) {
                            errorReasons.add(String.format('{0} - {1}', new String[]{
                                    error.code, error.message
                            }));
                        }
                        throw new FC_Exception(String.join(errorReasons, '; '));
                    }
                }
            } catch (Exception e) {
                exceptionCaught = true;
                throw new FC_Exception(String.format('{0}: {1}: {2}',
                        new String []{
                                e.getTypeName(), e.getMessage(), e.getStackTraceString()
                        }));
            } finally {
                if (exceptionCaught) {
                    zuoraClient.flushTransactions();
                }
            }

        }
    }

    public void finish(Database.BatchableContext context) {
        if (this.opportunityRecord != null && !this.subscribeInvoked && this.hasAmendAdd && this.amendAddSuccess &&
                new Set<String>{
                        'Database Access', 'Internet Sales', 'Membership'
                }.contains(this.opportunityRecord.One_time_Sale_Type__c) &&
                this.opportunityRecord.Purchase_Type__c != 'Price Increase Only') {
            update new Opportunity(Id = this.opportunityRecord.Id, FC_Send_Provisioning_Notification__c = true, Skip_Validation__c = true);
        }

        zuoraClient.flushTransactions();

        FC_MetroclientAccountProvisionBatchable batchable = new FC_MetroclientAccountProvisionBatchable(new Set<Id>{
                this.opportunityRecord.AccountId
        });
        batchable.parentTransactionId = this.opportunityRecord.Id;
        Database.executeBatch(batchable);

    }

}