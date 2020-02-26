@isTest
public with sharing class CustomTypeSetControllerTest {

    //USE SYSTEM.ASSERT()!
    static integer PAGESIZE = 25;
    static testmethod void returncorrectpageSize(){
        
        List<String> strList = new List<String>();
        
        for(integer i = 0; i < 150; i++)
        {
            
            strList.add('testdata' + i);
        }
        
        CustomTypeSetInterface testset = new CustomTypeSetController(strList);
        
        // Testing method getRecords
        
        System.assertequals(PAGESIZE, testset.getRecords().size());
        
        // Testing method setPageSize
        
        testset.setPageSize(25);
        System.assertequals(25, testset.getRecords().size());
        
        // Testing methods getHasNext and Next
        String testOldString = (String)testset.getRecords()[0];
        testset.next();
        String testNewString = (String)testset.getRecords()[0];
        
        System.assertNotEquals(testOldString, testNewString);
        
        
        // Testing methods getHasPrevious and Previous
        testOldString = (String)testset.getRecords()[0];
        testset.previous();
        testNewString = (String)testset.getRecords()[0];
        
        System.assertNotEquals(testOldString, testNewString);
        
        // Testing methods getHasPrevious and Previous one the First Page
        // Should fail
        
        testset.previous();
        testset.previous();
        
        System.assertEquals(1, testset.getCurrentPage());
    }
}