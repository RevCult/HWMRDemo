public with sharing class FC_CreateRenewalOpportunityController {

    private final Opportunity OPPORTUNITY_RECORD;

    public FC_CreateRenewalOpportunityController(ApexPages.StandardController standardController) {
        this.OPPORTUNITY_RECORD = (Opportunity) standardController.getRecord();
    }

    public PageReference createRenewalOpportunity() {
        FC_RenewalOpportunityService.RenewalOpportunityInfo[] renewalOpportunityInfos = new List<FC_RenewalOpportunityService.RenewalOpportunityInfo>();

        FC_RenewalOpportunityService.RenewalOpportunityInfo renewalOpportunityInfo = new FC_RenewalOpportunityService.RenewalOpportunityInfo();
        renewalOpportunityInfo.originalOpportunityId = this.OPPORTUNITY_RECORD.Id;
        renewalOpportunityInfo.renewalDate = this.OPPORTUNITY_RECORD.Contract.FC_Next_Charge_Date__c;
        renewalOpportunityInfo.annualize = this.OPPORTUNITY_RECORD.Contract.FC_Subscription_Start_Date__c >= Date.valueOf('2018-01-01');
        renewalOpportunityInfos.add(renewalOpportunityInfo);

        FC_RenewalOpportunityService.CreateRenewalOpportunityResponse createRenewalOpportunityResponse = FC_RenewalOpportunityService.createRenewalOpportunities(renewalOpportunityInfos);
        if (createRenewalOpportunityResponse.success) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                    String.format('Successfully created <a href="/{0}" target="_blank">renewal opportunity</a>.', new String[]{
                            createRenewalOpportunityResponse.results[0].renewalOpportunityId
                    })));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred when creating a renewal opportunity.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception Type: ' + createRenewalOpportunityResponse.exceptionType));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: ' + createRenewalOpportunityResponse.message));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Stack Trace: ' + createRenewalOpportunityResponse.stackTrace));
        }
        return null;
    }

}