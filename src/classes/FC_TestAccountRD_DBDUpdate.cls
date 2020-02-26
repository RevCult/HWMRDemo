@isTest
private class FC_TestAccountRD_DBDUpdate {

    @isTest
    private static void testStrategicAccount() {

        MetrostudySalesRegionAssignment__c[] testSalesRegionAssignments = [
                select Id, Name, Role__c, User__c, User__r.Name
                from MetrostudySalesRegionAssignment__c
                where Name in ('Test Other', 'Test RD', 'Test DBD')
        ];
        Map<String, MetrostudySalesRegionAssignment__c> testSalesRegionAssignmentsByNameMap =
                new Map<String, MetrostudySalesRegionAssignment__c>();
        for (MetrostudySalesRegionAssignment__c testSalesRegionAssignment : testSalesRegionAssignments) {
            testSalesRegionAssignmentsByNameMap.put(testSalesRegionAssignment.Name, testSalesRegionAssignment);
        }

        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account', Strategic_Account__c = true,
                ShippingPostalCode = '12345', BillingPostalCode = '12345',
                Metrostudy_Sales_Region_Assignment_DBD__c = testSalesRegionAssignmentsByNameMap.get('Test Other').Id,
                Metrostudy_Sales_Region_Assignment_RD__c = testSalesRegionAssignmentsByNameMap.get('Test Other').Id,
                RD_Name_for_Dashboard_Filter__c = testSalesRegionAssignmentsByNameMap.get('Test Other').User__r.Name);
        insert testAccount;
        Test.stopTest();

        testAccount = [
                select Id, Metrostudy_Sales_Region_Assignment_DBD__c, Metrostudy_Sales_Region_Assignment_RD__c,
                        RD_Name_for_Dashboard_Filter__c
                from Account
                where Id = :testAccount.Id
                limit 1
        ];
        System.assertEquals(testAccount.Metrostudy_Sales_Region_Assignment_DBD__c, testSalesRegionAssignmentsByNameMap.get('Test Other').Id);
        System.assertEquals(testAccount.Metrostudy_Sales_Region_Assignment_RD__c, testSalesRegionAssignmentsByNameMap.get('Test RD').Id);
        System.assertEquals(testAccount.RD_Name_for_Dashboard_Filter__c, testSalesRegionAssignmentsByNameMap.get('Test RD').User__r.Name);

    }

    @isTest
    private static void testNonStrategicAccount() {

        MetrostudySalesRegionAssignment__c[] testSalesRegionAssignments = [
                select Id, Name, Role__c, User__c, User__r.Name
                from MetrostudySalesRegionAssignment__c
                where Name in ('Test Other', 'Test RD', 'Test DBD')
        ];
        Map<String, MetrostudySalesRegionAssignment__c> testSalesRegionAssignmentsByNameMap =
                new Map<String, MetrostudySalesRegionAssignment__c>();
        for (MetrostudySalesRegionAssignment__c testSalesRegionAssignment : testSalesRegionAssignments) {
            testSalesRegionAssignmentsByNameMap.put(testSalesRegionAssignment.Name, testSalesRegionAssignment);
        }

        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account', Strategic_Account__c = false,
                ShippingPostalCode = '12345', BillingPostalCode = '12345',
                Metrostudy_Sales_Region_Assignment_DBD__c = testSalesRegionAssignmentsByNameMap.get('Test Other').Id,
                Metrostudy_Sales_Region_Assignment_RD__c = testSalesRegionAssignmentsByNameMap.get('Test Other').Id,
                RD_Name_for_Dashboard_Filter__c = testSalesRegionAssignmentsByNameMap.get('Test Other').User__r.Name);
        insert testAccount;
        Test.stopTest();

        testAccount = [
                select Id, Metrostudy_Sales_Region_Assignment_DBD__c, Metrostudy_Sales_Region_Assignment_RD__c,
                        RD_Name_for_Dashboard_Filter__c
                from Account
                where Id = :testAccount.Id
                limit 1
        ];
        System.assertEquals(testAccount.Metrostudy_Sales_Region_Assignment_DBD__c, testSalesRegionAssignmentsByNameMap.get('Test DBD').Id);
        System.assertEquals(testAccount.Metrostudy_Sales_Region_Assignment_RD__c, testSalesRegionAssignmentsByNameMap.get('Test RD').Id);
        System.assertEquals(testAccount.RD_Name_for_Dashboard_Filter__c, testSalesRegionAssignmentsByNameMap.get('Test RD').User__r.Name);

    }


    @testSetup
    private static void setup() {

        Profile testProfile = [select Id from Profile where Name = 'Media - Sales Rep' limit 1];

        User[] testUsers = new User[]{
                new User(FirstName = 'Test', LastName = 'User', ProfileId = testProfile.Id,
                        Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                        Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                        TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US'),
                new User(FirstName = 'Test', LastName = 'DBD', ProfileId = testProfile.Id,
                        Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                        Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                        TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US'),
                new User(FirstName = 'Test', LastName = 'RD', ProfileId = testProfile.Id,
                        Username = FC_UuidUtil.uuidV4() + '@example.com', Email = FC_UuidUtil.uuidV4() + '@example.com',
                        Alias = FC_UuidUtil.uuidV4().left(8), CommunityNickname = FC_UuidUtil.uuidV4(),
                        TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US')
        };
        insert testUsers;

        MetrostudySalesRegion__c testSalesRegion = new MetrostudySalesRegion__c(Name = 'Test Sales Region');
        insert testSalesRegion;

        MetrostudySalesRegionAssignment__c[] testSalesRegionAssignments = new MetrostudySalesRegionAssignment__c[]{
                new MetrostudySalesRegionAssignment__c(Name = 'Test Other', User__c =
                        testUsers[0].Id, Role__c = 'Other', SalesRegion__c = testSalesRegion.Id),
                new MetrostudySalesRegionAssignment__c(Name = 'Test DBD', User__c =
                        testUsers[1].Id, Role__c = 'DBD', SalesRegion__c = testSalesRegion.Id),
                new MetrostudySalesRegionAssignment__c(Name = 'Test RD', User__c =
                        testUsers[2].Id, Role__c = 'RD', SalesRegion__c = testSalesRegion.Id)
        };
        insert testSalesRegionAssignments;

        MetroclientGeographyType__c testGeographyType = new MetroclientGeographyType__c(Name = 'Test Geography Type',
                GeographyTypeId__c = 1);
        insert testGeographyType;

        MetroclientGeography__c testGeography = new MetroclientGeography__c(Name = 'Test Geography',
                GeographyType__c = testGeographyType.Id, SalesRegion__c = testSalesRegion.Id);
        insert testGeography;

        MetrostudyMarket__c testMarket = new MetrostudyMarket__c(Name = 'Test Market',
                Geography__c = testGeography.Id, ZipCode__c = '12345');
        insert testMarket;

        Metrostudy_ZIP_Code__c testZipCode = new Metrostudy_ZIP_Code__c(Name = '12345', Metrostudy_Market__c = testMarket.Id);
        insert testZipCode;

    }

}