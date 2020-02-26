public with sharing class trgPURAutoApproval {
	/*
		- This method will analyze the Project Update Requests received
		- If they are Pending [and weren't before], then we will do the auto approval checks on the PUR.
		- If all the PUR checks pass then, it will find any Plan Update Requests for the Project Update Request
		- Then it will go through the Auto Approval checks for the PLURs
		- IF the PUR and all PLURs pass the checks the PUR will be set to Approved, Auto Approved check box checked, and No Of Times Auto Approved +1.
	*/
       
	public static void PURAutoApprovalCriteria(List<Project_Update_Request__c> purs){

        Set<Id> purIdsToUpdate = new Set<Id>();
		Map<Id, Project_Update_Request__c> mapPURsToUpdate = new Map<Id, Project_Update_Request__c>();
		List<Project_Update_Request__c> finalListPURsToApprove = new List<Project_Update_Request__c>();
        List<Project_Update_Request__c> finalListPURsToFail = new List<Project_Update_Request__c>();
               
        String AutoApprovalStatusPUR = '';
        String AutoApprovalStatusPLUR = '';
        Integer purAutoApprovalPass = 0; // Pass = 1
        
        Integer plurChecksHappened = 0; // Confirmed = 1
        Integer plurFailed = 0; // Failed = 1
            
            
		Map<Id, Project_Update_Request__c> mapPURs = new Map<Id, Project_Update_Request__c>();
		// check each project update request to see if it's pending now and wasn't before
		for (Project_Update_Request__c pur : purs) {
            system.debug('in PURs map');
            
            // PUR is ready to go through Auto Approval Criteria
            IF (pur.Update_Request_Status__c == 'Pending' && pur.Previously_Set_to_Review__c == FALSE){ // if updated from In Process to Pending and was not previously set to review.
                system.debug('PUR Status is Pending');
                system.debug('PUR ID ' + pur.Id); 
                AutoApprovalStatusPUR = 'Pending PUR';
                
                mapPURs.put(pur.Id, pur);
                purIdsToUpdate.add(pur.Id);                
                
                // Round 1 -- Data User Days && Counter && Status && Product Type && Lot Dimention && Open Date && Sold Out Date
                        system.debug('Data User Days ' + pur.Days_Since_Data_User_Created__c);
                		system.debug('Counter ' + pur.Previous_No_Of_Times_Auto_Approved__c);
                        system.debug('Status: prev ' + pur.Previous_Status__c + '; new ' + pur.Status__c);
                        system.debug('ProductType: prev ' + pur.Previous_Product_Type__c + '; new ' + pur.Product_Type__c);
						system.debug('Lot Dimen: prev ' + pur.Previous_Lot_Dimension__c + '; new ' + pur.Lot_Dimension__c);
                        system.debug('Open Date: prev ' + pur.Previous_Open_Date__c + '; new ' + pur.Open_Date__c);
                        system.debug('Sold Out: prev ' + pur.Previous_Sold_Out_Date__c + '; new ' + pur.Sold_Out_Date__c);
                
                If (pur.Days_Since_Data_User_Created__c > 90
                    && pur.Previous_No_Of_Times_Auto_Approved__c < 2
                    && pur.Previous_Status__c == pur.Status__c
                    && pur.Previous_Product_Type__c == pur.Product_Type__c
                    && pur.Previous_Lot_Dimension__c == pur.Lot_Dimension__c
                    && pur.Previous_Open_Date__c == pur.Open_Date__c
                    && pur.Previous_Sold_Out_Date__c == pur.Sold_Out_Date__c
                    ){
                    system.debug('Inside Round 1');         
                        
                    
                    // Round 2 -- Variance of Typical Lot Size, Monthly HOA #1, Monthly HOA #2
                        	system.debug('Typical Lot Size; prev ' + pur.Previous_Typical_Lot_Size__c + '; new ' + pur.Typical_Lot_Size__c);
                        	system.debug('HOA; prev ' + pur.Previous_HOA__c + '; new ' + pur.HOA__c);
                        	system.debug('HOA2; prev ' + pur.Previous_HOA_2__c + '; new ' + pur.HOA_2__c);
                        
                	If ( ((pur.Typical_Lot_Size__c == null && pur.Previous_Typical_Lot_Size__c == null)
                          || (pur.Typical_Lot_Size__c == pur.Previous_Typical_Lot_Size__c)
                          || ((pur.Typical_Lot_Size__c != null && pur.Previous_Typical_Lot_Size__c != null) 
                              && ((pur.Typical_Lot_Size__c >= pur.Previous_Typical_Lot_Size__c && pur.Typical_Lot_Size__c < pur.Previous_Typical_Lot_Size__c * 2) // doubles
                                  || (pur.Typical_Lot_Size__c <= pur.Previous_Typical_Lot_Size__c && pur.Typical_Lot_Size__c > pur.Previous_Typical_Lot_Size__c / 2) // half
                                 )
                             )
                         ) 
                        && ((pur.HOA__c == null && pur.Previous_HOA__c == null)
                            || pur.HOA__c == pur.Previous_HOA__c
                            || ((pur.HOA__c != null && pur.Previous_HOA__c != null) 
                                && ((pur.HOA__c >= pur.Previous_HOA__c && pur.HOA__c < pur.Previous_HOA__c * 2) || (pur.HOA__c <= pur.Previous_HOA__c && pur.HOA__c > pur.Previous_HOA__c / 2)
                                   )
                               )
                           )
                        && ((pur.HOA_2__c == null && pur.Previous_HOA_2__c == null) 
                            || pur.HOA_2__c == pur.Previous_HOA_2__c
                            || ((pur.HOA_2__c != null && pur.Previous_HOA_2__c != null) 
                                && ((pur.HOA_2__c >= pur.Previous_HOA_2__c && pur.HOA_2__c < pur.Previous_HOA_2__c * 2 ) || (pur.HOA_2__c <= pur.Previous_HOA_2__c && pur.HOA_2__c > pur.Previous_HOA_2__c / 2)
                                   )
                               )
                           )
                       )
                    {
                    	system.debug('Inside Round 2');

                                                            
                    	// Round 3 -- Total Tax Rate
                    			system.debug('assesment: Prev ' + pur.Previous_Assessments__c + '; new ' + pur.Assessments__c);
                    	IF ( ( pur.Previous_Assessments__c == NULL && pur.Assessments__c < 5.00 ) || pur.Previous_Assessments__c == pur.Assessments__c ){
                        	system.debug('Inside Round 3');
                                                           
                            
                                //Round 4 -- Status specific checks
                        			system.debug('TUS: prev ' + pur.Previous_Total_Units_Sold__c + '; new ' + pur.Total_Units_Sold__c);
                                    system.debug('Sales Verified: ' + pur.Sales_Verified__c);
                                    system.debug('TUP: prev ' + pur.Previous_Total_Units_Planned__c + '; new ' + pur.Total_Units_Planned__c);
                                    system.debug('Disposition: prev ' + pur.Previous_Meyers_Disposition_calc__c + '; new ' + pur.Meyers_Disposition_calc__c);
                                    system.debug('num days since last updated: ' + pur.Num_of_Days_Since_Last_Update__c);
                                    system.debug('TUP: prev ' + pur.Previous_Total_Units_Planned__c + '; new ' + pur.Total_Units_Planned__c);
                                    
                                //Upcoming -- no change in TUS and TUP has not increased or decreased by 50% or more
                                IF (pur.Status__c == 'Upcoming' 
                                    && pur.Previous_Total_Units_Sold__c == null && pur.Total_Units_Sold__c == null
                                    && (pur.Total_Units_Planned__c == pur.Previous_Total_Units_Planned__c 
                                        || (pur.Total_Units_Planned__c != null && pur.Previous_Total_Units_Planned__c != null 
                                            && ((pur.Total_Units_Planned__c <= pur.Previous_Total_Units_Planned__c && pur.Total_Units_Planned__c > pur.Previous_Total_Units_Planned__c - (pur.Previous_Total_Units_Planned__c * .5))
                                                || (pur.Total_Units_Planned__c >= pur.Previous_Total_Units_Planned__c && pur.Total_Units_Planned__c < pur.Previous_Total_Units_Planned__c + (pur.Previous_Total_Units_Planned__c * .5))
                                               )
                                           )
                                       )
                                   ){
                                  	system.debug('Inside Round 4 - Upcoming');
                                    AutoApprovalStatusPUR = 'PUR Round 4 - Upcoming - Pass;';
                                    purAutoApprovalPass = 1;
                                       	
                                       //mapPURs.put(pur.Id, pur);
                                       //purIdsToUpdate.add(pur.Id);
                                        
                                //Active -- no change in Meyers Disposition or status, Days since last updated is < 60, TUS
                                } ELSE IF (pur.Status__c == 'Active' 
                                           && pur.Previous_Meyers_Disposition_calc__c == pur.Meyers_Disposition_calc__c 
                                           && (pur.Num_of_Days_Since_Last_Update__c < 60 || pur.Num_of_Days_Since_Last_Update__c ==null)
                                           && ((pur.Total_Units_Sold__c != null && pur.Previous_Total_Units_Sold__c == pur.Total_Units_Sold__c && pur.Sales_Verified__c == TRUE) 
                                               || (pur.Total_Units_Sold__c != null && pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c > pur.Previous_Total_Units_Sold__c && pur.Total_Units_Sold__c < pur.Previous_Total_Units_Sold__c + 10))
                                           && ((pur.Previous_Total_Units_Planned__c == pur.Total_Units_Planned__c) 
                                               || (pur.Total_Units_Planned__c != null && pur.Previous_Total_Units_Planned__c != null && pur.Total_Units_Planned__c >= pur.Previous_Total_Units_Planned__c && pur.Total_Units_Planned__c < pur.Previous_Total_Units_Planned__c + 10 ))
                                          ){
                                    system.debug('Inside Round 4 - Active');
                                    AutoApprovalStatusPUR = 'PUR Round 4 - Active - Pass;';
                                    purAutoApprovalPass = 1;
                                        
                                        //mapPURs.put(pur.Id, pur);
                                        //purIdsToUpdate.add(pur.Id);
                                              
                                              
                                } Else { 
                                    AutoApprovalStatusPUR = 'PUR Round 4 - Fail;';
                                    system.debug('purAutoApprovalPass - Round 4' + purAutoApprovalPass);
                                    //mapPURs.put(pur.Id, pur);
                                    //purIdsToUpdate.add(pur.Id);           
                                }
                        } Else {
                            AutoApprovalStatusPUR = 'PUR Round 3 - Fail;';
                            system.debug('purAutoApprovalPass - Round 3' + purAutoApprovalPass);
                            //mapPURs.put(pur.Id, pur);
                            //purIdsToUpdate.add(pur.Id);
                       }
                    } Else { 
                        AutoApprovalStatusPUR = 'PUR Round 2 - Fail;';
                        system.debug('purAutoApprovalPass - Round 2' + purAutoApprovalPass);
                        //mapPURs.put(pur.Id, pur);
                        //purIdsToUpdate.add(pur.Id);
                    }
                } Else { 
                    AutoApprovalStatusPUR = 'PUR Round 1 - Fail;';
                    system.debug('purAutoApprovalPass - Round 1' + purAutoApprovalPass);
                    //mapPURs.put(pur.Id, pur);
                    //purIdsToUpdate.add(pur.Id);
                }
            } 
		}
        system.debug('status string ' + AutoApprovalStatusPUR);
        system.debug('mapPURs' + mapPURs);
        system.debug('purIdsToUpdate' + purIdsToUpdate); 
        
		
        // Get all the Plan Update Requests that are associated to the PURs being checked
		List<Plan_Update_Request__c> allPLURsForPURs = new List<Plan_Update_Request__c>();
		allPLURsForPURs = [SELECT Id, Plan__c, Project_Update_Request__c, Update_Request_Status__c, Auto_Approval_Result__c, Previous_Plan_Name__c, Previous_Num_of_Beds__c, Previous_Num_of_Full_Baths__c, Previous_Num_of_Half_Baths__c, Previous_Num_of_Floors__c, Previous_Garage__c, Previous_Square_Footage__c, Previous_Price__c, Num_of_Beds__c, Num_of_Full_Baths__c, Num_of_Half_Baths__c, Num_of_Floors__c, Garage__c, Square_Footage__c, Price__c FROM Plan_Update_Request__c WHERE Project_Update_Request__c IN :mapPURs.keyset()];
        
        system.debug('mapPURs' + mapPURs);
        system.debug('purIdsToUpdate' + purIdsToUpdate);        
        system.debug('allPLURsForPURs' + allPLURsForPURs);      
        
        // Maping Plan Update Requests to Project Update Requests
		Map<Id, List<Plan_Update_Request__c>> mapPURsToPLURs = new Map<Id, List<Plan_Update_Request__c>>();
        
        system.debug('mapPURsToPLURs' + mapPURsToPLURs);
        
		if (!allPLURsForPURs.isEmpty()) {
			for (Plan_Update_Request__c plur : allPLURsForPURs) {
                system.debug('in PLURs map');
				
                system.debug('allPLURsForPURs ' + allPLURsForPURs);
                system.debug('PLURiD ' + plur.iD);
				system.debug('plurFailed START: ' + plurFailed);
                system.debug('plurChecksHappened START: ' + plurChecksHappened);
                
                // Did the Auto Approval Pass?  If yes then start the PLUR checks
                IF (purAutoApprovalPass == 1 && plurFailed == 0){
                    system.debug('In PLUR Checks ' + plur.iD);
                    system.debug('plan Name: ' + plur.Previous_Plan_Name__c);
                    
                    //PLUR Round 1
                    IF (plur.Previous_Plan_Name__c != 'New Plan'){
                        system.debug('PLURiD 1 pass ' + plur.iD);
                        
                        	system.debug('Price: prev ' + plur.Previous_Price__c + '; new ' + plur.Price__c);
                        	system.debug('Sq Ft: prev ' + plur.Previous_Square_Footage__c + '; new ' + plur.Square_Footage__c);

                        //PLUR Round 2
                        IF (   ( ((plur.Previous_Num_of_Beds__c == null || plur.Previous_Num_of_Beds__c == 0) && (plur.Num_of_Beds__c == null || plur.Num_of_Beds__c == 0)) || (plur.Previous_Num_of_Beds__c == plur.Num_of_Beds__c)) //Beds
                            && ( ((plur.Previous_Num_of_Full_Baths__c == null || plur.Previous_Num_of_Full_Baths__c == 0) && (plur.Num_of_Full_Baths__c == null || plur.Num_of_Full_Baths__c == 0)) || (plur.Previous_Num_of_Full_Baths__c == plur.Num_of_Full_Baths__c)) //Full Baths
                            && ( ((plur.Previous_Num_of_Half_Baths__c == null || plur.Previous_Num_of_Half_Baths__c == 0) && (plur.Num_of_Half_Baths__c == null || plur.Num_of_Half_Baths__c == 0)) || (plur.Previous_Num_of_Half_Baths__c == plur.Num_of_Half_Baths__c)) //Half Baths
                            && ( ((plur.Previous_Num_of_Floors__c == null || plur.Previous_Num_of_Floors__c == 0) && (plur.Num_of_Floors__c == null || plur.Num_of_Floors__c == 0)) || (plur.Previous_Num_of_Floors__c == plur.Num_of_Floors__c)) //Floors
                            && ( ((plur.Previous_Garage__c == null || plur.Previous_Garage__c == 0) && (plur.Garage__c == null || plur.Garage__c == 0)) || (plur.Previous_Garage__c == plur.Garage__c)) //Garage
                           ){
                           	   system.debug('PLURiD 2 pass ' + plur.iD);
                               
                               //PLUR Round 3
                               IF (((plur.Previous_Price__c == null || plur.Previous_Price__c == 0) && (plur.Price__c == null || plur.Price__c == 0)) 
                                   || ((plur.Previous_Price__c != null && plur.Previous_Price__c != 0)
                                       && ( (plur.Price__c >= plur.Previous_Price__c && plur.Price__c < plur.Previous_Price__c + (plur.Previous_Price__c * .049)) 
                                         || (plur.Price__c <= plur.Previous_Price__c && plur.Price__c > plur.Previous_Price__c - (plur.Previous_Price__c * .049))))){
                                   
                                         system.debug('PLURiD 3 pass ' + plur.iD);
                                         
                                         //PLUR Round 4
                                         IF (((plur.Previous_Square_Footage__c == null || plur.Previous_Square_Footage__c == 0) && (plur.Square_Footage__c == null || plur.Square_Footage__c == 0))
                                             ||((plur.Previous_Square_Footage__c != null && plur.Previous_Square_Footage__c != 0)
                                                && ( (plur.Square_Footage__c >= plur.Previous_Square_Footage__c && plur.Square_Footage__c < plur.Previous_Square_Footage__c + (plur.Previous_Square_Footage__c * .25))
                                                  || (plur.Square_Footage__c <= plur.Previous_Square_Footage__c && plur.Square_Footage__c > plur.Previous_Square_Footage__c - (plur.Previous_Square_Footage__c * .25))
                                            )
                                           )){
                                             system.debug('PLURiD 4 pass ' + plur.iD);
                                               plur.Auto_Approval_Result__c = 'Passed Auto Approval Checks';
                                               plur.Update_Request_Status__c = 'Approved';
                                               
                                               AutoApprovalStatusPLUR = ' PLUR Round 4 pass';
                                               plurChecksHappened = 1;                                               
                                               
                                                    if (!mapPURsToPLURs.containsKey(plur.Project_Update_Request__c)) {
                                                        system.debug('not mapped PLUR ' + plur.iD);
                                                        mapPURsToPLURs.put(plur.Project_Update_Request__c, new Plan_Update_Request__c[]{plur});
                                                    } else {
                                                        mapPURsToPLURs.get(plur.Project_Update_Request__c).add(plur);
                                                        system.debug('mapped PLUR ' + plur.iD);
                                                    }
                                               
                                         } Else { plurFailed = 1; AutoApprovalStatusPLUR = ' PLUR Round 4 FAILED'; }	
                               } Else { plurFailed = 1; AutoApprovalStatusPLUR = ' PLUR Round 3 FAILED'; }	
                        } Else { plurFailed = 1; AutoApprovalStatusPLUR = ' PLUR Round 2 FAILED'; }	
                    } Else { plurFailed = 1; AutoApprovalStatusPLUR = ' PLUR Round 1 FAILED'; }	
                } 
                
                system.debug('mapPURsToPLURs' + mapPURsToPLURs);
                system.debug('plurChecksHappened END: ' + plurChecksHappened);
                system.debug('plurFailed END: ' + plurFailed);
                
			}
		} ELSE if (allPLURsForPURs.isEmpty()){
            system.debug('no plurs');
            plurChecksHappened = 1;
            AutoApprovalStatusPLUR = ' no PLURs';
        }
        
        // get the PURs
		mapPURsToUpdate = new Map<Id, Project_Update_Request__c>([SELECT Id, Update_Request_Status__c , Auto_Approval_Result__c, Auto_Approved__c, Previous_No_Of_Times_Auto_Approved__c, No_Of_Times_Auto_Approved__c FROM Project_Update_Request__c WHERE Id IN :purIdsToUpdate]);
        
        // set the PUR values
        for (Project_Update_Request__c theProjectUpdateRequest : mapPURsToUpdate.values()) {
            system.debug('status string2 ' + AutoApprovalStatusPUR);
        		//passed the checks
            if (theProjectUpdateRequest != null && purAutoApprovalPass == 1 && plurChecksHappened == 1 && plurFailed == 0) {
                system.debug('status string3 ' + AutoApprovalStatusPUR);
		        
                theProjectUpdateRequest.Auto_Approval_Result__c = AutoApprovalStatusPUR + AutoApprovalStatusPLUR; // Comments about the auto approval for TESTING
                theProjectUpdateRequest.Auto_Approved__c = TRUE; // Auto Approval Flag
                theProjectUpdateRequest.No_Of_Times_Auto_Approved__c = theProjectUpdateRequest.Previous_No_Of_Times_Auto_Approved__c + 1; // Increase Auto approval counter
                theProjectUpdateRequest.Update_Request_Status__c = 'Approved';
				
                finalListPURsToApprove.add(theProjectUpdateRequest);
                
               //Else failed the checks 
			} Else if (theProjectUpdateRequest != null && (purAutoApprovalPass != 1 || plurChecksHappened != 1 || plurFailed != 0)) {
                system.debug('status string4 ...' + AutoApprovalStatusPUR);
                theProjectUpdateRequest.Auto_Approval_Result__c = AutoApprovalStatusPUR + AutoApprovalStatusPLUR;
                theProjectUpdateRequest.No_Of_Times_Auto_Approved__c = 0; // Set Auto approval counter back to 0
				
                finalListPURsToFail.add(theProjectUpdateRequest);
			}
                    system.debug(theProjectUpdateRequest);
        }

		
        // update all the PURs
		update finalListPURsToApprove;
        update finalListPURsToFail;

		// update PLURs
		update allPLURsForPURs;

	}
     
    
    
}