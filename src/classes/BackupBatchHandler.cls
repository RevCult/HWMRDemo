/*
* @Description
* 				Handler class for all batch classes those taking backup to big object
* @History 
* Status      Date         User Story     Author              Comments
* Created     2019-24-01
* Modified    2019-25-01								Added more methods.
*/
public class BackupBatchHandler {
    
    /*
    * @description 	Creates the Plan_Update_Request_B__b records from Plan_Update_Request__c
    * @param 		planUpdateRequests List<Plan_Update_Request__c>
    * @return		List<Plan_Update_Request_B__b>
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public List<Plan_Update_Request_B__b> createPlanUpdateRequestBackup(List<Plan_Update_Request__c> planUpdateRequests){
        List<Plan_Update_Request_B__b> backupRecords = new List<Plan_Update_Request_B__b>();
        for(Plan_Update_Request__c planUpdateRequest : planUpdateRequests){
            Plan_Update_Request_B__b purb = new Plan_Update_Request_B__b();
            purb.Name__c = planUpdateRequest.Name;
            purb.Num_of_Baths__c = planUpdateRequest.Num_of_Baths__c;
            purb.Num_of_Beds__c = planUpdateRequest.Num_of_Beds__c;            
            purb.Num_of_Floors__c = planUpdateRequest.Num_of_Floors__c;
            purb.Num_of_Full_Baths__c = planUpdateRequest.Num_of_Full_Baths__c;
            purb.Num_of_Half_Baths__c = planUpdateRequest.Num_of_Half_Baths__c;            
            purb.Auto_Approval_Result__c = planUpdateRequest.Auto_Approval_Result__c;
            purb.Price__c = planUpdateRequest.Price__c;
            purb.Change_in_Price__c = planUpdateRequest.Change_in_Price__c;            
            purb.Display_in_Zonda__c = planUpdateRequest.Display_in_Zonda__c ? 'TRUE' : 'FALSE';
            purb.Garage__c = planUpdateRequest.Garage__c;            
            purb.Plan_Name__c = planUpdateRequest.Plan_Name__c;
            purb.Off_Market__c = planUpdateRequest.Off_Market__c ? 'TRUE' : 'FALSE';            
            purb.Plan__c = planUpdateRequest.Plan__c;              
            purb.Created_By__c = planUpdateRequest.CreatedById;            
            purb.Created_Time__c = planUpdateRequest.CreatedDate;
            purb.Last_Modified_By__c = planUpdateRequest.LastModifiedById;
            purb.Last_Modified_Time__c = planUpdateRequest.LastModifiedDate;
            purb.Plan_Notes__c = planUpdateRequest.Plan_Notes__c;
            purb.Project_Update_Request__c = planUpdateRequest.Project_Update_Request__c;            
            purb.Previous_Num_of_Baths__c = planUpdateRequest.Previous_Num_of_Baths__c;
            purb.Previous_Num_of_Beds__c = planUpdateRequest.Previous_Num_of_Beds__c;            
            purb.Previous_Num_of_Floors__c = planUpdateRequest.Previous_Num_of_Floors__c;
            purb.Previous_Num_of_Full_Baths__c = planUpdateRequest.Previous_Num_of_Full_Baths__c;
            purb.Previous_Num_of_Half_Baths__c = planUpdateRequest.Previous_Num_of_Half_Baths__c;            
            purb.Previous_Garage__c = planUpdateRequest.Previous_Garage__c;
            purb.Previous_Off_Market__c = planUpdateRequest.Previous_Off_Market__c ? 'TRUE' : 'FALSE'; 
            purb.Previous_Plan_Name__c = planUpdateRequest.Previous_Plan_Name__c;
            purb.Previous_Plan_Notes__c = planUpdateRequest.Previous_Plan_Notes__c;
            purb.Previous_Price__c = planUpdateRequest.Previous_Price__c;
            purb.Price_Unchanged__c = planUpdateRequest.Price_Unchanged__c ? 'TRUE' : 'FALSE';
            purb.Project__c = planUpdateRequest.Project__c;
            purb.Square_Footage__c = planUpdateRequest.Square_Footage__c;
            purb.Update_Request_Status__c = planUpdateRequest.Update_Request_Status__c;
            purb.Update_Request_Type__c = planUpdateRequest.Update_Request_Type__c;
            
            backupRecords.add(purb);
        }
        return backupRecords;
    }
	
    /*
    * @description 	Fetches Plan_Update_Request__c records
    * @param 		lastDate Date
    * @return		List<Plan_Update_Request__c>
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public List<Plan_Update_Request__c> fetchPlanUpdateRequests(Date lastDate){
        return [SELECT Change_in_Price__c, Id, Name, Plan__c, Num_of_Baths__c, Num_of_Beds__c, Plan_Name__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                Previous_Num_of_Baths__c, Previous_Num_of_Beds__c, Previous_Plan_Name__c, Previous_Price__c, Previous_Square_Footage__c, Price__c, 
                Project_Update_Request__c, Project__c, Square_Footage__c, Update_Request_Status__c, Update_Request_Type__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, 
                Previous_Num_of_Full_Baths__c, Previous_Num_of_Half_Baths__c, Plan_Notes__c, Previous_Plan_Notes__c, Garage__c, Num_of_Floors__c, Previous_Garage__c, Previous_Num_of_Floors__c, Price_Unchanged__c, 
                Off_Market__c, Previous_Off_Market__c, Display_in_Zonda__c, Auto_Approval_Result__c 
                FROM Plan_Update_Request__c 
                WHERE CreatedDate < :lastDate 
                LIMIT 5000];
    }
       
    /*
    * @description 	Fetches Task records older than 6 months
    * @param 		
    * @return		List<Task>
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public List<Task> fetchOlderTasks(){
        return [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate, Status, Priority, IsHighPriority, 
                OwnerId, Description, Type, AccountId, IsClosed, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, 
                IsArchived, SystemModstamp, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, 
                RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, LastModifiedById, 
                RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceRegeneratedType, RecurrenceMonthOfYear, TaskSubtype, CompletedDateTime 
                FROM Task 
                WHERE Status ='Completed' 
                AND ActivityDate < LAST_N_MONTHS:6 LIMIT 5000];
    }
    
    /*
    * @description 	Creates Task__b records from tasks
    * @param 		tasks List<Task>
    * @return		List<Task__b>
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */    
    public List<Task__b> createTaskBackup(List<Task> tasks){
        List<Task__b> backupRecords = new List<Task__b>();
        for(Task taskO : tasks){
            Task__b bTask = new Task__b();
            bTask.Task_Id__c = taskO.Id;
           	bTask.TaskSubtype__c = taskO.TaskSubtype;
            bTask.Type__c = taskO.Type;
            bTask.Subject__c = taskO.Subject;
            bTask.Status__c = taskO.Status;
            bTask.Status__c = taskO.Status;
            bTask.RecurrenceRegeneratedType__c = taskO.RecurrenceRegeneratedType;           
			bTask.IsReminderSet__c = taskO.IsReminderSet ? 'TRUE' : 'FALSE';
			bTask.What__c = taskO.WhatId;
			bTask.RecurrenceInterval__c = taskO.RecurrenceInterval;  
            bTask.Priority__c = taskO.Priority;            
            //bTask.Phone__c = taskO.;            
            //bTask.Email__c = taskO.Email;            
            bTask.Who__c = taskO.WhoId;            
            bTask.ActivityDate__c = taskO.ActivityDate;
            bTask.IsRecurrence__c = taskO.IsRecurrence ? 'TRUE' : 'FALSE';   
            bTask.Description__c = taskO.Description;   
            bTask.CallType__c = taskO.CallType;   
            bTask.CallDisposition__c = taskO.CallDisposition;
            bTask.CallDurationInSeconds__c = taskO.CallDurationInSeconds;
            bTask.CallObject__c = taskO.CallObject;
            bTask.Owner__c = taskO.OwnerId;
            bTask.User__c = taskO.CreatedById;           
            bTask.Last_Modified_By__c = taskO.LastModifiedById;      
            bTask.CompletedDateTime__c = taskO.CompletedDateTime;      
            
            backupRecords.add(bTask);
        }
        return backupRecords;
    }
    
