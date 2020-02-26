public with sharing class TrgPlansHandler {
	public static void CreatePlanSnapshots(String triggerContext, List<Plan__c> triggerNew, Map<Id, Plan__c> triggerNewMap, List<Plan__c> triggerOld, Map<Id, Plan__c> triggerOldMap) {
		List<Plan_Snapshot__c> snapshotsToInsert = new List<Plan_Snapshot__c>();
		for (Plan__c oldPlan : triggerOld) {
			if (oldPlan.Price__c != triggerNewMap.get(oldPlan.Id).Price__c || triggerNewMap.get(oldPlan.Id).Price_Unchanged__c) {
				Plan_Snapshot__c newSnap = new Plan_Snapshot__c(
					Num_of_Baths__c = oldPlan.Num_of_Baths__c
				,	Num_of_Beds__c = oldPlan.Num_of_Beds__c
				,	Price__c = oldPlan.Price__c
				,	Plan__c = oldPlan.Id
				,	Project__c = oldPlan.Project__c
				,	Square_Footage__c = oldPlan.Square_Footage__c
					);
				snapshotsToInsert.add(newSnap);
			}
		}
		insert snapshotsToInsert;
	}
}