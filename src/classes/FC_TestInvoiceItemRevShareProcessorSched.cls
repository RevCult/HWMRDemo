@isTest
private class FC_TestInvoiceItemRevShareProcessorSched {

    @isTest
    private static void testSchedulable() {

        Test.startTest();

        String testCronExpression = '0 0 0 3 9 ? 2099';
        String testJobId = System.schedule('Test Schedule', testCronExpression, new FC_InvoiceItemRevenueShareProcessorSched());

        CronTrigger testCronTrigger = [
                select Id, CronExpression, TimesTriggered,
                        NextFireTime
                from CronTrigger
                where id = :testJobId
        ];
        System.assertEquals(testCronExpression, testCronTrigger.CronExpression);
        System.assertEquals(0, testCronTrigger.TimesTriggered);
        System.assertEquals('2099-09-03 00:00:00', String.valueOf(testCronTrigger.NextFireTime));

        Test.stopTest();

    }

}