public with sharing class FC_OpportunityCancellationFormController {

    private final Opportunity OPPORTUNITY_RECORD;
    private final ApexPages.StandardController STANDARD_CONTROLLER;

    public String effectiveDateString { get; set; }

    public Boolean preValid {

        get {
            if (preValid == null) {
                preValid = false;
            }
            return preValid;
        }

        private set;

    }

    public Boolean success {

        get {
            if (success == null) {
                success = false;
            }
            return success;
        }

        private set;

    }

    public Date effectiveDate {

        get {
            effectiveDate = null;
            if (String.isNotBlank(effectiveDateString)) {
                try {
                    effectiveDate = Date.valueOf(effectiveDateString);
                } catch (Exception e) {
                }
            }
            return effectiveDate;
        }

        private set;

    }

    public String selectedCancellationAction { get; set; }

    public RatePlanWrapper[] ratePlans {

        get {
            if (ratePlans == null) {
                Set<RatePlanWrapper> wrappedRatePlanSet = new Set<RatePlanWrapper>();
                for (Zuora__SubscriptionProductCharge__c chargeRecord : [
                        select Id, GeographyName__c, Zuora__Description__c, Zuora__EffectiveEndDate__c, Zuora__EffectiveStartDate__c,
                                Zuora__Price__c, Zuora__ProductName_Product__c, Zuora__SubscriptionRatePlan__c,
                                Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c,
                                Zuora__SubscriptionRatePlan__r.Zuora__SubscriptionRatePlanName__c,
                                Zuora__SubscriptionChargeNumber__c
                        from Zuora__SubscriptionProductCharge__c
                        where Zuora__Subscription__c = :this.OPPORTUNITY_RECORD.Contract.FC_Subscription__c
                        and Zuora__Type__c = 'Recurring'
                ]) {
                    String description = String.join(new String[]{
                            chargeRecord.Zuora__ProductName_Product__c, chargeRecord.GeographyName__c
                    }, ' | ').stripHtmlTags();
                    wrappedRatePlanSet.add(new RatePlanWrapper(chargeRecord.Zuora__SubscriptionChargeNumber__c,
                            chargeRecord.Zuora__SubscriptionRatePlan__c,
                            chargeRecord.Zuora__SubscriptionRatePlan__r.Zuora__External_Id__c,
                            chargeRecord.Zuora__SubscriptionRatePlan__r.Zuora__SubscriptionRatePlanName__c,
                            description, chargeRecord.Zuora__EffectiveStartDate__c,
                            chargeRecord.Zuora__EffectiveEndDate__c, chargeRecord.Zuora__Price__c));
                }
                ratePlans = new List<RatePlanWrapper>(wrappedRatePlanSet);
            }
            return ratePlans;
        }

        private set;

    }

    public FC_OpportunityCancellationFormController(ApexPages.StandardController standardController) {
        this.STANDARD_CONTROLLER = standardController;
        this.OPPORTUNITY_RECORD = (Opportunity) standardController.getRecord();
    }

    public PageReference preValidate() {
        this.preValid = true;
        if (this.OPPORTUNITY_RECORD.ContractId == null || this.OPPORTUNITY_RECORD.Contract.FC_Subscription__c == null ||
                this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Zuora__Status__c != 'Active') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'You must have a contract with an active subscription associated with this opportunity.'));
            this.preValid = false;
        }
        return null;
    }

    public PageReference processCancellation() {

        if (!isValid()) {
            return null;
        }

        FC_ZuoraClient client = new FC_ZuoraClient(this.OPPORTUNITY_RECORD.Id);

        try {

            if (selectedCancellationAction == 'SUBSCRIPTION') {

                // Cancel the subscription
                FC_ZuoraClient.CancelSubscriptionRequest cancelSubscriptionRequest = new FC_ZuoraClient.CancelSubscriptionRequest();
                cancelSubscriptionRequest.cancellationEffectiveDate = effectiveDate;
                cancelSubscriptionRequest.cancellationPolicy = 'SpecificDate';
                FC_ZuoraClient.CancelSubscriptionResponse cancelSubscriptionResponse = client.cancelSubscription(cancelSubscriptionRequest,
                        this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name);
                if (cancelSubscriptionResponse.success) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                            String.format('Subscription {0} has been successfully cancelled.',
                                    new String[]{
                                            this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name
                                    })));
                    this.success = true;

                    FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = new FC_ZuoraClient.UpdateSubscriptionRequest();
                    updateSubscriptionRequest.OpportunityID_c = this.OPPORTUNITY_RECORD.Id;
                    FC_ZuoraClient.UpdateSubscriptionResponse updateSubscriptionResponse = client.updateSubscription(updateSubscriptionRequest,
                            this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name);
                    if (!updateSubscriptionResponse.success) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                String.format('An error occurred while updating subscription {0}.', new String[]{
                                        this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name
                                })));
                        renderZuoraErrors(updateSubscriptionResponse.reasons);
                    }

                    this.OPPORTUNITY_RECORD.StageName = 'Cancelled';
                    this.OPPORTUNITY_RECORD.Probability = 0;
                    this.OPPORTUNITY_RECORD.FC_Last_Sent_To_Zuora__c = DateTime.now();
                    this.OPPORTUNITY_RECORD.FC_Cancellation_Action__c = selectedCancellationAction;
                    update this.OPPORTUNITY_RECORD;

                    OpportunityLineItem[] opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
                    for (OpportunityLineItem opportunityLineItemRecord : [
                            select Id
                            from OpportunityLineItem
                            where OpportunityId = :this.OPPORTUNITY_RECORD.Id
                    ]) {
                        opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemRecord.Id,
                                FC_Do_Not_Annualize__c = false, FC_End_Date__c = this.effectiveDate, FC_Zuora_Action__c = 'Remove', FC_Purchase_Type__c = 'Cancellation'));
                    }
                    if (!opportunityLineItemsToUpdate.isEmpty()) {
                        update opportunityLineItemsToUpdate;
                    }

                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                            String.format('An error occurred while cancelling subscription {0}.', new String[]{
                                    this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name
                            })));
                    renderZuoraErrors(cancelSubscriptionResponse.reasons);
                    this.success = false;
                }
            } else {
                FC_ZuoraClient.RemoveRatePlan[] ratePlansToRemove = new List<FC_ZuoraClient.RemoveRatePlan>();
                Integer selectedProductCount = 0;
                Set<String> chargeNumbersToMarkAsRemoved = new Set<String>();
                for (RatePlanWrapper ratePlan : ratePlans) {
                    if (ratePlan.selected) {
                        chargeNumbersToMarkAsRemoved.add(ratePlan.chargeNumber);
                        FC_ZuoraClient.RemoveRatePlan ratePlanToRemove = new FC_ZuoraClient.RemoveRatePlan();
                        ratePlanToRemove.ratePlanId = ratePlan.ratePlanZuoraId;
                        ratePlanToRemove.contractEffectiveDate = effectiveDate;
                        ratePlanToRemove.customerAcceptanceDate = effectiveDate;
                        ratePlanToRemove.serviceActivationDate = effectiveDate;
                        ratePlansToRemove.add(ratePlanToRemove);
                        selectedProductCount++;
                    }
                }
                FC_ZuoraClient.UpdateSubscriptionRequest request = new FC_ZuoraClient.UpdateSubscriptionRequest();
                request.OpportunityID_c = this.OPPORTUNITY_RECORD.Id;
                request.targetDate = effectiveDate;
                request.remove = ratePlansToRemove;
                FC_ZuoraClient.UpdateSubscriptionResponse response = client.updateSubscription(request,
                        this.OPPORTUNITY_RECORD.Contract.FC_Subscription__r.Name);
                if (response.success) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                            String.format('The selected {0} been successfully cancelled.',
                                    new String[]{
                                            (selectedProductCount == 1 ? 'product has' : 'products have')
                                    })));
                    this.OPPORTUNITY_RECORD.StageName = 'Cancelled';
                    this.OPPORTUNITY_RECORD.Probability = 0;
                    this.OPPORTUNITY_RECORD.FC_Last_Sent_To_Zuora__c = DateTime.now();
                    this.OPPORTUNITY_RECORD.FC_Cancellation_Action__c = selectedCancellationAction;
                    update this.OPPORTUNITY_RECORD;

                    OpportunityLineItem[] opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
                    if (!chargeNumbersToMarkAsRemoved.isEmpty()) {
                        for (OpportunityLineItem opportunityLineItemRecord : [
                                select Id
                                from OpportunityLineItem
                                where OpportunityId = :this.OPPORTUNITY_RECORD.Id
                                and FC_Billing_Instruction_Set__r.Charge_Number__c in :chargeNumbersToMarkAsRemoved
                        ]) {
                            opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemRecord.Id,
                                    FC_Do_Not_Annualize__c = false, FC_End_Date__c = this.effectiveDate, FC_Zuora_Action__c = 'Remove', FC_Purchase_Type__c = 'Cancellation'));
                        }
                    }
                    if (!opportunityLineItemsToUpdate.isEmpty()) {
                        update opportunityLineItemsToUpdate;
                    }

                    this.success = true;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' +
                            String.format('An error occurred while cancelling the selected {0}.', new String[]{
                                    selectedProductCount == 1 ? 'product' : 'products'
                            })));
                    renderZuoraErrors(response.reasons);
                    this.success = false;
                }

            }

        } finally {

            client.flushTransactions();

        }
        return null;
    }

    private Boolean isValid() {

        Boolean valid = true;

        if (effectiveDate == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Effective Date is required.'));
            valid = false;
        }
        if (String.isBlank(selectedCancellationAction)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cancellation Action is required.'));
            valid = false;
        } else if (selectedCancellationAction == 'PRODUCTS') {

            Integer selectedProductCount = 0;
            for (RatePlanWrapper ratePlan : this.ratePlans) {
                if (ratePlan.selected) {
                    selectedProductCount++;
                }
            }

            if (selectedProductCount == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'You must select at least one product to cancel.'));
                valid = false;
            }

        }

        return valid;
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

    public class RatePlanWrapper {

        public Boolean selected {
            get {
                if (selected == null) {
                    selected = false;
                }
                return selected;
            }
            set;
        }

        public String chargeNumber {
            get;
            set;
        }

        public Id ratePlanId {
            get;
            set;
        }

        public String ratePlanZuoraId {
            get;
            set;
        }

        public String name {
            get;
            set;
        }

        public String description {
            get;
            set;
        }

        public Date effectiveStartDate {
            get;
            set;
        }

        public String effectiveStartDateString {

            get {
                effectiveStartDateString = '';
                if (effectiveStartDate != null) {
                    effectiveStartDateString = effectiveStartDate.format();
                }
                return effectiveStartDateString;
            }

            private set;
        }

        public Date effectiveEndDate {
            get;
            set;
        }

        public String effectiveEndDateString {
            get {
                effectiveEndDateString = '';
                if (effectiveEndDate != null) {
                    effectiveEndDateString = effectiveEndDate.format();
                }
                return effectiveEndDateString;

            }

            private set;
        }

        public Decimal price {
            get;
            set;
        }

        public RatePlanWrapper(String chargeNumber, Id ratePlanId, String ratePlanZuoraId, String name, String description,
                Date effectiveStartDate, Date effectiveEndDate, Decimal price) {
            this.chargeNumber = chargeNumber;
            this.ratePlanId = ratePlanId;
            this.ratePlanZuoraId = ratePlanZuoraId;
            this.name = name;
            this.description = description;
            this.effectiveStartDate = effectiveStartDate;
            this.effectiveEndDate = effectiveEndDate;
            this.price = price != null ? price.setScale(2) : null;
        }

        public Boolean equals(Object otherObject) {
            if (otherObject instanceof RatePlanWrapper) {
                RatePlanWrapper other = (RatePlanWrapper) otherObject;
                return (this === other) ||
                        (other != null && this.chargeNumber == other.chargeNumber && this.ratePlanId == other.ratePlanId &&
                                this.ratePlanZuoraId == other.ratePlanZuoraId && this.name == other.name);
            }
            return false;
        }

        public Integer hashCode() {
            final Integer prime = 31;
            Integer result = 1;
            result = prime * result + (chargeNumber == null ? 0 : chargeNumber.hashCode());
            result = prime * result + (ratePlanId == null ? 0 : String.valueOf(ratePlanId).hashCode());
            result = prime * result + (ratePlanZuoraId == null ? 0 : String.valueOf(ratePlanZuoraId).hashCode());
            result = prime * result + (name == null ? 0 : name.hashCode());
            return result;
        }

    }

}