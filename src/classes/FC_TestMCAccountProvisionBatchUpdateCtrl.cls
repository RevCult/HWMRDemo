@isTest
private class FC_TestMCAccountProvisionBatchUpdateCtrl {

    @isTest
    private static void testInvoke() {
        Test.startTest();
        System.assertEquals(null, (new FC_MCAccountProvisionBatchUpdateCtrl()).invoke());
        Test.stopTest();
    }
    
}