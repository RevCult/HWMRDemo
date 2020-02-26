@isTest

private class WF_ArchivedProjectTriggerTest{

    static testMethod void testAfterUpdate(){
            
         
         Opportunity oppt = new Opportunity(Name ='New opp',StageName = 'Customer Won',Amount = 3000,CloseDate = System.today());
         insert oppt;
            
         WF_Archived_Project__c wf = new WF_Archived_Project__c();
         wf.Process_Done__c=true;
         wf.WF_Project_Id__c='2';
         wf.Opportunity__c=oppt.Id;
         insert wf;
         
         
         wf.WF_Project_Id__c='21';
         
         update wf;
   }

}