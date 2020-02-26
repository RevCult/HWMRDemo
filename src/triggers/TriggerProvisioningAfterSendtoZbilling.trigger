trigger TriggerProvisioningAfterSendtoZbilling on zqu__Quote__c (after update) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{
 
for (zqu__Quote__c localQuote: Trigger.new)
    {
    zqu__Quote__c oldQuote = Trigger.oldMap.get(localQuote.Id);
    if(oldQuote.zqu__Status__c == 'New' && localQuote.zqu__Status__c == 'Sent to Z-Billing'){
    
        Opportunity Opp = [Select Id, AccountId from Opportunity WHERE id = :localQuote.zqu__Opportunity__c];
    
    /*
        if(localQuote.zqu__SubscriptionType__c == 'New Subscription')
        {
            MetroclientAccountProvisioningUpdate.UpdateAccountProvisioningFromZuora(localQuote.zqu__ZuoraSubscriptionID__c, String.valueOf(Opp.AccountId));
        }
        else
        {
        */
            //Zuora.zApi zuoraApi = new Zuora.zApi();
            
            //zuoraApi.zlogin();
            
            //List<Zuora.zObject> Sub = zuoraApi.zQuery('Select Id from Subscription Where Name = \' + localQuote.zqu__Subscription_Name__c + \' AND status = \'active\'');    
            
            //ZuoraSubIdUpdate.updateSubId(localQuote.Id, localQuote.zqu__Subscription_Name__c);
         
            MetroclientAccountProvisioningUpdate.UpdateAccountProvisioningFromZuora(localQuote.zqu__ZuoraSubscriptionID__c, localQuote.zqu__Subscription_Name__c, localQuote.zqu__ExistSubscriptionID__c, localQuote.zqu__SubscriptionType__c, localQuote.Id, String.valueOf(Opp.AccountId));
    
        
        System.Debug('Account ID' + Opp.AccountId);
        System.Debug('Subscription ID' + localQuote.zqu__ZuoraSubscriptionID__c);  
        }
        
    }
}
}