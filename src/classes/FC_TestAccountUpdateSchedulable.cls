@isTest
private class FC_TestAccountUpdateSchedulable {

    private static final String CRON_EXPRESSION = '0 0 0 3 9 ? 2050';
    
    @isTest
    private static void testSchedulable() {
        
        Test.startTest();
        String jobId = System.schedule('TestScheduledApex', CRON_EXPRESSION, new FC_AccountUpdateSchedulable());
        
        CronTrigger cronTriggerRecord = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        System.assertEquals(CRON_EXPRESSION, cronTriggerRecord.CronExpression);
        
        System.assertEquals(0, cronTriggerRecord.TimesTriggered);
        System.assertEquals('2050-09-03 00:00:00', String.valueOf(cronTriggerRecord.NextFireTime));
        Test.stopTest();
        
    } 
    
}