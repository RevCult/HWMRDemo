public with sharing class TrgBuildersHandler {
	public static void AssociateProjectsToAccounts(String triggerContext, List<Builder__c> triggerNew, Map<Id, Builder__c> triggerNewMap, List<Builder__c> triggerOld, Map<Id, Builder__c> triggerOldMap) {
		List<Project__c> allProjectsFromTrigger = new List<Project__c>();
		List<Project__c> projectsToUpdate = new List<Project__c>();
		Map<Id, List<Project__c>> mapBuilderToProjects = new Map<Id, List<Project__c>>();

		if (null != triggerNew && !triggerNew.isEmpty()) { // we're updating or inserting or undeleting builders, so let's go get all the projects and set the account association
			// get all the projects for all of the builders involved
			allProjectsFromTrigger = [SELECT Id, Builder__c, Account__c FROM Project__c WHERE Builder__c IN :triggerNewMap.keyset()];
			// put them in the map so we can get them easily later
			for (Project__c p : allProjectsFromTrigger) {
				// if the map doesn't already have this builder
				if (!mapBuilderToProjects.containsKey(p.Builder__c)) {
					// add it with a new list of projects
					mapBuilderToProjects.put(p.Builder__c, new List<Project__c>());
					// then throw this project on the pile
					mapBuilderToProjects.get(p.Builder__c).add(p);
				} else { // the map already has this builder, so just add this one to the list
					mapBuilderToProjects.get(p.Builder__c).add(p);
				}
			}
			// now for each builder in the trigger
			for (Builder__c theBuilder : triggerNew) {
				// if it has an account value assigned
				if (null != theBuilder.Account__c) {
					// get all the projects
					List<Project__c> projectsForThisBuilder = mapBuilderToProjects.get(theBuilder.Id);
					if (null != projectsForThisBuilder && !projectsForThisBuilder.isEmpty()) {
						// set the account association for each one
						for (Project__c theProject : projectsForThisBuilder) {
							theProject.Account__c = theBuilder.Account__c;
							// add it to the list of projects we want to update
							projectsToUpdate.add(theProject);
						}

					}
				} else { // this Builder doesn't have an Account association, so let's go clear the association for all the projects just to make sure
					// get all the projects
					List<Project__c> projectsForThisBuilder = mapBuilderToProjects.get(theBuilder.Id);
					if (null != projectsForThisBuilder && !projectsForThisBuilder.isEmpty()) {
						// set the account association for each one
						for (Project__c theProject : projectsForThisBuilder) {
							theProject.Account__c = null;
							// add it to the list of projects we want to update
							projectsToUpdate.add(theProject);
						}
					}
				}
			}	
		} else { // we're deleting builders, so let's go get all the projects and remove the account association
			system.debug('inside delete section');
			// get all the projects for all of the builders involved
			allProjectsFromTrigger = [SELECT Id, Builder__c, Account__c FROM Project__c WHERE Builder__c IN :triggerOldMap.keyset()];
			system.debug('allProjectsFromTrigger: ' + allProjectsFromTrigger);
			for (Project__c p : allProjectsFromTrigger) {
				// just blank out the associations
				p.Account__c = null;
				p.Builder__c = null;
				// and add to the list to update
				projectsToUpdate.add(p);
			}
			system.debug('projectsToUpdate: ' + projectsToUpdate);
		}

		// if we have some projects to update - let's do it.
		if (!projectsToUpdate.isEmpty()) {
			system.debug('inside update block');
			try {
				update projectsToUpdate;
			} catch (DmlException e) {
				system.debug('DML Exception: ' + e);
			}
		}
	}
}