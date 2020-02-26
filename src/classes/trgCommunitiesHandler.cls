public class trgCommunitiesHandler {
    public static void UpdateDataFromGoogle(String triggerContext, List<Community__c> triggerNew, Map<Id, Community__c> triggerNewMap, List<Community__c> triggerOld, Map<Id, Community__c> triggerOldMap) {
        List<Id> CommunityIdsThatNeedUpdates = new List<Id>();
        Id singleCommunityToUpdate = null;
        // figure out which records actually need updates [website has changed or Location has changed], then hand off to an asynchronous method that calls google and then updates the records
        if (triggerContext == 'afterinsert') {
            if (triggerNew.size() == 1) {
                if (triggerNew[0].Override_Location_Information__c == FALSE) {
                    singleCommunityToUpdate = triggerNew[0].Id;
                }
            } else {
                for (Community__c comm : triggerNew) {
                    if (comm.Override_Location_Information__c == FALSE) {
                        CommunityIdsThatNeedUpdates.add(comm.Id);
                    }
                }
            }
        }  else if (triggerContext == 'afterupdate') {
            if (triggerNew.size() == 1) {
                singleCommunityToUpdate = triggerNew[0].Id;
            } else {
                for (Community__c newCommunity : triggerNew) {
                    if (newCommunity.Override_Location_Information__c == FALSE) {
                        CommunityIdsThatNeedUpdates.add(newCommunity.Id);
                    }
                }
            }
        }
        if (null != singleCommunityToUpdate) {
            if (triggerNewMap.get(singleCommunityToUpdate).Override_Location_Information__c == FALSE)
                GoogleIntegrationHelper.UpdateCommunityFieldsFromGoogleAsync(singleCommunityToUpdate);
        } else if (!CommunityIdsThatNeedUpdates.isEmpty()) {
            // queue up BatchGoogleIntegrationHelper batch and executeBatch with a scope size of 10
            if ([SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'].size()<5) {
                Database.executeBatch(new BatchGoogleIntegrationHelper(CommunityIdsThatNeedUpdates), 10);
            }
        }
    }
}