@isTest
private class TestBPMPages {
	static void setupTestData() {
		Builder__c b1 = new Builder__c(
			Name = 'the builder'
		);
		insert b1;
        
		Data_User__c du1 = new Data_User__c( 
            Name = 'test user'
        );
		insert du1;
        
		Project__c p1 = new Project__c(
			Name = 'the project'
		,	Builder__c = b1.Id
		,	Data_User__c = du1.Id
			);
        p1.Update_Cycle__c = '25';
        //p1.Total_Units_Sold__c = 10;
        //p1.Total_Units_Planned__c = 14;
		insert p1;

		Plan__c plan1 = new Plan__c(
			Project__c = p1.Id
			);
        plan1.Last_Updated_Date_Price__c = System.today().addDays(4);
		insert plan1;

		Project_Contact__c pc1 = new Project_Contact__c(
			Name = 'the guy'
		,	Project__c = p1.Id
			);
		insert pc1;
	}
	
	@isTest static void TestLandingPage() {
		setupTestData();
		
        Data_User__c theDataUser = [SELECT Id FROM Data_User__c LIMIT 1];
		
        User theUser = [SELECT Id FROM User LIMIT 1];
		Project_Contact__c theProjectContact = [SELECT Id FROM Project_Contact__c LIMIT 1];
		Builder__c theSelectedBuilder = [SELECT Id FROM Builder__c LIMIT 1];

		PageReference landingPage = Page.BuilderProjectMgmt;
		landingPage.getParameters().put('userId', '');
		Test.setCurrentPage(landingPage);
		BuilderProjectMgmtExt contExt = new BuilderProjectMgmtExt(new ApexPages.Standardcontroller(new Builder__c()));

		contExt.getBuilders();

		contExt.goToProjectList();

		contExt.selectedBuilder = theSelectedBuilder.Id;

		contExt.goToProjectList();

		landingPage = Page.BuilderProjectMgmt;
		landingPage.getParameters().put('userId', theDataUser.Id);
		Test.setCurrentPage(landingPage);
		contExt = new BuilderProjectMgmtExt(new ApexPages.Standardcontroller(new Builder__c()));

		contExt.getBuilders();

		contExt.goToProjectList();

		contExt.selectedBuilder = theSelectedBuilder.Id;

		contExt.goToProjectList();

		landingPage = Page.BuilderProjectMgmt;
		landingPage.getParameters().put('userId', theUser.Id);
		Test.setCurrentPage(landingPage);
		contExt = new BuilderProjectMgmtExt(new ApexPages.Standardcontroller(new Builder__c()));

		contExt.getBuilders();

		contExt.goToProjectList();

		contExt.selectedBuilder = theSelectedBuilder.Id;

		contExt.goToProjectList();

		landingPage = Page.BuilderProjectMgmt;
		landingPage.getParameters().put('userId', theProjectContact.Id);
		Test.setCurrentPage(landingPage);
		contExt = new BuilderProjectMgmtExt(new ApexPages.Standardcontroller(new Builder__c()));

		contExt.getBuilders();

		contExt.goToProjectList();

		contExt.selectedBuilder = theSelectedBuilder.Id;

		contExt.goToProjectList();
	}
    
	@isTest static void TestListPage() {
		setupTestData();
		Data_User__c theDataUser = [SELECT Id FROM Data_User__c LIMIT 1];		
        User theUser = [SELECT Id FROM User LIMIT 1];
		Project_Contact__c theProjectContact = [SELECT Id FROM Project_Contact__c LIMIT 1];
		Builder__c theSelectedBuilder = [SELECT Id FROM Builder__c LIMIT 1];

		PageReference listPage = Page.BuilderProjectList;
		listPage.getParameters().put('userId', '');
		Test.setCurrentPage(listPage);
		BuilderProjectListExt contExt = new BuilderProjectListExt(new ApexPages.Standardcontroller(new Builder__c()));

		listPage = Page.BuilderProjectList;
		listPage.getParameters().put('userId', theDataUser.Id);
		listPage.getParameters().put('id', theSelectedBuilder.Id);
		Test.setCurrentPage(listPage);
		contExt = new BuilderProjectListExt(new ApexPages.Standardcontroller(new Builder__c()));
		contExt.getStatusOptions();
        contExt.getUpdateCycleOptions();
		contExt.selectedBuilder = theSelectedBuilder.Id;
		contExt.filterProjects();
		contExt.searchTerm = 'the';
		contExt.filterProjects();
		contExt.projectSearchTerm = 'project';
		contExt.filterProjects();
		contExt.getCurrentSetEnd();
		contExt.getCurrentSetStart();
		contExt.next();
		contExt.previous();
		contExt.first();
		contExt.last();
		contExt.getProjectsWithStatusSet();
		contExt.clearFilter();
		BuilderProjectListExt.searchBuilders('a', UserInfo.getUserId());
		BuilderProjectListExt.searchProjects('a', UserInfo.getUserId());
	}
    