	/*
    * @description 	Fetches Project_Update_Request__c records
    * @param 		lastDate Date
    * @return		List<Project_Update_Request__c>
    * Status        Date         User Story          Author                Comments
    * Created       2019-25-01   
    */    
    public List<Project_Update_Request__c> fetchProjectUpdateRequests(Date lastDate){
        return [SELECT IsDeleted, Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastActivityDate, SystemModstamp, 
                LastViewedDate, LastReferencedDate, Account__c, Call_Center_Disposition__c, Builder__c, Call_Center_Notes__c, City__c, County__c, 
                Data_User__c, Do_Not_Call__c, Email_Special__c, FIPS__c, HOA__c, Last_Update_User_Price__c, Last_Update_User_Sales__c, Last_Updated_Date_Price__c, 
                Location__Latitude__s, Last_Updated_Date_Sales__c, Location__Longitude__s, Master_Plan__c, Location__c, Max_Price__c, Max_Unit_Size__c, Meyers_Disposition__c,
                Meyers_Notes__c, Min_Price__c, Min_Unit_Size__c, Open_Date__c, Phone_Number__c, Previous_City__c, Previous_County__c, Previous_Do_Not_Call__c, 
                Previous_Email_Special__c, Previous_FIPS__c, Previous_HOA__c, Previous_Location__Latitude__s, Previous_Location__Longitude__s, Previous_Location__c,
                Previous_Max_Price__c, Previous_Max_Unit_Size__c, Previous_Master_Plan__c, Previous_Min_Price__c, Previous_Meyers_Notes__c, Previous_Open_Date__c, 
                Previous_Min_Unit_Size__c, Previous_Phone_Number__c, Previous_Product_Type__c, Previous_Project_Characteristics__c, Previous_Region_ID__c,
                Previous_Sales_Person_2__c, Previous_Sales_Person_Name__c, Previous_Sales_Rate__c, Previous_Sales_and_Marketing_Firm__c, Previous_Sold_Out_Date__c, 
                Previous_State__c, Previous_Status__c, Previous_Total_Remaining__c, Previous_Total_Units_Planned__c, Previous_Typical_Lot_Size__c, Previous_Total_Units_Sold__c, 
                Product_Type__c, Previous_Website__c, Project_Characteristics__c, Project_ID_Legacy__c, Project__c, Region_ID__c, Sales_Person_2__c, Sales_Person_Name__c, 
                Sales_Rate__c, Sales_Rate_calc__c, Sales_and_Marketing_Firm__c, Sold_Out_Date__c, State__c, Total_Remaining__c, Status__c, Total_Remaining_calc__c, 
                Total_Units_Planned__c, Total_Units_Sold__c, Typical_Lot_Size__c, Update_Request_Status__c, Update_Request_Type__c, Website__c, Prices_Verified__c, 
                Sales_Verified__c, Assessment_Description__c, Assessments_Dollar__c, Assessments__c, HOA_2__c, Lot_Dimension__c, Previous_Assessment_Description__c,
                Previous_Assessments_Dollar__c, Previous_Assessments__c, Previous_HOA_2__c, Previous_Lot_Dimension__c, Project_Name__c, HOA_Description__c, Incentive_Options__c, 
                Monthly_HOA_SF__c, Previous_Incentive_Options__c, Previous_HOA_Description__c, Previous_Monthly_HOA_SF__c, Project_City__c, Project_County__c, Project_State__c, 
                Big_Change_Alert__c, Big_Change_Reasons__c, Inside_Update_Cycle__c, Approved_Date__c, Approved_Date_formula__c, Alternate_Phone_Number__c, MeyersNotesCounter__c, 
                Previous_Alternate_Phone_Number__c, Previous_Sales_Office_Notes__c, Sales_Office_Notes__c, Total_Units_Sold_Diff_Calc__c, Multiple_Attempts__c, 
                Last_Updated_Date_UUC__c, Last_Updated_Date_UnUUC__c, Last_Updated_User_UUC__c, Previous_Units_under_construction__c, Last_Updated_User_UnUUC__c, 
                Previous_Unsold_units_under_construct__c, Units_under_construction__c, Unsold_units_under_construction__c, Broker_Co_Op_Incentives__c, 
                Broker_Co_Op_Incentives_Unchanged__c, Last_Updated_Date_Broker_Cop_Incentives__c, Last_Updated_Date_Quick_Move_Incentive__c, Last_Updated_Date_To_Be_Built_Incentive__c, 
                Previous_Broker_Co_Op_Incentives__c, Previous_Broker_Co_Op_Unchanged__c, Previous_Quick_Move_In_Incentives__c, Previous_Quick_Move_In_Unchanged__c, 
                Previous_To_Be_Built_Incentives__c, Previous_To_Be_Built_Unchanged__c, Quick_Move_In_Incentives_Unchanged__c, Quick_Move_In_Incentives__c, 
                To_Be_Built_Incentives_Unchanged__c, To_Be_Built_Incentives__c, Auto_Approved__c, Meyers_Disposition_calc__c, Previous_Meyers_Disposition_calc__c,
                Multiple_Atempts__c, Previous_Sales_Rate_calc__c, Sales_Rate_Validated__c, Previous_Sales_based_on_closing_data__c, Sales_based_on_closing_data__c,
                Previously_Set_to_Review__c, Meyers_Notes_internal__c, Previous_No_Of_Times_Auto_Approved_Set__c, Previous_No_Of_Times_Auto_Approved__c, Previous_Sales_Verified__c,
                Auto_Approval_Result__c, Count_of_Plans__c, Days_Since_Data_User_Created__c, No_Of_Times_Auto_Approved__c, Num_of_Days_Since_Last_Update__c, Monthly_HOA_SF_NA__c,
                HOA_2_NA__c, HOA_NA__c, Assessments_Dollar_NA__c 
                FROM Project_Update_Request__c
                WHERE CreatedDate < :lastDate LIMIT 5000];
    }
    
