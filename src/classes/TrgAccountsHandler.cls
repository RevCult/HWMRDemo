public with sharing class TrgAccountsHandler {
    private static boolean run = true;
    
    public static boolean runOnce(){
        if (run) {
            run=false;
            return true;
        } else {
            return run;
        }
    }

    public static void UpdateDataFromGoogle(String triggerContext, List<Account> triggerNew, Map<Id, Account> triggerNewMap, List<Account> triggerOld, Map<Id, Account> triggerOldMap) {
        List<Id> AccountIdsThatNeedUpdates = new List<Id>();
        Id singleAccountToUpdate = null;

        	if (triggerNew.size() == 1){
                if (triggerNew[0].Override_Billing_Address_Information__c == FALSE){
                    singleAccountToUpdate = triggerNew[0].Id;
                }
            } else {
                for (Account aNew : triggerNew) {
                    if (aNew.Override_Billing_Address_Information__c == FALSE){
                        AccountIdsThatNeedUpdates.add(aNew.Id);
                    }
                }
            }
        
        /*if (TriggerContext == 'afterinsert'){
            if (triggerNew.size() == 1){
                if (triggerNew[0].Override_Billing_Address_Information__c == FALSE){
                    singleAccountToUpdate = triggerNew[0].Id;
                }
            } else {
                for (Account aNew : triggerNew) {
                    if (aNew.Override_Billing_Address_Information__c == FALSE){
                        AccountIdsThatNeedUpdates.add(aNew.Id);
                    }
                }
            }
        } else if (triggerContext == 'afterupdate') {
            if (triggerNew.size() == 1) {
                if (triggerNew[0].Override_Billing_Address_Information__c == FALSE){
                    singleAccountToUpdate = triggerNew[0].Id;
                }
            } else {
                for (Account a : triggerNew){
                    if(a.Override_Billing_Address_Information__c == FALSE){
                        AccountIdsThatNeedUpdates.add(a.Id);
                    }
                }
            }
        }*/
        
        if (null != singleAccountToUpdate) {
            if (triggerNewMap.get(singleAccountToUpdate).id !=null)
                GoogleIntegrationHelper.UpdateAccountFieldsFromGoogleAsync(singleAccountToUpdate);
        } else if (!AccountIdsThatNeedUpdates.isEmpty()){
            if ([SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'].size()<5){
                Database.executeBatch(new BatchGoogleIntegrationHelper(AccountIdsThatNeedUpdates, 'Account'),10);
            }
        }
    }
}