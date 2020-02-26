@isTest
private class WorkFrontServiceTest{
    
     static testMethod void loginTest(){
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new WorkFrontServiceTest_mock());
        WorkFrontService.login();
        Test.stopTest(); 
    }

    static testMethod void updateProjectTest1(){
           Test.setMock(HttpCalloutMock.class, new WorkFrontServiceTest_mock());
          WorkFrontService.updateProject('56f006ec00ac4e12df7549307c334fc6','123456789W');
    }
    
    static testMethod void updateProjectTest2(){
         DSM_Products__c prod = new DSM_Products__c();
         Test.setMock(HttpCalloutMock.class, new WorkFrontServiceTest_mock());
         WorkFrontService.updateProject('56f006ec00ac4e12df7549307c334fc6',prod);
    
    }



}