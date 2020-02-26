public without sharing class BuilderProjectEditExt {

	private Project__c theProject;
    private List<Task> tasksToInsertToPurUponSaveNew = new List<Task>();
    private String purId {get; set;}
    
    public Project_Update_Request__c theProjectUpdateRequest {get; set;}
    public List<Task> lastFiveActivities {private get; private set;}
    public List<Plan__c> plans = new List<Plan__c>();
    public List<Plan_Update_Request__c> planUpdateRequests = new List<Plan_Update_Request__c>();
    
    public String userId {get; set;}
    public String userType {get; set;}
    public String userName {get; set;}
    public String pageMode {get; private set;}
    public String searchTerm {get; set;}
    public String callNotes {get; set;}
    public Boolean isProjectAllowedToBeWorked {get; private set;}

    public BuilderProjectEditExt(ApexPages.StandardController stdController) {
        callNotes = '';
        if (!Test.isRunningTest()) 
            stdController.addFields( new list<string>( Project__c.sobjecttype.getdescribe().fields.getmap().keyset() ) );

        theProject = (Project__c)stdController.getRecord();
                
        if (null != ApexPages.currentPage().getParameters().get('userId')) {
            userId = ApexPages.currentPage().getParameters().get('userId');
            userType = BuilderProjectMgmtCmn.getUserType(userId);
            userName = BuilderProjectMgmtCmn.getUserName(userId);
        }

        pageMode = 'project'; // THIS MEANS THIS IS A "FRESH" UPDATE REQUEST, NOT A CONTINUANCE OF ONE STARTED EARLIER
        if (null != ApexPages.currentPage().getParameters().get('purId')) { // DID WE GET A PUR ID PASSED IN?
            purId = ApexPages.currentPage().getParameters().get('purId'); // IF SO, LET'S GO GET THE PUR ITSELF
            theProjectUpdateRequest = [SELECT Id
                                       , Status__c
                                       , Phone_Number__c
                                       , Sales_and_Marketing_Firm__c
                                       , Sales_Person_Name__c
                                       , Sales_Person_2__c
                                       , Website__c
                                       , FIPS__c
                                       , Master_Plan__c
                                       , Product_Type__c
                                       , Typical_Lot_Size__c
                                       , Open_Date__c
                                       , Sold_Out_Date__c
                                       , Total_Units_Planned__c
                                       , Total_Units_Sold__c
                                       , Total_Remaining__c
                                       , HOA__c
                                       , HOA_2__c
                                       , Monthly_HOA_SF__c
                                       , HOA_Description__c
                                       , Meyers_Notes__c
                                       , Min_Unit_Size__c
                                       , Max_Unit_Size__c
                                       , Min_Price__c
                                       , Max_Price__c
                                       //, Prices_Verified__c
                                       , Sales_Verified__c
                                       //, HOA_NA__c
                                       //, HOA_2_NA__c
                                       //, Assessments_Dollar_NA__c
                                       //, Monthly_HOA_SF_NA__c
                                       , Lot_Dimension__c
                                       , Assessments__c
                                       , Assessments_Dollar__c
                                       , Assessment_Description__c
                                       , Total_Remaining_calc__c
                                       , Incentive_Options__c
                                       , Project__c
                                       // Newer Fields
                                       , MeyersNotesCounter__c, Alternate_Phone_Number__c, Sales_Office_Notes__c, Email_Special__c
                                       //, Units_under_construction__c, Unsold_units_under_construction__c, Last_Updated_Date_UUC__c, Last_Updated_Date_UnUUC__c
                                       , To_Be_Built_Incentives__c, Quick_Move_In_Incentives__c, Broker_Co_Op_Incentives__c, To_Be_Built_Incentives_Unchanged__c, Quick_Move_In_Incentives_Unchanged__c, Broker_Co_Op_Incentives_Unchanged__c
                                       , Meyers_Notes_internal__c, Auto_Approved__c, Sales_based_on_closing_data__c, Multiple_Atempts__c, Sales_Rate_Validated__c, Meyers_Disposition_calc__c
                                       , Previously_Set_to_Review__c
                                       // Added for the Auto Approval Checks
                                       , Days_Since_Data_User_Created__c
                                       , Num_of_Days_Since_Last_Update__c
                                       , Previous_No_Of_Times_Auto_Approved__c
                                       , Previous_Status__c
                                       , Previous_Product_Type__c
                                       , Previous_Lot_Dimension__c
                                       , Previous_Open_Date__c
                                       , Previous_Sold_Out_Date__c
                                       , Previous_Typical_Lot_Size__c
                                       , Previous_HOA__c
                                       , Previous_HOA_2__c
                                       , Previous_Assessments__c
                                       , Previous_Total_Units_Sold__c
                                       , Previous_Total_Units_Planned__c
                                       , Previous_Meyers_Disposition_calc__c
                                       FROM Project_Update_Request__c WHERE Id = :purId];
            if (null != theProjectUpdateRequest){ // WERE WE ABLE TO RETRIEVE ONE?
                pageMode = 'pur'; // LET'S SET THE PAGE MODE SO WE KNOW ON THE PAGE THAT WE'RE WORKING WITH AN EXISTING UPDATE REQUEST, NOT CREATING A NEW ONE
            }
        }
        isProjectAllowedToBeWorked = preValidation('onload');        
    }

    private Boolean preValidation(String callerType) {
        Boolean isValid = true;

        // If the Project's Last_Price_Update_display__c is within (today minus the Update Days value) 
        //  AND 
        // the Project's Last_Updated_Date_Sales__c is within (today minus the Update Days value) 
        // then this Project should not be worked

        Project__c theProjectNow = theProject;
        if (theProject.Id != null) {
            theProjectNow = [SELECT Id, Update_Cycle_Days__c, Last_Price_Update_display__c, Last_Updated_Date_Sales__c
                             , Last_Updated_Date_Quick_Move_Incentives__c, Last_Updated_Date_Broker_Co_Cop_Incenti__c, Last_Updated_Date_To_Be_Built_Incentive__c
                             , ZIC_Date__c, Update_Cycle__c
                             //, Meyers_Notes_internal__c
                             , (Select LastModifiedDate, Update_Request_Status__c, Update_Request_Type__c From Project_Update_Requests__r) FROM Project__c WHERE Id =: theProject.Id];
        }

        
        //Start ZIC_Date
        if (theProject.Id == null) {
            if (null != theProjectNow.Update_Cycle__c) {
                theProjectNow.ZIC_Date__c = System.today().addDays(Integer.valueOf(theProjectNow.Update_Cycle__c));
            } else {
                theProjectNow.ZIC_Date__c = System.today();
            }
        }
        /*  else if(theProject.Id != null && !ISNEW()){
              theProjectNow.ZIC_Date__c = System.today().addDays(theProjectNow.Update_Cycle__c);
          }
          else if(theProject.Id != null && !ISNEW()){
              theProjectNow.ZIC_Date__c = theProjectNow.LastModifiedDate().addDays(theProjectNow.Update_Cycle__c);
          }*/
        // End ZIC Date

        
        Date beginningOfUpdateCycle = System.today().addDays(-Integer.valueOf(theProjectNow.Update_Cycle_Days__c));
        system.debug('beginningOfUpdateCycle: ' + beginningOfUpdateCycle);
        system.debug('theProjectNow.Last_Price_Update_display__c: ' + theProjectNow.Last_Price_Update_display__c);
        system.debug('theProjectNow.Last_Updated_Date_Sales__c: ' + theProjectNow.Last_Updated_Date_Sales__c);

        if (theProjectNow.Last_Price_Update_display__c > beginningOfUpdateCycle &&
            theProjectNow.Last_Updated_Date_Sales__c > beginningOfUpdateCycle) {
            isValid = false;
        }

        //if (!isValid) {
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //List<String> emailAddressList = ZicSiteSetting__c.getInstance('Error Emails').Value__c.split(';');

        //email.setToAddresses(emailAddressList);
        //email.setReplyTo('noreply@zonda.co');
        //email.setSenderDisplayName('Meyers Research ZIC Site Issue');
        //email.setSubject('Meyers Research :: Project Failed PreValidation '+callerType);
        //String body = 'The following Project failed PreValidation '+callerType+': '+theProject.Id+'<br/><br/>';
        //body += 'theProjectNow: '+theProjectNow;
        //if (theProjectUpdateRequest != null) {
        //    body += '<br/><br/>theProjectUpdateRequest: '+theProjectUpdateRequest;
        //}
        //if (userName != null) {
        //    body += '<br/><br/>userName: '+userName;
        //}
        //email.setHtmlBody(body);

        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });    
        //}

        return isValid;
    }

    public void init() {
        system.debug('inside init()');
        if (null != ApexPages.currentPage().getParameters().get('id')) {
            Id projectId = ApexPages.currentPage().getParameters().get('id');
            if (null != ApexPages.currentPage().getParameters().get('purId')) { // DID WE GET A PUR ID PASSED IN?
                purId = ApexPages.currentPage().getParameters().get('purId'); // IF SO, LET'S GO GET THE PUR ITSELF
                // We need to go check if there are any Plans for the Project that don't have Plan Update Requests [but should]:
                createPlanUpdateRequestsIfMissing(projectId, purId);
            }
        }
    }

    private void createPlanUpdateRequestsIfMissing(Id projectId, Id projectUpdateRequestId) {
        if (null != theProjectUpdateRequest && null != theProjectUpdateRequest.Project__c) {
            List < Plan__c > allPlansForProject = new List < Plan__c > ();
            List < Plan_Update_Request__c > plursThatNeedToBeCreated = new List < Plan_Update_Request__c > ();
            allPlansForProject = Database.query(Utils.getSelectStarQueryForSobjectType('Plan__c') + ' WHERE Project__c = \'' + projectId + '\' and Hidden_from_ZIC_site__c = FALSE ORDER BY Name');
            if (!allPlansForProject.isEmpty()) {
                List < Plan_Update_Request__c > existingPLURs = new List < Plan_Update_Request__c > ();
                existingPLURs = Database.query(Utils.getSelectStarQueryForSobjectType('Plan_Update_Request__c') + ' WHERE Project_Update_Request__c = \'' + projectUpdateRequestId + '\' ORDER BY Name');
                Map < Id, Plan_Update_Request__c > mapPlanIdToPLUR = new Map < Id, Plan_Update_Request__c > ();
                if (!existingPLURs.isEmpty()) {
                    for (Plan_Update_Request__c plur: existingPLURs) {
                        mapPlanIdToPLUR.put(plur.Plan__c, plur);
                    }
                }

                for (Plan__c p : allPlansForProject) {
                    if (!mapPlanIdToPLUR.containsKey(p.Id)) {
                        plursThatNeedToBeCreated.add(
                                new Plan_Update_Request__c(
                                    Plan__c = p.Id
                                ,   Project__c = p.Project__c
                                ,   Project_Update_Request__c = theProjectUpdateRequest.Id
                                ,   Plan_Name__c = p.Name
                                ,   Num_of_Baths__c = p.Num_of_Baths__c
                                ,   Num_of_Full_Baths__c = p.Num_of_Full_Baths__c
                                ,   Num_of_Half_Baths__c = p.Num_of_Half_Baths__c
                                ,   Num_of_Beds__c = p.Num_of_Beds__c
                                ,   Square_Footage__c = p.Square_Footage__c
                                ,   Plan_Notes__c = p.Plan_Notes__c
                                ,   Price__c = Integer.valueOf(p.Price__c)
                                ,   Price_Unchanged__c = p.Price_Unchanged__c
                                ,   Num_of_Floors__c = p.Num_of_Floors__c
                                ,   Garage__c = p.Garage__c
                                ,   Previous_Plan_Name__c = p.Name
                                ,   Previous_Price__c = Integer.valueOf(p.Price__c)
                                ,   Previous_Num_of_Baths__c = p.Num_of_Baths__c
                                ,   Previous_Num_of_Full_Baths__c = p.Num_of_Full_Baths__c
                                ,   Previous_Num_of_Half_Baths__c = p.Num_of_Half_Baths__c
                                ,   Previous_Num_of_Beds__c = p.Num_of_Beds__c
                                ,   Previous_Square_Footage__c = p.Square_Footage__c
                                ,   Previous_Plan_Notes__c = p.Plan_Notes__c
                                ,   Previous_Num_of_Floors__c = p.Num_of_Floors__c
                                ,   Previous_Garage__c = p.Garage__c
                                ,   Update_Request_Status__c = 'In Progress'
                                ,	Display_in_Zonda__c = p.Display_in_Zonda__c
                                    )
                        );
                    }
                }
                if (!plursThatNeedToBeCreated.isEmpty()) {
                    insert plursThatNeedToBeCreated;
                }
            }
        }
    }

    /**
        To get Plans when you're working on a "fresh" project update request:
    */
    public List<Plan__c> getPlans() {
        if (plans.isEmpty())
            plans = [SELECT Id, Name, Project__c, Last_Updated_Date_Price__c, Num_of_Beds__c, Num_of_Baths__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, Square_Footage__c, Price__c, Plan_Notes__c, External_Id__c, LastModifiedDate, Num_of_Floors__c, Garage__c, Price_Unchanged__c, Off_Market__c, Display_in_Zonda__c FROM Plan__c WHERE Project__c =: theProject.Id and Hidden_from_ZIC_site__c !=: TRUE ORDER BY Name];
        return plans;
    }

    /**
        Adds a Plan when you're working on a "fresh" update and need another plan entry
    */
    public void addPlan() {
        Plan__c p = new Plan__c(
            Name = 'New Plan'
        ,   Project__c = theProject.Id
        ,   Display_in_Zonda__c = FALSE
        );
        insert p;

        plans.add(p);
    }

    /**
        Adds a Plan AND PLUR when you're working on a "continued" update and need another plan entry
    */
    public void addPlanAndPlur() {
        if (!planUpdateRequests.isEmpty())
            update planUpdateRequests;
        
        Plan__c p = new Plan__c(
            Name = 'New Plan'
        ,   Project__c = theProject.Id
        ,   Display_in_Zonda__c = FALSE
        );
        insert p;
        Plan_Update_Request__c plur = new Plan_Update_Request__c(
            Plan__c = p.Id
        ,   Project__c = theProject.Id
        ,   Project_Update_Request__c = theProjectUpdateRequest.Id
        ,   Plan_Name__c = p.Name
        );
        insert plur;
    }

    /**
        To get Plan Update Requests when you're working on a "continued" project update request [we create a PLUR for every plan on the "fresh" request]:
    */
    public List<Plan_Update_Request__c> getPlanUpdateRequests() {
        planUpdateRequests = [SELECT Id, Plan__c, Name, Plan_Name__c, Project__c, Num_of_Beds__c, Num_of_Baths__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, Square_Footage__c, Price__c, Plan_Notes__c, Plan__r.External_Id__c, Plan__r.LastModifiedDate, Plan__r.Last_Updated_Date_Price__c, Num_of_Floors__c, Garage__c, LastModifiedDate, Price_Unchanged__c, Off_Market__c, Previous_Price__c, Display_in_Zonda__c FROM Plan_Update_Request__c WHERE Project_Update_Request__c =: theProjectUpdateRequest.Id ORDER BY Name];
        return planUpdateRequests;
    }

    private Boolean validateSave() {
        Boolean validated = true;
        Boolean theresAPlanIssue = false;

        validated = preValidation('onsave');
        // if we failed at preValidation, add a message about why it's failing:
        if (!validated) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Project should not be in your Project List. Please send Project link to your coordinator.'));
        }

        if (pageMode == 'pur') {
            if (theProjectUpdateRequest.Total_Units_Sold__c > theProjectUpdateRequest.Total_Units_Planned__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Units Sold is greater than Total Units Planned'));
                validated = false;
            }
            /* //HIDE THE UNITS UNDER CONSTRUCTION WORK 
            } else if ((theProjectUpdateRequest.Units_under_construction__c > theProjectUpdateRequest.Total_Units_Planned__c) || (theProjectUpdateRequest.Units_under_construction__c != null && theProjectUpdateRequest.Total_Units_Planned__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Units Under construction must be less than Total Units Planned'));
                validated = false;
            } else if ((theProjectUpdateRequest.Unsold_units_under_construction__c > theProjectUpdateRequest.Total_Units_Planned__c) || (theProjectUpdateRequest.Unsold_units_under_construction__c != null && theProjectUpdateRequest.Total_Units_Planned__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unsold Units Under construction must be less than Total Units Planned'));
                validated = false;
            } else if ((theProjectUpdateRequest.Unsold_units_under_construction__c > theProjectUpdateRequest.Units_under_construction__c) || (theProjectUpdateRequest.Unsold_units_under_construction__c != null && theProjectUpdateRequest.Units_under_construction__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unsold Units Under Construction cannot be greater than Units Under Construction'));
                validated = false;
            }*/


            // SFDC-62: (05.19.2016)
            // Prevent ZICs from submitting without either: price changes or the price unchanged boxed selected or 
            // the plan level "Off-Market" check box being checked for all plans.  
            // This needs to be specific for Active Projects as Upcoming projects may not have prices available.
            if (theProjectUpdateRequest.Status__c == 'Active') {
                for (Plan_Update_Request__c plur: planUpdateRequests) {
                    if (!plur.Off_Market__c && !plur.Price_Unchanged__c && plur.Price__c == plur.Previous_Price__c) {
                        theresAPlanIssue = true;
                        validated = false;
                    }
                }
            }
        } else { // this is a NEW update
            if (theProject.Total_Units_Sold__c > theProject.Total_Units_Planned__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Units Sold is greater than Total Units Planned'));
                validated = false;
            }
           /* //HIDE THE UNITS UNDER CONSTRUCTION WORK 
           } else if ((theProject.Units_under_construction__c > theProject.Total_Units_Planned__c) || (theProject.Units_under_construction__c != null && theProject.Total_Units_Planned__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Units Under construction must be less than Total Units Planned'));
                validated = false;
            } else if ((theProject.Unsold_units_under_construction__c > theProject.Total_Units_Planned__c) || (theProject.Unsold_units_under_construction__c != null && theProject.Total_Units_Planned__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unsold Units Under construction must be less than Total Units Planned'));
                validated = false;
            } else if ((theProject.Unsold_units_under_construction__c > theProject.Units_under_construction__c) || (theProject.Unsold_units_under_construction__c != null && theProject.Units_under_construction__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unsold Units Under Construction cannot be greater than Units Under Construction'));
                validated = false;
            }*/

            // SFDC-62: (05.19.2016)
            // Prevent ZICs from submitting without either:
            //   price changes or 
            //   the price unchanged boxed selected or 
            //   the plan level "Off-Market" check box being checked 
            // for all plans.  
            // This needs to be specific for Active Projects as Upcoming projects may not have 
            //   prices available.
            Map < Id, Plan__c > existingPlanValues = new Map < Id, Plan__c > ([SELECT Id, Price__c FROM Plan__c WHERE ID IN: plans]);
            if (theProject.Status__c == 'Active') {
                for (Plan__c p: plans) {
                    if (!p.Off_Market__c && !p.Price_Unchanged__c && p.Price__c == existingPlanValues.get(p.Id).Price__c) {
                        theresAPlanIssue = true;
                        validated = false;
                    }
                }
            }
        }

        if (theresAPlanIssue) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All Plans must have Price information submitted or be Off-Market.'));
        }

        return validated;
    }


    /**
        Methods for when a User is working on a previously created Update Request:
    */

    // this is for when a user is updating an update request they started previously, but they're still not done
    public PageReference saveUpdateAndFinishLater() {
        System.debug('saveUpdateAndFinishLater');
        update theProjectUpdateRequest;
        update planUpdateRequests;
		
        ApexPages.PageReference whereToGo = Page.BuilderProjectList;
        System.debug('saveUpdateAndFinishLater after');
        if (null != userId && '' != userId) {
            whereToGo.getParameters().put('userId', userId);
        }
        whereToGo.setRedirect(TRUE);
        return whereToGo;
    }

    // this is for when a user is updating an update request they started previously, and they want to submit it
    public PageReference saveAndSubmitUpdate() {
        				system.debug('Inside submitting an in progress PUR and PLURs');
        
        if (!validateSave()) return null;
        theProjectUpdateRequest.Update_Request_Status__c = 'Pending';
        update theProjectUpdateRequest;

        for (Plan_Update_Request__c plur : planUpdateRequests) {
            plur.Update_Request_Status__c = 'Pending';
        }
        update planUpdateRequests;
        
        ApexPages.PageReference whereToGo = Page.BuilderProjectList;
        if (null != userId && '' != userId) {
            whereToGo.getParameters().put('userId', userId);
        }
        
        //Pass PUR to Auto Approval checks;
        List<Project_Update_Request__c> pursForAutoApprovalCheck = new List < Project_Update_Request__c > ();
        pursForAutoApprovalCheck.add(theProjectUpdateRequest);
        If (theProjectUpdateRequest.Update_Request_Status__c == 'Pending'){
            system.debug('Start the Auto Approval Checks - Previously Saved');
            system.debug('pur: ' + theProjectUpdateRequest);
            system.debug('pursForAutoApprovalCheck: ' + pursForAutoApprovalCheck);
            trgPURAutoApproval.PURAutoApprovalCriteria(pursForAutoApprovalCheck);
        }

        
        whereToGo.setRedirect(TRUE);
        return whereToGo;
    }

    /**
        Methods for when a User is working on a brand new Update Request:
    */

    // this is for when a user is submitting an update request for a project, but they're not done with it yet
    public PageReference saveNewAndFinishLater() {
        System.debug('saveNewAndFinishLater');
        PageReference whereToGo;
        try{
            whereToGo = createUpdateRequest(false);
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record could not saved:'+ exp.getMessage()));
        }
        return whereToGo;
    }

    // this is for when a user is submitting a brand new update request for a project and they finished the update request in one sitting
    public PageReference saveAndSubmitNew() {
        system.debug('Inside submitting an brand NEW PUR and PLURs');
        if (!validateSave()) return null;
        PageReference whereToGo;
        try{
            whereToGo = createUpdateRequest(true);
        }catch(Exception exp){
            System.debug('EXCP :' + exp.getStackTraceString());
            System.debug('EXCP :' + exp.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record could not saved:'+ exp.getMessage())); 
        }
       
        return whereToGo;
    }

    // create a Project Update Request [update request type = "update"; project__c = id of project that's getting updated]
    // populate the current values into the record
    public PageReference createUpdateRequest(Boolean isComplete) {
        system.debug('In createUpdateRequest Method');
        Project_Update_Request__c pur = new Project_Update_Request__c(
              Project__c = theProject.Id
            , Update_Request_Type__c = 'Update'
            , Account__c = theProject.Account__c
            , Builder__c = theProject.Builder__c
            , Call_Center_Disposition__c = theProject.Call_Center_Disposition__c
            , Call_Center_Notes__c = theProject.Call_Center_Notes__c
            , Do_Not_Call__c = theProject.Do_Not_Call__c
            , Email_Special__c = theProject.Email_Special__c
            , FIPS__c = theProject.FIPS__c
            , HOA__c = theProject.HOA__c
            , Location__Latitude__s = theProject.Location__Latitude__s
            , Location__Longitude__s = theProject.Location__Longitude__s
            , Master_Plan__c = theProject.Master_Plan__c
            , Max_Price__c = theProject.Max_Price__c
            , Max_Unit_Size__c = theProject.Max_Unit_Size__c
            , Meyers_Disposition__c = theProject.Meyers_Disposition__c
            , Meyers_Notes__c = theProject.Meyers_Notes__c
            , Min_Price__c = theProject.Min_Price__c
            , Min_Unit_Size__c = theProject.Min_Unit_Size__c
            , Open_Date__c = theProject.Open_Date__c
            , Phone_Number__c = theProject.Phone_Number__c
            , Product_Type__c = theProject.Product_Type__c
            , Project_Characteristics__c = theProject.Project_Characteristics__c
            , Project_ID_Legacy__c = theProject.Project_ID_Legacy__c
            , Region_ID__c = theProject.Region_ID__c
            , Sales_and_Marketing_Firm__c = theProject.Sales_and_Marketing_Firm__c
            , Sales_Person_2__c = theProject.Sales_Person_2__c
            , Sales_Person_Name__c = theProject.Sales_Person_Name__c
            , Sales_Rate__c = theProject.Sales_Rate__c
            , Sold_Out_Date__c = theProject.Sold_Out_Date__c
            , Status__c = theProject.Status__c
            , Total_Remaining__c = theProject.Total_Remaining__c
            , Total_Units_Planned__c = theProject.Total_Units_Planned__c
            , Total_Units_Sold__c = theProject.Total_Units_Sold__c
            , Typical_Lot_Size__c = theProject.Typical_Lot_Size__c
            , Website__c = theProject.Website__c
            //, Prices_Verified__c = theProject.Prices_Verified__c
            //, HOA_NA__c = theProject.HOA_NA__c
            //, HOA_2_NA__c = theProject.HOA_2_NA__c
            //, Assessments_Dollar_NA__c = theProject.Assessments_Dollar_NA__c
            //, Monthly_HOA_SF_NA__c = theProject.Monthly_HOA_SF_NA__c
			, Sales_Verified__c = theProject.Sales_Verified__c
            , Lot_Dimension__c = theProject.Lot_Dimension__c
            , HOA_2__c = theProject.HOA_2__c
            , Assessments__c = theProject.Assessments__c
            , Assessments_Dollar__c = theProject.Assessments_Dollar__c
            , Assessment_Description__c = theProject.Assessment_Description__c
            , HOA_Description__c = theProject.HOA_Description__c
            , Monthly_HOA_SF__c = theProject.Monthly_HOA_SF__c
            , Incentive_Options__c = theProject.Incentive_Options__c
            //, Units_under_construction__c = theProject.Units_under_construction__c, Unsold_units_under_construction__c = theProject.Unsold_units_under_construction__c   
            , MeyersNotesCounter__c = theProject.MeyersNotesCounter__c, Alternate_Phone_Number__c = theProject.Alternate_Phone_Number__c
            , Sales_Office_Notes__c = theProject.Sales_Office_Notes__c, Meyers_Disposition_calc__c = theProject.Meyers_Disposition_calc__c
            //, Email_Special__c = theProject.Email_Special__c
            , Meyers_Notes_internal__c = theProject.Meyers_Notes_internal__c
            , To_Be_Built_Incentives__c = theProject.To_Be_Built_Incentives__c, Broker_Co_Op_Incentives__c = theProject.Broker_Co_Op_Incentives__c, Quick_Move_In_Incentives__c = theProject.Quick_Move_In_Incentives__c
            , To_Be_Built_Incentives_Unchanged__c = theProject.To_Be_Built_Incentives_Unchanged__c, Quick_Move_In_Incentives_Unchanged__c = theProject.Quick_Move_In_Incentives_Unchanged__c, Broker_Co_Op_Incentives_Unchanged__c = theProject.Broker_Co_Op_Incentives_Unchanged__c
            //, Sales_based_on_closing_data__c = theProject.Closing_data__c // This field needs to be defaulted to unchecked -- should not be populated
            );

        // select the currently saved values for the related Project out of the db
        Project__c theProjectCurrentValues = [SELECT Id
                                                ,   Account__c
                                              , Builder__c
                                              , Do_Not_Call__c
                                              , Email_Special__c
                                              , FIPS__c
                                              , HOA__c
                                              , Location__Longitude__s
                                              , Location__Latitude__s
                                              , Master_Plan__c
                                              , Master_Plan__r.Name
                                              , Max_Price__c
                                              , Max_Unit_Size__c
                                              , Meyers_Notes__c
                                              , Min_Price__c
                                              , Min_Unit_Size__c
                                              , Open_Date__c
                                              , Phone_Number__c
                                              , Product_Type__c
                                              , Project_Characteristics__c
                                              , Region_ID__c
                                              , Sales_and_Marketing_Firm__c
                                              , Sales_Person_2__c
                                              , Sales_Person_Name__c
                                              , Sales_Rate__c
                                              , Sold_Out_Date__c
                                              , Status__c
                                              , Total_Remaining__c
                                              , Total_Units_Planned__c
                                              , Total_Units_Sold__c
                                              , Typical_Lot_Size__c
                                              , Website__c
                                              , Last_Updated_Date_Sales__c
                                              , Last_Updated_Date_Price__c
                                              , Last_Price_Update_display__c // this is the displayed price date -- from the plans
                                              , Last_Update_User_Sales__c
                                              , Last_Update_User_Price__c
                                              , HOA_2__c
                                              //, HOA_NA__c
                                              //, HOA_2_NA__c
                                              //, Assessments_Dollar_NA__c
                                              //, Monthly_HOA_SF_NA__c
                                              , Assessments__c
                                              , Assessments_Dollar__c
                                              , Assessment_Description__c
                                              , Lot_Dimension__c
                                              , HOA_Description__c
                                              , Monthly_HOA_SF__c
                                              , Incentive_Options__c
                                              //, Units_under_construction__c, Unsold_units_under_construction__c, Last_Updated_Date_UUC__c, Last_Updated_Date_UnUUC__c
                                              , MeyersNotesCounter__c
                                              , Alternate_Phone_Number__c
                                              , Sales_Office_Notes__c
                                              , Closing_data__c
                                              , Meyers_Disposition_calc__c
                                              , Num_of_Days_Since_Last_Update__c
                                              , Sales_Rate_calc__c
                                              , Sales_Verified__c
                                              , Meyers_Notes_internal__c
                                              , To_Be_Built_Incentives__c, Broker_Co_Op_Incentives__c, Quick_Move_In_Incentives__c
                                              , To_Be_Built_Incentives_Unchanged__c, Quick_Move_In_Incentives_Unchanged__c, Broker_Co_Op_Incentives_Unchanged__c
                                              , Last_Updated_Date_To_Be_Built_Incentive__c, Last_Updated_Date_Broker_Co_Cop_Incenti__c, Last_Updated_Date_Quick_Move_Incentives__c
                                              , No_Of_Times_Auto_Approved__c, No_Of_Times_Auto_Approved_Set__c
                                              , Data_User__r.Days_Since_Data_User_Created__c
                                            FROM Project__c WHERE Id = :theProject.Id];
        // populate the currently saved values to the Previous fields on the update request
        pur.Previous_Do_Not_Call__c = theProjectCurrentValues.Do_Not_Call__c;
        pur.Previous_Email_Special__c = theProjectCurrentValues.Email_Special__c;
        pur.Previous_FIPS__c = theProjectCurrentValues.FIPS__c;
        pur.Previous_HOA__c = theProjectCurrentValues.HOA__c;
        pur.Previous_Location__Longitude__s = theProjectCurrentValues.Location__Longitude__s;
        pur.Previous_Location__Latitude__s = theProjectCurrentValues.Location__Latitude__s;
        pur.Previous_Master_Plan__c = theProjectCurrentValues.Master_Plan__r.Name;
        pur.Previous_Max_Price__c = theProjectCurrentValues.Max_Price__c;
        pur.Previous_Max_Unit_Size__c = theProjectCurrentValues.Max_Unit_Size__c;
        pur.Previous_Meyers_Notes__c = theProjectCurrentValues.Meyers_Notes__c;
        pur.Previous_Min_Price__c = theProjectCurrentValues.Min_Price__c;
        pur.Previous_Min_Unit_Size__c = theProjectCurrentValues.Min_Unit_Size__c;
        pur.Previous_Open_Date__c = theProjectCurrentValues.Open_Date__c;
        pur.Previous_Phone_Number__c = theProjectCurrentValues.Phone_Number__c;
        pur.Previous_Product_Type__c = theProjectCurrentValues.Product_Type__c;
        pur.Previous_Project_Characteristics__c = theProjectCurrentValues.Project_Characteristics__c;
        pur.Previous_Region_ID__c = theProjectCurrentValues.Region_ID__c;
        pur.Previous_Sales_and_Marketing_Firm__c = theProjectCurrentValues.Sales_and_Marketing_Firm__c;
        pur.Previous_Sales_Person_2__c = theProjectCurrentValues.Sales_Person_2__c;
        pur.Previous_Sales_Person_Name__c = theProjectCurrentValues.Sales_Person_Name__c;
        pur.Previous_Sales_Rate__c = theProjectCurrentValues.Sales_Rate__c;
        pur.Previous_Sold_Out_Date__c = theProjectCurrentValues.Sold_Out_Date__c;
        pur.Previous_Status__c = theProjectCurrentValues.Status__c;
        pur.Previous_Total_Remaining__c = theProjectCurrentValues.Total_Remaining__c;
        pur.Previous_Total_Units_Planned__c = theProjectCurrentValues.Total_Units_Planned__c;
        pur.Previous_Total_Units_Sold__c = theProjectCurrentValues.Total_Units_Sold__c;
        pur.Previous_Typical_Lot_Size__c = theProjectCurrentValues.Typical_Lot_Size__c;
        pur.Previous_Website__c = theProjectCurrentValues.Website__c;
        pur.Last_Updated_Date_Sales__c = theProjectCurrentValues.Last_Updated_Date_Sales__c;
        //pur.Last_Updated_Date_Price__c = theProjectCurrentValues.Last_Updated_Date_Price__c;
        pur.Last_Updated_Date_Price__c = theProjectCurrentValues.Last_Price_Update_display__c;
        pur.Last_Update_User_Sales__c = theProjectCurrentValues.Last_Update_User_Sales__c;
        pur.Last_Update_User_Price__c = theProjectCurrentValues.Last_Update_User_Price__c;
        pur.Previous_HOA_2__c = theProjectCurrentValues.HOA_2__c;
        pur.Previous_Lot_Dimension__c = theProjectCurrentValues.Lot_Dimension__c;
        pur.Previous_Assessments__c = theProjectCurrentValues.Assessments__c;
        pur.Previous_Assessments_Dollar__c = theProjectCurrentValues.Assessments_Dollar__c;
        pur.Previous_Assessment_Description__c = theProjectCurrentValues.Assessment_Description__c;
        pur.Previous_HOA_Description__c = theProjectCurrentValues.HOA_Description__c;
        pur.Previous_Monthly_HOA_SF__c = theProjectCurrentValues.Monthly_HOA_SF__c;
        pur.Previous_Incentive_Options__c = theProjectCurrentValues.Incentive_Options__c;
        //pur.Previous_Units_under_construction__c = theProjectCurrentValues.Units_under_construction__c;
        //pur.Previous_Unsold_units_under_construct__c = theProjectCurrentValues.Unsold_units_under_construction__c;
        pur.Previous_Meyers_Disposition_calc__c = theProjectCurrentValues.Meyers_Disposition_calc__c;
        pur.Previous_Sales_Rate_calc__c = theProjectCurrentValues.Sales_Rate_calc__c;
        pur.Previous_Sales_based_on_closing_data__c = theProjectCurrentValues.Closing_data__c;
        pur.Previous_Sales_Verified__c = theProjectCurrentValues.Sales_Verified__c;       
        //pur.Previous_Prices_Verified__c = theProjectCurrentValues.Prices_Verified__c;
        pur.MeyersNotesCounter__c = theProjectCurrentValues.MeyersNotesCounter__c;
        pur.Previous_Alternate_Phone_Number__c = theProjectCurrentValues.Alternate_Phone_Number__c;
        pur.Previous_Sales_Office_Notes__c = theProjectCurrentValues.Sales_Office_Notes__c;
        pur.Previous_Email_Special__c = theProjectCurrentValues.Email_Special__c;
        pur.Meyers_Notes_internal__c = theProjectCurrentValues.Meyers_Notes_internal__c;
        pur.Previous_To_Be_Built_Incentives__c = theProjectCurrentValues.To_Be_Built_Incentives__c;
        pur.Previous_Broker_Co_Op_Incentives__c = theProjectCurrentValues.Broker_Co_Op_Incentives__c;
        pur.Previous_Quick_Move_In_Incentives__c = theProjectCurrentValues.Quick_Move_In_Incentives__c;
        pur.Previous_To_Be_Built_Unchanged__c = theProjectCurrentValues.To_Be_Built_Incentives_Unchanged__c;
        pur.Previous_Broker_Co_Op_Unchanged__c = theProjectCurrentValues.Broker_Co_Op_Incentives_Unchanged__c;
        pur.Previous_Quick_Move_In_Unchanged__c = theProjectCurrentValues.Quick_Move_In_Incentives_Unchanged__c;
        pur.Last_Updated_Date_To_Be_Built_Incentive__c = theProjectCurrentValues.Last_Updated_Date_To_Be_Built_Incentive__c;
        pur.Last_Updated_Date_Quick_Move_Incentive__c = theProjectCurrentValues.Last_Updated_Date_Quick_Move_Incentives__c;
        pur.Last_Updated_Date_Broker_Cop_Incentives__c = theProjectCurrentValues.Last_Updated_Date_Broker_Co_Cop_Incenti__c;
        pur.Previous_No_Of_Times_Auto_Approved__c = theProjectCurrentValues.No_Of_Times_Auto_Approved__c;
        pur.Previous_No_Of_Times_Auto_Approved_Set__c = theProjectCurrentValues.No_Of_Times_Auto_Approved_Set__c;
        pur.No_Of_Times_Auto_Approved__c = theProjectCurrentValues.No_Of_Times_Auto_Approved__c;
        pur.Days_Since_Data_User_Created__c = theProjectCurrentValues.Data_User__r.Days_Since_Data_User_Created__c;
        pur.Num_of_Days_Since_Last_Update__c = theProjectCurrentValues.Num_of_Days_Since_Last_Update__c;
        //pur.HOA_NA__c = theProjectCurrentValues.HOA_NA__c;
        //pur.HOA_2_NA__c = theProjectCurrentValues.HOA_2_NA__c;
        //pur.Assessments_Dollar_NA__c = theProjectCurrentValues.Assessments_Dollar_NA__c;
        //pur.Monthly_HOA_SF_NA__c = theProjectCurrentValues.Monthly_HOA_SF_NA__c;

        if ('dataUser' == userType && null != userId && '' != userId) {
            pur.Data_User__c = userId;
        }

        if (isComplete) {
            pur.Update_Request_Status__c = 'Pending';
        } else {
            pur.Update_Request_Status__c = 'In Progress';
        }
        
        insert pur;
        if (!plans.isEmpty()) {
            List < Plan_Update_Request__c > plursToInsert = new List < Plan_Update_Request__c > ();
            Map < Id, Plan__c > existingPlanValues = new Map < Id, Plan__c > ([SELECT Id, Name, Off_Market__c, Project__c, Num_of_Beds__c, Num_of_Baths__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, Square_Footage__c, Price__c, Plan_Notes__c, Num_of_Floors__c, Garage__c, Display_in_Zonda__c FROM Plan__c WHERE ID IN: plans]);
            for (Plan__c p: plans) {
                if (!existingPlanValues.isEmpty() && null != existingPlanValues.get(p.Id)) { // it's not a newly submitted plan
                    Plan__c theExistingPlan = existingPlanValues.get(p.Id);
                    Plan_Update_Request__c plur = new Plan_Update_Request__c(
                          Plan__c = p.Id
                    	, Project__c = p.Project__c
                        , Project_Update_Request__c = pur.Id
                        , Plan_Name__c = p.Name
                        , Num_of_Baths__c = p.Num_of_Baths__c
                        , Num_of_Full_Baths__c = p.Num_of_Full_Baths__c
                        , Num_of_Half_Baths__c = p.Num_of_Half_Baths__c
                        , Num_of_Beds__c = p.Num_of_Beds__c
                        , Square_Footage__c = p.Square_Footage__c
                        , Plan_Notes__c = p.Plan_Notes__c
                        , Price__c = Integer.valueOf(p.Price__c)
                        , Price_Unchanged__c = p.Price_Unchanged__c
                        , Num_of_Floors__c = p.Num_of_Floors__c
                        , Garage__c = p.Garage__c
                        , Off_Market__c = p.Off_Market__c
                        , Previous_Plan_Name__c = existingPlanValues.get(p.Id).Name
                        , Previous_Price__c = existingPlanValues.get(p.Id).Price__c
                        , Previous_Num_of_Baths__c = existingPlanValues.get(p.Id).Num_of_Baths__c
                        , Previous_Num_of_Full_Baths__c = existingPlanValues.get(p.Id).Num_of_Full_Baths__c
                        , Previous_Num_of_Half_Baths__c = existingPlanValues.get(p.Id).Num_of_Half_Baths__c
                        , Previous_Num_of_Beds__c = existingPlanValues.get(p.Id).Num_of_Beds__c
                        , Previous_Square_Footage__c = existingPlanValues.get(p.Id).Square_Footage__c
                        , Previous_Plan_Notes__c = existingPlanValues.get(p.Id).Plan_Notes__c
                        , Previous_Num_of_Floors__c = existingPlanValues.get(p.Id).Num_of_Floors__c
                        , Previous_Garage__c = existingPlanValues.get(p.Id).Garage__c
                        , Previous_Off_Market__c = existingPlanValues.get(p.Id).Off_Market__c
                        , Display_in_Zonda__c = p.Display_in_Zonda__c
                        );
                    if (isComplete) {
                        plur.Update_Request_Status__c = 'Pending';
                    } else {
                        plur.Update_Request_Status__c = 'In Progress';
                    }
                    plursToInsert.add(plur);
                }
            }
            insert plursToInsert;
        }

        for (Task t : tasksToInsertToPurUponSaveNew) {
            t.WhatId = pur.Id;
        }
        upsert tasksToInsertToPurUponSaveNew;

       
        ApexPages.PageReference whereToGo = Page.BuilderProjectList;
        if (null != userId && '' != userId) {
            whereToGo.getParameters().put('userId', userId);
        }
        
        //Pass PUR to Auto Approval checks;
        List<Project_Update_Request__c> pursForAutoApprovalCheck = new List < Project_Update_Request__c > ();
        pursForAutoApprovalCheck.add(pur);
        If (pur.Update_Request_Status__c == 'Pending'){
            system.debug('Start the Auto Approval Checks - New');
            system.debug('pur: ' + pur);
            system.debug('pursForAutoApprovalCheck: ' + pursForAutoApprovalCheck);
            trgPURAutoApproval.PURAutoApprovalCriteria(pursForAutoApprovalCheck);  // tried Pur.ID
        }
        
        return whereToGo;
    }


    /**
            CALL LOGGING STUFF
    **/

    public void logCall() {
        Task theCall = new Task(
                WhatId = theProject.Id
            ,   Type = 'Call'
            ,   Subject = 'Call logged by Data User: '+userName
            ,   Status = 'Completed'
            ,   ActivityDate = System.today()
            ,   Description = callNotes
            );
        insert theCall;
        if (null != theProjectUpdateRequest) {
            Task thePURCall = new Task(
                    WhatId = theProjectUpdateRequest.Id
                ,   Type = 'Call'
                ,   Subject = 'Call logged by Data User: '+userName
                ,   Status = 'Completed'
                ,   ActivityDate = System.today()
                ,   Description = callNotes
                );
            insert thePURCall;
        } else {
            Task thePURCall = new Task(
                    Type = 'Call'
                ,   Subject = 'Call logged by Data User: '+userName
                ,   Status = 'Completed'
                ,   ActivityDate = System.today()
                ,   Description = callNotes
                );
            tasksToInsertToPurUponSaveNew.add(thePURCall);
        }
    } 

    public List<Task> getLastFiveActivities() {
        lastFiveActivities = [SELECT Id, Description, ActivityDate FROM Task WHERE whatId = :theProject.Id ORDER BY CreatedDate DESC LIMIT 5];
        return lastFiveActivities;
    }

    /** 
            JS Remoting action called from the master plan lookup box
    */
    @RemoteAction
    public static List<Master_Plan__c> searchMasterPlans (String searchTerm) {
        List<Master_Plan__c> masterPlans = Database.query('Select Id, Name from Master_Plan__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return masterPlans;
    }
}