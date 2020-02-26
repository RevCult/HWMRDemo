public class AdBookIntegration {
        
    // Set the AdBook [AB Contact Type] based on the parent Accounts [Media Account Type]
    public void handleContactTrigger(List<Contact> triggerNew) {
        for(Contact c : triggerNew) {
            if(c.Media_Account_Type__c == 'ADVERTISER') {
                appendContactType(c, 'Client');
            } else if(c.Media_Account_Type__c == 'Agency') {
                appendContactType(c, 'Agency');
            }
        }
    }
    
    // Called from FC_OpportunityTrigger on insert/update of an Opportunity
    public static void handleOpportunityTriggerPopulateFields(Opportunity oldOpportunityRecord, Opportunity newOpportunityRecord){
        //System.debug('handleOpportunityTriggerPopulateFields() ' + newOpportunityRecord);
        
        // Copy the local Billing Contact custom field to the AdBook Billing Contact Id
        if(oldOpportunityRecord == null || oldOpportunityRecord.Billing_Contact__c != newOpportunityRecord.Billing_Contact__c) {
            newOpportunityRecord.AB2__ABBillingContact__c = newOpportunityRecord.Billing_Contact__c;
        }
        
        // Copy the Double Click custom field to the AdBook Agency Name
        if(oldOpportunityRecord == null || oldOpportunityRecord.Agency_Name__c != newOpportunityRecord.Agency_Name__c) {
            // The field is a Lookup(Account), so it doesn't need to be converted to the Account.Name
            newOpportunityRecord.AB2__AB_Agency__c = newOpportunityRecord.Agency_Name__c;
        }
    }
    
    public static void handleOpportunityLineItemTriggerPopulateFields(OpportunityLineItem opportunityLineItemRecord) {
        // Create DateTimes in the current users TimeZone at midnight so that they appear to be on the same Date in the UI.
        // Note, if there are users in various timezones they will naturally see different values.
        
        // Copy the value from the AB2__ABStartDate__c (Date) to HW_Line_Item_Start_Date__c (Date/Time)
        // Allow for the current users timezone
        if(opportunityLineItemRecord.AB2__ABStartDate__c != null) {
            opportunityLineItemRecord.HW_Line_Item_Start_Date__c = 
                DateTime.newInstance(opportunityLineItemRecord.AB2__ABStartDate__c.year(), 
                                     opportunityLineItemRecord.AB2__ABStartDate__c.month(), 
                                     opportunityLineItemRecord.AB2__ABStartDate__c.day(),
                                     0,0,0);
        }
        
        // Copy the value from the AB2__ABEndDate__c (Date) to HW_Line_Item_End_Date__c (Date/Time)
        if(opportunityLineItemRecord.AB2__ABEndDate__c != null) {
            opportunityLineItemRecord.HW_Line_Item_End_Date__c = 
                DateTime.newInstance(opportunityLineItemRecord.AB2__ABEndDate__c.year(), 
                                     opportunityLineItemRecord.AB2__ABEndDate__c.month(), 
                                     opportunityLineItemRecord.AB2__ABEndDate__c.day(),
                                     0,0,0);
        }
    }
    
    /**
     * Called when the refresh from AdBook process is completed.
     * Check for changes from AdBook and update mapped fields.
     */
    @future
    public static void updateOpportunityDetails(Id oppId) {
        updateOpportunityDetailsSync(oppId);
    }
        
    /**
     * Called when the refresh from AdBook process is completed.
     * Check for changes from AdBook and update mapped fields.
     */
    public static void updateOpportunityDetailsSync(Id oppId) {
        List<Opportunity> opps = [Select Id, AB2__ABBillingContact__c, Billing_Contact__c, AB2__AB_Agency__c, Agency_Name__c from Opportunity where Id = :oppId];
        if(opps.isEmpty()) {
            System.debug(LoggingLevel.Error, 'Unable to find Opportunity with ID: ' + oppId);
            return;
        }
        Opportunity opp = opps[0];
        
        boolean updatedRequired = false;
        if(opp.Agency_Name__c != opp.AB2__AB_Agency__c) {
            opp.Agency_Name__c = opp.AB2__AB_Agency__c;
            updatedRequired = true;
        }
        
        if(opp.Billing_Contact__c != opp.AB2__ABBillingContact__c) {
            opp.Billing_Contact__c = opp.AB2__ABBillingContact__c;
            updatedRequired = true;
        }
        
        if(updatedRequired) {
            update opp;
        }
    }
    
    private void appendContactType(Contact c, string typeToAppend) {
        if(c == null) { return; }
        
        if(string.isBlank(c.AB2__AB_Contact_Type_new__c)) {
            c.AB2__AB_Contact_Type_new__c = typeToAppend;    
        } else if (c.AB2__AB_Contact_Type_new__c.contains(typeToAppend)) {
            //Noop - already present
        } else {
            // Merge
            c.AB2__AB_Contact_Type_new__c += ';' + typeToAppend;
        }
        
    }
}