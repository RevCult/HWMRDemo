public with sharing class FC_ZuoraSubscriptionTCAmendmentFormCtrl {

    private final Zuora__Subscription__c SUBSCRIPTION_RECORD;

    public Boolean success { get; private set; }

    public String displaySubscriptionTermStartDate {

        get {
            displaySubscriptionTermStartDate = '';
            if (this.SUBSCRIPTION_RECORD.Zuora__TermStartDate__c != null) {
                displaySubscriptionTermStartDate = this.SUBSCRIPTION_RECORD.Zuora__TermStartDate__c.format();
            }
            return displaySubscriptionTermStartDate;
        }

        private set;

    }

    public String displaySubscriptionTermEndDate {

        get {
            displaySubscriptionTermEndDate = 'N/A';
            if (this.SUBSCRIPTION_RECORD.Zuora__TermSettingType__c == 'TERMED' &&
                    this.SUBSCRIPTION_RECORD.Zuora__TermEndDate__c != null) {
                displaySubscriptionTermEndDate = this.SUBSCRIPTION_RECORD.Zuora__TermEndDate__c.format();
            }
            return displaySubscriptionTermEndDate;
        }

        private set;

    }

    public String displayNewTermEndDate {

        get {
            displayNewTermEndDate = 'N/A';
            if (this.termType == 'TERMED' && this.termStartDate != null && this.currentTerm != null &&
                    String.isNotBlank(this.currentTermPeriodType)) {
                if (this.currentTermPeriodType == 'Month') {
                    displayNewTermEndDate = this.termStartDate.addMonths(this.currentTerm).format();
                } else if (this.currentTermPeriodType == 'Year') {
                    displayNewTermEndDate = this.termStartDate.addYears(this.currentTerm).format();
                } else if (this.currentTermPeriodType == 'Week') {
                    displayNewTermEndDate = this.termStartDate.addDays(this.currentTerm * 7).format();
                } else if (this.currentTermPeriodType == 'Day') {
                    displayNewTermEndDate = this.termStartDate.addDays(this.currentTerm).format();
                }
            }
            return displayNewTermEndDate;
        }

        private set;

    }

    public String termType { get; set; }
    public Integer currentTerm { get; set; }
    public String currentTermPeriodType { get; set; }
    public String renewalSetting { get; set; }
    public Integer renewalTerm { get; set; }
    public String renewalTermPeriodType { get; set; }
    public Date termStartDate { get; set; }
    public Boolean autoRenew { get; set; }

    public FC_ZuoraSubscriptionTCAmendmentFormCtrl(ApexPages.StandardController standardController) {
        this.SUBSCRIPTION_RECORD = (Zuora__Subscription__c) standardController.getRecord();
        this.termType = this.SUBSCRIPTION_RECORD.Zuora__TermSettingType__c;
        if (this.termType == 'TERMED') {
            if (String.isNotBlank(this.SUBSCRIPTION_RECORD.Zuora__InitialTerm__c)) {
                String initalTermString = this.SUBSCRIPTION_RECORD.Zuora__InitialTerm__c.replaceAll('[^0-9]', '');
                if (String.isNotBlank(initalTermString)) {
                    this.currentTerm = Integer.valueOf(initalTermString);
                }
            }
            this.currentTermPeriodType = this.SUBSCRIPTION_RECORD.Zuora__CurrentTermPeriodType__c;
            if (String.isNotBlank(this.SUBSCRIPTION_RECORD.Zuora__RenewalTerm__c)) {
                String renewalTermString = this.SUBSCRIPTION_RECORD.Zuora__RenewalTerm__c.replaceAll('[^0-9]', '');
                if (String.isNotBlank(renewalTermString)) {
                    this.renewalTerm = Integer.valueOf(renewalTermString);
                }
            }
            this.renewalSetting = 'RENEW_WITH_SPECIFIC_TERM';
            this.renewalTermPeriodType = this.SUBSCRIPTION_RECORD.Zuora__RenewalTermPeriodType__c;
            this.termStartDate = this.SUBSCRIPTION_RECORD.Zuora__TermStartDate__c;
            this.autoRenew = this.SUBSCRIPTION_RECORD.Zuora__AutoRenew__c;
        }
    }

    public PageReference processAmendment() {

        FC_ZuoraClient client = new FC_ZuoraClient();
        try {

            Boolean isTermed = this.termType == 'TERMED';
            FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest =
                    FC_ZuoraUtil.buildUpdateSubscriptionRequest(this.termType,
                            isTermed ? this.currentTerm : null,
                            isTermed ? this.currentTermPeriodType : null,
                            isTermed ? this.renewalSetting : null,
                            isTermed ? this.renewalTerm : null,
                            isTermed ? this.renewalTermPeriodType : null,
                            termStartDate,
                            isTermed ? this.autoRenew : null);
            FC_ZuoraClient.UpdateSubscriptionResponse updateSubscriptionResponse = client.updateSubscription(updateSubscriptionRequest,
                    this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c);
            if (updateSubscriptionResponse.success) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                        String.format('Subscription {0} has been successfully amended.', new String[]{
                                this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c
                        })));
                this.success = true;

                // Provision subscription IDs
                FC_MetroclientAccountProvisioningUtil.buildProvisioningRecords(
                        new Id[]{
                                this.SUBSCRIPTION_RECORD.Zuora__Account__c
                        }, null);
                FC_MetroclientAccountProvisioningUtil.commitProvisioningRecords();

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        String.format('An error occurred while updating subscription {0}.', new String[]{
                                this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c
                        })));
                renderZuoraErrors(updateSubscriptionResponse.reasons);
                this.success = false;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;

    }

    private void renderZuoraErrors(FC_ZuoraClient.ZuoraError[] errors) {
        if (errors != null) {
            for (FC_ZuoraClient.ZuoraError error : errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        String.format('{0} - {1}', new String[]{
                                String.valueOf(error.code), error.message
                        })));
            }
        }
    }

}