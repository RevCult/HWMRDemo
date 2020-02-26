trigger trgCommunities on Community__c (after insert,after Update) {

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
    }
    
    if (!System.isBatch() && !System.isFuture()) {
        if ('afterinsert' == triggerContext) {
            trgCommunitiesHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        } 
        else if ('afterupdate' == triggerContext) {
            trgCommunitiesHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);        
        }
        
    }
}
}