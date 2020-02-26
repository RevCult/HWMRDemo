global class MetroclientAccountProvisionBatchDelete implements Schedulable {
 
global void execute(SchedulableContext ctx) {

 
     /*  SchedulableContext sc = null;
         MetroclientAccountProvisionBatchDelete b = new MetroclientAccountProvisionBatchDelete ();
         b.execute(sc);    */
     
    boolean bFound;
    boolean bFailed=false;  
    string Subject = 'Results: SubscriptionRemoveAmmendmentLastCheck';
    string sMailMessage='';
    string sMailMessageNotUpdated='';
    boolean bChanges = false;
    string queryAmendment='';
    string querySubscription='';
    string lastAccount = '';
    List<MetroclientAccountProductGeography__c> UpdateList = new List<MetroclientAccountProductGeography__c>(); 
    
    /*
    1) Get Date of last run time ***************************************************/   
    

    MetrostudyProvisionSettings__c mps = MetrostudyProvisionSettings__c.getOrgDefaults();
    string  sTo =mps.SendEmailTo__c;
    string sCc= mps.SendEmailCc__c;
    boolean  bUpdateProvisioning=mps.UpdateProvisioning__c;
    DateTime LastCheck =  mps.DeleteAmmendmentLastCheck__c;
    if(LastCheck==null)
        LastCheck =System.now().addHours(-24);
    if (Test.isRunningTest()) {
            bUpdateProvisioning=true;
        }
      
    
           
    
    DateTime zLastCheck=LastCheck.AddHours(-8); //Subtract 8 hours for Zuora offset from GMT 
    string sLastCheck =zLastCheck.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
    DateTime NewDate = System.now();
    
    /*
    2) Find all RemoveProduct Amendments modified since last check; Put Amendments IDs in a string for Where statement   **************************/
    
    
try{ 
     
    System.Debug('Find all RemoveProduct Amendments created since last check');
    //and Status=\'Active\' 
    List<Zuora.zObject> zAmm= ZuoraAPIUtil.zQueryZuora('Amendment','select CreatedDate, Id, SubscriptionId, Name, Status, Code, Type,EffectiveDate from Amendment where Type=\'RemoveProduct\' and Status!=\'Draft\' and UpdatedDate   >=' + sLastCheck +'  ');
    Map<String, String> mapSub = new Map<String ,String>();
    Map<String, datetime> mapAmm = new Map<String ,datetime>();
    Map<String, String> mapAmmName = new Map<String ,String>();
    Map<String, String> mapAmmCode = new Map<String ,String>();
    string Status;
    for (Zuora.zObject Amm: zAmm)    
    { 
            bChanges = true;
            System.debug('Amendment Name ' + (string)Amm.getValue('Name') + ' ....Amendment Id ' + (string)Amm.getValue('Id') + '.......EffectiveDate: ' + (dateTime)Amm.getValue('EffectiveDate') );
            Status =  (string)Amm.getValue('Status');    
            System.debug('Status: ' + Status );
            
           if(Status=='Completed' || Status=='Active')
           {
                if(queryAmendment!='')
                    queryAmendment =  queryAmendment + ' OR ';
                queryAmendment = queryAmendment + ' AmendmentId = \'' + (string)Amm.getValue('Id') + '\'' ;
                
                mapAmm.put((string)Amm.getValue('Id'),(datetime)Amm.getValue('EffectiveDate') ); 
                mapAmmName.put((string)Amm.getValue('Id'),(string)Amm.getValue('Name') ); 
                mapAmmCode.put((string)Amm.getValue('Id'),(string)Amm.getValue('Code') );  
           }
    } 
    System.Debug(queryAmendment);
    
    
    if(!bChanges){
        System.Debug('No Change');
        
    }else{    
        
        string RatePlanId;
        string queryRatePlanChargeWhere='';
        string queryChrgName = '\'PreventEmpty\'';
        
        /*3) Find all RatePlans with an amendmentid in the list of  RemoveProduct Amendments  **************************************/
        
        System.Debug('Find all RatePlans with an amendmentid in the list of  RemoveProduct Amendments ');
        List<Zuora.zObject> zobjs = ZuoraAPIUtil.zQueryZuora('RatePlan','select Id, SubscriptionId, Name, AmendmentType, AmendmentId from RatePlan where AmendmentType=\'RemoveProduct\' AND ' + queryAmendment  );
               
         for (Zuora.zObject r: zobjs)    
         { 
                   RatePlanId = (string)r.getValue('Id') ;
                   System.Debug((string)r.getValue('Name')  + '....AmendmentType: ' + (string)r.getValue('AmendmentType') + '.....AmendmentId: ' + (string)r.getValue('AmendmentId')+ ' ....... RatePlanId ' + RatePlanId );             
                   
                   
                   if((string)r.getValue('AmendmentType')=='RemoveProduct')
                     {
                       if(queryRatePlanChargeWhere!='')
                               queryRatePlanChargeWhere =  queryRatePlanChargeWhere + ' OR ';
                        queryRatePlanChargeWhere = queryRatePlanChargeWhere + ' RatePlanId = \'' + RatePlanId+ '\'' ;
                         
                         if(querySubscription!='')
                            querySubscription=  querySubscription+ ' OR ';
                        querySubscription= querySubscription+ ' Id = \'' + (string)r.getValue('SubscriptionId') + '\'  ' ;                    
                         
                    }
          }        
        System.Debug(queryRatePlanChargeWhere);
        System.Debug(querySubscription);
    
        /*
        4) Get Subscription Names for the matching rate plan subscriptions ***************************************/
        
        List<Zuora.zObject> zSub = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name, SubscriptionEndDate from Subscription where ' + querySubscription);
        
        for (Zuora.zObject s: zSub)    
        {     
           System.Debug('--- map sub id: ' + (string)s.getValue('Id') +' .... Name: ' + (string)s.getValue('Name'));
           mapSub.put((string)s.getValue('Id'),(string)s.getValue('Name') );        
        }
        
        /*        
        5) Get the Rate Plan Charges for the Removed Rate Plans********************************************************/
   
        
        System.Debug('-----------Find all RatePlanCharges from the RemoveProduct Rate Plans------------ ');
        String queryRatePlanCharge = 'select Id,Name,EffectiveStartDate,EffectiveEndDate,ChargeNumber,Record_Id__c,ChargeType, RatePlanId from RatePlanCharge Where  ' + queryRatePlanChargeWhere;
        System.debug('-----------Query to Pull rate plan charges: ' +queryRatePlanCharge);
        
        string Record_Id;
        string ChargeNumber;
        string SubscriptionName;
        dateTime AmendmentEffectiveDate;
        date AEffectiveDate;
        string AmendmentName; 
        string AmendmentCode; 
     
        List<Zuora.zObject> zRatePlanCharge  = ZuoraAPIUtil.zQueryZuora('RatePlanCharge',queryRatePlanCharge );
        
        for (Zuora.zObject c: zRatePlanCharge)    
        {      
               if(queryChrgName!='')
                      queryChrgName = queryChrgName + ',';
                queryChrgName =  queryChrgName +   '\'' + (string)c.getValue('ChargeNumber') + '\'';  
        }    
        
        
        
        string queryAP= 'Select Id,Account__r.Name, Account__c, MetroclientProductGeography__r.Name, Deleted__c, Override__c, SubscriptionName__c,ChargeNumber__c, StartDate__c, EndDate__c,MetroclientProductGeography__c,RemovalAmendment__c';
        queryAP+=' from MetroclientAccountProductGeography__c where Deleted__c = false and ChargeNumber__c in ('+ queryChrgName +')';
        System.debug('queryAP::::'+ queryAP);             
        List<MetroclientAccountProductGeography__c> AccountProvision =  Database.query(queryAP);             
         Map<string, MetroclientAccountProductGeography__c> mapAccountProvision = new Map<string, MetroclientAccountProductGeography__c>(AccountProvision);       
        
        
        for (Zuora.zObject c: zRatePlanCharge)    
        {
            System.debug('***********************************');
            ChargeNumber  = (string)c.getValue('ChargeNumber'); 
            System.debug('ChargeNumber ' + ChargeNumber );
            Record_Id= (string)c.getValue('Record_Id__c'); 
            System.debug('Record_Id__c' + Record_Id);
            RatePlanId= (string)c.getValue('RatePlanId'); 
            AEffectiveDate = null;
            bFound = false;
             AmendmentName ='';
            SubscriptionName ='';
            AmendmentCode ='';
          
            
              for (Zuora.zObject r: zobjs)    
              { 
                 
                  
                if(RatePlanId== (string)r.getValue('Id'))  
                {
                    SubscriptionName = mapSub.get((string)r.getValue('SubscriptionId'));
                    AmendmentEffectiveDate = mapAmm.get((string)r.getValue('AmendmentId'));
                    AmendmentName  = mapAmmName.get((string)r.getValue('AmendmentId'));
                    AmendmentCode = mapAmmCode.get((string)r.getValue('AmendmentId'));
                    System.debug('*found rate plan ... AmendmentName: ' + AmendmentName + ' . . . ' + AmendmentCode  );
                    System.debug('  SubscriptionId' +(string)r.getValue('SubscriptionId') + '.....SubscriptionName:'+SubscriptionName + ' ......AmendmentEffectiveDate:' + AmendmentEffectiveDate );
                    if(AmendmentEffectiveDate!=null)
                        AEffectiveDate   = AmendmentEffectiveDate.Date();               
                    
                        //*////
                    if(AEffectiveDate!=null)
                    {
                     For(MetroclientAccountProductGeography__c  a: mapAccountProvision.values())
                      {
                             if(a.ChargeNumber__c ==ChargeNumber  && a.SubscriptionName__c==SubscriptionName )
                             {
                                  bFound = true;
                                 
                                  
                                 if(a.EndDate__c!=AEffectiveDate) 
                                 {
                                     if(lastAccount !=a.Account__r.Name)
                                             sMailMessage += '<br /><br /><strong>' + a.Account__r.Name + '</strong>';
                                             
                                     sMailMessage += '<br /><br />'+SubscriptionName + ' | ' + ChargeNumber + '<br />' + AmendmentCode + ' - ' + AmendmentName + '<br />' + a.MetroclientProductGeography__r.Name;
                                     sMailMessage +=  '<br /><strong>End Date Changed</strong>&nbsp; &nbsp; Before: '  + formatDateString(a.EndDate__c) + ' &nbsp;  After: '  + formatDateString(AEffectiveDate);  
                                     lastAccount=a.Account__r.Name;
                                     
                                     if(a.Override__c)
                                     {
                                         sMailMessage = '<br />Not Changed because Override is on';
                                     }else
                                     {  
                                         System.debug('Account Provisioning Updated');
                                         a.EndDate__c=AEffectiveDate   ;  
                                         a.RemovalAmendment__c =  AmendmentCode;                 
                                         UpdateList.add(a);    
                                     }                                                         
                                 }else{
                                     
                                     if(a.RemovalAmendment__c !=AmendmentCode && !a.Override__c) 
                                     {
                                         
                                         a.RemovalAmendment__c =  AmendmentCode;                 
                                             UpdateList.add(a);  
                                     }
                                     
                                     sMailMessageNotUpdated += '<br />'+SubscriptionName + ' | ' + ChargeNumber + ' | ' + AmendmentCode + ' &nbsp; ' + AmendmentName  ;
                                 }
                             }               
                      } 
                    }
                    
                    ///*////
                 
                  break;
                }
                
                  
              }             
            
            if(!bFound)
                     sMailMessageNotUpdated += '<br /><br />*Not Found in provisioning: '+SubscriptionName + ' | ' + ChargeNumber + ' &nbsp; ' + AmendmentCode + '  -  ' + AmendmentName;
                          
               
        }  //for (Zuora.zObject c: zRatePlanCharge)   
        
        if(!bUpdateProvisioning)
        {
                 sMailMessage = '<br /><br />* * * Provisioning set to not update.  No changes were made to Provisioning. * * *<br /><br />' + sMailMessage;
                
        }else{
            try{      
                if (UpdateList.isEmpty() == false) 
                    Database.update(UpdateList); 
                
            }catch (Exception ex) {
            
                     System.debug('Update Exception' + ex);
                     sMailMessage += '<br /><br />Update Exception' + ex;
                     bFailed= true;
            }   
        }        
              
       
    }
    
     if(sMailMessageNotUpdated!='')
        {
            sMailMessageNotUpdated='<br /><br /><br />Subscription charges checked but no change needed:<br />' + sMailMessageNotUpdated;
        }
    
 
 
  }catch (Exception ex) {
            
             System.debug('Exception: ' + ex + '....Line # ' + ex.getLineNumber());
             sMailMessage += '<br /><br />Exception' + ex + '....Line # ' +  ex.getLineNumber();
             bFailed= true;
             
           
    }  
    
    string sMailBody = '<body style="font-family:arial;font-size:10pt">Active Delete Amendments Modified since ' + LastCheck.formatLong() + '<br />' ;
    sMailBody += sMailMessage + sMailMessageNotUpdated;
    sMailBody += '<br /><br /><br /><i>Automated email sent from SFDC Class MetroclientAccountProvisionBatchDelete</i>.';
    sMailBody += '</body>';   
    
     
    System.debug(sMailBody);
    
    SendEmail(sTo, sCC, Subject, sMailBody);
    
    
    /************ LAST *******************    Update date of last check***************/
    if(bFailed==false && bUpdateProvisioning && !Test.isRunningTest())
    {
        mps.DeleteAmmendmentLastCheck__c = NewDate;
        update mps;
        System.Debug('DeleteAmmendmentLastCheck__c updated to:  ' + NewDate);
    }
    
       
}


 private string formatDateString(Date d)
    {
        if(d==null)
            return '[blank]';
        else
            return d.format();       
          
       }
   
   
    private void SendEmail(string sTo, string sCC, string sSubject, string sBody){
      
         try{             
           
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