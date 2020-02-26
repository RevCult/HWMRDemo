trigger trgPlanUpdateRequests on Plan_Update_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{
    List<Plan_Update_Request__c> planUpdateRequestsToUpdate = new List<Plan_Update_Request__c>();

    String triggerContext = '';
    if (Trigger.isBefore) {triggerContext = 'before';} else {triggerContext = 'after';}
    if (Trigger.isInsert) {triggerContext += 'insert';} else if (Trigger.isUpdate) {triggerContext += 'update';} else if (Trigger.isDelete) {triggerContext += 'delete';} else {triggerContext += 'undelete';}

    if ('afterupdate' == triggerContext) {
        TrgPlanUpdateRequestsHandler.ApprovePlanUpdateRequests(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if ('afterinsert' == triggerContext) {
        TrgPlanUpdateRequestsHandler.ApprovePlanUpdateRequests(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } 
}
}