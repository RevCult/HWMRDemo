@IsTest
private class FC_TestChargeMonthlyRevShareProcessCtrl {

    @IsTest
    private static void testHttpPost() {
        FC_Charge_Monthly_Revenue_Settings__c testConfig = FC_Charge_Monthly_Revenue_Settings__c.getOrgDefaults();
        System.assert(String.isBlank(testConfig.Active_Import_Process_ID__c));
        Test.startTest();
        FC_ChargeMonthlyRevShareProcessorCtrl.runProcess('123456');
        Test.stopTest();
        testConfig = FC_Charge_Monthly_Revenue_Settings__c.getOrgDefaults();
        System.assertEquals('123456', testConfig.Active_Import_Process_ID__c);
    }

}