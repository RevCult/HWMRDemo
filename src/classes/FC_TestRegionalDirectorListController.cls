@isTest
private class FC_TestRegionalDirectorListController {

    @isTest
    private static void testRegionalDirectorList() {
        Test.startTest();
        FC_RegionalDirectorListController controller = new FC_RegionalDirectorListController();
        String[] testResult = controller.regionalDirectorNames;
        System.assertEquals(1, testResult.size());
        System.assertEquals('Test Sales', testResult[0]);
        Test.stopTest();
    }

    @testSetup
    private static void setup() {
        Profile testSalesProfile = [select Id from Profile where Name = 'Media - Sales Rep' limit 1];

        User testSalesUser = new User(FirstName = 'Test', LastName = 'Sales', ProfileId = testSalesProfile.Id,
                Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US');
        insert testSalesUser;

        MetrostudySalesRegion__c testSalesRegion = new MetrostudySalesRegion__c(Abbreviation__c = 'TEST',
                Description__c = 'Test Sales Region', Name = 'Test Sales Region');
        insert testSalesRegion;

        MetrostudySalesRegionAssignment__c testSalesRegionAssignment = new MetrostudySalesRegionAssignment__c(
                Name = 'Test Sales Region Assignment', Role__c = 'RD', SalesRegion__c = testSalesRegion.Id,
                User__c = testSalesUser.Id);
        insert testSalesRegionAssignment;
    }

}