    @isTest static void TestBPMAutoComplete() {
		setupTestData();
		Data_User__c theDataUser = [SELECT Id FROM Data_User__c LIMIT 1];
		User theUser = [SELECT Id FROM User LIMIT 1];
		Project_Contact__c theProjectContact = [SELECT Id FROM Project_Contact__c LIMIT 1];
		Builder__c theSelectedBuilder = [SELECT Id FROM Builder__c LIMIT 1];

		PageReference listPage = Page.BuilderProjectList;
		listPage.getParameters().put('userId', '');
		Test.setCurrentPage(listPage);
		BuilderProjectListExt contExt = new BuilderProjectListExt(new ApexPages.Standardcontroller(new Builder__c()));
		BuilderProjectMgmtAutocompleteExt auto = new BuilderProjectMgmtAutocompleteExt(new ApexPages.Standardcontroller(new Builder__c()));
		listPage = Page.BuilderProjectList;
		listPage.getParameters().put('userId', theDataUser.Id);
		listPage.getParameters().put('id', theSelectedBuilder.Id);
		Test.setCurrentPage(listPage);
		contExt = new BuilderProjectListExt(new ApexPages.Standardcontroller(new Builder__c()));
		contExt.getCurrentSetEnd();
		contExt.getCurrentSetStart();
		contExt.next();
		contExt.previous();
		contExt.first();
		contExt.last();
		contExt.getProjectsWithStatusSet();
		contExt.clearFilter();
        auto = new BuilderProjectMgmtAutocompleteExt(new ApexPages.Standardcontroller(new Builder__c()));
        auto.searchTerm = 'build';
        BuilderProjectMgmtAutocompleteExt.searchBuilders('b');
        //BuilderProjectMgmtAutocompleteExt.searchBuilders(auto.searchTerm);
	}
    
