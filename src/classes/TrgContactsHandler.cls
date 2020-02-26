public with sharing class TrgContactsHandler {

    /**
        SFDC-51
        Prevent contacts from being deleted if there is a Zonda User associated and show a message 
        "This Contact is a Zonda User and cannot be deleted"  -- or something similar.
    */
    public static void dontDeleteZondaUserContacts(Map<Id, Contact> triggerOldMap) {
        List<Zonda_User__c> zondaUsers = new List<Zonda_User__c>();
        zondaUsers = [SELECT Id, Contact__c FROM Zonda_User__c WHERE Contact__c IN :triggerOldMap.keyset()];
        if (!zondaUsers.isEmpty()) {
            Set<Id> contactsWithZondaUsers = new Set<Id>();
            for (Zonda_User__c zu : zondaUsers) {
                contactsWithZondaUsers.add(zu.Contact__c);
            }
            for (Id contactId : contactsWithZondaUsers) {
                triggerOldMap.get(contactId).addError('This Contact is a Zonda User and cannot be deleted');
            }
        }
    }

    /**
        SFDC-51
        Prevent users from updating the contact's email address if there is a Zonda User associated.  
        Maybe show a error message "This Contact is a Zonda User and the email cannot be updated"
    */
    public static void dontChangeZondaUserEmails(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        List<Zonda_User__c> zondaUsers = new List<Zonda_User__c>();
        zondaUsers = [SELECT Id, Contact__c FROM Zonda_User__c WHERE Contact__c IN :triggerOldMap.keyset()];
        if (!zondaUsers.isEmpty()) {
            Set<Id> contactsWithZondaUsers = new Set<Id>();
            for (Zonda_User__c zu : zondaUsers) {
                contactsWithZondaUsers.add(zu.Contact__c);
            }
            for (Contact c : triggerNew) {
                if (c.Email == null) { c.Email = ''; }
                if (triggerOldMap.get(c.Id).Email == null) { triggerOldMap.get(c.Id).Email = ''; }
                if (contactsWithZondaUsers.contains(c.Id) && c.Email != triggerOldMap.get(c.Id).Email) {
                    c.addError('This Contact is a Zonda User and the email cannot be updated');
                }
            }
        }
    }

    private static boolean run = true;
    public static boolean runOnce(){
        if (run) {
            run=false;
            return true;
        } else {
            return run;
        }
    }
    
    public static void UpdateDataFromGoogle(String triggerContext, List<Contact> triggerNew, Map<Id, Contact> triggerNewMap, List<Contact> triggerOld, Map<Id, Contact> triggerOldMap) {
        List<Id> ContactIdsThatNeedUpdates = new List<Id>();
        Id singleContactToUpdate = null;
        
        if (triggerNew.size() == 1){
            if (triggerNew[0].Override_Mailing_Address_Information__c == FALSE){
                singleContactToUpdate = triggerNew[0].Id;
            }
        } else {
            for (Contact cNew : triggerNew) {
                if (cNew.Override_Mailing_Address_Information__c == FALSE){
                    ContactIdsThatNeedUpdates.add(cNew.Id);
                }
            }
        }
        
        /*
        if (TriggerContext == 'afterinsert'){
            if (triggerNew.size() == 1){
                if (triggerNew[0].Override_Mailing_Address_Information__c   == FALSE){
                    singleContactToUpdate = triggerNew[0].Id;
                }
            } else {
                for (Contact cNew : triggerNew) {
                    if (cNew.Override_Mailing_Address_Information__c   == FALSE){
                        ContactIdsThatNeedUpdates.add(cNew.Id);
                    }
                }
            }
        } else if (triggerContext == 'afterupdate') {
            if (triggerNew.size() == 1) {
                singleContactToUpdate = triggerNew[0].Id;
            } else {
                for (Contact c : triggerNew){
                    if(c.Override_Mailing_Address_Information__c   == FALSE){
                        ContactIdsThatNeedUpdates.add(c.Id);
                    }
                }
            }
        }
        */
        
        if (null != singleContactToUpdate) {
            if (triggerNewMap.get(singleContactToUpdate).id !=null)
                GoogleIntegrationHelper.UpdateContactFieldsFromGoogleAsync(singleContactToUpdate);
        } else if (!ContactIdsThatNeedUpdates.isEmpty()){
            if ([SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'].size()<5){
                Database.executeBatch(new BatchGoogleIntegrationHelper(ContactIdsThatNeedUpdates, 'Contact'),10);
            }
        }
    }
}