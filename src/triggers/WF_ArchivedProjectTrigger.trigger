trigger WF_ArchivedProjectTrigger on WF_Archived_Project__c (after update) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            WF_ArchivedProjectTriggerHandler.onAfterUpdate(Trigger.new);
        }
    }
}