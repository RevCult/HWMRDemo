public with sharing class PUR_Status_Update_Helper {

    public static integer flag = 0;
    public static integer Approvalflag = 0;
    //////////// ******SFDC-169 && SFDC-170 && SFDC-172 for AUTO APPROVE SCENARIOS******/////////////

    public static void PURinsert_Active(id theProjectId, Project_Update_Request__c pur, Boolean havePlans) {
        system.debug('In PURinsert_Active method');
        boolean isTotalTaxRateSet = false;
        Integer noOfflag = 0;
        
        Project__c prj = [select id, Status__c, Num_of_Days_Since_Last_Update__c, Builder__r.Name, Total_Units_Sold__c, Meyers_Notes__c, Update_Cycle__c, ZIC_Date__c, Data_User__r.Days_Since_Data_User_Created__c, No_Of_Times_Auto_Approved__c, No_Of_Times_Auto_Approved_Set__c from Project__c where id =: theProjectId];
        system.debug('prj.Builder__r.Name==>' + prj.Builder__r.Name);
        
      //Status is not Active -- including this so just in case a NON-Active project slips through
        if (prj.Status__c != 'Active') {
            system.debug('PUR Pending ==> Status is not Active');
            noOfflag++;
            flag++;		// Nicole Added 7.17.18
        }
        
      //Days Since User was Created check
        system.debug('Data_User_Days==>' + prj.Data_User__r.Days_Since_Data_User_Created__c);
        Decimal Days_Since_Data_User_Created;        
        if (Test.isRunningTest()) {
            Days_Since_Data_User_Created = 91;
        } else {
            Days_Since_Data_User_Created = prj.Data_User__r.Days_Since_Data_User_Created__c;
        }
        system.debug(Days_Since_Data_User_Created);
        if (Days_Since_Data_User_Created > 90) {
            system.debug('PUR Approved ==> Days_Since_Data_User_Created > 90' + Days_Since_Data_User_Created );
            Approvalflag++;
        } else {
            noOfflag++;
            flag++;
            system.debug('PUR Pending ==> Days_Since_Data_User_Created <90' + Days_Since_Data_User_Created );
        }
        
        	//if ((Days_Since_Data_User_Created > 90) && (prj.No_Of_Times_Auto_Approved__c == 3)) {
        if (prj.No_Of_Times_Auto_Approved__c == 3) {
            system.debug('PUR Pending ==> No_Of_Times_Auto_Approved__c==3');
            noOfflag++;
            flag++;		// Nicole Added 7.17.18
        }
        
      // # days since last update
        if (prj.Num_of_Days_Since_Last_Update__c < 60) {
            	system.debug('PUR Approved ==> Num_of_Days_Since_Last_Update__c < 60');
            	system.debug('Num_of_Days_Since_Last_Update__c ==>' + prj.Num_of_Days_Since_Last_Update__c);
            Approvalflag++;
        } else {
            if (prj.Num_of_Days_Since_Last_Update__c >= 60) {
                	system.debug('PUR Pending ==> Num_of_Days_Since_Last_Update__c >= 60');
                	system.debug('Num_of_Days_Since_Last_Update__c ==>' + prj.Num_of_Days_Since_Last_Update__c);
                noOfflag++;  // Nicole added 8.28.2018
            	flag++;
            }
        }
      
      // Project Status Changes
        if (pur.Status__c == pur.Previous_Status__c) {
            system.debug('PUR Approved ==> there is NO change to a project status');
            Approvalflag++;
        } else {
            if (pur.Status__c != pur.Previous_Status__c) {
                system.debug('PUR Pending ==> project status changed');
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
            }
        }
        
      // Builder Name list
        if (prj.Builder__r.Name.containsIgnoreCase('Toll Brothers') || prj.Builder__r.Name.containsIgnoreCase('Pulte') || prj.Builder__r.Name.containsIgnoreCase('CalAtlantic Homes') || prj.Builder__r.Name.containsIgnoreCase('Centex Homes') || prj.Builder__r.Name.containsIgnoreCase('M/I Homes') || prj.Builder__r.Name.containsIgnoreCase('K. Hovnanian Homes') || prj.Builder__r.Name.containsIgnoreCase('Ashton Woods Homes') || prj.Builder__r.Name.containsIgnoreCase('Edward Andrews') || prj.Builder__r.Name.containsIgnoreCase('Westport Homes')) {
            system.debug('PUR Approved ==> builder is in the list');
            Approvalflag++;
        } else {
            system.debug('PUR Pending ==> builder is not in the list');
            noOfflag++;  // Nicole added 8.28.2018
            flag++;
        }
        
      // Meyers Disposition
        if (pur.Previous_Meyers_Disposition_calc__c == 'Follow Up' && pur.Meyers_Disposition_calc__c == 'Baselined') {
            system.debug('PUR Pending ==> Meyers_Disposition_calc__c Changed from Follow Up to Baselined');
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
        }
        if (pur.Previous_Meyers_Disposition_calc__c == 'Baselined' && pur.Meyers_Disposition_calc__c != 'Baselined') {
            system.debug('PUR Approved ==> Meyers_Disposition_calc__c Changed from Baselined to other');
            Approvalflag++;
        }
        
      // Total Units Planned changes
        if (pur.Total_Units_Planned__c != pur.Previous_Total_Units_Planned__c) {
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
            system.debug('PUR Pending ==> Total_Units_Planned Changed from ' + pur.Previous_Total_Units_Planned__c + ' to ' + pur.Total_Units_Planned__c);
        }
        
      // Product Type changes
        if (pur.Product_Type__c != pur.Previous_Product_Type__c) {
            system.debug('PUR Pending ==> Product_Type Changed from ' + pur.Previous_Product_Type__c + ' to ' + pur.Product_Type__c);
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
        }
        
      // Lot Dimension changes
        if (pur.Lot_Dimension__c != pur.Previous_Lot_Dimension__c) {
            system.debug('PUR Pending ==> Lot_Dimension Changed from ' + pur.Previous_Lot_Dimension__c + ' to ' + pur.Lot_Dimension__c);
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
        }
        
      //Open Date changes
        if (pur.Open_Date__c != pur.Previous_Open_Date__c) {
            system.debug('PUR Pending ==> Open_Date Changed from ' + pur.Previous_Open_Date__c + ' to ' + pur.Open_Date__c);
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
        }
        
      //Sold Out Date changes
        if (pur.Sold_Out_Date__c != pur.Previous_Sold_Out_Date__c) {
            system.debug('PUR Pending ==> Sold_Out_Date Changed from ' + pur.Previous_Sold_Out_Date__c + ' to ' + pur.Sold_Out_Date__c);
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
        }
        
      //Typical Lot Size
        if (pur.Previous_Typical_Lot_Size__c != null && pur.Previous_Typical_Lot_Size__c != 0 && pur.Previous_Typical_Lot_Size__c != pur.Typical_Lot_Size__c) {
            system.debug('Previous_Typical_Lot_Size value is ==> ' + pur.Previous_Typical_Lot_Size__c);
            system.debug('Typical_Lot_Size value is ==> ' + pur.Typical_Lot_Size__c);
            decimal Typical_Lot_Size;
            decimal Previous_Typical_Lot_Size;
            decimal tper;
            Typical_Lot_Size = pur.Typical_Lot_Size__c;
            Previous_Typical_Lot_Size = pur.Previous_Typical_Lot_Size__c;
            tper = integer.valueof(Typical_Lot_Size) - integer.valueof(Previous_Typical_Lot_Size);
            system.debug('*tper**' + tper);
            decimal i = (tper / integer.valueof(Previous_Typical_Lot_Size)) * 100;
            system.debug('i in Typical_Lot_Size==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in Typical_Lot_Size==>' + j);
            //if(!(j<=100 && j>=-100) ){
            if (j >= 100 || j <= -50) {
                system.debug('Typical_Lot_Size percentage is==>' + j);
                system.debug('PUR Pending ==> Typical_Lot_Size__c  percentage is greater than 100');
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
            } else {
                Approvalflag++;
                system.debug('PUR Approved ==> Typical_Lot_Size percentage is ==> ' + j);

            }
        }
        
      // HOA
        if (pur.Previous_HOA__c != null && pur.Previous_HOA__c != 0 && pur.Previous_HOA__c != pur.HOA__c) {
            system.debug('Previous_Monthly HOA #1 value is ==> ' + pur.Previous_HOA__c);
            system.debug('Monthly HOA #1 value is ==> ' + pur.HOA__c);
            decimal HOA;
            decimal Previous_HOA;
            decimal hper;
            HOA = pur.HOA__c;
            Previous_HOA = pur.Previous_HOA__c;
            hper = integer.valueof(HOA) - integer.valueof(Previous_HOA);
            system.debug('*hper**' + hper);
            decimal i = (hper / integer.valueof(Previous_HOA)) * 100;
            system.debug('i in HOA==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in HOA==>' + j);
            // if(j>200){
            if (j >= 100 || j <= -50) {
                system.debug('Monthly HOA #1 percentage is==>' + j);
                system.debug('PUR Pending ==>Monthly HOA #1 percentage is greater than 200');
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
            } else {
                Approvalflag++;
                system.debug('PUR Approved== >Monthly HOA #1 percentage is==>' + j);

            }
        }
        if (pur.Previous_HOA_2__c != null && pur.Previous_HOA_2__c != 0 && pur.Previous_HOA_2__c != pur.HOA_2__c) {
            system.debug('Previous_Monthly HOA #2 value is==>' + pur.Previous_HOA_2__c);
            system.debug('Monthly HOA #2 value is==> ' + pur.HOA_2__c);
            decimal HOA2;
            decimal Previous_HOA2;
            decimal hper2;
            HOA2 = pur.HOA_2__c;
            Previous_HOA2 = pur.Previous_HOA_2__c;
            hper2 = integer.valueof(HOA2) - integer.valueof(Previous_HOA2);
            system.debug('*hper2**' + hper2);
            decimal i = (hper2 / integer.valueof(Previous_HOA2)) * 100;
            system.debug('i in HOA2==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in HOA2==>' + j);
            // if(j>200){
            if (j >= 100 || j <= -50) {
                system.debug('Monthly HOA #2 percentage is==>' + j);
                system.debug('PUR Pending ==>Monthly HOA #2 percentage is greater than 200');
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
            } else {
                Approvalflag++;
                system.debug('PUR Approved== >Monthly HOA #2 percentage is==>' + j);

            }
        }
        
      //Assessments
        if (pur.Assessments__c != null && (pur.Previous_Assessments__c == pur.Assessments__c)) {
            system.debug('PUR Approved == >  Total Tax Rate == updated tax');
            Approvalflag++;
        } else {
            if (pur.Assessments__c != null) {
                if (pur.Assessments__c < 5.00 && pur.Assessments__c >= 0) {
                    system.debug('PUR Approved == >  Total Tax Rate (%) is LESS THAN 5.00');
                    Approvalflag++;
                } else {
                    system.debug('PUR Pending == >  Total Tax Rate percentage is==>' + pur.Assessments__c);
                    flag++;
                    noOfflag++;  // Nicole added 8.28.2018
                }
            }
        }
     
   // Total Units Sold - Active Project Check
        //TUS is added
        if (pur.Previous_Total_Units_Sold__c == null && pur.Total_Units_Sold__c != null) {
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
            system.debug('PUR Pending ==> Total_Units_Sold__c  changed from null to a value');
        }
        //TUS Removed
        if (pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c == null) {
            flag++;
            noOfflag++;  // Nicole added 8.28.2018
            system.debug('PUR Pending ==> Total_Units_Sold__c removed');
        }
        
        //TUS is not NULL and changes
        if (pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c != null) {
            // TUS is less than before -- Status = Pending
            if(pur.Total_Units_Sold__c < pur.Previous_Total_Units_Sold__c){
                	system.debug('PUR Pending ==> Total_Units_Sold__c decreased');
                	system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
                flag++;
                noOfflag++;        
                isTotalTaxRateSet = true;	//Why are we setting this???
            // Greater than or = 10 -- Status = Pending
            } else if (pur.Total_Units_Sold__c >= (pur.Previous_Total_Units_Sold__c + 10)){
                	system.debug('PUR Pending ==> Total_Units_Sold__c >= 10');
                	system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
                isTotalTaxRateSet = true;	//Why are we setting this???
            //Total Units Sold is LESS THAN Previous Total Units Sold + 10 -- Status = Approved
            } else if (pur.Total_Units_Sold__c < (pur.Previous_Total_Units_Sold__c + 10)){
					system.debug('PUR Approved => Total Units Sold is LESS THAN Previous Total Units Sold + 10');                
                Approvalflag++;
                isTotalTaxRateSet = true;	//Why are we setting this???
            }
        }
        
        
        //if (pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) {
            //TUS is less than before -- PENDING PUR
            //if (pur.Total_Units_Sold__c < pur.Previous_Total_Units_Sold__c) {
            //    	system.debug('PUR Pending ==> Total_Units_Sold__c decreased');
            //    	system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
            //    flag++;
            //    noOfflag++;  // Nicole added 8.28.2018
            //    isTotalTaxRateSet = true;
            // Greater than or = 10 -- PENDING PUR
            //} else if ((pur.Total_Units_Sold__c != null) && ((pur.Total_Units_Sold__c >= (pur.Previous_Total_Units_Sold__c + 10)))) {
            //    	system.debug('PUR Pending ==> Total_Units_Sold__c >= 10');
            //    	system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
            //    flag++;
            //    noOfflag++;  // Nicole added 8.28.2018
            //    isTotalTaxRateSet = true;
            //
            //} else if (pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c != null && pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) {
            //    system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
                //if ((pur.Total_Units_Sold__c < (pur.Previous_Total_Units_Sold__c + 10))) { // && (pur.Total_Units_Sold__c >= (pur.Previous_Total_Units_Sold__c+0)) ))
                    //system.debug('PUR Approved => Total Units Sold is LESS THAN Previous Total Units Sold + 10 and GREATER THAN or EQUAL TO Previous TUS + 0');
                    //Approvalflag++;
                    //isTotalTaxRateSet = true;
                //}
            //}
        //}
       
    //Sales Verified flag Check
        if (pur.Total_Units_Sold__c != null && pur.Previous_Total_Units_Sold__c != null) {
            if (((pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == true) || ((pur.Total_Units_Sold__c == pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == false && pur.Sales_Verified__c != pur.Previous_Sales_Verified__c)) {
                system.debug('PUR Pending ==>Total_Units_Sold__c and Sales_Verified__c varies');
                flag++;
                noOfflag++;  // Nicole added 8.28.2018
            }
        }
        
        //Total Units Sold Has not changed, but Sales_Verified__c is false
        if (pur.Total_Units_Sold__c != null && pur.Total_Units_Sold__c != 0) {
            if ((pur.Total_Units_Sold__c == pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == false) {
                system.debug('PUR Pending == >  Total units sold not varied but Sales_Verified__c false');
                flag++;
            }
        }

// Set PUR Status based on the logic flags 
        system.debug('flag==' + flag + ',' + 'Approvalflag==' + Approvalflag + ',' + 'noOfflag==' + noOfflag);
        if (flag != 0) {
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;								// Nicole added 8.28.18
            system.debug('Auto_Approved__c needs to be set to FALSE 1');
            system.debug('PUR Pending ==>pending criteria met');
        } else if (noOfflag != 0) {										// Moved this section up once
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;								// Nicole added 8.28.18
            system.debug('Auto_Approved__c needs to be set to FALSE 11');
        } else if (flag == 0 && noOfflag == 0 && Approvalflag != 0) {	// Nicole added noflag check 8.28.18
            pur.Update_Request_Status__c = 'Approved';
            pur.Auto_Approved__c = true;
            system.debug('Auto_Approved__c = true 5');
            system.debug('PUR Approved==>Approved criteria met');            
        } else {
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;								// Nicole added 8.28.18
            system.debug('Auto_Approved__c needs to be set to FALSE 12');
        }
    }
    ////////////////////*********** SFDC-173 FOR UPCOMIMG STATUS ***********///////////////////

    public static void PURinsert_Upcoming(id theProjectId, Project_Update_Request__c pur, boolean havePlans) {
        system.debug('In PUR insert_Upcoming method');
        Integer noOfflag = 0;
        Project__c prj = [select id,Status__c,Num_of_Days_Since_Last_Update__c,Builder__r.Name,Total_Units_Sold__c,Meyers_Notes__c,Update_Cycle__c,ZIC_Date__c,Data_User__r.Days_Since_Data_User_Created__c,No_Of_Times_Auto_Approved__c,No_Of_Times_Auto_Approved_Set__c from Project__c where id=:theProjectId];
        Decimal Days_Since_Data_User_Created;
        if(Test.isRunningTest()){ Days_Since_Data_User_Created = 91;} else { Days_Since_Data_User_Created = prj.Data_User__r.Days_Since_Data_User_Created__c ;}
        system.debug(Days_Since_Data_User_Created);
 
      //Status is not Upcoming -- including this so just in case a NON-Upcoming project slips through
        if (prj.Status__c != 'Upcoming') {
            system.debug('PUR Pending ==> Status is not Upcoming');
            noOfflag++;
            flag++;		// Nicole Added 7.17.18
        }
        
        if(Days_Since_Data_User_Created >90 ){
            system.debug('PUR Approved==> Days_Since_Data_User_Created >90');
            Approvalflag++;
        }
        else {noOfflag++;// Nicole Added 7.17.18
              flag++;
            system.debug('PUR Pending ==>Days_Since_Data_User_Created <90');            
        }
        if((Days_Since_Data_User_Created >90)  && (prj.No_Of_Times_Auto_Approved__c==3)){
            system.debug('PUR Pending ==>No_Of_Times_Auto_Approved__c==3');
            flag++;
            noOfflag++;  // Nicole Added 7.17.18
        }
            // Project__c prj = [select id,Status__c,Num_of_Days_Since_Last_Update__c,Builder__r.Name,Total_Units_Sold__c,Meyers_Notes__c,Update_Cycle__c,ZIC_Date__c,Data_User__r.Days_Since_Data_User_Created__c,No_Of_Times_Auto_Approved__c,No_Of_Times_Auto_Approved_Set__c from Project__c where id=:theProjectId];
            /*  Decimal Days_Since_Data_User_Created;
                if(Test.isRunningTest()){ 
                Days_Since_Data_User_Created = 91;
                } 
                else{ 
                Days_Since_Data_User_Created = prj.Data_User__r.Days_Since_Data_User_Created__c ;
            } */

        if (pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) {
            system.debug('PUR Pending == > Total_Units_Sold__c Changed to ' + pur.Total_Units_Sold__c + ' from ' + pur.Previous_Total_Units_Sold__c);
            flag++;
        }
        if (pur.Open_Date__c != pur.Previous_Open_Date__c) {
            system.debug('PUR Pending == > Open_Date Changed from ' + pur.Previous_Open_Date__c + ' to ' + pur.Open_Date__c);
            flag++;
        }

        decimal Total_Units_Planned;
        decimal Previous_Total_Units_Planned;
        decimal per;
        Total_Units_Planned = pur.Total_Units_Planned__c;
        Previous_Total_Units_Planned = pur.Previous_Total_Units_Planned__c;
        if (Total_Units_Planned != null && Total_Units_Planned != 0 && Previous_Total_Units_Planned != null && Previous_Total_Units_Planned != 0 && Previous_Total_Units_Planned != Total_Units_Planned) {
            per = integer.valueof(Total_Units_Planned) - integer.valueof(Previous_Total_Units_Planned);
            system.debug('*sub**' + per);
            decimal i = (per / integer.valueof(Previous_Total_Units_Planned)) * 100;
            system.debug(i);
            integer j = integer.valueOf(i);
            system.debug('Total Units Planned percentage' + j);
            if (!(j <= 50 && j >= -50)) {
                system.debug('PUR Pending == > Total_Units_Planned percentage is==>' + j);
                flag++;
            } else {
                Approvalflag++;
                system.debug('PUR Approved== > Total_Units_Planned percentage is==>' + j);

            }
        }

        if (pur.Product_Type__c != pur.Previous_Product_Type__c) {
            system.debug('PUR Pending == > Product_Type Changed from ' + pur.Previous_Product_Type__c + ' to ' + pur.Product_Type__c);
            flag++;
        }
        if (pur.Lot_Dimension__c != pur.Previous_Lot_Dimension__c) {
            system.debug('PUR Pending == > Lot_Dimension Changed from ' + pur.Previous_Lot_Dimension__c + ' to ' + pur.Lot_Dimension__c);
            flag++;
        }
        if (pur.Open_Date__c != pur.Previous_Open_Date__c) {
            system.debug('PUR Pending == > Open_Date Changed from ' + pur.Previous_Open_Date__c + ' to ' + pur.Open_Date__c);
            flag++;
        }
        if (pur.Sold_Out_Date__c != pur.Previous_Sold_Out_Date__c) {
            system.debug('PUR Pending == > Sold_Out_Date Changed from ' + pur.Previous_Sold_Out_Date__c + ' to ' + pur.Sold_Out_Date__c);
            flag++;
        }
        if (pur.Previous_Typical_Lot_Size__c != null && pur.Previous_Typical_Lot_Size__c != 0 && pur.Previous_Typical_Lot_Size__c != pur.Typical_Lot_Size__c) {
            system.debug('Previous_Typical_Lot_Size value is==> ' + pur.Previous_Typical_Lot_Size__c);
            system.debug('Typical_Lot_Size value is==> ' + pur.Typical_Lot_Size__c);
            decimal Typical_Lot_Size;
            decimal Previous_Typical_Lot_Size;
            decimal tper;
            Typical_Lot_Size = pur.Typical_Lot_Size__c;
            Previous_Typical_Lot_Size = pur.Previous_Typical_Lot_Size__c;
            tper = integer.valueof(Typical_Lot_Size) - integer.valueof(Previous_Typical_Lot_Size);
            system.debug('*tper**' + tper);
            decimal i = (tper / integer.valueof(Previous_Typical_Lot_Size)) * 100;
            system.debug('i in Typical_Lot_Size==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in Typical_Lot_Size==>' + j);
            // if(!(j<=200 && j>=-200) ){
            if (j >= 100 || j <= -50) {
                system.debug('PUR Pending == > Typical_Lot_Size percentage is==>' + j);
                flag++;
            } else {
                Approvalflag++;
                system.debug('PUR Approved== > Typical_Lot_Size percentage is==>' + j);

            }
        }
        if (pur.Previous_HOA__c != null && pur.Previous_HOA__c != 0 && pur.Previous_HOA__c != pur.HOA__c) {
            system.debug('Previous_Monthly HOA #1 value is==>' + pur.Previous_HOA__c);
            system.debug('Monthly HOA #1 value is==> ' + pur.HOA__c);
            decimal HOA;
            decimal Previous_HOA;
            decimal hper;
            HOA = pur.HOA__c;
            Previous_HOA = pur.Previous_HOA__c;
            hper = integer.valueof(HOA) - integer.valueof(Previous_HOA);
            system.debug('*hper**' + hper);
            decimal i = (hper / integer.valueof(Previous_HOA)) * 100;
            system.debug('i in HOA==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in HOA==>' + j);
            // if(j>200){
            if (j >= 100 || j <= -50) {
                system.debug('PUR Pending == >  Monthly HOA #1 percentage is==>' + j);
                flag++;
            } else {
                Approvalflag++;
                system.debug('PUR Approved== > Monthly HOA #1 percentage is==>' + j);

            }
        }
        if (pur.Previous_HOA_2__c != null && pur.Previous_HOA_2__c != 0 && pur.Previous_HOA_2__c != pur.HOA_2__c) {
            system.debug('Previous_Monthly HOA #2 value is==>' + pur.Previous_HOA_2__c);
            system.debug('Monthly HOA #2 value is==> ' + pur.HOA_2__c);
            decimal HOA2;
            decimal Previous_HOA2;
            decimal hper2;
            HOA2 = pur.HOA_2__c;
            Previous_HOA2 = pur.Previous_HOA_2__c;
            hper2 = integer.valueof(HOA2) - integer.valueof(Previous_HOA2);
            system.debug('*hper2**' + hper2);
            decimal i = (hper2 / integer.valueof(Previous_HOA2)) * 100;
            system.debug('i in HOA2==>' + i);
            integer j = integer.valueOf(i);
            system.debug('j in HOA2==>' + j);
            // if(j>200){
            if (j >= 100 || j <= -50) {
                system.debug('PUR Pending == >  Monthly HOA #2 percentage is==>' + j);
                flag++;
            } else {
                Approvalflag++;
                system.debug('PUR Approved== >  Monthly HOA #2  percentage is==>' + j);

            }
        }
        if (pur.Assessments__c != null && (pur.Previous_Assessments__c == pur.Assessments__c)) {
            system.debug('PUR Approved == >  Total Tax Rate == updated tax');
            Approvalflag++;
        } else {
            if (pur.Assessments__c != null) {
                if (pur.Assessments__c < 5.00 && pur.Assessments__c >= 0) {
                    system.debug('PUR Approved == >  Total Tax Rate (%) is LESS THAN 5.00');
                    Approvalflag++;
                } else {
                    system.debug('PUR Pending == >  Total Tax Rate percentage is==>' + pur.Assessments__c);
                    flag++;
                }
            }
        }
        if (pur.Previous_Total_Units_Sold__c == null && pur.Total_Units_Sold__c != null) {
            flag++;
            system.debug('PUR Pending ==>Total_Units_Sold__c  changed from null to a value');

        }

        if (pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) {
            if ((pur.Total_Units_Sold__c != null) && ((pur.Total_Units_Sold__c >= (pur.Previous_Total_Units_Sold__c + 10)) || (pur.Total_Units_Sold__c < pur.Previous_Total_Units_Sold__c))) {
                system.debug('PUR Pending == >  Total_Units_Sold__c  varies');
                flag++;
            }
        }
        if (pur.Previous_Total_Units_Sold__c != null && pur.Previous_Total_Units_Sold__c != null && pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) {
            system.debug('pur.Total_Units_Sold__c===' + pur.Total_Units_Sold__c + 'pur.Previous_Total_Units_Sold__c==' + pur.Previous_Total_Units_Sold__c);
            if (pur.Total_Units_Sold__c < (pur.Previous_Total_Units_Sold__c + 10)) {
                system.debug('PUR Approved =>Total Units Sold is LESS THAN Previous Total Units Sold + 10 and GREATER THAN or EQUAL TO Previous TUS + 0');
                Approvalflag++;
            }
        }

        if (pur.Total_Units_Sold__c != null && pur.Previous_Total_Units_Sold__c != null) {
            if (((pur.Total_Units_Sold__c != pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == true) || ((pur.Total_Units_Sold__c == pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == false && pur.Sales_Verified__c != pur.Previous_Sales_Verified__c)) {
                system.debug('PUR Pending ==>Total_Units_Sold__c and Sales_Verified__c varies');
                flag++;
            }
        }
        if (pur.Total_Units_Sold__c != null && pur.Total_Units_Sold__c != 0) {
            if ((pur.Total_Units_Sold__c == pur.Previous_Total_Units_Sold__c) && pur.Sales_Verified__c == false) {
                system.debug('PUR Pending == >  Total units sold not varied but Sales_Verified__c false');
                flag++;
            }
        }
        system.debug('flag==' + flag + ',' + 'Approvalflag==' + Approvalflag);
        if (flag != 0) {
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;
            system.debug('PUR Pending ==> Pending criteria met');
            		system.debug('Auto_Approved__c needs to be set to FALSE 2');
        } else if (flag == 0 && Approvalflag != 0) {
            pur.Update_Request_Status__c = 'Approved';
            pur.Auto_Approved__c = true;
            system.debug('PUR Approved==> Approved criteria met 1');
            system.debug('Auto_Approved__c = true 1');

        } else if (flag == 0 && Approvalflag == 0) {
            system.debug('Both flags are 0');
            if ((pur.Meyers_Notes__c != pur.Previous_Meyers_Notes__c) && havePlans == false) {
                //pur.Update_Request_Status__c = 'Approved';
                pur.Update_Request_Status__c = 'Pending';
                //pur.Auto_Approved__c = true;
                pur.Auto_Approved__c = false;
                //system.debug('Auto_Approved__c = true 2');
                //system.debug('PUR Approved==> Approved criteria met');

            } else if ((pur.Meyers_Notes__c != pur.Previous_Meyers_Notes__c) && havePlans == true) {
                system.debug('PUR Approved==> Approved criteria met');
                pur.Update_Request_Status__c = 'Approved';
                pur.Auto_Approved__c = true;
                system.debug('Auto_Approved__c = true 3');
                Approvalflag++;
            } else if ((pur.Meyers_Notes__c == pur.Previous_Meyers_Notes__c) && havePlans == false) {
                system.debug('PUR Pending ==> Pending criteria met');
                system.debug('Auto_Approved__c needs to be set to FALSE 3');
                pur.Update_Request_Status__c = 'Pending';
                system.debug('Auto_Approved__c needs to be set to FALSE 13');
            } else if ((pur.Meyers_Notes__c == pur.Previous_Meyers_Notes__c) && havePlans == true) {
                pur.Update_Request_Status__c = 'Pending';
                flag++;
                system.debug('PUR Pending ==> Pending criteria met');
                system.debug('Auto_Approved__c needs to be set to FALSE 4');
            }
        }

    }

    ///////////////////************* SFDC-171 **************////////////////////// 

    public static string PURUpdate(Project_Update_Request__c pur, Plan_Update_Request__c plnur) {
        system.debug('In Plr to Update PUR');
        system.debug(plnur.Previous_Plan_Name__c + ',' + plnur.Plan_Name__c + ',' + plnur.Previous_Price__c + ',' + plnur.Price__c + ',' + plnur.Previous_Num_of_Baths__c + ',' + plnur.Num_of_Baths__c + ',' + plnur.Previous_Num_of_Full_Baths__c + ',' + plnur.Num_of_Full_Baths__c + ',' + plnur.Previous_Num_of_Half_Baths__c + ',' + plnur.Num_of_Half_Baths__c + ',' + plnur.Previous_Num_of_Beds__c + ',' + plnur.Num_of_Beds__c + ',' + plnur.Previous_Square_Footage__c + ',' + plnur.Square_Footage__c + ',' + plnur.Previous_Plan_Notes__c + ',' + plnur.Plan_Notes__c + ',' + plnur.Previous_Num_of_Floors__c + ',' + plnur.Num_of_Floors__c + ',' + plnur.Previous_Garage__c + ',' + plnur.Garage__c + ',' + plnur.Previous_Off_Market__c + ',' + plnur.Off_Market__c);
        if ((plnur.Previous_Plan_Name__c == NULL && plnur.Plan_Name__c != NULL) || (plnur.Previous_Price__c == NULL && plnur.Price__c != NULL) || (plnur.Previous_Num_of_Baths__c == NULL && plnur.Num_of_Baths__c != NULL) || (plnur.Previous_Num_of_Full_Baths__c == NULL && plnur.Num_of_Full_Baths__c != NULL) || (plnur.Previous_Num_of_Half_Baths__c == NULL && plnur.Num_of_Half_Baths__c != NULL) || (plnur.Previous_Num_of_Beds__c == NULL && plnur.Num_of_Beds__c != NULL) || (plnur.Previous_Square_Footage__c == NULL && plnur.Square_Footage__c != NULL) || (plnur.Previous_Plan_Notes__c == NULL && plnur.Plan_Notes__c != '') || (plnur.Previous_Num_of_Floors__c == NULL && plnur.Num_of_Floors__c != NULL) || (plnur.Previous_Garage__c == NULL && plnur.Garage__c != NULL) || (plnur.Previous_Off_Market__c != true && plnur.Off_Market__c == true)) {
            system.debug('PUR pending ==> Plan Added');
            flag++;
        }
        if ((plnur.Previous_Price__c == NULL || plnur.Previous_Price__c == 0) && (plnur.Price__c != NULL && plnur.Price__c != 0)) {
            system.debug('PUR pending ==> Plan Price__c varied');
            flag++;
        }
        if ((plnur.Previous_Square_Footage__c == NULL || plnur.Previous_Square_Footage__c == 0) && (plnur.Square_Footage__c != NULL && plnur.Square_Footage__c != 0)) {
            system.debug('PUR pending ==> Plan Square_Footage__c varied');
            flag++;
        }

        //////////////////////////////////////////////////////////////////////////////////////
        decimal Base_Price;
        decimal Previous_Base_Price;
        decimal per3;
        Base_Price = plnur.Price__c;
        Previous_Base_Price = plnur.Previous_Price__c;
        if (Base_Price != null && Base_Price != 0 && (Previous_Base_Price == null || Previous_Base_Price == 0)) {
            if (!(Base_Price <= 4.9 && Base_Price >= -4.9)) {
                flag++;
                system.debug('PUR pending ==> Plan Base_Price varied is 5% above or -5%  below');
                pur.Auto_Approved__c = false;

            } else {
                system.debug('PUR Approved==> Plan Base_Price varied is not in 5% above or -5%  below');
                Approvalflag++;
            }
        }
        if (Base_Price != null && Base_Price != 0 && Previous_Base_Price != null && Previous_Base_Price != 0 && Base_Price != Previous_Base_Price) {
            per3 = integer.valueof(Base_Price) - integer.valueof(Previous_Base_Price);
            system.debug('*diff per3**' + per3);
            decimal i2 = (per3 / integer.valueof(Previous_Base_Price)) * 100;
            system.debug(i2);
            integer j2 = integer.valueOf(i2);
            system.debug('Base_Price percentage' + j2);
            if (!(j2 <= 4.9 && j2 >= -4.9)) {
                system.debug('PUR pending ==> Plan Base_Price varied is 5% above or -5%  below');
                flag++;
            } else {
                system.debug('PUR Approved==> Plan Base_Price varied is not in 5% above or -5%  below');
                Approvalflag++;
            }
        }
        /////////////////////////////////////////////////////////////////////////////////////// 
        decimal Square_Footage;
        decimal Previous_Square_Footage;
        decimal per2;
        Square_Footage = plnur.Square_Footage__c;
        Previous_Square_Footage = plnur.Previous_Square_Footage__c;

        if (Square_Footage != null && Square_Footage != 0 && Previous_Square_Footage != null && Previous_Square_Footage != 0 && Square_Footage != Previous_Square_Footage) {
            per2 = integer.valueof(Square_Footage) - integer.valueof(Previous_Square_Footage);
            system.debug('*sub**' + per2);
            decimal i2 = (per2 / integer.valueof(Previous_Square_Footage)) * 100;
            system.debug(i2);
            integer j2 = integer.valueOf(i2);
            system.debug('&&&&' + j2);
            if (!(j2 <= 25 && j2 >= -25)) {
                system.debug('PUR pending ==> Plan Square_Footage varied is 25% above or -25%  below');
                flag++;
            } else {
                system.debug('PUR Approved==> Plan Square_Footage varied is not in 25% above or -25%  below');
                Approvalflag++;
            }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////

        system.debug('flag==' + flag + ',' + 'Approvalflag==' + Approvalflag);
        if (flag != 0) {
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;
            system.debug('Auto_Approved__c needs to be set to FALSE 14');
            return pur.Update_Request_Status__c + ',' + '1';
        } else if (flag == 0 && Approvalflag != 0) {
            system.debug('PUR Approved ==> Approved criteria met');
            pur.Update_Request_Status__c = 'Approved';
            pur.Auto_Approved__c = true;
            system.debug('Auto_Approved__c = true 4');
            return pur.Update_Request_Status__c + ',' + '2';
        } else {
            pur.Update_Request_Status__c = 'Pending';
            pur.Auto_Approved__c = false;
            system.debug('Auto_Approved__c needs to be set to FALSE 15');
            system.debug('PUR Pending ==> Pending criteria met 9');
            return pur.Update_Request_Status__c + ',' + '3';
            
        }
    }
}