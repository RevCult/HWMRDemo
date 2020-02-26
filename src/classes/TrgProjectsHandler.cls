public with sharing class TrgProjectsHandler {
	private static boolean run = true;

	public static boolean runOnce(){
	if (run) {
		run=false;
		return true;
	} else {
		return run;
	}
	}

	public static void SetAccountFromBuilder(String triggerContext, List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap) {
		system.debug('inside SetAccountFromBuilder; triggerNew = '+triggerNew);
		Set<Id> builderIdsFromTrigger = new Set<Id>();
		for (Project__c project : triggerNew) {
			if (null != project.Builder__c) {
			builderIdsFromTrigger.add(project.Builder__c);
			}
		}

		if (!builderIdsFromTrigger.isEmpty()){
			Map<Id, Builder__c> mapBuilders = new Map<Id, Builder__c>([SELECT Id, Account__c FROM Builder__c WHERE Id IN :builderIdsFromTrigger]);

			for (Project__c project : triggerNew) {
				if (null != mapBuilders.get(project.Builder__c)) {
					project.Account__c = mapBuilders.get(project.Builder__c).Account__c;
				}
			}
		}

		for(Project__c project : triggerNew){
			if(project.ZIC_Date__c != null && project.id != null){
			//if(project.id != null){
				for(Project__c projectOld : triggerOld){

				if(project.Update_Cycle__c != projectOld.Update_Cycle__c){
                    if (project.Last_Review__c != null) {
                        project.ZIC_Date__c = date.valueOf(project.Last_Review__c.addDays(integer.valueOf(project.Update_Cycle__c))); 
                    } else {
                        project.ZIC_Date__c = date.valueOf(project.Last_Updated_Date_Sales__c.addDays(integer.valueOf(project.Update_Cycle__c))); 
                    }        			 
				} else{
                        list<Project_Update_Request__c> po = [Select Update_Request_Status__c, Project__c, Project_Name__c, Name, LastModifiedDate, Id From Project_Update_Request__c where Project__c=:project.id and Update_Request_Status__c='approved' order by LastModifiedDate desc limit 1];
                        if(po.size()>0 && project.Update_Cycle__c =='0'||project.Update_Cycle__c =='1'){
                                      
                            project.ZIC_Date__c = date.valueOf(po[0].LastModifiedDate).addDays(integer.valueOf(project.Update_Cycle__c));
                        }
                    } 
				}
			}
		}
	}
    
    
	public static void UpdateDataFromGoogle(String triggerContext, List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap) {
        List<Id> projectIdsThatNeedUpdates = new List<Id>();
        Id singleProjectToUpdate = null;
        // figure out which records actually need updates [website has changed or Location has changed], then hand off to an asynchronous method that calls google and then updates the records
        if (triggerContext == 'afterinsert') {
          	if (triggerNew.size() == 1) {
            	if (triggerNew[0].Override_Location_Information__c == FALSE) {
              		singleProjectToUpdate = triggerNew[0].Id;
				}
      		} else {
				for (Project__c p : triggerNew) {
					if (p.Override_Location_Information__c == FALSE) {
						projectIdsThatNeedUpdates.add(p.Id);
					}
				}
			}
            
		}  else if (triggerContext == 'afterupdate') {
				if (triggerNew.size() == 1) {
					singleProjectToUpdate = triggerNew[0].Id;
				} else {
					for (Project__c newProject : triggerNew) {
					if (newProject.Website__c != triggerOldMap.get(newProject.Id).Website__c || 
					  newProject.Location__Latitude__s != triggerOldMap.get(newProject.Id).Location__Latitude__s || 
					  newProject.Location__Longitude__s != triggerOldMap.get(newProject.Id).Location__Longitude__s) {
					if (newProject.Override_Location_Information__c == FALSE) {
						projectIdsThatNeedUpdates.add(newProject.Id);
					}
				}
				}
			}
		}
		if (null != singleProjectToUpdate) {
			if (triggerNewMap.get(singleProjectToUpdate).Override_Location_Information__c == FALSE)
			GoogleIntegrationHelper.UpdateProjectFieldsFromGoogleAsync(singleProjectToUpdate);
		} else if (!projectIdsThatNeedUpdates.isEmpty()) {
		// queue up BatchGoogleIntegrationHelper batch and executeBatch with a scope size of 10
			if ([SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'].size()<5) {
				Database.executeBatch(new BatchGoogleIntegrationHelper(projectIdsThatNeedUpdates), 10);
			}
		}
	}

	public static void UpdateAllActivePURsWhenProjectIsUpdated(String triggerContext, List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap) {
		// this is what we're doing here - getting some PUR records updated, so this collection will be used to track the ones that get changed:
		List<Project_Update_Request__c> pursToUpdate = new List<Project_Update_Request__c>();
		// get references to all PURs that are 'In Progress', 'Pending' or 'Review'
		Map<Id, Project_Update_Request__c> pursInProgress = new Map<Id, Project_Update_Request__c>([SELECT Id FROM Project_Update_Request__c WHERE Project__c IN :triggerNewMap.keyset() AND Update_Request_Status__c IN ('In Progress', 'Pending', 'Review')]);
		// if we actually have some "active" ones, let's do some work
		if (!pursInProgress.keySet().isEmpty()) {
		// get fully fleshed out records for all the active PURs
		List<Project_Update_Request__c> thePURs = BuilderProjectMgmtCmn.getProjectUpdateRequests(pursInProgress.keyset());
		// build a map so we know which PURs relate to which Projects
		Map<Id, List<Project_Update_Request__c>> mapProjectIdsToPURs = new Map<Id, List<Project_Update_Request__c>>();
		for (Project_Update_Request__c pur : thePURs) {
			if (!mapProjectIdsToPURs.containsKey(pur.Project__c)) {
				mapProjectIdsToPURs.put(pur.Project__c, new List<Project_Update_Request__c>());
			}
			mapProjectIdsToPURs.get(pur.Project__c).add(pur);
		}
		for (Project__c p : triggerNew) { // for each project that got updated
			if (mapProjectIdsToPURs.containsKey(p.Id)) { // if it has any active PURs
			List<Project_Update_Request__c> currProjectsPURs = mapProjectIdsToPURs.get(p.Id); // get the active PURs
			for (Project_Update_Request__c pur : currProjectsPURs) { // then for each of the PURs, update all the values from the Project
				Boolean updatePUR = false;
				Set<String> projectFieldNames = BuilderProjectMgmtCmn.getProjectFields();
				Set<String> purFieldNames = BuilderProjectMgmtCmn.getProjectUpdateRequestFields();
				Map<String, String> mapProjectFieldsToPurPreviousFields = BuilderProjectMgmtCmn.getProjectToPURFieldMap();
				system.debug('mapProjectFieldsToPurPreviousFields: '+mapProjectFieldsToPurPreviousFields);

				for (String fieldName : projectFieldNames) { // loop through all the project fields
					if (p.get(fieldName) != triggerOldMap.get(p.Id).get(fieldName)) { // if the field's value has actually changed in this update
						if (purFieldNames.contains(fieldName)) { // if the PUR has a field with the same name
							pur.put(fieldName, p.get(fieldName)); // set the value to the Project's value
							updatePUR = true;
						}
						if (mapProjectFieldsToPurPreviousFields.containsKey(fieldName)) { // if the PUR has a field called Previous_<fieldName>
							pur.put(mapProjectFieldsToPurPreviousFields.get(fieldName), p.get(fieldName)); // set the value to the Project's current value
							updatePUR = true;
							}
						}
					}
				if (updatePUR) pursToUpdate.add(pur);
				}
			}
		}
			// update the PURs
			system.debug('pursToUpdate: '+pursToUpdate);
			update pursToUpdate;
		}
	}

  public static void UpdateDataUsers(String triggerContext, List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap) {
    // if the Data_User__c field has been changed on a Project, go get all of the PURs that are In Progress and assign them to the new Data User
    List<Project_Update_Request__c> pursToUpdate = new List<Project_Update_Request__c>();
    Set<Id> projectsWhereDataUserChanged = new Set<Id>();
    for (Project__c project : triggerNew) {
      if (null != triggerOldMap.get(project.Id)) {
        if (triggerOldMap.get(project.Id).Data_User__c != project.Data_User__c) {
          projectsWhereDataUserChanged.add(project.Id);
        }
      }
    }
    pursToUpdate = [SELECT Id, Project__c, Data_User__c FROM Project_Update_Request__c WHERE Project__c IN :projectsWhereDataUserChanged AND Update_Request_Status__c = 'In Progress'];
    for (Project_Update_Request__c pur : pursToUpdate) {
      if (null != triggerNewMap.get(pur.Project__c)) {
        pur.Data_User__c = triggerNewMap.get(pur.Project__c).Data_User__c;
      }
    }
    update pursToUpdate;
  }

	public static void CreateProjectSnapshots(String triggerContext, List<Project__c> triggerNew, Map<Id, Project__c> triggerNewMap, List<Project__c> triggerOld, Map<Id, Project__c> triggerOldMap) {
		if (runOnce()) {
			List<Project_Snapshot__c> snapshotsToInsert = new List<Project_Snapshot__c>();
			for (Project__c project : triggerOld) {
        		// we only want to create a snapshot if something important has been updated:
                if (project.Total_Units_Sold__c != triggerNewMap.get(project.Id).Total_Units_Sold__c ||
                    project.Total_Units_Planned__c != triggerNewMap.get(project.Id).Total_Units_Planned__c ||
                    project.Min_Price__c != triggerNewMap.get(project.Id).Min_Price__c ||
                    project.Max_Price__c != triggerNewMap.get(project.Id).Max_Price__c ||
                    project.Min_Unit_Size__c != triggerNewMap.get(project.Id).Min_Unit_Size__c ||
                    project.Max_Unit_Size__c != triggerNewMap.get(project.Id).Max_Unit_Size__c ||
                   	project.To_Be_Built_Incentives__c != triggerNewMap.get(project.Id).To_Be_Built_Incentives__c ||
                    project.Quick_Move_In_Incentives__c != triggerNewMap.get(project.Id).Quick_Move_In_Incentives__c ||
                    project.Broker_Co_Op_Incentives__c != triggerNewMap.get(project.Id).Broker_Co_Op_Incentives__c ||
                    project.Units_under_construction__c != triggerNewMap.get(project.Id).Units_under_construction__c ||
                    project.Unsold_units_under_construction__c != triggerNewMap.get(project.Id).Unsold_units_under_construction__c ||
                    project.Lot_Dimension__c != triggerNewMap.get(project.Id).Lot_Dimension__c || 
                    project.Typical_Lot_Size__c != triggerNewMap.get(project.Id).Typical_Lot_Size__c ||
                    project.Sales_Verified__c != triggerNewMap.get(project.Id).Sales_Verified__c ||
                    project.Prices_Verified__c != triggerNewMap.get(project.Id).Prices_Verified__c ) {
          
					Project_Snapshot__c newSnap = new Project_Snapshot__c(
							Average_Plan_Price_calc__c = project.Average_Price_calc__c
						,   Builder__c = project.Builder__c
						,   City__c = project.City__c
						,   County__c = project.County__c
						,   Do_Not_Call__c = project.Do_Not_Call__c
						,   Email_Special__c = project.Email_Special__c
						,   FIPS__c = project.FIPS__c
						,   HOA__c = project.HOA__c
						,   Last_Updated_Date_Price__c = project.Last_Price_Update_display__c
						//,   Last_Updated_Date_Price__c = project.Last_Updated_Date_Price__c
						,   Last_Updated_Date_Sales__c = project.Last_Updated_Date_Sales__c
						,   Last_Update_User_Price__c = project.Last_Update_User_Price__c
						,   Last_Update_User_Sales__c = project.Last_Update_User_Sales__c
						,   Location__Latitude__s = project.Location__Latitude__s
						,   Location__Longitude__s = project.Location__Longitude__s
						,   Master_Plan__c = project.Master_Plan__c
						,   Max_Price__c = project.Max_Price__c
						,   Max_Price_calc__c = project.Max_Price_calc__c
						,   Max_Unit_Size__c = project.Max_Unit_Size__c
						,   Max_Unit_Size_calc__c = project.Max_Unit_Size_calc__c
						,   Meyers_Disposition__c = project.Meyers_Disposition__c
						,   Meyers_Notes__c = project.Meyers_Notes__c
						,   Min_Price__c = project.Min_Price__c
						,   Min_Price_calc__c = project.Min_Price_calc__c
						,   Min_Unit_Size__c = project.Min_Unit_Size__c
						,   Min_Unit_Size_calc__c = project.Min_Unit_Size_calc__c
						,   Open_Date__c = project.Open_Date__c
						,   Phone_Number__c = project.Phone_Number__c
						,   Product_Type__c = project.Product_Type__c
						//,   Alternate_Phone_Number__c = project.Alternate_Phone_Number__c
						,   Project__c = project.Id
						,   Project_Characteristics__c = project.Project_Characteristics__c
						,   Project_ID_Legacy__c = project.Project_ID_Legacy__c
						,   Region_ID__c = project.Region_ID__c
						,   Sales_and_Marketing_Firm__c = project.Sales_and_Marketing_Firm__c
						,   Sales_Person_2__c = project.Sales_Person_2__c
						,   Sales_Person_Name__c = project.Sales_Person_Name__c
						,   Sales_Rate__c = project.Sales_Rate_calc__c
						,   Sold_Out_Date__c = project.Sold_Out_Date__c
						,   State__c = project.State__c
						,   Status__c = project.Status__c
						,   Total_Remaining__c = project.Total_Remaining__c
						,   Total_Units_Planned__c = project.Total_Units_Planned__c
						,   Total_Units_Sold__c = project.Total_Units_Sold__c
						,   Typical_Lot_Size__c = project.Typical_Lot_Size__c
						,   Website__c = project.Website__c
                        ,	To_Be_Built_Incentives__c = project.To_Be_Built_Incentives__c
                    	,	Quick_Move_In_Incentives__c = project.Quick_Move_In_Incentives__c
                    	,	Broker_Co_Op_Incentives__c = project.Broker_Co_Op_Incentives__c
                    	,	Last_Updated_Date_To_Be_Built__c = project.Last_Updated_Date_To_Be_Built_Incentive__c
                    	,	Last_Updated_Date_Broker_Co_Op__c = project.Last_Updated_Date_Broker_Co_Cop_Incenti__c
                    	,	Last_Updated_Date_Quick_Move_In__c = project.Last_Updated_Date_Quick_Move_Incentives__c
						,   Units_under_construction__c = project.Units_under_construction__c
						,   Unsold_units_under_construction__c = project.Unsold_units_under_construction__c
						,   Last_Updated_Date_UUC__c = project.Last_Updated_Date_UUC__c
						,   Last_Updated_User_UUC__c = project.Last_Updated_User_UUC__c
						,   Last_Updated_Date_UnUUC__c = project.Last_Updated_Date_UnUUC__c
						,   Last_Updated_User_UnUUC__c = project.Last_Updated_User_UnUUC__c
					);
					snapshotsToInsert.add(newSnap);
				}
			}
			insert snapshotsToInsert;
		}
        
	}
}