public with sharing class FC_OpportunityBillingAccountFormCtrl {

    private final Opportunity OPPORTUNITY_RECORD;
    private final ApexPages.StandardController STANDARD_CONTROLLER;

    public Id selectedBillingAccountId { get; set; }

    public String selectedBillingAccountAction { get; set; }

    public SelectOption[] billingAccountContactOptions {

        get {
            if (billingAccountContactOptions == null) {
                billingAccountContactOptions = new List<SelectOption>();
                billingAccountContactOptions.add(new SelectOption('', '-- Select One --'));
                Set<Id> visitedContactIds = new Set<Id>();
                for (OpportunityContactRole opportunityContactRoleRecord : [
                        select Id, ContactId, Contact.Name
                        from OpportunityContactRole
                        where OpportunityId = :this.OPPORTUNITY_RECORD.Id
                        order by Contact.LastName asc
                ]) {
                    if (!visitedContactIds.contains(opportunityContactRoleRecord.ContactId)) {
                        billingAccountContactOptions.add(new SelectOption(opportunityContactRoleRecord.ContactId,
                                opportunityContactRoleRecord.Contact.Name));
                        visitedContactIds.add(opportunityContactRoleRecord.ContactId);
                    }
                }
            }
            return billingAccountContactOptions;
        }

        private set;

    }

    public Zuora__CustomerAccount__c[] billingAccounts {

        get {
            if (billingAccounts == null) {
                billingAccounts = [
                        select Id, Name, Zuora__AccountNumber__c, Zuora__Balance__c, Zuora__BillToCity__c,
                                Zuora__BillToCountry__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c,
                                Zuora__BillToState__c, Zuora__BillToPostalCode__c, Zuora__BillToName__c,
                                Zuora__SoldToAddress1__c, Zuora__SoldToAddress2__c, Zuora__SoldToCity__c,
                                Zuora__SoldToCountry__c,Zuora__SoldToName__c,Zuora__SoldToPostalCode__c,
                                Zuora__SoldToState__c
                        from Zuora__CustomerAccount__c
                        where Zuora__Account__c = :this.OPPORTUNITY_RECORD.AccountId
                ];
            }
            return billingAccounts;
        }

        private set;

    }

    public FC_OpportunityBillingAccountFormCtrl(ApexPages.StandardController standardController) {
        this.OPPORTUNITY_RECORD = (Opportunity) standardController.getRecord();
        this.STANDARD_CONTROLLER = standardController;
    }

    public void refreshUi() {
        this.billingAccountContactOptions = null;
        this.billingAccounts = null;
        this.selectedBillingAccountId = null;
        this.OPPORTUNITY_RECORD.FC_Bill_To_Contact__c = null;
        this.OPPORTUNITY_RECORD.FC_Sold_To_Contact__c = null;
        this.OPPORTUNITY_RECORD.FC_Billing_Account__c = null;
    }

    public PageReference saveOpportunity() {

        if (!isValid()) {
            return null;
        }

        if (selectedBillingAccountAction == 'USE_EXISTING') {
            this.OPPORTUNITY_RECORD.FC_Billing_Account__c = selectedBillingAccountId;
        }

        update this.OPPORTUNITY_RECORD;

        return this.STANDARD_CONTROLLER.view();
    }

    private Boolean isValid() {
        Boolean valid = true;

        if (selectedBillingAccountAction == 'USE_EXISTING' && String.isBlank(selectedBillingAccountId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'You must select a billing account.'));
            valid = false;
        }

        if (this.OPPORTUNITY_RECORD.FC_Last_Sent_To_Zuora__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'You cannot change the billing account or contacts since this opportunity was sent to Zuora.'));
            valid = false;
        }

        return valid;
    }

}