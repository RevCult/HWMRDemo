/*
* @Description : Test Class for TrgProjectsHandler and trgProjects
* @CreatedDate  : 05 March 2019
*/
@isTest
public class TrgProjectsHandlerTest {

/*
* @Description : Setup Method to create data
*/    
    @testSetup
    public static void setup(){
       
        //Create Builder__c record
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='Pulte';
        insert buliderOne;
        
         //Create Community__c record
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c mcomm = new Community__c();
        mcomm.RecordTypeId = RT[0].getRecordTypeId();
        mcomm.name = 'mTestCommu1';
        mcomm.Open_Date__c = system.today();
        insert mcomm;
    }


/*
* @Description : Test Method for trgProjects
*/    
    public static testMethod void beforeInsertTest(){
        test.startTest();
            Builder__c buliderOne = [Select Id From Builder__c LIMIT 1];
            Community__c mcomm  = [Select Id From Community__c LIMIT 1];
            
            //Insert Project records
            Project__c project = createProject(buliderOne, mcomm);
            List<Project_Update_Request__c> PURList = createPURList(project, buliderOne);
            
            //Create Data_User__c Record 
            Data_User__c du = new Data_User__c();
            du.Name            ='TestUser';
            du.Organization__c ='Meyers Temp';
            insert du;
            
            
            //update project
            project.Total_Units_Sold__c = 20;
            project.Total_Units_Planned__c = 20;
            project.Min_Price__c = 1000;
            project.Data_User__c = du.Id;
            project.Website__c = 'www.tesing.com';
            project.ZIC_Date__c = system.today()-8;
            update project;
            
            //delete project
            delete project;
            
            
            //Insert Multiple Project__c
            List<Project__c> projectsToUpdate = new List<Project__c>(); 
            projectsToUpdate.add(createProject(buliderOne, mcomm));
            projectsToUpdate.add(createProject(buliderOne, mcomm));
            projectsToUpdate.add(createProject(buliderOne, mcomm));
            
            //update 
            for( Project__c pro : projectsToUpdate ){
                pro.Total_Units_Sold__c = 20;
                pro.Total_Units_Planned__c = 20;
                pro.Min_Price__c = 1000;
                pro.Data_User__c = du.Id;
                pro.Website__c = 'www.tesing.com';
                pro.ZIC_Date__c = system.today()-8;
            }
            update projectsToUpdate;
        test.stopTest();
    }
    
/*
* @Description : Method to create Project_Update_Request__c record
* @Param : Project__c pro, Builder__c buliderOne 
* @Return Value : List<Project_Update_Request__c> PURList
*/    
    private static List<Project_Update_Request__c> createPURList(Project__c pro, Builder__c buliderOne ){
        List<Project_Update_Request__c> PURList = new List<Project_Update_Request__c>();
       
            Project_Update_Request__c pur1 = new Project_Update_Request__c();
            pur1.Builder__c = buliderOne.Id;
            pur1.Project__c = pro.Id;
            pur1.Status__c = 'Active'; 
            pur1.Previous_Status__c = 'Active';
            pur1.Previous_Meyers_Disposition_calc__c = 'Follow Up';
            pur1.Meyers_Disposition_calc__c = 'Baselined';
            pur1.Previous_Status__c = 'Upcoming';
            pur1.Product_Type__c =  'Attached';
            pur1.Previous_Product_Type__c = 'Detached';
            pur1.Lot_Dimension__c = 'test1';
            pur1.Previous_Lot_Dimension__c ='test2';
            pur1.Open_Date__c = system.today();
            pur1.Previous_Open_Date__c = system.today()-1;
            pur1.Sold_Out_Date__c = system.today();
            pur1.Previous_Sold_Out_Date__c = system.today()-1;
            pur1.Previous_Typical_Lot_Size__c = 1;
            pur1.Typical_Lot_Size__c = 210; 
            pur1.Previous_HOA__c = 1;
            pur1.HOA__c = 210;
            pur1.Previous_HOA_2__c =1;
            pur1.HOA_2__c = 210;
            pur1.Assessments__c = 4;
            pur1.Total_Units_Sold__c = 11;
            pur1.Previous_Total_Units_Sold__c = 1;
            pur1.Update_Request_Status__c = 'In Progress';
            PURList.add(pur1);

        Insert PURList;
        return PURList;
    }

/*
* @Description : Method to create Project__c record
* @Param : Builder__c buliderOne, Community__c mcomm
* @Return Value : Project__c masp
*/      
    private static Project__c createProject(Builder__c buliderOne, Community__c mcomm){
        Project__c masp = new Project__c();
        masp.Name = 'mTestProject';
        masp.Builder__c = buliderOne.id;
        masp.Status__c = 'Active';
        masp.open_Date__c = system.today()-1;
        masp.Total_Units_Planned__c = 10;
        masp.Total_Units_Sold__c = 5;
        masp.Website__c = 'http://www.test.com/';
        masp.Location__Latitude__s = 40.731;
        masp.Location__Longitude__s = -73.997;
        masp.Master_Plan_Community__c = mcomm.id;
        masp.Min_Price__c = 200;
        masp.Location__Latitude__s =56.47;
        masp.ZIC_Date__c = system.today()-2;
        Insert masp;
        return masp;
    }
}