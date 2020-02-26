@isTest
private class TestProjectStatusBoardController {
      static testMethod void myUnitTest() {
      Builder__c b = new  Builder__c(); 
            b.Name = 'CalAtlantic Homes';
            b.Builder_Website__c = 'http://www.calatlantichomes.com/';
            b.State__c = 'CA';
            b.Builder_Logo_URL__c ='https://kennedywilson.box.com/shared/static/d2dvbd8nz72wt7e44jxpuv9qcas0odhy.jpg';    
            insert b;
      Project__c p = new Project__c();
            p.Name = 'Crawford';
            P.Builder__c = b.id;
            p.Status__c = 'Active';
            insert p;
      Project_Update_Request__c pur = new Project_Update_Request__c ();
            pur.Project__c =p.id;
            pur.Update_Request_Status__c ='Pending';
            insert pur;
      Project_Update_Request__c pur1 = new Project_Update_Request__c ();
            pur1.Project__c =p.id;
            pur1.Update_Request_Status__c ='In Progress';
            insert pur1;  
      Project_Update_Request__c pur2 = new Project_Update_Request__c ();
            pur2.Project__c =p.id;
            pur2.Update_Request_Status__c ='Approved';
            insert pur2;
            }
            
       static testMethod void myUnitTestOne() {
         
         ProjectStatusBoardController pro = new ProjectStatusBoardController();
         pro.getPendingUpdateCount();
         pro.getInProgressUpdateCount();
         pro.getTotalBuilderCount();
         pro.getTotalProjectCount();
         
       }
            
            
      }