@IsTest
private class FC_TestZuoraClient {

    @isTest
    private static void testCancelSubscription() {
        Opportunity testOpportunity = [select Id from Opportunity where Name = 'Test Opportunity' limit 1];
        System.assertEquals(0, [select count() from FC_Opportunity_Zuora_Transaction__c where Opportunity__c = :testOpportunity.Id]);

        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient(testOpportunity.Id);
        FC_ZuoraClient.CancelSubscriptionRequest request = new FC_ZuoraClient.CancelSubscriptionRequest();
        FC_ZuoraClient.CancelSubscriptionResponse response = client.cancelSubscription(request, 'S-1');
        client.flushTransactions();

        System.assertEquals(true, response.success);

        Test.stopTest();

        System.assertEquals(1, [select count() from FC_Opportunity_Zuora_Transaction__c where Opportunity__c = :testOpportunity.Id]);
    }

    @isTest
    private static void testGetAmendmentBySubscriptionId() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.GetAmendmentResponse response = client.getAmendmentBySubscriptionId('S-1');

        System.assertEquals(true, response.success);
        Test.stopTest();
    }

    @isTest
    private static void testGetSubscriptionByKey() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.GetSubscriptionResponse response = client.getSubscriptionByKey('S-1');

        System.assertEquals(true, response.success);
        Test.stopTest();
    }

    @isTest
    private static void testGetSubscriptionByKeyAndVersion() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.GetSubscriptionResponse response = client.getSubscriptionByKeyAndVersion('S-1', 1);

        System.assertEquals(true, response.success);
        Test.stopTest();
    }

    @isTest
    private static void testGetSubscriptionObject() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.Subscription response = client.getSubscriptionObject('S-1');

        System.assertNotEquals(null, response);
        Test.stopTest();
    }

    @isTest
    private static void testQuery() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.QueryActionRequest request = new FC_ZuoraClient.QueryActionRequest();
        FC_ZuoraClient.QueryActionRequestConf conf = new FC_ZuoraClient.QueryActionRequestConf();
        conf.batchSize = 2000;
        request.conf = conf;
        request.queryString = 'select Id from Account';
        FC_ZuoraClient.QueryActionResponse response = client.query(request);
        client.flushTransactions();

        System.assertEquals(false, response.done);

        Test.stopTest();
    }

    @isTest
    private static void testQueryError() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock(true));
        Test.startTest();

        try {
            FC_ZuoraClient client = new FC_ZuoraClient();
            FC_ZuoraClient.QueryActionRequest request = new FC_ZuoraClient.QueryActionRequest();
            FC_ZuoraClient.QueryActionRequestConf conf = new FC_ZuoraClient.QueryActionRequestConf();
            conf.batchSize = 2000;
            request.conf = conf;
            request.queryString = 'select Id from Account';
            FC_ZuoraClient.QueryActionResponse response = client.query(request);
            client.flushTransactions();
            System.assert(false);
        } catch (FC_Exception e) {
            System.assert(true);
        }

        Test.stopTest();
    }

    @isTest
    private static void testQueryMore() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.QueryMoreActionRequest request = new FC_ZuoraClient.QueryMoreActionRequest();
        request.queryLocator = 'QL-1';
        FC_ZuoraClient.QueryActionResponse response = client.queryMore(request);
        client.flushTransactions();

        System.assertEquals(true, response.done);

        Test.stopTest();
    }

    @isTest
    private static void testQueryMoreError() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock(true));
        Test.startTest();

        try {
            FC_ZuoraClient client = new FC_ZuoraClient();
            FC_ZuoraClient.QueryMoreActionRequest request = new FC_ZuoraClient.QueryMoreActionRequest();
            request.queryLocator = 'QL-1';
            FC_ZuoraClient.QueryActionResponse response = client.queryMore(request);
            client.flushTransactions();
            System.assert(false);
        } catch (FC_Exception e) {
            System.assert(true);
        }

        Test.stopTest();
    }

    @isTest
    private static void testRenewSubscription() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.RenewSubscriptionRequest request = new FC_ZuoraClient.RenewSubscriptionRequest();
        FC_ZuoraClient.RenewSubscriptionResponse response = client.renewSubscription(request, 'S-1');
        client.flushTransactions();

        System.assertEquals(true, response.success);

        Test.stopTest();
    }

    @isTest
    private static void testSubscribe() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.SubscribeActionRequest request = new FC_ZuoraClient.SubscribeActionRequest();
        FC_ZuoraClient.SubscribeActionResponse[] response = client.subscribe(request);
        client.flushTransactions();

        System.assertEquals(true, ((FC_ZuoraClient.SubscribeResult) response[0]).Success);

        Test.stopTest();
    }

    @isTest
    private static void testSubscribeKnownError() {
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testSubscribeKnownError = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.SubscribeActionRequest request = new FC_ZuoraClient.SubscribeActionRequest();
        FC_ZuoraClient.SubscribeActionResponse[] response = client.subscribe(request);
        client.flushTransactions();

        System.assertEquals(false, ((FC_ZuoraClient.SubscribeError) response[0]).Success);

        Test.stopTest();
    }

    @isTest
    private static void testSubscribeUnknownError() {
        FC_ZuoraCalloutMock mock = new FC_ZuoraCalloutMock();
        mock.testSubscribeUnknownError = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

        try {
            FC_ZuoraClient client = new FC_ZuoraClient();
            FC_ZuoraClient.SubscribeActionRequest request = new FC_ZuoraClient.SubscribeActionRequest();
            FC_ZuoraClient.SubscribeActionResponse[] response = client.subscribe(request);
            client.flushTransactions();
            System.assert(false);
        } catch (FC_Exception e) {
            System.assert(true);
        }

        Test.stopTest();
    }

    @isTest
    private static void testUpdateSubscription() {
        Test.setMock(HttpCalloutMock.class, new FC_ZuoraCalloutMock());
        Test.startTest();

        FC_ZuoraClient client = new FC_ZuoraClient();
        FC_ZuoraClient.UpdateSubscriptionRequest request = new FC_ZuoraClient.UpdateSubscriptionRequest();
        FC_ZuoraClient.UpdateSubscriptionResponse response = client.updateSubscription(request, 'S-1');
        client.flushTransactions();

        System.assertEquals(true, response.success);

        Test.stopTest();
    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'Test Account', BillingPostalCode = '12345');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',
                AccountId = testAccount.Id, Amount = 100,
                StageName = 'New Opportunity', CloseDate = Date.today(), FC_Term_End_Date__c = Date.today() + 30);
        insert testOpportunity;

    }

}