    /*
    * @description 	Creates Project_Update_Request_Backup__b records from Project_Update_Request__c
    * @param 		planUpdateRequests List<Project_Update_Request__c>
    * @return		List<Project_Update_Request_Backup__b>
    * Status        Date         User Story          Author                Comments
    * Created       2019-25-01   
    */  
    public List<Project_Update_Request_Backup__b> createProjectUpdateRequestBackup(List<Project_Update_Request__c> planUpdateRequests){
        List<Project_Update_Request_Backup__b> backupRecords = new List<Project_Update_Request_Backup__b>();
        for(Project_Update_Request__c projectUpdateRequest : planUpdateRequests){
            Project_Update_Request_Backup__b purb = new Project_Update_Request_Backup__b();
            purb.Num_of_Days_Since_Last_Update__c = projectUpdateRequest.Num_of_Days_Since_Last_Update__c;
            purb.Units_under_construction__c = projectUpdateRequest.Units_under_construction__c;
            purb.Unsold_units_under_construction__c = projectUpdateRequest.Unsold_units_under_construction__c;
            purb.Account__c = projectUpdateRequest.Account__c;            
            purb.Assessments_Dollar_NA__c = projectUpdateRequest.Assessments_Dollar_NA__c ? 'TRUE' : 'FALSE';
            purb.Assessments_Dollar__c = projectUpdateRequest.Assessments_Dollar__c;
            purb.Alternate_Phone_Number__c = projectUpdateRequest.Alternate_Phone_Number__c;
            purb.Approved_Date_formula__c = projectUpdateRequest.Approved_Date_formula__c;
            purb.Approved_Date__c = projectUpdateRequest.Approved_Date__c;            
            purb.Auto_Approval_Result__c = projectUpdateRequest.Auto_Approval_Result__c;
            purb.Auto_Approved__c = projectUpdateRequest.Auto_Approved__c ? 'TRUE' : 'FALSE';
            purb.Big_Change_Alert__c = projectUpdateRequest.Big_Change_Alert__c ? 'TRUE' : 'FALSE';
            purb.Big_Change_Reason_s__c = projectUpdateRequest.Big_Change_Reasons__c;            
            purb.Broker_Co_Op_Incentives__c = projectUpdateRequest.Broker_Co_Op_Incentives__c;
            purb.Broker_Co_Op_Incentives_Unchanged__c = projectUpdateRequest.Broker_Co_Op_Incentives_Unchanged__c ? 'TRUE' : 'FALSE';            
            purb.Builder__c = projectUpdateRequest.Builder__c;
            purb.Call_Center_Disposition__c = projectUpdateRequest.Call_Center_Disposition__c;
            purb.Call_Center_Notes__c = projectUpdateRequest.Call_Center_Notes__c;
            purb.City__c = projectUpdateRequest.City__c;
            purb.Count_of_Plans__c = projectUpdateRequest.Count_of_Plans__c;
            purb.County__c = projectUpdateRequest.County__c;
            purb.Created_By__c = projectUpdateRequest.CreatedById;            
            purb.Created_Time__c = projectUpdateRequest.CreatedDate;            
            purb.Data_User__c = projectUpdateRequest.Data_User__c;
            purb.Days_Since_Data_User_Created__c = projectUpdateRequest.Days_Since_Data_User_Created__c;
            purb.Do_Not_Call__c = projectUpdateRequest.Do_Not_Call__c ? 'TRUE' : 'FALSE';            
            purb.Email_Special__c = projectUpdateRequest.Email_Special__c;
            purb.FIPS__c = projectUpdateRequest.FIPS__c;
            purb.HOA_Description__c = projectUpdateRequest.HOA_Description__c;
            purb.Incentive_Options__c = projectUpdateRequest.Incentive_Options__c;            
            purb.Inside_Update_Cycle__c = projectUpdateRequest.Inside_Update_Cycle__c ? 'TRUE' : 'FALSE';
            purb.Last_Modified_Time__c = projectUpdateRequest.LastModifiedDate;            
            purb.Last_Updated_Date_Broker_Co_Op__c = projectUpdateRequest.Last_Updated_Date_Broker_Cop_Incentives__c;
            purb.Last_Updated_Date_Price__c = projectUpdateRequest.Last_Updated_Date_Price__c;
            purb.Last_Updated_Date_Quick_Move__c = projectUpdateRequest.Last_Updated_Date_Quick_Move_Incentive__c;
            purb.Last_Updated_Date_Sales__c = projectUpdateRequest.Last_Updated_Date_Sales__c;            
            purb.Last_Updated_Date_To_Be_Built_q__c = projectUpdateRequest.Last_Updated_Date_To_Be_Built_Incentive__c;            
            purb.Last_Updated_Date_UnUUC__c = projectUpdateRequest.Last_Updated_Date_UnUUC__c;
            purb.Last_Updated_Date_UUC__c = projectUpdateRequest.Last_Updated_Date_UUC__c;            
            purb.Last_Updated_User_UnUUC__c = projectUpdateRequest.Last_Updated_User_UnUUC__c;
            purb.Last_Updated_User_UUC__c = projectUpdateRequest.Last_Updated_User_UUC__c;            
            purb.Last_Update_User_Price__c = projectUpdateRequest.Last_Update_User_Price__c;
            purb.Last_Update_User_Sales__c = projectUpdateRequest.Last_Update_User_Sales__c;            
            purb.Location__c = String.valueOf(projectUpdateRequest.Location__c);
            purb.Lot_Dimension__c = projectUpdateRequest.Lot_Dimension__c;            
            purb.Master_Plan__c = projectUpdateRequest.Master_Plan__c;            
            purb.Max_Price__c = projectUpdateRequest.Max_Price__c;            
            purb.Max_Unit_Size__c = projectUpdateRequest.Max_Unit_Size__c;            
            purb.Meyers_Disposition__c = projectUpdateRequest.Meyers_Disposition__c;
            purb.Meyers_Disposition_calc__c = projectUpdateRequest.Meyers_Disposition_calc__c;
            purb.Meyers_Notes__c = projectUpdateRequest.Meyers_Notes__c;            
            purb.Meyers_Notes_internal__c = projectUpdateRequest.Meyers_Notes_internal__c;
            purb.MeyersNotesCounter__c = projectUpdateRequest.MeyersNotesCounter__c;
            purb.Min_Price__c = projectUpdateRequest.Min_Price__c;            
            purb.Min_Unit_Size__c = projectUpdateRequest.Min_Unit_Size__c;            
            purb.Monthly_HOA_SF__c = projectUpdateRequest.Monthly_HOA_SF__c;
            purb.Monthly_HOA_SF_NA__c = projectUpdateRequest.Monthly_HOA_SF_NA__c ? 'TRUE' : 'FALSE';
            purb.HOA__c = projectUpdateRequest.HOA__c;
            purb.HOA_NA__c = projectUpdateRequest.HOA_NA__c ? 'TRUE' : 'FALSE';            
            purb.HOA_2__c = projectUpdateRequest.HOA_2__c;
            purb.HOA_2_NA__c = projectUpdateRequest.HOA_2_NA__c ? 'TRUE' : 'FALSE';            
            purb.Multiple_Attempts__c = projectUpdateRequest.Multiple_Attempts__c ? 'TRUE' : 'FALSE';   
            purb.Multiple_Atempts__c = projectUpdateRequest.Multiple_Atempts__c ? 'TRUE' : 'FALSE';   
            purb.No_Of_Times_Auto_Approved__c = projectUpdateRequest.No_Of_Times_Auto_Approved__c;
            purb.Open_Date__c = projectUpdateRequest.Open_Date__c;            
            purb.Owner__c = projectUpdateRequest.OwnerId;
            purb.Phone_Number__c = projectUpdateRequest.Phone_Number__c;            
            purb.Previous_Units_under_construction__c = projectUpdateRequest.Previous_Units_under_construction__c;
            purb.Previous_Unsold_units_under_construct__c = projectUpdateRequest.Previous_Unsold_units_under_construct__c;
            purb.Previous_Assessments_Dollar__c = projectUpdateRequest.Previous_Assessments_Dollar__c;
            purb.Previous_Alternate_Phone_Number__c = projectUpdateRequest.Previous_Alternate_Phone_Number__c;            
            purb.Previous_Assessment_Description__c = projectUpdateRequest.Previous_Assessment_Description__c;
            purb.Previous_Broker_Co_Op_Incentives__c = projectUpdateRequest.Previous_Broker_Co_Op_Incentives__c;
            purb.Previous_Broker_Co_Op_Unchanged__c	 = projectUpdateRequest.Previous_Broker_Co_Op_Unchanged__c ? 'TRUE' : 'FALSE';
            purb.Previous_City__c = projectUpdateRequest.Previous_City__c;
            purb.Previous_County__c = projectUpdateRequest.Previous_County__c;            
            purb.Previous_Email_Special__c = projectUpdateRequest.Previous_Email_Special__c;
            purb.Previous_Do_Not_Call__c = projectUpdateRequest.Previous_Do_Not_Call__c ? 'TRUE' : 'FALSE';
            purb.Previous_HOA_Description__c = projectUpdateRequest.Previous_HOA_Description__c;
            purb.Previous_FIPS__c = projectUpdateRequest.Previous_FIPS__c;            
            purb.Previous_Incentive_Options__c = projectUpdateRequest.Previous_Incentive_Options__c;
            purb.Previous_Location__c = String.valueOf( projectUpdateRequest.Previous_Location__c );        
            purb.Previous_Lot_Dimension__c = projectUpdateRequest.Previous_Lot_Dimension__c;
            purb.Previously_Set_to_Review__c = projectUpdateRequest.Previously_Set_to_Review__c ? 'TRUE' : 'FALSE';
            purb.Previous_Master_Plan__c = projectUpdateRequest.Previous_Master_Plan__c;
            purb.Previous_Max_Price__c = projectUpdateRequest.Previous_Max_Price__c;
            purb.Previous_Max_Unit_Size__c = projectUpdateRequest.Previous_Max_Unit_Size__c;
            purb.Previous_Meyers_Disposition_calc__c = projectUpdateRequest.Previous_Meyers_Disposition_calc__c;            
            purb.Previous_Meyers_Notes__c = projectUpdateRequest.Previous_Meyers_Notes__c;            
            purb.Previous_Min_Price__c = projectUpdateRequest.Previous_Min_Price__c;            
            purb.Previous_Min_Unit_Size__c = projectUpdateRequest.Previous_Min_Unit_Size__c;
            purb.Previous_Monthly_HOA_SF__c = projectUpdateRequest.Previous_Monthly_HOA_SF__c;
            purb.Previous_HOA__c = projectUpdateRequest.Previous_HOA__c ;            
            purb.Previous_Monthly_HOA_SF__c = projectUpdateRequest.Previous_Monthly_HOA_SF__c;
            purb.Previous_HOA__c = projectUpdateRequest.Previous_HOA__c;
            purb.Previous_HOA_2__c = projectUpdateRequest.Previous_HOA_2__c;
            purb.Previous_No_Of_Times_Auto_Approved__c = projectUpdateRequest.Previous_No_Of_Times_Auto_Approved__c; 
            purb.Previous_No_Of_Times_Auto_Approved_Set__c = projectUpdateRequest.Previous_No_Of_Times_Auto_Approved_Set__c ;
            purb.Previous_Open_Date__c = projectUpdateRequest.Previous_Open_Date__c;            
            purb.Previous_Phone_Number__c = projectUpdateRequest.Previous_Phone_Number__c;
            purb.Previous_Product_Type__c = projectUpdateRequest.Previous_Product_Type__c;
            purb.Previous_Project_Characteristics__c = projectUpdateRequest.Previous_Project_Characteristics__c;
            purb.Previous_Quick_Move_In_Incentives__c = projectUpdateRequest.Previous_Quick_Move_In_Incentives__c;   
            purb.Previous_Quick_Move_In_Unchanged__c = projectUpdateRequest.Previous_Quick_Move_In_Unchanged__c ? 'TRUE' : 'FALSE';           
            purb.Previous_Region_ID__c = projectUpdateRequest.Previous_Region_ID__c;
            purb.Previous_Sales_and_Marketing_Firm__c = projectUpdateRequest.Previous_Sales_and_Marketing_Firm__c;            
            purb.Previous_Sales_based_on_closing_data__c = projectUpdateRequest.Previous_Sales_based_on_closing_data__c ? 'TRUE' : 'FALSE';
            purb.Previous_Sales_Office_Notes__c = projectUpdateRequest.Previous_Sales_Office_Notes__c;            
            purb.Previous_Sales_Person_2__c = projectUpdateRequest.Previous_Sales_Person_2__c;
            purb.Previous_Sales_Person_Name__c = projectUpdateRequest.Previous_Sales_Person_Name__c;            
            purb.Previous_Sales_Rate__c =projectUpdateRequest.Previous_Sales_Rate__c;
            purb.Previous_Sales_Rate_calc__c = projectUpdateRequest.Previous_Sales_Rate_calc__c;            
            purb.Previous_Sales_Unchanged__c = projectUpdateRequest.Previous_Sales_Verified__c? 'TRUE' : 'FALSE';            
            purb.Previous_Sold_Out_Date__c = projectUpdateRequest.Previous_Sold_Out_Date__c;            
            purb.Previous_State__c = projectUpdateRequest.Previous_State__c;            
            purb.Previous_Status__c = projectUpdateRequest.Previous_Status__c;
            purb.Previous_To_Be_Built_Incentives__c = projectUpdateRequest.Previous_To_Be_Built_Incentives__c;
            purb.Previous_To_Be_Built_Unchanged__c = projectUpdateRequest.Previous_To_Be_Built_Unchanged__c ? 'TRUE' : 'FALSE';            
            purb.Previous_Total_Remaining__c = projectUpdateRequest.Previous_Total_Remaining__c;
            purb.Previous_Total_Tax_Rate__c = projectUpdateRequest.Previous_Assessments__c;
            purb.Previous_Total_Units_Planned__c = projectUpdateRequest.Previous_Total_Units_Planned__c;            
            purb.Previous_Total_Units_Sold__c = projectUpdateRequest.Previous_Total_Units_Sold__c;            
            purb.Previous_Typical_Lot_Size__c = projectUpdateRequest.Previous_Typical_Lot_Size__c;
            purb.Previous_Website__c = projectUpdateRequest.Previous_Website__c;
            purb.Product_Type__c = projectUpdateRequest.Product_Type__c;
            purb.Prices_Unchanged__c = projectUpdateRequest.Prices_Verified__c ? 'TRUE' : 'FALSE';            
            purb.Project__c = projectUpdateRequest.Project__c;            
            purb.Project_Characteristics__c = projectUpdateRequest.Project_Characteristics__c;            
            purb.Project_City__c = projectUpdateRequest.Project_City__c;
            purb.Project_County__c = projectUpdateRequest.Project_County__c;
            purb.Project_ID_Legacy__c = projectUpdateRequest.Project_ID_Legacy__c;
            purb.Project_Name__c = projectUpdateRequest.Project_Name__c;            
            purb.Project_State__c = projectUpdateRequest.Project_State__c;
            purb.Project_Update_Request_Id__c = projectUpdateRequest.Id; // PUR Id            
            purb.Quick_Move_In_Incentives_Unchanged__c = projectUpdateRequest.Quick_Move_In_Incentives_Unchanged__c ? 'TRUE' : 'FALSE';
            purb.Region_ID__c = projectUpdateRequest.Region_ID__c;
            purb.Sales_and_Marketing_Firm__c = projectUpdateRequest.Sales_and_Marketing_Firm__c;
            purb.Sales_based_on_closing_data__c = projectUpdateRequest.Sales_based_on_closing_data__c ? 'TRUE' : 'FALSE';            
            purb.Sales_Office_Notes__c = projectUpdateRequest.Sales_Office_Notes__c;
            purb.Sales_Person_2__c = projectUpdateRequest.Sales_Person_2__c;
            purb.Sales_Person_Name__c = projectUpdateRequest.Sales_Person_Name__c;
            purb.Sales_Rate__c = projectUpdateRequest.Sales_Rate__c;
            purb.Sales_Rate_calc__c = projectUpdateRequest.Sales_Rate_calc__c;            
            purb.Sold_Out_Date__c = projectUpdateRequest.Sold_Out_Date__c;
            purb.Sales_Unchanged__c = projectUpdateRequest.Sales_Verified__c ? 'TRUE' : 'FALSE';
            purb.Sales_Rate_Validated__c = projectUpdateRequest.Sales_Rate_Validated__c ? 'TRUE' : 'FALSE';
            purb.State__c = projectUpdateRequest.State__c;            
            purb.Status__c = projectUpdateRequest.Status__c;
            purb.Tax_Assessment_Description__c = projectUpdateRequest.Assessment_Description__c;            
            purb.To_Be_Built_Incentives__c = projectUpdateRequest.To_Be_Built_Incentives__c;
            purb.To_Be_Built_Incentives_Unchanged__c = projectUpdateRequest.To_Be_Built_Incentives_Unchanged__c ? 'TRUE' : 'FALSE';
            purb.Total_Remaining__c = projectUpdateRequest.Total_Remaining__c;
            purb.Total_Remaining_calc__c = projectUpdateRequest.Total_Remaining_calc__c;
            purb.Total_Tax_Rate__c = projectUpdateRequest.Assessments__c;
            purb.Total_Units_Planned__c = projectUpdateRequest.Total_Units_Planned__c;
            purb.Total_Units_Sold__c = projectUpdateRequest.Total_Units_Sold__c;            
            purb.Total_Units_Sold_Diff_Calc__c = projectUpdateRequest.Total_Units_Sold_Diff_Calc__c;            
            purb.Typical_Lot_Size__c = projectUpdateRequest.Typical_Lot_Size__c;
            purb.Update_Request_Status__c = projectUpdateRequest.Update_Request_Status__c;
            purb.Update_Request_Type__c = projectUpdateRequest.Update_Request_Type__c;   
            purb.Website__c = projectUpdateRequest.Website__c;
            
            backupRecords.add(purb);
        }
        return backupRecords;
    }
    
    public List<Plan_Update_Request__c> fetchPlanUpdateRequestFromRecycle(Date lastDate){
        String query1 = 'SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, Project__c '+
            'FROM Plan_Update_Request__c '+
            'WHERE LastModifiedDate >= :lastDate AND IsDeleted = true LIMIT 5000 ALL ROWS ';
        List<Plan_Update_Request__c> purs = Database.query(query1);
        return purs;
    }
    
    public List<Project_Update_Request__c> fetchProjectUpdateRequestFromRecycle(Date lastDate){
        String query1 = 'SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, Project__c '+
            'FROM Project_Update_Request__c '+
            'WHERE LastModifiedDate >= :lastDate AND IsDeleted = true LIMIT 5000 ALL ROWS ';
        List<Project_Update_Request__c> purs = Database.query(query1);
        return purs;
    }
}