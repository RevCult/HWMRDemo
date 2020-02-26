trigger trgContacts on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

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
            
        } else if ('beforeupdate' == triggerContext) {
            
        } else if ('afterinsert' == triggerContext) {
            for(Contact newContact : trigger.new){
                if (newContact.MailingPostalCode != NULL){
                    trgContactsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
        } else if ('afterupdate' == triggerContext) {
           for(Contact newContact : trigger.new){
               Contact oldContact = Trigger.oldMap.get(newContact.Id);  //Old Map does not exist for Insert 
               if (oldContact.MailingPostalCode != newContact.MailingPostalCode
                   || oldContact.MailingCity != newContact.MailingCity
                   || oldContact.MailingState != newContact.MailingState
                   || oldContact.MailingCountry != newContact.MailingCountry
                   ){
                    trgContactsHandler.UpdateDataFromGoogle(triggerContext, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
            }
        } 
    }

    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            TrgContactsHandler.dontChangeZondaUserEmails(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            TrgContactsHandler.dontDeleteZondaUserContacts(Trigger.oldMap);
        }
    }
}
}