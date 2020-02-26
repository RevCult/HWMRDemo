trigger trgZondaUsers on Zonda_User__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    String triggerContext = '';
    if (Trigger.isBefore) { triggerContext = 'before'; } else { triggerContext = 'after'; }
    if (Trigger.isInsert) { triggerContext += 'insert'; } else if (Trigger.isUpdate) { triggerContext += 'update'; } else if (Trigger.isDelete) { triggerContext += 'delete'; } else { triggerContext += 'undelete'; }

    List<Zonda_User__c> theUsersWithAllNeededFields = new List<Zonda_User__c>();

    if ('beforeinsert' == triggerContext) {
        trgZondaUsersHandler.resetPasswordIfNeeded(Trigger.new, null);
    } else if ('beforeupdate' == triggerContext) {
        if (!Context.isTriggerContext) { // avoid trigger recursion resetting the pw multiple times
            trgZondaUsersHandler.resetPasswordIfNeeded(Trigger.new, Trigger.oldMap);
        }
    } else if ('afterinsert' == triggerContext) {
        trgZondaUsersHandler.updateContactMaxValues(Trigger.new);
        //getAdditionalFields();
        //String webhookPayload = ZondaCallout.generateWebhookPayloadFromObjects(theUsersWithAllNeededFields);
        //if (String.isNotBlank(webhookPayload)) {
        //  ZondaCallout.sendWebhookRequest('users', webhookPayload);
        //}
    } else if ('afterupdate' == triggerContext) {
        if (!Context.isFutureContext) { // don't do this if it's part of an update that was made by an asynchronous method
            getAdditionalFields();
            for (Integer i = theUsersWithAllNeededFields.size() - 1; i >= 0; -- i) {
                
                Zonda_User__c zu = theUsersWithAllNeededFields[i];
                system.debug('here');
                
                if ((zu.Reset_Password__c == Trigger.oldMap.get(zu.Id).Reset_Password__c) && (zu.Password__c == Trigger.oldMap.get(zu.Id).Password__c)) {
                    theUsersWithAllNeededFields.remove(i);
                }
            }
            if(theUsersWithAllNeededFields.size() > 0) {
                String webhookPayload = ZondaCallout.generateWebhookPayloadFromObjects(theUsersWithAllNeededFields);
                if (String.isNotBlank(webhookPayload)) {
                    ZondaCallout.sendWebhookRequest('users', webhookPayload);
                }
            }
            trgZondaUsersHandler.updateContactMaxValues(Trigger.new);
        }
    }

    private void getAdditionalFields() {
        theUsersWithAllNeededFields = [SELECT Id, 
                                            Password__c,
                                            Reset_Password__c
                                        FROM Zonda_User__c 
                                        WHERE Id IN :Trigger.newMap.keyset()];
    }
}