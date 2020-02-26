@isTest
private class FC_TestAmendmentJobStatusController {

    @isTest
    public static void testController() {

        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];

        Id asyncJobId = Database.executeBatch(new FC_ZuoraAmendmentProcessorBatchable(testOpportunity.Id, false), 1);
        System.assertNotEquals(null, asyncJobId);

        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_AmendmentJobStatusController controller = new FC_AmendmentJobStatusController();
        controller.amendmentJobId = asyncJobId;

        System.assertNotEquals(null, controller.job);
        System.assertEquals(true, controller.isJobRunning);
        System.assertNotEquals('Error', controller.jobStatus);

        fcf__Exception_Log__c testExceptionLog = new fcf__Exception_Log__c(fcf__Message__c = 'Test Message',
                fcf__Related_To_ID__c = asyncJobId, fcf__Type__c = 'TestException');
        insert testExceptionLog;

        controller.refresh();

        System.assertEquals('TestException: Test Message', controller.jobExtendedStatus);

        Test.stopTest();

    }

    @testSetup
    public static void setup() {

        Account testAccount = new Account(Name = 'Test Account', Has_Active_Subscription__c = false, BillingPostalCode = '10069', Override_Billing_Address_Information__c = true);
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', Amount = 100,
                CloseDate = Date.today() + 30, StageName = 'New Opportunity', AccountId = testAccount.Id);
        insert testOpportunity;

    }

}