@isTest
private class TestMapNearbyProjects {
	
	@isTest static void createTestData() {
		Builder__c b1 = new Builder__c(
			Name = 'the builder'
		);
		insert b1;

		Data_User__c du1 = new Data_User__c(
			Name = 'test user'
			);
		insert du1;

		Project__c p1 = new Project__c(
			Name = 'the project'
		,	Builder__c = b1.Id
		,	Data_User__c = du1.Id
			);
		insert p1;

		Project_Contact__c pc1 = new Project_Contact__c(
			Name = 'the guy'
		,	Project__c = p1.Id
			);
		insert pc1;
	}
	
	@isTest static void testMapNearbyProjectsPage() {
		createTestData();

		PageReference mapNearbyProjects = Page.MapNearbyProjects;
		Test.setCurrentPage(mapNearbyProjects);
		MapNearbyProjectsExt contExt = new MapNearbyProjectsExt(new ApexPages.Standardcontroller(new Project__c()));

		MapNearbyProjectsExt.getNearby('','');
	}
	
}