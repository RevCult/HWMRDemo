public with sharing class TrgLandListingsHandler {
	public static void updateShortUrlFromGoogle(String triggerContext, List<Land_Listing__c> triggerNew, Map<Id, Land_Listing__c> triggerNewMap, List<Land_Listing__c> triggerOld, Map<Id, Land_Listing__c> triggerOldMap) {
		List<Id> listingIdsThatNeedUpdates = new List<Id>();
		Id singleListingToUpdate = null;
		
		if (triggerNew.size() == 1) {
			singleListingToUpdate = triggerNew[0].Id;
		} else {
			listingIdsThatNeedUpdates.addAll(triggerNewMap.keyset());
		}
		
		if (null != singleListingToUpdate) {
			GoogleIntegrationHelper.UpdateLandListingFieldsFromGoogleAsync(singleListingToUpdate);
		} else if (!listingIdsThatNeedUpdates.isEmpty()) {
			// queue up BatchGoogleIntegrationHelper batch and executeBatch with a scope size of 10
			if ([SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'].size()<5) {
				Database.executeBatch(new BatchGoogleIntegrationHelper(listingIdsThatNeedUpdates, 'Land_Listing__c'), 10);
			}
		}
	}
}