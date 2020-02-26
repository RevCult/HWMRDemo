public with sharing class TrgProjectUpdateRequestsHandler {
	/**
		- this method will analyze the Project Update Requests received and if they're in an approved state [and weren't before], it'll go update the corresponding
		- Project and also go find any Plan Update Requests for the Project Update Request and approve them, which will trigger the Plan Update Request trigger to
		- update the associated Plans...  Sounds more complicated than it is. :)
	*/
	public static void ApproveProjectUpdateRequests(String triggerContext, List<Project_Update_Request__c> triggerNew, Map<Id, Project_Update_Request__c> triggerNewMap, List<Project_Update_Request__c> triggerOld, Map<Id, Project_Update_Request__c> triggerOldMap) {
		Set<Id> projectIdsToUpdate = new Set<Id>();
		Map<Id, Project__c> mapProjectsToUpdate = new Map<Id, Project__c>();
		List<Project__c> finalListProjectsToUpdate = new List<Project__c>();
		
		Map<Id, Project_Update_Request__c> mapPURsToApprove = new Map<Id, Project_Update_Request__c>();
		// check each project update request to see if it's approved now and wasn't before
		for (Project_Update_Request__c pur : triggerNew) {
			if (pur.Update_Request_Status__c == 'Approved') {
				if (Trigger.isInsert) {
					mapPURsToApprove.put(pur.Id, pur);
					projectIdsToUpdate.add(pur.Project__c);
				} else if (Trigger.isUpdate) {
					if (triggerOldMap.get(pur.Id).Update_Request_Status__c != 'Approved') {
						mapPURsToApprove.put(pur.Id, pur);
						projectIdsToUpdate.add(pur.Project__c);
					}
				}
			}
		}
		// let's go find all the Plan Update Requests that are associated to the PURs we're going to approve!
		List<Plan_Update_Request__c> allPLURsForPURsToApprove = new List<Plan_Update_Request__c>();
		allPLURsForPURsToApprove = [SELECT Id, Plan__c, Project_Update_Request__c, Update_Request_Status__c FROM Plan_Update_Request__c WHERE Project_Update_Request__c IN :mapPURsToApprove.keyset()];
		// now let's make sure we know which Plan Update Requests are for which Project Update Requests!
		Map<Id, List<Plan_Update_Request__c>> mapPURsToPLURs = new Map<Id, List<Plan_Update_Request__c>>();
		if (!allPLURsForPURsToApprove.isEmpty()) {
			for (Plan_Update_Request__c plur : allPLURsForPURsToApprove) {
                system.debug('tPURH PLUR iD ' + plur.iD);
				plur.Update_Request_Status__c = 'Approved';
				if (!mapPURsToPLURs.containsKey(plur.Project_Update_Request__c)) {
					mapPURsToPLURs.put(plur.Project_Update_Request__c, new Plan_Update_Request__c[]{plur});
                    system.debug('tPURH not mapped PLUR ' + plur.iD);
				} else {
					mapPURsToPLURs.get(plur.Project_Update_Request__c).add(plur);
                    system.debug('tPURH mapped PLUR ' + plur.iD);
				}
			}
		}
		// get the projects so we can set their fields:
		mapProjectsToUpdate = new Map<Id, Project__c>([SELECT Id, 
																Assessments__c,
																Assessments_Dollar__c,
																Assessment_Description__c,
								                                Do_Not_Call__c,
								                                Email_Special__c,
								                                FIPS__c,
								                                HOA__c,
								                                HOA_2__c,
								                                Location__Longitude__s,
								                                Location__Latitude__s,
								                                Lot_Dimension__c,
								                                Master_Plan__c,
								                                Max_Price__c,
								                                Max_Unit_Size__c,
								                                Min_Price__c,
								                                Min_Unit_Size__c,
								                                Open_Date__c,
								                                Phone_Number__c,
								                                Alternate_Phone_Number__c,
								                                Sales_Office_Notes__c,
								                                Product_Type__c,
								                                Project_Characteristics__c,
								                                Region_ID__c,
								                                Sales_and_Marketing_Firm__c,
								                                Sales_Person_2__c,
								                                Sales_Person_Name__c,
								                                Sales_Rate__c,
								                                Sold_Out_Date__c,
								                                Status__c,
								                                Total_Remaining__c,
								                                Total_Units_Planned__c,
								                                Multiple_Attempts__c,
								                                Sales_Rate_Validated__c,
								                                Closing_data__c,
								                                Total_Units_Sold__c,
								                                Typical_Lot_Size__c,
								                                Website__c,
								                                Last_Updated_Date_Price__c,
                                                       			Last_Price_Update_display__c,
								                                Last_Update_User_Price__c,
								                                Last_Updated_Date_Sales__c,
								                                Last_Update_User_Sales__c,
								                                Last_Updated_Date_To_Be_Built_Incentive__c,
								                                Last_Updated_Date_Quick_Move_Incentives__c,
								                                Last_Updated_Date_Broker_Co_Cop_Incenti__c,
								                                Prices_Verified__c,
								                                Sales_Verified__c,
								                                Meyers_Notes__c,
								                                HOA_Description__c,
								                                Monthly_HOA_SF__c,
								                                //Incentive_Options__c,
                                                       			Incentive_Options__c,
                                                       			To_Be_Built_Incentives__c,
                                                                To_Be_Built_Incentives_Unchanged__c,
                                                                Quick_Move_In_Incentives__c,
                                                                Quick_Move_In_Incentives_Unchanged__c,
                                                                Broker_Co_Op_Incentives__c,
                                                                Broker_Co_Op_Incentives_Unchanged__c,
                                                                Meyers_Notes_internal__c,
																Units_under_construction__c,
																Unsold_units_under_construction__c,
                                                       			No_Of_Times_Auto_Approved__c
												FROM Project__c WHERE Id IN :projectIdsToUpdate]);       
		// go set the project values from the update request
        for (Project_Update_Request__c theProjectUpdateRequest : mapPURsToApprove.values()) {
        	Project__c theProject = mapProjectsToUpdate.get(theProjectUpdateRequest.Project__c);
        	if (theProject != null) {
		        theProject.Do_Not_Call__c = theProjectUpdateRequest.Do_Not_Call__c;
		        theProject.Email_Special__c = theProjectUpdateRequest.Email_Special__c;
		        theProject.FIPS__c = theProjectUpdateRequest.FIPS__c;
		        theProject.HOA__c = theProjectUpdateRequest.HOA__c;
		        theProject.Location__Longitude__s = theProjectUpdateRequest.Location__Longitude__s;
		        theProject.Location__Latitude__s = theProjectUpdateRequest.Location__Latitude__s;
		        theProject.Master_Plan__c = theProjectUpdateRequest.Master_Plan__c;
		        theProject.Max_Price__c = theProjectUpdateRequest.Max_Price__c;
		        theProject.Max_Unit_Size__c = theProjectUpdateRequest.Max_Unit_Size__c;
		        theProject.Min_Price__c = theProjectUpdateRequest.Min_Price__c;
		        theProject.Min_Unit_Size__c = theProjectUpdateRequest.Min_Unit_Size__c;
		        theProject.Open_Date__c = theProjectUpdateRequest.Open_Date__c;
		        theProject.Phone_Number__c = theProjectUpdateRequest.Phone_Number__c;
		        theProject.Email_Special__c = theProjectUpdateRequest.Email_Special__c;
		        theProject.Alternate_Phone_Number__c = theProjectUpdateRequest.Alternate_Phone_Number__c;
		        theProject.Sales_Office_Notes__c = theProjectUpdateRequest.Sales_Office_Notes__c;
		        theProject.Product_Type__c = theProjectUpdateRequest.Product_Type__c;
		        theProject.Project_Characteristics__c = theProjectUpdateRequest.Project_Characteristics__c;
		        theProject.Region_ID__c = theProjectUpdateRequest.Region_ID__c;
		        theProject.Sales_and_Marketing_Firm__c = theProjectUpdateRequest.Sales_and_Marketing_Firm__c;
		        theProject.Sales_Person_2__c = theProjectUpdateRequest.Sales_Person_2__c;
		        theProject.Sales_Person_Name__c = theProjectUpdateRequest.Sales_Person_Name__c;
		        theProject.Sales_Rate__c = theProjectUpdateRequest.Sales_Rate__c;
		        theProject.Sold_Out_Date__c = theProjectUpdateRequest.Sold_Out_Date__c;
		        theProject.Status__c = theProjectUpdateRequest.Status__c;
		        theProject.Total_Remaining__c = theProjectUpdateRequest.Total_Remaining__c;
		        theProject.Total_Units_Planned__c = theProjectUpdateRequest.Total_Units_Planned__c;
                theProject.Sales_Rate_Validated__c = theProjectUpdateRequest.Sales_Rate_Validated__c;
                theProject.Multiple_Attempts__c = theProjectUpdateRequest.Multiple_Atempts__c;
                theProject.Closing_data__c = theProjectUpdateRequest.Sales_based_on_closing_data__c;
		        theProject.Total_Units_Sold__c = theProjectUpdateRequest.Total_Units_Sold__c;
		        theProject.Typical_Lot_Size__c = theProjectUpdateRequest.Typical_Lot_Size__c;
		        theProject.Website__c = theProjectUpdateRequest.Website__c;
		        theProject.Prices_Verified__c = theProjectUpdateRequest.Prices_Verified__c;
		        theProject.Sales_Verified__c = theProjectUpdateRequest.Sales_Verified__c;
		        theProject.Meyers_Notes__c = theProjectUpdateRequest.Meyers_Notes__c;
		        theProject.Assessments__c = theProjectUpdateRequest.Assessments__c;
		        theProject.Assessments_Dollar__c = theProjectUpdateRequest.Assessments_Dollar__c;
		        theProject.Assessment_Description__c = theProjectUpdateRequest.Assessment_Description__c;
		        theProject.HOA_2__c = theProjectUpdateRequest.HOA_2__c;
		        theProject.Lot_Dimension__c = theProjectUpdateRequest.Lot_Dimension__c;
		        theProject.HOA_Description__c = theProjectUpdateRequest.HOA_Description__c;
		        theProject.Monthly_HOA_SF__c = theProjectUpdateRequest.Monthly_HOA_SF__c;
		        theProject.Incentive_Options__c = theProjectUpdateRequest.Incentive_Options__c;
                theProject.To_Be_Built_Incentives__c = theProjectUpdateRequest.To_Be_Built_Incentives__c;
                theProject.Quick_Move_In_Incentives__c = theProjectUpdateRequest.Quick_Move_In_Incentives__c;
                theProject.Broker_Co_Op_Incentives__c = theProjectUpdateRequest.Broker_Co_Op_Incentives__c;
                theProject.To_Be_Built_Incentives_Unchanged__c = theProjectUpdateRequest.To_Be_Built_Incentives_Unchanged__c;               
                theProject.Quick_Move_In_Incentives_Unchanged__c = theProjectUpdateRequest.Quick_Move_In_Incentives_Unchanged__c;
                theProject.Broker_Co_Op_Incentives_Unchanged__c = theProjectUpdateRequest.Broker_Co_Op_Incentives_Unchanged__c;
                theProject.Meyers_Notes_internal__c = theProjectUpdateRequest.Meyers_Notes_internal__c;
                theProject.Units_under_construction__c = theProjectUpdateRequest.Units_under_construction__c;
				theProject.Unsold_units_under_construction__c = theProjectUpdateRequest.Unsold_units_under_construction__c;
                theProject.No_Of_Times_Auto_Approved__c = theProjectUpdateRequest.No_Of_Times_Auto_Approved__c;
				finalListProjectsToUpdate.add(theProject);
			}
        }
		// finally - let's update all the projects:
		update finalListProjectsToUpdate;
		// also - update the Plan Update Requests so they can update their Plans:
		update allPLURsForPURsToApprove;
	}
}