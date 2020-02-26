@isTest
private class TestZondaAdmin {
	
	//@isTest static void createSomeData() {
	//	List<ZondaApiSetting__c> settingsToInsert = new List<ZondaApiSetting__c>();
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'base_url', Value__c = 'http://www.google.com/v4'));
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'access_token', Value__c = ''));
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'refresh_token', Value__c = ''));
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'api_user', Value__c = 'username'));
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'api_pw', Value__c = 'password'));
	//	settingsToInsert.add(new ZondaApiSetting__c(Name = 'token_expiration_timestamp', Value__c = ''));
	//	insert settingsToInsert;
		
	//	Account a = new Account(
	//		Name = 'Test Account'
	//		);
	//	insert a;

	//	Contact c = new Contact(
	//		LastName = 'Test'
	//	,	Email = 'test@testing.com'
	//	,	AccountId = a.Id
	//		);
	//	insert c;

	//	Zonda_Account__c za = new Zonda_Account__c(
	//		Account__c = a.Id
	//	,	Status__c = 'Active'
	//	,	Subscription_End_Date__c = system.today() + 60
	//		);
	//	insert za;

	//	Zonda_User__c zu = new Zonda_User__c(
	//		Zonda_Account__c = za.Id
	//	,	Contact__c = c.Id
	//	,	User_Role__c = 'Zonda User'
	//	,	Username__c = 'zondauser@testing.com'
	//		);
	//	insert zu;
	//}

	//@isTest static void testCoverageManagerExt() {
	//	createSomeData();

	//	Zonda_Account__c za = [SELECT Id, Customer_Id__c FROM Zonda_Account__c LIMIT 1];
	//	za.Customer_Id__c = 123;
	//	update za;

	//	PageReference thePage = Page.ZondaAccountCoverageManager;
	//	Test.setCurrentPage(thePage);
	//	ZondaAccountCoverageManagerExt contExt = new ZondaAccountCoverageManagerExt(new ApexPages.Standardcontroller(za));
	//}
}