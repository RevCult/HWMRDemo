public with sharing class ProjectUpdateRequestCreateExt {
	private final Project_Update_Request__c thePUR;

    public ProjectUpdateRequestCreateExt(ApexPages.StandardController stdController) {
        thePUR = (Project_Update_Request__c)stdController.getRecord();
    }

    public PageReference goSomewhere() {
    	List<Project__c> theProjects = BuilderProjectMgmtCmn.getProjects(new Set<Id>(new Id[]{thePUR.Project__c}));
    	if (theProjects.isEmpty()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Oops - you can only get here by clicking "New Project Update Request" from the Project you want to update. Sorry!'));
    		return null;
    	}
    	Project__c theProject = theProjects[0];

    	Set<String> projectFieldNames = BuilderProjectMgmtCmn.getProjectFields();
		Set<String> purFieldNames = BuilderProjectMgmtCmn.getProjectUpdateRequestFields();
		Map<String, String> mapProjectFieldsToPurPreviousFields = BuilderProjectMgmtCmn.getProjectToPURFieldMap();

		for (String fieldName : projectFieldNames) { // loop through all the project fields
			if (purFieldNames.contains(fieldName)) { // if the PUR has a field with the same name
				thePUR.put(fieldName, theProject.get(fieldName)); // set the value to the Project's value
			}
			if (mapProjectFieldsToPurPreviousFields.containsKey(fieldName)) { // if the PUR has a field called Previous_<fieldName>
				thePUR.put(mapProjectFieldsToPurPreviousFields.get(fieldName), theProject.get(fieldName)); // set the value to the Project's current value
			}
		}
		thePUR.Data_User__c = null;
    	insert thePUR;
    	PageReference whereToGo = new PageReference('/'+thePUR.Id+'/e?retURL=/'+thePUR.Project__c);
        return whereToGo;
    }

}