    @isTest static void TestEditPage() {
		setupTestData();
		Data_User__c theDataUser = [SELECT Id FROM Data_User__c LIMIT 1];
		User theUser = [SELECT Id FROM User LIMIT 1];
		Project_Contact__c theProjectContact = [SELECT Id FROM Project_Contact__c LIMIT 1];
		Builder__c theSelectedBuilder = [SELECT Id FROM Builder__c LIMIT 1];
		Project__c theProject = [SELECT Id
							        ,   Account__c
							        ,   Builder__c
							        ,   Call_Center_Disposition__c
							        ,   Call_Center_Notes__c
							        ,   County__c
							        ,   Do_Not_Call__c
							        ,   Email_Special__c
							        ,   FIPS__c
							        ,   HOA__c
                                 	,	HOA_NA__c
							        ,   Location__Latitude__s
							        ,   Location__Longitude__s
							        ,   Master_Plan__c
							        ,   Max_Price__c
							        ,   Max_Unit_Size__c
							        ,   Meyers_Disposition__c
							        ,   Meyers_Notes__c
							        ,   Min_Price__c
							        ,   Min_Unit_Size__c
							        ,   Open_Date__c
							        ,   Phone_Number__c
							        ,   Product_Type__c
							        ,   Project_Characteristics__c
							        ,   Project_ID_Legacy__c
							        ,   Region_ID__c
							        ,   Sales_and_Marketing_Firm__c
							        ,   Sales_Person_2__c
							        ,   Sales_Person_Name__c
							        ,   Sales_Rate__c
							        ,   Sold_Out_Date__c
							        ,   State__c
							        ,   Status__c
							        ,   Total_Remaining__c
							        ,   Total_Units_Planned__c
							        ,   Total_Units_Sold__c
							        ,   Typical_Lot_Size__c
							        ,   Website__c
    								,   City__c
    								,   Prices_Verified__c
    								,   Sales_Verified__c
							        ,   Lot_Dimension__c
							        ,   HOA_2__c
							        ,   Assessments__c
							        ,   Assessments_Dollar__c
							        ,   Assessment_Description__c
							        ,   HOA_Description__c
							        ,   Monthly_HOA_SF__c
                                 	,	Monthly_HOA_SF_NA__c
							        ,   Incentive_Options__c
                                 	,	MeyersNotesCounter__c
                                 	,	Alternate_Phone_Number__c
                                 	,	Sales_Office_Notes__c
                                 	,	Assessments_Dollar_NA__c
                                 	,	Meyers_Disposition_calc__c
                                 	,	Meyers_Notes_internal__c, HOA_2_NA__c
                                    ,	To_Be_Built_Incentives__c, Quick_Move_In_Incentives__c, Broker_Co_Op_Incentives__c, To_Be_Built_Incentives_Unchanged__c, Quick_Move_In_Incentives_Unchanged__c, Broker_Co_Op_Incentives_Unchanged__c
                                 	,	Units_under_construction__c 
                                 	,	Unsold_units_under_construction__c
                                FROM Project__c LIMIT 1];
        
        insert (new Project_Update_Request__c(Project__c = theProject.Id));

		PageReference editPage = Page.BuilderProjectEdit;
		Test.setCurrentPage(editPage);
		BuilderProjectEditExt contExt = new BuilderProjectEditExt(new ApexPages.Standardcontroller(theProject));


		editPage = Page.BuilderProjectEdit;
		editPage.getParameters().put('id', theProject.Id);
		editPage.getParameters().put('userId', theDataUser.Id);
		contExt.init();
		Test.setCurrentPage(editPage);
		contExt = new BuilderProjectEditExt(new ApexPages.Standardcontroller(theProject));
		contExt.getPlans();
		contExt.getLastFiveActivities();
		contExt.logCall();
		contExt.saveNewAndFinishLater();
		contExt.saveAndSubmitNew();
        BuilderProjectEditExt.searchMasterPlans('dsfd');        

		Project_Update_Request__c thePUR = [SELECT Id
                                            ,   Account__c
                                            ,   Builder__c
                                            ,   Call_Center_Disposition__c
							        		,   Call_Center_Notes__c
							        		,   County__c
							        		,   Do_Not_Call__c
							        		,   Email_Special__c
							        		,   FIPS__c
							        		,   HOA__c
		                            		,   Last_Updated_Date_Price__c
		                            		,   Last_Update_User_Price__c
		                            		,   Last_Updated_Date_Sales__c
		                            		,   Last_Update_User_Sales__c
							        		,   Location__Latitude__s
							        		,   Location__Longitude__s
							        		,   Master_Plan__c
							        		,   Max_Price__c
							        		,   Max_Unit_Size__c
							        		,   Meyers_Disposition__c
							        		,   Meyers_Notes__c
							        		,   Min_Price__c
							        		,   Min_Unit_Size__c
							        		,   Open_Date__c
							        		,   Phone_Number__c
							        		,   Product_Type__c
							        		,   Project_Characteristics__c
							        		,   Project_ID_Legacy__c
							        		,   Region_ID__c
							        		,   Sales_and_Marketing_Firm__c
							        		,   Sales_Person_2__c
							        		,   Sales_Person_Name__c
							        		,   Sales_Rate__c
							        		,   Sold_Out_Date__c
							        		,   State__c
							        		,   Status__c
							        		,   Total_Remaining__c
							        		,   Total_Units_Planned__c
							        		,   Total_Units_Sold__c
							        		,   Typical_Lot_Size__c
							        		,   Website__c
    										,   City__c
    										,	Project__c
    										,   Prices_Verified__c
    										,   Sales_Verified__c
                                            ,	Alternate_Phone_Number__c
                                            ,	Sales_Office_Notes__c
                                            ,	Units_under_construction__c 
                                 			,	Unsold_units_under_construction__c
    									 FROM Project_Update_Request__c LIMIT 1];
		PageReference purApprovalPage = Page.BuilderProjectMgmtApproval;
        contExt.theProjectUpdateRequest = thePUR;
        thePUR.Status__c = 'Active';
        contExt.logCall();
		Test.setCurrentPage(purApprovalPage);
		BuilderProjectMgmtApprovalExt apprExtension = new BuilderProjectMgmtApprovalExt(new ApexPages.Standardcontroller(thePUR));

		apprExtension.updateProject();

		editPage = Page.BuilderProjectEdit;
		editPage.getParameters().put('id', theProject.Id);
		editPage.getParameters().put('userId', theDataUser.Id);
		editPage.getParameters().put('purId', thePUR.Id);
		Test.setCurrentPage(editPage);
		contExt = new BuilderProjectEditExt(new ApexPages.Standardcontroller(theProject));
		contExt.init();
		contExt.getPlans();

		contExt.saveUpdateAndFinishLater();
		contExt.saveAndSubmitUpdate();

		contExt.getPlans();
		contExt.getPlanUpdateRequests();

		contExt.addPlan();
		contExt.addPlanAndPlur();

		contExt.getPlans();
		contExt.getPlanUpdateRequests();

		// testing the PLUR trigger really quick, too...
		/*List<Plan_Update_Request__c> thePLURS = [SELECT Id, Update_Request_Status__c FROM Plan_Update_Request__c];
		for (Plan_Update_Request__c plur : thePLURs) {
			plur.Update_Request_Status__c = 'Approved';
		}
		update thePLURs;*/
		
	}
    

	@isTest static void TestPURCreatePage() {
		setupTestData();
		PageReference purPage = Page.ProjectUpdateRequestCreate;
		Test.setCurrentPage(purPage);
		Project__c theProject = [SELECT Id FROM Project__c LIMIT 1];
		ProjectUpdateRequestCreateExt contExt = new ProjectUpdateRequestCreateExt(new ApexPages.Standardcontroller(new Project_Update_Request__c()));

		contExt.goSomewhere();

		contExt = new ProjectUpdateRequestCreateExt(new ApexPages.Standardcontroller(new Project_Update_Request__c(Project__c = theProject.Id)));

		contExt.goSomewhere();
        //contExt.createUpdateRequest(true);


	}
	
}