public with sharing class FC_OpportunityContractFormController {

    private final Opportunity OPPORTUNITY_RECORD;

    private final ApexPages.StandardController STANDARD_CONTROLLER;

    public Map<Id, Zuora__SubscriptionProductCharge__c[]> subscriptionIdToChargesMap {

        get {
            if (subscriptionIdToChargesMap == null && subscriptionIds != null) {
                subscriptionIdToChargesMap = new Map<Id, Zuora__SubscriptionProductCharge__c[]>();
                for (Zuora__SubscriptionProductCharge__c chargeRecord : [
                        select Id, GeographyName__c, Name, Zuora__Subscription__c, Zuora__Description__c,
                                Zuora__ProductName_Product__c
                        from Zuora__SubscriptionProductCharge__c
                        where Zuora__Subscription__c in :subscriptionIds
                ]) {
                    Zuora__SubscriptionProductCharge__c[] charges = subscriptionIdToChargesMap.get(chargeRecord.Zuora__Subscription__c);
                    if (charges == null) {
                        charges = new List<Zuora__SubscriptionProductCharge__c>();
                        subscriptionIdToChargesMap.put(chargeRecord.Zuora__Subscription__c, charges);
                    }
                    charges.add(chargeRecord);
                }
            }
            return subscriptionIdToChargesMap;
        }

        private set;

    }

    public Set<Id> subscriptionIds {

        get {
            if (subscriptionIds == null && accountContracts != null) {
                subscriptionIds = new Set<Id>();
                for (Contract contractRecord : accountContracts) {
                    subscriptionIds.add(contractRecord.FC_Subscription__c);
                }
            }
            return subscriptionIds;
        }

        private set;

    }

    public Contract[] accountContracts {

        get {
            if (accountContracts == null) {
                accountContracts = [
                        select Id, FC_Subscription__c, FC_Price_Book__c, FC_Subscription__r.Name,
                                FC_Subscription__r.Opportunity__c,
                                FC_Subscription__r.Zuora__AutoRenew__c,
                                FC_Subscription__r.Zuora__ContractEffectiveDate__c,
                                FC_Subscription__r.Zuora__CustomerAccount__c,
                                FC_Subscription__r.Zuora__CustomerAccount__r.Name,
                                FC_Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                FC_Subscription__r.Zuora__InitialTerm__c,
                                FC_Subscription__r.Zuora__RenewalTerm__c,
                                FC_Subscription__r.Zuora__ServiceActivationDate__c,
                                FC_Subscription__r.Zuora__TermEndDate__c,
                                FC_Subscription__r.Zuora__TermStartDate__c,
                                FC_Subscription__r.Zuora__TermSettingType__c
                        from Contract
                        where AccountId = :this.OPPORTUNITY_RECORD.AccountId
                        and FC_Subscription__c != null
                        and FC_Subscription__r.Zuora__Status__c = 'Active'
                        order by FC_Subscription__r.Name desc
                ];
            }
            return accountContracts;
        }

        private set;

    }

    public ContractWrapper[] wrappedAccountContracts {

        get {
            if (wrappedAccountContracts == null && accountContracts != null) {
                wrappedAccountContracts = new List<ContractWrapper>();
                for (Contract contractRecord : accountContracts) {
                    Set<String> productSet = new Set<String>();
                    List<Zuora__SubscriptionProductCharge__c> charges = subscriptionIdToChargesMap.get(contractRecord.FC_Subscription__c);
                    String products = '';
                    if (charges != null) {
                        for (Zuora__SubscriptionProductCharge__c chargeRecord : charges) {
                            productSet.add(String.join(new String[]{
                                    chargeRecord.Zuora__ProductName_Product__c,
                                    chargeRecord.GeographyName__c
                            }, ' | ').stripHtmlTags());
                        }
                        List<String> productList = new List<String>(productSet);
                        productList.sort();
                        products = String.join(productList, '<br />');
                    }
                    wrappedAccountContracts.add(new ContractWrapper(contractRecord.Id, contractRecord.FC_Subscription__r.Name,
                            contractRecord.FC_Subscription__r.Opportunity__c,
                            contractRecord.FC_Subscription__r.Zuora__CustomerAccount__r.Name,
                            contractRecord.FC_Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                            contractRecord.FC_Subscription__r.Zuora__TermStartDate__c,
                            contractRecord.FC_Subscription__r.Zuora__TermEndDate__c, products));
                }
            }
            return wrappedAccountContracts;
        }

        private set;

    }

    public Id selectedContractId { get; set; }

    public FC_OpportunityContractFormController(ApexPages.StandardController standardController) {
        this.STANDARD_CONTROLLER = standardController;
        this.OPPORTUNITY_RECORD = (Opportunity) standardController.getRecord();
    }

    public PageReference selectContract() {
        if (this.selectedContractId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a contract.'));
            return null;
        }

        FC_OpportunityContractUtil.associateOpportunitiesWithContracts(new Map<Id, Id>{
                this.OPPORTUNITY_RECORD.Id => this.selectedContractId
        });

        return this.STANDARD_CONTROLLER.view();
    }


    public class ContractWrapper {

        public Id contractId {
            get;
            set;
        }


        public String customerAccountName { get; set; }

        public String customerAccountNumber { get; set; }

        public Id opportunityId { get; set; }

        public String products {
            get;
            set;
        }

        public String subscriptionNumber { get; set; }

        public String termEndDate {
            get;
            set;
        }

        public String termStartDate {
            get;
            set;
        }

        public ContractWrapper(Id contractId, String subscriptionNumber, Id opportunityId, String customerAccountName,
                String customerAccountNumber, Date termStartDate, Date termEndDate, String products) {
            this.contractId = contractId;
            this.subscriptionNumber = subscriptionNumber;
            this.opportunityId = opportunityId;
            this.customerAccountName = customerAccountName;
            this.customerAccountNumber = customerAccountNumber;
            if (termStartDate != null) {
                this.termStartDate = termStartDate.format();
            }
            if (termEndDate != null) {
                this.termEndDate = termEndDate.format();
            }
            this.products = products;
        }

    }

}