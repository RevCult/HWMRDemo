public with sharing class ZuoraSubIdUpdate {

    @future(callout = true)
    public static void updateSubId(Id quoteId, String zuoraSubName) {
    
        Zuora.zApi zuoraApi = new Zuora.zApi();
            
        zuoraApi.zlogin();
            
        List<Zuora.zObject> Sub = zuoraApi.zQuery('Select Id from Subscription Where Name = \'' + zuoraSubName + '\' AND status = \'Active\'');
    
        String SubId = (String)Sub[0].getValue('Id');
        
        zqu__Quote__c LocalQuote = [Select Id from zqu__Quote__c where Id = :quoteId];
        
        LocalQuote.zqu__ZuoraSubscriptionID__c = SubId;
    
        update LocalQuote;
    }
}