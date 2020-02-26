@isTest
private class TestManagePlansExt {
	
	@testSetup static void setupData() {
		Project__c p = new Project__c(
			Name = 'Test Project'
			);
		insert p;

		Plan__c p1 = new Plan__c(
			Name = 'Plan 1'
		,	Project__c = p.Id
			);
		insert p1;

		Plan__c p2 = new Plan__c(
			Name = 'Plan 2'
		,	Project__c = p.Id
			);
		insert p2;
	}
	
	//@isTest static void testThePage() {
	//	PageReference thePage = Page.ManagePlans;
	//	Project__c p = [SELECT Id FROM Project__c LIMIT 1];
	//	thePage.getParameters().put('id', p.Id);
	//	Test.setCurrentPage(thePage);
	//	List<Plan__c> thePlans = [SELECT Id FROM Plan__c];
	//	ApexPages.StandardSetController theSetController = new ApexPages.StandardSetController(thePlans);
	//	theSetController.setSelected(thePlans);
	//	ManagePlansExt contExt = new ManagePlansExt(theSetController);

	//	contExt.displayCheckbox = false;
	//	contExt.updateDisplayValues();
	//	contExt.displayCheckbox = true;
	//	contExt.updateDisplayValues();
	//}

	@isTest static void testThePage() {
		PageReference thePage = Page.ManagePlans;
		Project__c theProject = [SELECT Id FROM Project__c LIMIT 1];
		thePage.getParameters().put('id', theProject.Id);
		Test.setCurrentPage(thePage);

		List<Plan__c> thePlans = [SELECT Id FROM Plan__c WHERE Project__c = :theProject.Id];
		ApexPages.StandardSetController theSetController = new ApexPages.StandardSetController(thePlans);
		theSetController.setSelected(thePlans);
		ManagePlansExt contExt = new ManagePlansExt(theSetController);

		// just make sure our wrapper class collection has some plans in it....
		system.assert(contExt.planList.size() > 0);

		// exercise the getSelected() function real quicklike...
		contExt.getSelected();

		// update a plan in the planlist to have Hidden_from_ZIC_Site__c checked and then validate the change
		contExt.planList[0].thePlan.Hidden_from_ZIC_site__c = TRUE;
		contExt.updateValues();

		contExt.planList[0].isSelected = TRUE;
		contExt.getSelected();
		contExt.deleteSelectedPlans();

	}
	
}