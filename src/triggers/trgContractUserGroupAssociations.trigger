/**
 * Created by pete on 1/7/16.
 */
trigger trgContractUserGroupAssociations on Contract_User_Group_Association__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

//Disable logic is added to allow for bulk imports as needed.    
hw_settings__c settings = hw_settings__c.getInstance();
Boolean isOff = settings.Bypass_Research_Triggers__c;

if(! isOff)
{

    String triggerContext = '';
    if (Trigger.isBefore) {triggerContext = 'before';} else {triggerContext = 'after';}
    if (Trigger.isInsert) {triggerContext += 'insert';} else if (Trigger.isUpdate) {triggerContext += 'update';} else if (Trigger.isDelete) {triggerContext += 'delete';} else {triggerContext += 'undelete';}

    if ('afterinsert' == triggerContext) {
        AdminToolDataMaintenance.updateFieldsOnUserGroups(Trigger.new);
    } else if ('afterupdate' == triggerContext) {
        AdminToolDataMaintenance.updateFieldsOnUserGroups(Trigger.new);
    } else if ('afterdelete' == triggerContext) {
        AdminToolDataMaintenance.updateFieldsOnUserGroups(Trigger.old);
    } else if ('afterundelete' == triggerContext) {
        AdminToolDataMaintenance.updateFieldsOnUserGroups(Trigger.new);
    }
}
}