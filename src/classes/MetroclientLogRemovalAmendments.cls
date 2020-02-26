global class MetroclientLogRemovalAmendments implements Schedulable {
 
global void execute(SchedulableContext ctx) { 
     /*  SchedulableContext sc = null;
         MetroclientLogRemovalAmendments b = new MetroclientLogRemovalAmendments ();
         b.execute(sc);    */
         System.debug('Call Method');
         LogRemovalAmendments();
   } 

@future(callout=true)
private static void LogRemovalAmendments() { 
    boolean bFailed=false; 
    boolean bChanges = false;
    string queryAmendment='';
    string querySubscription='';
    string amdStatus;
    string SubStatus;
    string RatePlanId;
    string queryRatePlanChargeWhere='';
    string queryRatePlanChargeWhere_All='';
    string whereAmmCode = '\'PreventEmpty\'';
    string name = '';
    string ChargeNumber;
    string SubscriptionName;
    dateTime AmendmentEffectiveDate;
    date AEffectiveDate;
    string AmendmentName; 
    string AmendmentCode; 
    string SubscriptionId;
    string AmendmentId;    
    string sMailMessage = ''; 
    boolean IsLastSegment;
    List<MetroclientSubscriptionAmendmentLog__c> UpsertList = new List<MetroclientSubscriptionAmendmentLog__c>(); 
    Map<String, String> mapSub = new Map<String ,String>();
    Map<String, String> mapSubSt= new Map<String ,String>();
    Map<String, String> mapAmmCode = new Map<String ,String>(); 
    Map<String, String> mapRat = new Map<String ,String>();
    Map<String, String> mapRatA = new Map<String ,String>();
    Map<String, datetime> mapAmm = new Map<String ,datetime>();
    Map<String, datetime> mapMetro= new Map<String ,datetime>();    
 
       /*
    1) Get Date of last run time ***************************************************/   
  
    MetrostudyProvisionSettings__c mps = MetrostudyProvisionSettings__c.getOrgDefaults();
    string  sTo=mps.SendEmailTo__c;
    string  sCc=mps.SendEmailCc__c;
    DateTime LastCheck =  mps.LogRemovalAmendmentsLastRun__c;
    DateTime MaxCheck = mps.LogRemovalAmendmentsMaxRun__c;
    System.debug('LastCheck : ' + LastCheck  + '.....' +  mps.LogRemovalAmendmentsLastRun__c);
    System.debug('MaxCheck: ' + MaxCheck + '.....' +  mps.LogRemovalAmendmentsMaxRun__c);

    
    if(LastCheck==null)
        LastCheck =System.now().addHours(-24);   
      
    
   
    DateTime NewDate = System.now();
    
    System.debug('NewDate : ' + NewDate);
    System.debug('MaxCheck: ' + MaxCheck + '.....' +  mps.LogRemovalAmendmentsMaxRun__c);
    If(MaxCheck!=null && MaxCheck< NewDate && MaxCheck > LastCheck )
         NewDate = MaxCheck;
     
   System.debug('NewDate : ' + NewDate);
    
    
    if(LastCheck.addHours(25)< NewDate)//don't go over a day
              NewDate = LastCheck.addHours(25);
   
    System.debug('NewDate : ' + NewDate);
    

   DateTime zLastCheck=LastCheck.AddHours(-8); //Subtract 8 hours for Zuora offset from GMT 
   string sLastCheck =zLastCheck.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
   DateTime zNewDate =NewDate.AddHours(-8); //Subtract 8 hours for Zuora offset from GMT 
   string sNewDate=zNewDate .formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
    
    /*
    2) Find all RemoveProduct Amendments modified since last check; Put Amendments IDs in a string for Where statement   **************************/
    System.Debug('Find all RemoveProduct Amendments created since last check: ' + sLastCheck + ' through ' + sNewDate);   
    
    try{    
        
        List<Zuora.zObject> zAmm= ZuoraAPIUtil.zQueryZuora('Amendment','select CreatedDate, Id, SubscriptionId, Name, Status, Code, Type,EffectiveDate,UpdatedDate from Amendment where Type=\'RemoveProduct\' and Status!=\'Draft\' and UpdatedDate >=' + sLastCheck +' and UpdatedDate <=' + sNewDate+' ');
    
        for (Zuora.zObject Amm: zAmm)    
        { 
            bChanges = true;
            amdStatus =  (string)Amm.getValue('Status');    
            System.debug('Amendment Name ' + (string)Amm.getValue('Name') + ' ....Amendment Id ' + (string)Amm.getValue('Id') + '.......EffectiveDate: ' + (dateTime)Amm.getValue('EffectiveDate') + '.....amdStatus=' + amdStatus  + '...............Amendment -UpdatedDate......' +(dateTime)Amm.getValue('UpdatedDate') );
         
           if(amdStatus=='Completed' || amdStatus=='Active')
           {
                if(queryAmendment!='')
                    queryAmendment =  queryAmendment + ' OR ';
                queryAmendment = queryAmendment + ' AmendmentId = \'' + (string)Amm.getValue('Id') + '\'' ;
                
                whereAmmCode=  whereAmmCode+ ',' +   '\'' + (string)Amm.getValue('Code') + '\''; 
                 
                mapAmm.put((string)Amm.getValue('Id'),(datetime)Amm.getValue('EffectiveDate') ); 
                mapAmmCode.put((string)Amm.getValue('Id'),(string)Amm.getValue('Code') );            
           }
        } 
        System.Debug(queryAmendment);    
        
        if(!bChanges){
            System.Debug('No Change');        
        }else{                
                  
            
            string queryAP= 'Select UniqueName__c, EffectiveDate__c';
            queryAP+=' from MetroclientSubscriptionAmendmentLog__c where ProvisioningUpdated__c= true and Name in ('+ whereAmmCode+')';
            System.debug('queryAP::::'+ queryAP);             
            List<MetroclientSubscriptionAmendmentLog__c> RemoveAmd =  Database.query(queryAP);             
            for(MetroclientSubscriptionAmendmentLog__c m: RemoveAmd)
            {
                mapMetro.put(m.UniqueName__c,m.EffectiveDate__c ); 
                System.Debug(m.EffectiveDate__c);
            }                 
            
            
            
           List<Zuora.zObject> zRatePlanChargeAll = new List<Zuora.zObject>(); 
           List<Zuora.zObject> zRatePlanCharge = new List<Zuora.zObject>();
            
            /*3) Find all RatePlans with an amendmentid in the list of  RemoveProduct Amendments  **************************************/
            
            System.Debug('Find all RatePlans with an amendmentid in the list of  RemoveProduct Amendments ');
            List<Zuora.zObject> zobjs = ZuoraAPIUtil.zQueryZuora('RatePlan','select Id, SubscriptionId, Name, AmendmentType, AmendmentId, AmendmentSubscriptionRatePlanId from RatePlan where AmendmentType=\'RemoveProduct\' AND ' + queryAmendment  );
            
            integer s = 0;
            integer p = 0;
            integer lim = 200; // 200 is Zuora's maximum number of parameters in the Where clause.
            String queryRatePlanCharge = 'select Id,Name,ChargeNumber,RatePlanId,IsLastSegment from RatePlanCharge Where ' ;
                   
            for (Zuora.zObject r: zobjs)    
             { 
                   RatePlanId = (string)r.getValue('Id') ;
                   System.Debug((string)r.getValue('Name')  + '....AmendmentType: ' + (string)r.getValue('AmendmentType') + '.....AmendmentId: ' + (string)r.getValue('AmendmentId')+ ' ....... RatePlanId ' + RatePlanId + '................AmendmentSubscriptionRatePlanId......' +(string)r.getValue('AmendmentSubscriptionRatePlanId') );             
                  
                   
                   if((string)r.getValue('AmendmentType')=='RemoveProduct')
                   {
                       mapRat.put(RatePlanId,(string)r.getValue('SubscriptionId')); 
                       mapRatA.put(RatePlanId,(string)r.getValue('AmendmentId')); 
                       if(!queryRatePlanChargeWhere.contains('\'' + RatePlanId + '\''))
                       {
                           if(p>=lim)
                           {
                                 // this is to have multiple lists added to a big list b/c of Zuora's 200 limit in WHERE clause.  If this callout happens more than 5 times, could reach Zuora's API callout limit.  Handle with adding a maximum date in the Custom Settings to reduce results.*/
                                 System.debug('----***---Query to Pull rate plan charges: ' +queryRatePlanCharge);   
                                 System.Debug('---p=' + p + ' rateplans; ' +queryRatePlanChargeWhere);      
                                 zRatePlanCharge  = ZuoraAPIUtil.zQueryZuora('RatePlanCharge',queryRatePlanCharge + queryRatePlanChargeWhere);            
                                 zRatePlanChargeAll.addall(zRatePlanCharge);
                                 queryRatePlanChargeWhere='';
                                 p = 0;                                 
                           }
                           
                           p+=1;
                           if(queryRatePlanChargeWhere!='')
                                queryRatePlanChargeWhere =  queryRatePlanChargeWhere + ' OR';
                           queryRatePlanChargeWhere = queryRatePlanChargeWhere + ' RatePlanId=\'' + RatePlanId+ '\'' ;
                        }
                        
                       if(!querySubscription.contains('\'' + (string)r.getValue('SubscriptionId') + '\''))
                       {
                           s+=1;
                           if(querySubscription!='')
                                   querySubscription=  querySubscription+ ' OR';
                           querySubscription= querySubscription+ ' Id=\'' + (string)r.getValue('SubscriptionId') + '\'' ;                    
                       }
                         
                    }
              }        
           
            System.Debug(s + ' subs;  ' + querySubscription);
        
            /*
            4) Get Subscription Names for the matching rate plan subscriptions ***************************************/
            
            List<Zuora.zObject> zSub = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name, Status from Subscription where ' + querySubscription);
            
            for (Zuora.zObject sub: zSub)    
            {     
               System.Debug('--- map sub id: ' + (string)sub.getValue('Id') +' .... Name: ' + (string)sub.getValue('Name'));
               mapSub.put((string)sub.getValue('Id'),(string)sub.getValue('Name') );  
               mapSubSt.put((string)sub.getValue('Id'),(string)sub.getValue('Status') );        
            }
            
            
           
            /*        
            5) Get the Rate Plan Charges for the Removed Rate Plans********************************************************/
            
            /* Add last rate plans charges LIST to "All" list.  If there are more than 200 total rate plan charges, the list has more from the loop above */
            System.debug('----***---Query to Pull rate plan charges: ' +queryRatePlanCharge);   
            System.Debug('---p=' + p + ' rateplans; ' +queryRatePlanChargeWhere);      
            if(queryRatePlanChargeWhere!='')
            {
                zRatePlanCharge  = ZuoraAPIUtil.zQueryZuora('RatePlanCharge',queryRatePlanCharge + queryRatePlanChargeWhere);            
                zRatePlanChargeAll.addall(zRatePlanCharge);         
            }
                   
            for (Zuora.zObject c: zRatePlanChargeAll)    
            {
                System.debug('***********************************');
                RatePlanId= (string)c.getValue('RatePlanId'); 
                IsLastSegment= (boolean)c.getValue('IsLastSegment'); 
                ChargeNumber  = (string)c.getValue('ChargeNumber');           
                SubscriptionId = mapRat.get(RatePlanId);
                SubscriptionName = mapSub.get(SubscriptionId);
                SubStatus= mapSubSt.get(SubscriptionId);
                AmendmentId = mapRatA.get(RatePlanId);
                AmendmentCode= mapAmmCode.get(AmendmentId );
                AmendmentEffectiveDate = mapAmm.get(AmendmentId);
                name = SubscriptionName  + ' | ' + ChargeNumber   + ' | ' + AmendmentCode;            
               
                AEffectiveDate = null;
                if(AmendmentEffectiveDate!=null)
                     AEffectiveDate   = AmendmentEffectiveDate.Date();   
                System.debug(name  + ' ' + AEffectiveDate + ' ' + IsLastSegment + ' SubStatus:' + SubStatus); 
                
                if(IsLastSegment && SubStatus=='Active' && AEffectiveDate!=mapMetro.get(name))
                {   
                    System.Debug('Upsert');                                   
                    MetroclientSubscriptionAmendmentLog__c a= new MetroclientSubscriptionAmendmentLog__c();                                        
                    a.SubscriptionName__c=SubscriptionName ;
                    a.ChargeNumber__c=ChargeNumber  ;
                    a.name=AmendmentCode;
                    a.UniqueName__c=name;
                    a.EffectiveDate__c=AEffectiveDate;                                
                    a.ProvisioningUpdated__c = false;
                    a.AmendmentType__c = 'RemoveProduct';
                    UpsertList.add(a);                             
                 }    
                   
              }  //for (Zuora.zObject c: zRatePlanCharge)   
            
            
            try{      
                if (UpsertList.isEmpty() == false)                 
                  {upsert UpsertList UniqueName__c;
                  }
             }catch (Exception ex) {
                  System.debug('Update Exception' + ex); 
                  sMailMessage +=  'Update Exception' + ex + '<br /><br />Line# ' + ex.getLineNumber();              
                  bFailed= true;      
                   }     
       }//!bChanges else
    
     
   }catch (Exception ex) {            
         System.debug('Exception: ' + ex + '....Line # ' + ex.getLineNumber()); 
         sMailMessage +=  'Exception' + ex + '<br /><br />Line# ' + ex.getLineNumber();  
         bFailed= true;        
   }  
           
    /************ LAST: Update date of last check***************/
    if(bFailed==false && !Test.isRunningTest())
    {
        mps.LogRemovalAmendmentsLastRun__c= NewDate;
        update mps;
        System.Debug('LogRemovalAmendmentsLastRun__cupdated to:  ' + NewDate);
    }
    
      if(bFailed)
    {
       SendEmail('**MetroclientLogRemovalAmendments',sMailMessage, sTo, sCc);
    }
           
}   
 
  private static void SendEmail(string sSubject, string sBody, string sTo, string sCc){
      
         try{  
            
            sBody='<body style="font-family:arial;font-size:10pt">' + sBody  +'</body>' ;        
                      
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {sTo});
            mail.setToAddresses(new String[] {sCc});
            mail.setSubject(sSubject);
            String messageBody = sBody;
            mail.setHtmlBody(messageBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
         }catch (Exception ex) {
                System.debug('EMAIL Error -Line#'+ ex.getLineNumber() + '-----' + ex );
         } 
    
   }   
}