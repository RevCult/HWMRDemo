public with sharing class trgZondaUsersHandler { 
    
    public static void resetPasswordIfNeeded(List<Zonda_User__c> triggerNew, Map<Id, Zonda_User__c> triggerOldMap) {
        Context.isTriggerContext = TRUE;
        for (Zonda_User__c zu : triggerNew) {
            if ((Trigger.isInsert && zu.Reset_Password__c == TRUE) || (Trigger.isUpdate && zu.Reset_Password__c == TRUE && triggerOldMap.get(zu.Id).Reset_Password__c == FALSE)) {
                // generate password
                String newPassword = generatePassword();
                // set into the plain text AND password fields
                zu.Password__c = newPassword;
                zu.Plain_Text_Password__c = newPassword;
                zu.Password_Sent_Date__c = Datetime.now();
                //zu.Reset_Password__c = false;
                // done
            }
        }
    }

    /**
        SFDC-52
        Accounting has requested that the Max Last Login Date and the Max App Version be added to the contact 
        so that it can be displayed on the related list on the account. Can this information be used to assist 
        with preventing the contact from being deleted and/or the email from being updated?
    */
    public static void updateContactMaxValues(List<Zonda_User__c> triggerNew) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for (Zonda_User__c zu : triggerNew) {
            contactIds.add(zu.Contact__c);
        }
        if (!contactIds.isEmpty()) {
            Map<Id, Contact> contactsFromZondaUsers = new Map<Id, Contact>([SELECT Id, Last_Login_Date_Time__c, Max_App_Version__c, Zonda_User_Status__c, Zonda_Role__c, Zonda_Pro__c, Zonda_User_Group__c, Zonda_User_Group_RSD__c FROM Contact WHERE Id IN :contactIds]);
            for (Zonda_User__c zu : triggerNew) {
                Boolean somethingChanged = false;
                if (null != zu.Contact__c && contactsFromZondaUsers.containsKey(zu.Contact__c)) {
                    Contact c = contactsFromZondaUsers.get(zu.Contact__c);
                    if (getNumericString(c.Max_App_Version__c) < getNumericString(zu.App_Version__c) ) {
                        c.Max_App_Version__c = zu.App_Version__c;
                        somethingChanged = true;
                    }
                    if (c.Last_Login_Date_Time__c == null || c.Last_Login_Date_Time__c < zu.Last_Login_Date_Time__c) {
                        c.Last_Login_Date_Time__c = zu.Last_Login_Date_Time__c;
                        somethingChanged = true;
                    }
                    // Passing values to Contact for Last Login Report for RSDs
                    // Role 
                    if (c.Zonda_User_Status__c == null || c.Zonda_User_Status__c != zu.Status__c) {
                        c.Zonda_User_Status__c = zu.Status__c;
                        somethingChanged = true;
                    }
                    // Role 
                    if (c.Zonda_Role__c == null || c.Zonda_Role__c != zu.Role_s__c) {
                        c.Zonda_Role__c = zu.Role_s__c;
                        somethingChanged = true;
                    }
                    // Pro 
                    if (c.Zonda_Pro__c == null || c.Zonda_Pro__c != zu.Zonda_Pro__c) {
                        c.Zonda_Pro__c = zu.Zonda_Pro__c;
                        somethingChanged = true;
                    }
                    //User Group Name
                    if (c.Zonda_User_Group__c == null || c.Zonda_User_Group__c != zu.User_Group_read_only__c) {
                        c.Zonda_User_Group__c = zu.User_Group_read_only__c;
                        somethingChanged = true;
                    }
                    //User Group Name
                    if (c.Zonda_User_Group_RSD__c == null || c.Zonda_User_Group_RSD__c != zu.RSD_Email__c) {
                        c.Zonda_User_Group_RSD__c = zu.RSD_Email__c;
                        somethingChanged = true;
                    }    
                    if (somethingChanged) {
                        contactsToUpdate.put(c.Id, c);
                    }
                }
            }
            if (!contactsToUpdate.values().isEmpty()) {
                update contactsToUpdate.values();
            }
        }
    }

    private static String generatePassword() {
        return String.valueOf(Math.random()).replace('0','').substring(2, 7);
    }

    private static String getNumericString(String s) {
        if (s != null) {
            return s.replaceAll('[^0-9]', '');
        } else {
            return '';
        }
    }
}