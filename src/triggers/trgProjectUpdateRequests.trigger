trigger trgProjectUpdateRequests on Project_Update_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{
    List<Project_Update_Request__c> projectUpdateRequestsToUpdate = new List<Project_Update_Request__c>();

    String triggerContext = '';
    if (Trigger.isBefore) {triggerContext = 'before';} else {triggerContext = 'after';}
    if (Trigger.isInsert) {triggerContext += 'insert';} else if (Trigger.isUpdate) {triggerContext += 'update';} else if (Trigger.isDelete) {triggerContext += 'delete';} else {triggerContext += 'undelete';}
    system.debug('triggerContext===='+triggerContext);

    if ('beforeinsert' == triggerContext) {
        system.debug('in beforeInsert');
        
    } else if ('beforeupdate' == triggerContext) {
        system.debug('in beforeUpdate');
        
    } else if ('afterupdate' == triggerContext) {
        system.debug('in AfterUpdate');
        TrgProjectUpdateRequestsHandler.ApproveProjectUpdateRequests(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        
    } else if ('afterinsert' == triggerContext) {
        system.debug('in AfterInsert');
        TrgProjectUpdateRequestsHandler.ApproveProjectUpdateRequests(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    
    
}
}