trigger trgBuilders on Builder__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{

    List<Builder__c> buildersToUpdate = new List<Builder__c>();

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

    if ('beforeinsert' == triggerContext) {

    } else if ('beforeupdate' == triggerContext) {
        
    } else if ('beforedelete' == triggerContext) {
        TrgBuildersHandler.AssociateProjectsToAccounts(triggerContext, Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    } else if ('afterinsert' == triggerContext) {
        TrgBuildersHandler.AssociateProjectsToAccounts(triggerContext, Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    } else if ('afterupdate' == triggerContext) {
        for(Builder__c newBuilder : trigger.new){
            Builder__c oldBuilder = Trigger.oldMap.get(newBuilder.Id);
            if (oldBuilder.Account__c != newBuilder.Account__c ){
                system.debug('AfterUpdate action: Account changed');
                TrgBuildersHandler.AssociateProjectsToAccounts(triggerContext, Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
            }
        }
    } else if ('afterdelete' == triggerContext) {

    } else if ('afterundelete' == triggerContext) {
        TrgBuildersHandler.AssociateProjectsToAccounts(triggerContext, Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    }
}
}