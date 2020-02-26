public with sharing class TrgPlanUpdateRequestsHandler {
	/**
	// 		this method will analyze the Plan Update Requests received and if they're in an approved state [and weren't before], it'll go update the corresponding
	// 		Plans -- this is very likely to be called as part of a cascading update when a Project Update Request gets approved
	*/
	public static void ApprovePlanUpdateRequests(String triggerContext, List<Plan_Update_Request__c> triggerNew, Map<Id, Plan_Update_Request__c> triggerNewMap, List<Plan_Update_Request__c> triggerOld, Map<Id, Plan_Update_Request__c> triggerOldMap) {
		Set<Id> planIdsToUpdate = new Set<Id>();
		Map<Id, Plan__c> mapPlanIdsToPlans = new Map<Id, Plan__c>();
		List<Plan__c> plansToUpdate = new List<Plan__c>();
		Set<Id> planIdsGettingUpdated = new Set<Id>();
		List<Plan_Update_Request__c> plursToApprove = new List<Plan_Update_Request__c>();
		// check each plan update request to see if it's approved now and wasn't before
		for (Plan_Update_Request__c plur : triggerNew) {
			if (plur.Update_Request_Status__c == 'Approved') {
				if (Trigger.isInsert) {
					plursToApprove.add(plur);
					planIdsToUpdate.add(plur.Plan__c);
				} else if (Trigger.isUpdate) {
					if (triggerOldMap.get(plur.Id).Update_Request_Status__c != 'Approved') {
						plursToApprove.add(plur);
						planIdsToUpdate.add(plur.Plan__c);
					}
				}
			}
		}
		// get all the plans in a map
		mapPlanIdsToPlans = new Map<Id, Plan__c>([SELECT Id, Num_of_Beds__c, Off_Market__c, Num_of_Baths__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, Name, Price__c, Square_Footage__c, Plan_Notes__c, Num_of_Floors__c, Garage__c, Price_Unchanged__c FROM Plan__c WHERE Id IN :planIdsToUpdate]);
		// loop through the plan update requests and set the fields on the plans with the updated values, then add them to plansToUpdate
		for (Plan_Update_Request__c plur : plursToApprove) {
			if (null != mapPlanIdsToPlans.get(plur.Plan__c)) {
				Plan__c thePlan = mapPlanIdsToPlans.get(plur.Plan__c);
				thePlan.Num_of_Baths__c = plur.Num_of_Baths__c;
				thePlan.Num_of_Full_Baths__c = plur.Num_of_Full_Baths__c;
				thePlan.Num_of_Half_Baths__c = plur.Num_of_Half_Baths__c;
				thePlan.Num_of_Beds__c = plur.Num_of_Beds__c;
				thePlan.Price__c = plur.Price__c;
				thePlan.Square_Footage__c = plur.Square_Footage__c;
				thePlan.Name = plur.Plan_Name__c;
				thePlan.Plan_Notes__c = plur.Plan_Notes__c;
				thePlan.Num_of_Floors__c = plur.Num_of_Floors__c;
				thePlan.Garage__c = plur.Garage__c;
				thePlan.Price_Unchanged__c = plur.Price_Unchanged__c;
				thePlan.Display_in_Zonda__c = plur.Display_in_Zonda__c;
				thePlan.Off_Market__c = plur.Off_Market__c;
				//thePlan.Display_in_Zonda__c = true;
				if (!planIdsGettingUpdated.contains(thePlan.Id)) {
					planIdsGettingUpdated.add(thePlan.Id);
					plansToUpdate.add(thePlan);
				}
			}
		}
		// update the plansToUpdate collection
		update plansToUpdate;
	}
}