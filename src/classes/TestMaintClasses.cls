@isTest
private class TestMaintClasses {
	@isTest static void TestBatchDeleteSubscriberActivity() {
		BatchDeleteSubscriberActivity theBatch = new BatchDeleteSubscriberActivity();
		Database.executeBatch(theBatch);
	}

	@isTest static void TestBatchMaintProjectFields() {
		BatchMaintProjectFields theBatch2 = new BatchMaintProjectFields();
		Database.executeBatch(theBatch2);
	}

	@isTest static void TestBasicGoogleStuff() {
		GoogleIntegrationHelper.BuildSignedUrl('foo');
		GoogleIntegrationHelperSetting__c crypto = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'bar');
		insert crypto;
		GoogleIntegrationHelper.BuildSignedUrl('foo');
	}

	@isTest static void TestScheduleBatchMaint() {
		System.schedule('ScheduleApexClassTest',
                        '0 0 0 15 3 ? 2022', 
                        new BatchMaintProjectFields());
	}

	@isTest static void TestScheduledBatchDeleteSubscriberActivity_scheduler() {
		System.schedule('ScheduleApexClassTest',
                        '0 0 0 15 3 ? 2022', 
                        new BatchDeleteSubscriberActivity_scheduler());
	}

	@isTest static void TestMaintProjectFields() {
		List<Project__c> projectsToInsert = new List<Project__c>();
		projectsToInsert.add(new Project__c(Name = 'Test 1', Total_Units_Planned__c = 20, Total_Units_Sold__c = 10, Sold_Out_Date__c = System.today()));
		projectsToInsert.add(new Project__c(Name = 'Test 2', Total_Units_Planned__c = 40, Total_Units_Sold__c = 0, Last_Updated_Date_Sales__c = System.today()));
		projectsToInsert.add(new Project__c(Name = 'Test 3', Total_Units_Planned__c = 60, Total_Units_Sold__c = 20));

		insert projectsToInsert;

		List<Project_Snapshot__c> snapsToInsert = new List<Project_Snapshot__c>();
		for (Project__c p : projectsToInsert) {
			snapsToInsert.add(new Project_Snapshot__c(Project__c = p.Id, Total_Units_Planned__c = p.Total_Units_Planned__c, Total_Units_Sold__c = p.Total_Units_Sold__c + 1));
			snapsToInsert.add(new Project_Snapshot__c(Project__c = p.Id, Total_Units_Planned__c = p.Total_Units_Planned__c, Total_Units_Sold__c = p.Total_Units_Sold__c + 2));
		}
		insert snapsToInsert;

		MaintProjectFields.updateThreeMonthSalesRate(projectsToInsert);
	}
}