trigger trgPlans on Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{
    List<Plan__c> plansToUpdate = new List<Plan__c>();

    String triggerContext = '';
    if (Trigger.isBefore) {triggerContext = 'before';} else {triggerContext = 'after';}
    if (Trigger.isInsert) {triggerContext += 'insert';} else if (Trigger.isUpdate) {triggerContext += 'update';} else if (Trigger.isDelete) {triggerContext += 'delete';} else {triggerContext += 'undelete';}

    if ('afterupdate' == triggerContext) {
        TrgPlansHandler.CreatePlanSnapshots(triggerContext, Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    }
}
}