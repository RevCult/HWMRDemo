@isTest(seealldata=true)
Private class PUR_Status_Update_HelperTest {
    static testMethod void Activetestmethod1(){
        
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='Pulte';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
      //  Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj1 = new Project__c ();
        prj1.Name        ='TestProject1';
        prj1.Builder__c  = buliderOne.Id;
        prj1.Status__c   ='Active';
        prj1.Last_Updated_Date_Sales__c = system.today();
        insert prj1;
        
        Project_Update_Request__c pur1 = new Project_Update_Request__c();
        pur1.Builder__c = buliderOne.Id;
        pur1.Project__c = prj1.Id;
        pur1.Status__c = 'Active'; 
        pur1.Previous_Status__c = 'Active';
        pur1.Previous_Meyers_Disposition_calc__c = 'Follow Up';
        pur1.Meyers_Disposition_calc__c = 'Baselined';
        pur1.Product_Type__c =  'Attached';
        pur1.Previous_Product_Type__c = 'Detached';
        pur1.Previous_Typical_Lot_Size__c = 1;
        pur1.Typical_Lot_Size__c = 0; 
        pur1.Previous_HOA__c = 1;
        pur1.HOA__c = 0;
        pur1.Previous_HOA_2__c =1;
        pur1.HOA_2__c = 0;
        pur1.Previous_Assessments__c = 1;
        pur1.Assessments__c = 1;
        pur1.Total_Units_Sold__c = 1;
        pur1.Previous_Total_Units_Sold__c = 2;
        insert pur1;
        
        system.debug('Project_Update_Request__c is======>');
        
        PUR_Status_Update_Helper.PURinsert_Active(prj1.id,pur1,false);
        pur1.Total_Units_Sold__c = 10;
        pur1.Previous_Total_Units_Sold__c = 1;
        pur1.Sales_Verified__c = true ;
        PUR_Status_Update_Helper.PURinsert_Active(prj1.id,pur1,false);
        
    }
    static testMethod void Activetestmethod2(){
        
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='Pulte';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
       // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj = new Project__c ();
        prj.Name        ='Latest171TUP';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        insert prj;
        
        Project__c  prj2 = new Project__c ();
        prj2.Name        ='TestProject2';
        prj2.Builder__c  = buliderOne.Id;
        prj2.Status__c   ='Active';
        prj2.Last_Updated_Date_Sales__c = system.today()-70;
        prj2.No_Of_Times_Auto_Approved__c = 3;
        insert prj2;
        
        system.debug('prj is======>');
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj.Id;
        insert pur;
        
        Project_Update_Request__c pur1 = new Project_Update_Request__c();
        pur1.Builder__c = buliderOne.Id;
        pur1.Project__c = prj2.Id;
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
        insert pur1;
        
        
        system.debug('Project_Update_Request__c is======>');
        
        PUR_Status_Update_Helper.PURinsert_Active(prj2.id,pur1,false);
        pur1.Assessments__c = 7;
        pur1.Total_Units_Sold__c = 1;
        pur1.Previous_Total_Units_Sold__c = 1;
        pur1.Sales_Verified__c = true ;
        PUR_Status_Update_Helper.PURinsert_Active(prj2.id,pur1,false);
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj.id,pur,false);
        
    }
    static testMethod void Activetestmethod3(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
      //  Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Active';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Active';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        PUR_Status_Update_Helper.PURinsert_Active(prj3.id,pur,false);
        PUR_Status_Update_Helper.PURinsert_Active(prj.id,pur,false);
    }
    
    static testMethod void Upcomingtestmethod1(){
        
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='Pulte';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
       // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj1 = new Project__c ();
        prj1.Name        ='TestProject1';
        prj1.Builder__c  = buliderOne.Id;
        prj1.Status__c   ='Upcoming';
        prj1.Last_Updated_Date_Sales__c = system.today();
        insert prj1;
        
        Project_Update_Request__c pur1 = new Project_Update_Request__c();
        pur1.Builder__c = buliderOne.Id;
        pur1.Project__c = prj1.Id;
        pur1.Status__c = 'Active'; 
        pur1.Previous_Status__c = 'Upcoming';
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
        pur1.Total_Units_Planned__c = 100;
        pur1.Previous_Total_Units_Planned__c = 1;
        insert pur1;
        
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj1.id,pur1,false);
        pur1.Total_Units_Sold__c = 1;
        pur1.Previous_Total_Units_Sold__c = 1;
        pur1.Sales_Verified__c = true ;
        pur1.Total_Units_Planned__c = 110;
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj1.id,pur1,false);
        
    }
    static testMethod void Upcomingtestmethod2(){
        
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='Pulte';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
      // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj1 = new Project__c ();
        prj1.Name        ='TestProject1';
        prj1.Builder__c  = buliderOne.Id;
        prj1.Status__c   ='Upcoming';
        prj1.Last_Updated_Date_Sales__c = system.today();
        insert prj1;
        
        Project_Update_Request__c pur1 = new Project_Update_Request__c();
        pur1.Builder__c = buliderOne.Id;
        pur1.Project__c = prj1.Id;
        pur1.Status__c = 'Upcoming'; 
        pur1.Previous_Status__c = 'Upcoming';
        pur1.Previous_Meyers_Disposition_calc__c = 'Follow Up';
        pur1.Meyers_Disposition_calc__c = 'Baselined';
        pur1.Product_Type__c =  'Attached';
        pur1.Previous_Product_Type__c = 'Detached';
        pur1.Lot_Dimension__c = 'test1';
        pur1.Previous_Lot_Dimension__c ='test2';
        pur1.Open_Date__c = system.today();
        pur1.Previous_Open_Date__c = system.today()-1;
        pur1.Sold_Out_Date__c = system.today();
        pur1.Previous_Sold_Out_Date__c = system.today()-1;
        pur1.Previous_Typical_Lot_Size__c = 1;
        pur1.Typical_Lot_Size__c = 0; 
        pur1.Previous_HOA__c = 1;
        pur1.HOA__c = 0;
        pur1.Previous_HOA_2__c =1;
        pur1.HOA_2__c = 0;
        pur1.Previous_Assessments__c = 1;
        pur1.Assessments__c = 1;
        pur1.Total_Units_Sold__c = 1;
        pur1.Previous_Total_Units_Sold__c = 2;
        pur1.Total_Units_Planned__c = 10;
        pur1.Previous_Total_Units_Planned__c = 9;
        insert pur1;
        
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj1.id,pur1,false);
        pur1.Total_Units_Sold__c = 10;
        pur1.Previous_Total_Units_Sold__c = 1;
        pur1.Sales_Verified__c = true ;
        pur1.Total_Units_Planned__c = 1;
        pur1.Assessments__c = 7;
        pur1.Previous_Total_Units_Planned__c = 1;
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj1.id,pur1,false);
        
    }
    static testMethod void Upcomingtestmethod3(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;        
       // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Upcoming';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj3.id,pur,false);
        PUR_Status_Update_Helper.PURinsert_Upcoming(prj.id,pur,false);
    }
    static testMethod void PURUpdateMethod1(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
       // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Upcoming';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        Plan__c  pln = new Plan__c();
        pln.Name     ='testPln';
        pln.Project__c = prj.id;
        insert pln;
        
        Plan_Update_Request__c plur = new Plan_Update_Request__c();
        plur.Project__c = prj.id;
        plur.Plan__c = pln.id;
        plur.Project_Update_Request__c = pur.id;
        plur.Plan_Name__c = 'testPlan';
        plur.Previous_Price__c = NULL;
        plur.Price__c = 1;
        plur.Previous_Square_Footage__c = NULL;
        plur.Square_Footage__c = 1;
     /*   plur.Price__c = 10;
        plur.Previous_Price__c =1;
        plur.Square_Footage__c =1;
        plur.Previous_Square_Footage__c =30;*/
        insert plur;
        
        PUR_Status_Update_Helper.PURUpdate(pur,plur);
        
    }
     static testMethod void PURUpdateMethod2(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
      // Test.setCreatedDate(du.Id, system.Now()-20);  
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Upcoming';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        Plan__c  pln = new Plan__c();
        pln.Name     ='testPln';
        pln.Project__c = prj.id;
        insert pln;
        
        Plan_Update_Request__c plur = new Plan_Update_Request__c();
        plur.Project__c = prj.id;
        plur.Plan__c = pln.id;
        plur.Project_Update_Request__c = pur.id;
        plur.Plan_Name__c = 'testPlan';
        plur.Price__c = 10;
        plur.Previous_Price__c =1;
        plur.Square_Footage__c =1;
        plur.Previous_Square_Footage__c =30;
        insert plur;
        
        PUR_Status_Update_Helper.PURUpdate(pur,plur);
        
    }
     static testMethod void PURUpdateMethod3(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
       // Test.setCreatedDate(du.Id, system.Now()-20);    
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Upcoming';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        Plan__c  pln = new Plan__c();
        pln.Name     ='testPln';
        pln.Project__c = prj.id;
        insert pln;
        
        Plan_Update_Request__c plur = new Plan_Update_Request__c();
        plur.Project__c = prj.id;
        plur.Plan__c = pln.id;
        plur.Project_Update_Request__c = pur.id;
        plur.Plan_Name__c = 'testPlan';
        plur.Price__c = 0;
        plur.Previous_Price__c =1;
        plur.Square_Footage__c =1;
        plur.Previous_Square_Footage__c =0;
        insert plur;         
        PUR_Status_Update_Helper.PURUpdate(pur,plur);
        
    }
     static testMethod void PURUpdateMethod4(){  
        Builder__c buliderOne = new Builder__c();
        buliderOne.Name='testuser';
        insert buliderOne;
        
        Data_User__c du = new Data_User__c();
        du.Name            ='TestUser';
        du.Organization__c ='Meyers Temp';
        insert du;         
       // Test.setCreatedDate(du.Id, system.Now()-20);    
        
        Project__c  prj3 = new Project__c ();
        prj3.Name        ='testPrj3';
        prj3.Builder__c  = buliderOne.Id;
        prj3.Status__c   ='Upcoming';
        insert prj3;
        
        Project__c  prj = new Project__c ();
        prj.Name        ='testPrj3';
        prj.Builder__c  = buliderOne.Id;
        prj.Status__c   ='Upcoming';
        prj.No_Of_Times_Auto_Approved__c = 3;
        insert prj;
        
        Project_Update_Request__c pur = new Project_Update_Request__c();
        pur.Builder__c = buliderOne.Id;
        pur.Project__c = prj3.Id;
        insert pur;
        
        Plan__c  pln = new Plan__c();
        pln.Name     ='testPln'; 
        pln.Project__c = prj.id;
        insert pln;
        
        Plan_Update_Request__c plur = new Plan_Update_Request__c();
        plur.Project__c = prj.id;
        plur.Plan__c = pln.id;
        plur.Project_Update_Request__c = pur.id;
        plur.Plan_Name__c = 'testPlan';
        plur.Price__c = 100;
        plur.Previous_Price__c =99;
        plur.Square_Footage__c =100;
        plur.Previous_Square_Footage__c =90;
        insert plur;         
        PUR_Status_Update_Helper.PURUpdate(pur,plur);
        PUR_Status_Update_Helper.flag = 0; 
        PUR_Status_Update_Helper.PURUpdate(pur,plur);
    }
       
}