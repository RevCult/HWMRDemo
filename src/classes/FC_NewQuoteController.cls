public class FC_NewQuoteController {

    private static final Set<String> MULTI_QUOTE_RECORD_TYPE_DEVELOPER_NAMES = new Set<String> {
            'Metrostudy_Opportunity_Record_Type_Consult', 'Metrostudy_Opportunity_REE' };
        
    private final Opportunity record;
    
    public FC_NewQuoteController(ApexPages.StandardController standardController) {
        this.record = (Opportunity) standardController.getRecord();
    }

    public PageReference redirect() {
        PageReference prResult = null;
        Integer sentToZBillingQuoteCount = [select count() from zqu__Quote__c 
                                            where zqu__Opportunity__c = :record.Id 
                                            and zqu__Status__c = 'Sent to Z-Billing'];    
        if ((record.RecordTypeId != null && MULTI_QUOTE_RECORD_TYPE_DEVELOPER_NAMES.contains(record.RecordType.DeveloperName)) || 
                sentToZBillingQuoteCount == 0) {
            prResult = Page.zqu__QuoteOption;
            prResult.getParameters().put('id', record.Id);
            prResult.setRedirect(true);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       'A quote on this opportunity has already been sent to Z-Billing.'));
        }
        return prResult;
    }
    
}