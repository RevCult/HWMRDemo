public with sharing class BuilderProjectMgmtApprovalExt {

	private final Project_Update_Request__c theProjectUpdateRequest;

    public BuilderProjectMgmtApprovalExt(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest())
            stdController.addFields( new list<string>( Project_Update_Request__c.sobjecttype.getdescribe().fields.getmap().keyset() ) );
        this.theProjectUpdateRequest = (Project_Update_Request__c)stdController.getRecord();
    }

    public PageReference updateProject() {
        Project__c theProject = [SELECT City__c,
                                County__c,
                                Do_Not_Call__c,
                                Email_Special__c,
                                FIPS__c,
                                HOA__c,
                                Location__Longitude__s,
                                Location__Latitude__s,
                                Master_Plan__c,
                                Max_Price__c,
                                Max_Unit_Size__c,
                                Min_Price__c,
                                Min_Unit_Size__c,
                                Open_Date__c,
                                Phone_Number__c,
                                Product_Type__c,
                                Alternate_Phone_Number__c,
                                Sales_Office_Notes__c,
             //                 Email_Special__c,
                                Project_Characteristics__c,
                                Region_ID__c,
                                Sales_and_Marketing_Firm__c,
                                Sales_Person_2__c,
                                Sales_Person_Name__c,
                                Sales_Rate__c,
                                Sold_Out_Date__c,
                                State__c,
                                Status__c,
                                Total_Remaining__c,
                                Total_Units_Planned__c,
                                Total_Units_Sold__c,
                                Typical_Lot_Size__c,
                                Website__c,
                                Last_Updated_Date_Price__c,
                                Last_Update_User_Price__c,
                                Last_Updated_Date_Sales__c,
                                Last_Update_User_Sales__c,
                                Prices_Verified__c,
                                Sales_Verified__c,
                                Meyers_Notes__c
                                FROM Project__c WHERE Id = :theProjectUpdateRequest.Project__c];
        theProject.City__c = theProjectUpdateRequest.City__c;
        theProject.County__c = theProjectUpdateRequest.County__c;
        theProject.Do_Not_Call__c = theProjectUpdateRequest.Do_Not_Call__c;
        theProject.Email_Special__c = theProjectUpdateRequest.Email_Special__c;
        theProject.Alternate_Phone_Number__c = theProjectUpdateRequest.Alternate_Phone_Number__c;
        theProject.Sales_Office_Notes__c = theProjectUpdateRequest.Sales_Office_Notes__c;
        theProject.FIPS__c = theProjectUpdateRequest.FIPS__c;
        theProject.HOA__c = theProjectUpdateRequest.HOA__c;
        theProject.Location__Longitude__s = theProjectUpdateRequest.Location__Longitude__s;
        theProject.Location__Latitude__s = theProjectUpdateRequest.Location__Latitude__s;
        theProject.Master_Plan__c = theProjectUpdateRequest.Master_Plan__c;
        theProject.Max_Price__c = theProjectUpdateRequest.Max_Price__c;
        theProject.Max_Unit_Size__c = theProjectUpdateRequest.Max_Unit_Size__c;
        theProject.Min_Price__c = theProjectUpdateRequest.Min_Price__c;
        theProject.Min_Unit_Size__c = theProjectUpdateRequest.Min_Unit_Size__c;
        theProject.Open_Date__c = theProjectUpdateRequest.Open_Date__c;
        theProject.Phone_Number__c = theProjectUpdateRequest.Phone_Number__c;
        theProject.Product_Type__c = theProjectUpdateRequest.Product_Type__c;
        theProject.Project_Characteristics__c = theProjectUpdateRequest.Project_Characteristics__c;
        theProject.Region_ID__c = theProjectUpdateRequest.Region_ID__c;
        theProject.Sales_and_Marketing_Firm__c = theProjectUpdateRequest.Sales_and_Marketing_Firm__c;
        theProject.Sales_Person_2__c = theProjectUpdateRequest.Sales_Person_2__c;
        theProject.Sales_Person_Name__c = theProjectUpdateRequest.Sales_Person_Name__c;
        theProject.Sales_Rate__c = theProjectUpdateRequest.Sales_Rate__c;
        theProject.Sold_Out_Date__c = theProjectUpdateRequest.Sold_Out_Date__c;
        theProject.State__c = theProjectUpdateRequest.State__c;
        theProject.Status__c = theProjectUpdateRequest.Status__c;
        theProject.Total_Remaining__c = theProjectUpdateRequest.Total_Remaining__c;
        theProject.Total_Units_Planned__c = theProjectUpdateRequest.Total_Units_Planned__c;
        theProject.Total_Units_Sold__c = theProjectUpdateRequest.Total_Units_Sold__c;
        theProject.Typical_Lot_Size__c = theProjectUpdateRequest.Typical_Lot_Size__c;
        theProject.Website__c = theProjectUpdateRequest.Website__c;
        theProject.Prices_Verified__c = theProjectUpdateRequest.Prices_Verified__c;
        theProject.Sales_Verified__c = theProjectUpdateRequest.Sales_Verified__c;
        theProject.Meyers_Notes__c = theProjectUpdateRequest.Meyers_Notes__c;
        //theProject.Last_Updated_Date_Price__c = theProjectUpdateRequest.Last_Updated_Date_Price__c;
        //theProject.Last_Update_User_Price__c = theProjectUpdateRequest.Last_Update_User_Price__c;
        //theProject.Last_Updated_Date_Sales__c = theProjectUpdateRequest.Last_Updated_Date_Sales__c;
        //theProject.Last_Update_User_Sales__c = theProjectUpdateRequest.Last_Update_User_Sales__c;

        update theProject;

        theProjectUpdateRequest.Update_Request_Status__c = 'Approved';
        update theProjectUpdateRequest;

        ApexPages.PageReference whereToGo = new ApexPages.PageReference('/'+theProject.Id);
        return whereToGo;
    }
}