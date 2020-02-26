trigger trgAccounts on Account(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;


if(! isOff)
{
    
    String triggerContext = '';

    if (Trigger.isBefore) {
        triggerContext = 'before';
    } else {
        triggerContext = 'after';
    }

    if (Trigger.isInsert) {
        triggerContext += 'insert';
    } else if (Trigger.isUpdate) {
        triggerContext += 'update';
    } else if (Trigger.isDelete) {
        triggerContext += 'delete';
    } else {
        triggerContext += 'undelete';
    }

    if (!System.isBatch() && !System.isFuture()) {
        if ('beforeinsert' == triggerContext) { 
           //trgAccountsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);            
        } else if ('beforeupdate' == triggerContext) {
           //trgAccountsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap); 
        } else if ('afterinsert' == triggerContext) {
            for(Account newAccount : trigger.new){
                if (newAccount.BillingPostalCode != NULL){
                    //CP: 10/4/2019... commenting this out so we can test in our Sandbox... 
                    //CP: trgAccountsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
           
        } else if ('afterupdate' == triggerContext) {
            for(Account newAccount : trigger.new){
                Account oldAccount = Trigger.oldMap.get(newAccount.Id);  //Old Map does not exist for Insert 
                if (oldAccount.BillingPostalCode != newAccount.BillingPostalCode 
                    || oldAccount.BillingCity != newAccount.BillingCity
                    || oldAccount.BillingState != newAccount.BillingState
                    || oldAccount.BillingCountry != newAccount.BillingCountry
                   ){
                       trgAccountsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
        }
    }
}
}