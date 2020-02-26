@isTest
private class FC_TestZuoraPaymentInvoiceHandler {

    @isTest
    private static void testInsert() {
        Zuora__ZInvoice__c testInvoice = [
                select Id, Zuora__BillingAccount__c, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];

        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraZInvoiceHandler', 'FC_ZuoraPaymentInvoiceHandler'
        });

        Zuora__PaymentInvoice__c testPaymentInvoice = [
                select Id
                from Zuora__PaymentInvoice__c
                where Zuora__Invoice__c = :testInvoice.Id
                limit 1
        ];
        update testPaymentInvoice;

        testInvoice = [
                select Id, Zuora__BillingAccount__c, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 2, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerRunStatus.unblockAll();

        Test.startTest();
        Zuora__Payment__c testPayment = new Zuora__Payment__c(Name = 'TEST PROCESSED PAYMENT 2',
                Zuora__BillingAccount__c = testInvoice.Zuora__BillingAccount__c,
                Zuora__Effective_Date__c = Date.today() - 1, Zuora__Status__c = 'Processed');
        insert testPayment;
        testPaymentInvoice = new Zuora__PaymentInvoice__c(Zuora__ApplyAmount__c = 100,
                Zuora__Invoice__c = testInvoice.Id, Zuora__Payment__c = testPayment.Id);
        insert testPaymentInvoice;
        Test.stopTest();

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 1, testInvoice.FC_Most_Recent_Payment_Processed_On__c);
    }

    @isTest
    private static void testUpdate() {
        Zuora__ZInvoice__c testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];

        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraZInvoiceHandler', 'FC_ZuoraPaymentInvoiceHandler'
        });

        Test.startTest();
        Zuora__PaymentInvoice__c testPaymentInvoice = [
                select Id
                from Zuora__PaymentInvoice__c
                where Zuora__Invoice__c = :testInvoice.Id
                limit 1
        ];
        update testPaymentInvoice;
        Test.stopTest();

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 2, testInvoice.FC_Most_Recent_Payment_Processed_On__c);
    }

    @isTest
    private static void testDelete() {
        Zuora__ZInvoice__c testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];

        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraZInvoiceHandler', 'FC_ZuoraPaymentInvoiceHandler'
        });

        Zuora__PaymentInvoice__c testPaymentInvoice = [
                select Id
                from Zuora__PaymentInvoice__c
                where Zuora__Invoice__c = :testInvoice.Id
                limit 1
        ];
        update testPaymentInvoice;

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 2, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerRunStatus.unblockAll();

        Test.startTest();
        delete testPaymentInvoice;
        Test.stopTest();

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);
    }

    @isTest
    private static void testUndelete() {

        Zuora__ZInvoice__c testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];

        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerHandlerSettings.enable(new Set<String>{
                'FC_ZuoraZInvoiceHandler', 'FC_ZuoraPaymentInvoiceHandler'
        });

        Zuora__PaymentInvoice__c testPaymentInvoice = [
                select Id
                from Zuora__PaymentInvoice__c
                where Zuora__Invoice__c = :testInvoice.Id
                limit 1
        ];
        update testPaymentInvoice;

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 2, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerRunStatus.unblockAll();

        delete testPaymentInvoice;

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(null, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

        fcf.TriggerRunStatus.unblockAll();

        Test.startTest();
        undelete testPaymentInvoice;
        Test.stopTest();

        testInvoice = [
                select Id, FC_Most_Recent_Payment_Processed_On__c
                from Zuora__ZInvoice__c
                where Name = 'TEST INVOICE'
                limit 1
        ];
        System.assertEquals(Date.today() - 2, testInvoice.FC_Most_Recent_Payment_Processed_On__c);

    }

    @testSetup
    private static void setup() {

        Account testAccount = new Account(Name = 'TEST ACCOUNT', BillingPostalCode = '12345');
        insert testAccount;

        Zuora__CustomerAccount__c testCustomerAccount = new Zuora__CustomerAccount__c(Name = 'TEST ACCOUNT', Zuora__Account__c = testAccount.Id);
        insert testCustomerAccount;

        Zuora__ZInvoice__c testInvoice = new Zuora__ZInvoice__c(Name = 'TEST INVOICE',
                Zuora__BillingAccount__c = testCustomerAccount.Id);
        insert testInvoice;

        Zuora__Payment__c[] testPayments = new Zuora__Payment__c[]{
                new Zuora__Payment__c(Name = 'TEST PROCESSED PAYMENT', Zuora__BillingAccount__c = testCustomerAccount.Id,
                        Zuora__Effective_Date__c = Date.today() - 2, Zuora__Status__c = 'Processed'),
                new Zuora__Payment__c(Name = 'TEST ERROR PAYMENT', Zuora__BillingAccount__c = testCustomerAccount.Id,
                        Zuora__Effective_Date__c = Date.today(), Zuora__Status__c = 'ERROR')
        };
        insert testPayments;

        Zuora__PaymentInvoice__c[] testPaymentInvoices = new Zuora__PaymentInvoice__c[]{
                new Zuora__PaymentInvoice__c(Zuora__ApplyAmount__c = 100, Zuora__Invoice__c = testInvoice.Id, Zuora__Payment__c = testPayments[0].Id),
                new Zuora__PaymentInvoice__c(Zuora__ApplyAmount__c = 100, Zuora__Invoice__c = testInvoice.Id, Zuora__Payment__c = testPayments[1].Id)
        };
        insert testPaymentInvoices;

    }

}