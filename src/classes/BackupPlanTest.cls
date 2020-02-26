/*
* Test for BackupPlanTest
* @since           : 30 Jan 2019
* @date            : 30 Jan 2019 - Navin: created initial version
* @see      
*/ 

@isTest
public class BackupPlanTest {
	
    // Create testsetup records
    @TestSetup
    public static void createTestRecord(){
        Builder__c builderRecord = new  Builder__c(); 
        builderRecord.Name = 'TestBuilder';
        builderRecord.Builder_Website__c = 'http://www.test.com/';
        builderRecord.State__c = 'CA';
        builderRecord.Builder_Logo_URL__c ='https://kennedywilson.box.com/shared/static/d2dvbd8nz72wt7e44jxpuv9qcas0odhy.jpg';    
        INSERT builderRecord;
        
        Schema.DescribeSObjectResult communitObjectDescribe = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> communityRecordTypeInfo = communitObjectDescribe.getRecordTypeInfos();
        
        Community__c communityRecord = new Community__c();
        communityRecord.RecordTypeId = communityRecordTypeInfo[0].getRecordTypeId();
        communityRecord.name = 'mTestCommu1';
        communityRecord.Open_Date__c = system.today();
        INSERT communityRecord;
        
        
        
        Project__c projectRecord = new Project__c();
        projectRecord.Name = 'mTestProject';
        projectRecord.Builder__c = builderRecord.id;
        projectRecord.Status__c = 'Active';
        projectRecord.open_Date__c = system.today()-1;
        projectRecord.Total_Units_Planned__c = 10;
        projectRecord.Total_Units_Sold__c = 5;
        projectRecord.Website__c = 'http://www.test.com/';
        projectRecord.Location__Latitude__s = 40.731;
        projectRecord.Location__Longitude__s = -73.997;
        projectRecord.Master_Plan_Community__c = communityRecord.id;
        INSERT projectRecord;  
        
        List<Project_Update_Request__c> projectUpdateRequestRecordList = new List<Project_Update_Request__c>();
        for(Integer i=0; i<10; i++) {
            projectUpdateRequestRecordList.add(new Project_Update_Request__c(Builder__c = builderRecord.Id,
                                                                             Project__c = projectRecord.Id));
        }
        
        INSERT projectUpdateRequestRecordList;
        
        for(Project_Update_Request__c pur : projectUpdateRequestRecordList) {
           Test.setCreatedDate(pur.Id, System.today().addDays(-3));
        }
        
        System.assertEquals(System.today().addDays(-3), [SELECT Id, createdDate FROM Project_Update_Request__c][0].createdDate);
        
        Opportunity opportunityRecord = new Opportunity(name = 'test opp 1',
                                                        StageName = 'Oferecer projeto/orçamento',
                                                        LeadSource = 'Google',
                                                        CloseDate = system.today()) ;
        
        insert opportunityRecord;
        
        List<Task> taskList = new List<Task>();
        for(Integer i=0; i<10; i++) {
            taskList.add(new Task(WhatID = opportunityRecord.id,
                                  Subject='Test '+i,
                                  Status='Completed',
                                  Priority='Normal',
                                  ActivityDate = (System.today().addMonths(-8)))); 
        }
        INSERT taskList;  
        
        Plan__c  planRecord = new Plan__c();
        planRecord.Name     ='testPln';
        planRecord.Project__c = projectRecord.id;
        INSERT planRecord;
        
        List<Plan_Update_Request__c> planUpdateRequestList = new List<Plan_Update_Request__c>();
        for(Integer i=0; i<10; i++){
            planUpdateRequestList.add(new Plan_Update_Request__c(Project__c = projectRecord.id,
                                                                 Plan__c = planRecord.id,
                                                                 Project_Update_Request__c = projectUpdateRequestRecordList[0].id,
                                                                 Plan_Name__c = 'testPlan',
                                                                 Previous_Price__c = NULL,
                                                                 Price__c = 1,
                                                                 Previous_Square_Footage__c = NULL,
                                                                 Square_Footage__c = 1));
        }
        INSERT planUpdateRequestList;
        
        List<Plan_Snapshot__c> planSnapShotList = new List<Plan_Snapshot__c>();
        for(Integer i=0; i<10; i++) {
            planSnapShotList.add(new Plan_Snapshot__c(Plan__c = planRecord.Id,
                                                      Project__c = projectRecord.Id));
        }
        INSERT planSnapShotList;
        
        List<Plan_Image__c> planImageList = new List<Plan_Image__c>();
        for(Integer i=0; i<10; i++) {
            planImageList.add(new Plan_Image__c(Name = 'Test Plan Image '+i,
                                                Plan__c = planRecord.Id));
        }
        INSERT planImageList;
    }
    
    // Test for BackupProjectUpdateRequests batch class
    @isTest
    public static void backupProjectUpdateRequestsTest() {
        Test.startTest(); 
        BackupProjectUpdateRequests backupProjectUpdateObject = new BackupProjectUpdateRequests(System.today()+1);
        Database.executeBatch(backupProjectUpdateObject);
        Test.stopTest();
    }
    
    // Test for BackupTasksBatch batch class
    @isTest
    public static void backupTasksBatchTest() {
        Test.startTest(); 
        BackupTasksBatch backupTasksBatchObject = new BackupTasksBatch();
        Database.executeBatch(backupTasksBatchObject);
        Test.stopTest();
    }
    
    // Test for BackupPlanUpdateRequestsBatch batch class
    @isTest
    public static void backupPlanUpdateRequestsTest() {
        Test.startTest(); 
        BackupPlanUpdateRequestsBatch BackupPlanUpdateRequestsObject = new BackupPlanUpdateRequestsBatch(System.today()+1);
        Database.executeBatch(BackupPlanUpdateRequestsObject);
        Test.stopTest();
    }
}