/******************************************************************************
*
* @description  Tests for LeadAssignmentHandler Class
* @author       10KView
* @date         16th October 2017
*
*****************************************************************************/
@isTest(SeeAllData=False)
private class LeadAssignmentHandlerTest {

    /******************************************************************************
    *
    * @description  Create Required Test Data
    * @params       none
    * @return       void
    *
    *****************************************************************************/
    @testSetup static void createTestData() {
        // Nothing required here
    }

    /******************************************************************************
    *
    * @description  1 Test Lead Assignment Rules
    * @params       none
    * @return       void
    *
    *****************************************************************************/

    @isTest static void test_LeadAssignmentTrigger() {

        Lead l = (Lead)TestFactoryHandler.createSObject(new Lead( FirstName='Barnypok',
                                                                    LastName='LastName',
                                                                    Company='Test',
                                                                    Email='test@trashmail.us'));

        Test.startTest();
            insert l;
        Test.stopTest();

        List<Lead> leads = [select Id, CreatedById, OwnerId, Name from Lead where Company = 'Test'];
        
        // The lead created should not be owned by the creator, hence the assignment rules have been run
        System.assertNotEquals(leads[0].CreatedById, leads[0].OwnerId);







    }


}