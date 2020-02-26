global class MetroclientAccountProvisionBatchUpdate implements Schedulable {
 
     /*  SchedulableContext sc = null;
         MetroclientAccountProvisionBatchUpdate b = new MetroclientAccountProvisionBatchUpdate();
         b.execute(sc);    */       
    
  
     
    global void execute(SchedulableContext ctx) {
    
         boolean bFailed=false;  
         string sMailMessage='';
         string sMailMessageEnd='';
        string Subscription;
        string SubscriptionName;
        string Account;
        string AccountName;
        string ChargeNumber;
        string ChargeType;
        string Record_Id;
        string status;
        boolean bValid;
        boolean bFound;
        boolean SubscriptionOnly;
        date startDate;
        date endDate; 
        date subStartDate;   
        string queryRid = '\'PreventEmpty\'';
        string queryAcc= '\'PreventEmpty\'';
        string ProdGeoName;
        boolean bHighP = false; 
        boolean bUpdate;
        string lastSub = ''; 
        string sLastCheck;
        string sNewCheck;
        
        integer z = 0;
        Map<String, String> mapRecName = new Map<String ,String>();
        Map<String, boolean> mapRecSubOnly = new Map<String ,boolean>();              
   
        MetrostudyProvisionSettings__c mps = MetrostudyProvisionSettings__c.getOrgDefaults();
        DateTime LastCheck =  mps.SubscriptionUpdateLastCheck__c;
        DateTime NewDate  =  mps.SubscriptionUpdateMaxCheck__c; 
        string  sTo =mps.SendEmailTo__c;
        string  sCc= mps.SendEmailCc__c;
        boolean bUpdateProvisioning=mps.UpdateProvisioning__c;
        System.Debug('bUpdateProvisioning:' + bUpdateProvisioning+ '....sTo :' + sTo );
        if (Test.isRunningTest()) {
            bUpdateProvisioning=true;
        }
      
      try{ 
            if(LastCheck==null)
                LastCheck =System.now().addHours(-24);
            if(NewDate==null || NewDate < LastCheck  )    
                 NewDate = System.now(); 
            if(LastCheck.addHours(25)< NewDate)//don't go over a day
            {
                NewDate = LastCheck.addHours(25);
                sMailMessage+='*** Job looks for records updated during a maximum time period of a 24 hours. Running this job again is needed to get changes that occurred after ' + NewDate  + '.<br /><br />';
                bHighP = true;  
            }
    
            sLastCheck = LastCheck.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000');
            sNewCheck = NewDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000');
            
            System.Debug('LastCheck:' + LastCheck + '....sLastCheck :' + sLastCheck );
           
            string spcQuery = 'select Id, Name, CreatedDate,  LastModifiedDate , Zuora__Type__c, Zuora__Subscription__c, Record_Id__c, Zuora__ChargeNumber__c,';
            spcQuery +=' Zuora__Subscription__r.Zuora__Account__r.Name,Zuora__Subscription__r.Zuora__Account__c ,Zuora__Subscription__r.Zuora__Status__c,Zuora__Subscription__r.Name,';
            spcQuery +=' Zuora__EffectiveEndDate__c, Zuora__EffectiveStartDate__c, Zuora__Subscription__r.Zuora__SubscriptionStartDate__c, Zuora__Subscription__r.Zuora__SubscriptionEndDate__c ';
            spcQuery +=' from Zuora__SubscriptionProductCharge__c where Record_Id__c != null and ((LastModifiedDate >=' +sLastCheck + ' and LastModifiedDate <=' +sNewCheck + ') or (Zuora__Subscription__r.LastModifiedDate >=' + sLastCheck +' and Zuora__Subscription__r.LastModifiedDate <=' + sNewCheck +'))';
            spcQuery +=' order by Zuora__Subscription__r.Zuora__Account__r.Name, Zuora__Subscription__r.Name, Zuora__ChargeNumber__c';     
            System.Debug('spcQuery::::  ' + spcQuery  );
            
            List<MetroclientAccountProductGeography__c> InsertList = new List<MetroclientAccountProductGeography__c>();
            List<MetroclientAccountProductGeography__c> UpdateList = new List<MetroclientAccountProductGeography__c>();  
            List<Zuora__SubscriptionProductCharge__c>  SubProdCharge = Database.query(spcQuery);
           // Map<string, Zuora__SubscriptionProductCharge__c> mapSubProdCharge = new Map<string, Zuora__SubscriptionProductCharge__c>(SubProdCharge);
           
           System.debug('Get string of record ids and string of accounts to narrow down queries and avoid reaching limits');
           for(Zuora__SubscriptionProductCharge__c item: SubProdCharge)
           {
                Record_Id = item.Record_Id__c;
                System.debug('Record_Id=' + Record_Id + '....Account=' + item.Zuora__Subscription__r.Zuora__Account__c  + '...SubscriptionName=' +  item.Zuora__Subscription__r.Name );
                
                if( Record_Id != null && Record_Id !=''){        
                   if(!queryRid .contains('\'' + Record_Id + '\''))
                    {
                        if(queryRid!='')
                            queryRid = queryRid + ',';
                        queryRid =  queryRid +   '\'' + Record_Id + '\'';     
                    }     
                }  
               if(!queryAcc.contains('\'' + item.Zuora__Subscription__r.Name + '\''))  
               {
                    if(queryAcc!='')
                        queryAcc = queryAcc + ',';
                    queryAcc =  queryAcc +   '\'' + item.Zuora__Subscription__r.Name + '\'';  
               }
            }
            
            System.debug('Record_Ids to include: ' + queryRid ); 
            System.debug('Subscriptions to include: ' + queryAcc );
             
            string queryVRI= 'Select Name, ProductGeographyType__r.Name,ProductGeographyType__r.Product__r.SubscriptionOnly__c FROM  MetroclientProductGeography__c where ProductCatalogRecordId__c in (' + queryRid +')';
            string queryAP= 'Select Id,Account__r.Name, Account__c, MetroclientProductGeography__r.Name, Deleted__c, Override__c, SubscriptionName__c,ChargeNumber__c, StartDate__c, EndDate__c,MetroclientProductGeography__c';
            queryAP+=' from MetroclientAccountProductGeography__c where Deleted__c = false and SubscriptionName__c in ('+ queryAcc +')';
            System.debug('queryRecordId::::' + queryVRI);   
            System.debug('queryAccountProv::::'+ queryAP);  
             List<MetroclientProductGeography__c >   ValidRecordIdList = Database.query(queryVRI);
             for(MetroclientProductGeography__c r: ValidRecordIdList)
            {            
                 mapRecName.put(r.Id,r.Name); 
                 mapRecSubOnly.put(r.Id, r.ProductGeographyType__r.Product__r.SubscriptionOnly__c );        
                
            }           
    
           
            List<MetroclientAccountProductGeography__c> AccountProvision =  Database.query(queryAP);             
            //Map<string, MetroclientAccountProductGeography__c> mapAccountProvision = new Map<string, MetroclientAccountProductGeography__c>(AccountProvision);       
            
            for(Zuora__SubscriptionProductCharge__c item: SubProdCharge)
            {
                z+=1;
                System.debug('Start z:' + z);
                bValid = false;
                bFound = false;
                ProdGeoName='';
                SubscriptionOnly = false;
                Record_Id = item.Record_Id__c;
                ChargeType = item.Zuora__Type__c; 
                AccountName = item.Zuora__Subscription__r.Zuora__Account__r.Name;    
                ChargeNumber  =  item.Zuora__ChargeNumber__c;
                SubscriptionName  = item.Zuora__Subscription__r.Name;
                
                
                
                try{ 
                    ProdGeoName = mapRecName.get(Record_Id);
                    SubscriptionOnly = mapRecSubOnly.get(Record_Id);
                    System.debug('--- ProductGeo Name: ' + ProdGeoName + '  . . . . . . . .  SubscriptionOnly=' + SubscriptionOnly);
                    bValid = true;
               }catch(Exception ex) {            
                    System.debug('Exception: ' + ex + '....Line # ' + ex.getLineNumber()); 
                    sMailMessage += '<br /><br />Exception: ' + ex + '....Line # ' + ex.getLineNumber();
                    bValid = false;               
               }
                
               if(ProdGeoName ==null)
               {
                   bValid = false;
                   System.debug('** -- ** __ ** __ Bad Record ID....' + Record_Id + '.......'+AccountName  + ' ' + SubscriptionName   + '-' + ChargeNumber   );
                   sMailMessage += '<br /><br /><strong>Invalid RECORD ID Found</strong> The Subscription Charge had to be skipped.  Please correct.<br />';
                   sMailMessage += AccountName  + ' ' + SubscriptionName   + '-' + ChargeNumber  + ' Invalid Record Id: ' + Record_Id + '<br /><br />';
                   bHighP = true;               
                   
               }
               
                Account = item.Zuora__Subscription__r.Zuora__Account__c ;  
                Subscription = item.Zuora__Subscription__c;
                status = item.Zuora__Subscription__r.Zuora__Status__c;
                startDate = item.Zuora__EffectiveStartDate__c;  // Rate Charge Effective Date
                subStartDate = item.Zuora__Subscription__r.Zuora__SubscriptionStartDate__c;   // Subscription Start Date
                      
                if(status=='Cancelled'|| ChargeType=='OneTime' || ChargeType=='One-Time')
                {
                    endDate =  item.Zuora__Subscription__r.Zuora__SubscriptionEndDate__c;
                    
                }else{    
                    
                    endDate = item.Zuora__EffectiveEndDate__c;                
                }    
                System.debug('----- Account: ' + Account + ' . . SubscriptionName  : ' + SubscriptionName+ ' . . ChargeNumber  : ' + ChargeNumber  + '. . Record_Id: ' + Record_Id);
                System.debug('Name: ' + item.Name );
                System.debug('CreatedDate: ' + item.CreatedDate);System.debug('LastModifiedDate: ' + item.LastModifiedDate);System.debug('ChargeType: ' + ChargeType);
                System.debug('status: ' + status + '..startDate: ' + startDate + '...endDate: ' + endDate);    
                
                bFound = false;    
                For(MetroclientAccountProductGeography__c  a: AccountProvision)
                {
                      if(a.ChargeNumber__c==ChargeNumber  && a.SubscriptionName__c==SubscriptionName )
                      {
                        bFound = true;
                        bUpdate = false;
                        System.debug('Already exists in Account Provisioning: ' + a.ChargeNumber__c);
                        if(a.StartDate__c!=startDate || a.EndDate__c!=endDate || a.Account__c != Account ||  a.MetroclientProductGeography__c !=Record_Id)
                        {
                            System.debug('...................   Update Account Provisioning:  ..................................................................');
                            
                            
                            if(AccountName + SubscriptionName!=lastSub )
                            {
                                  if(lastSub!='')
                                     sMailMessage += '<br /><hr style="color:gray;width:100%;size:1pt;" />';
                                  sMailMessage += '<br /><br /><strong>' + AccountName + '</strong>';                                  
                            }      
                            lastSub =AccountName + SubscriptionName;
                            
                            sMailMessage += '<br /><br />' + SubscriptionName+ ' | ' + ChargeNumber ;
                            sMailMessage += '<br />'  + ProdGeoName +'';
                           
                            if(a.StartDate__c!=startDate && !a.Override__c){
                                    
                                  sMailMessage +=  '<br /><strong>Start Date Changed</strong>&nbsp; &nbsp;Before: ' + formatDateString(a.StartDate__c)+ ' &nbsp; After: ' + formatDateString(startDate);   
                                  if(startDate < a.StartDate__c ||startDate  == subStartDate )
                                  { 
                                       sMailMessage +=  ' &nbsp; <i>Provisioning Start Date was updated</i>';
                                       a.StartDate__c=startDate;
                                       bUpdate =true;
                                    
                                }else{
                                
                                    sMailMessage +=  ' &nbsp; <i>Provisioning date not changed - most likely a price increase</i>';
                                }
                            }
                                    
                            if(a.EndDate__c!=endDate) { 
                                sMailMessage +=  '<br /><strong>End Date Changed</strong>&nbsp; &nbsp; Before: '  + formatDateString(a.EndDate__c) + ' &nbsp;  After: '  + formatDateString(endDate);  
                                if(!a.Override__c) 
                                {            
                                    sMailMessage +=  ' &nbsp; <i>Provisioning End Date was updated</i>';
                                    a.EndDate__c=endDate;
                                    bUpdate =true;
                                }
                                
                                
                            }
                            
                            if( a.Account__c != Account){                        
                              
                                 sMailMessage +=  '<br /><strong>Account Changed</strong>';
                                 if( !a.Override__c)
                                 {
                                     sMailMessage += '<font style="color:red"> ***</font>';
                                     bHighP = true;
                                 }
                                 sMailMessage +=  '  &nbsp; In SFDC: &nbsp;'+ a.Account__r.Name;//  +  ' &nbsp; &nbsp; (Id=' + a.Account__c + ')<br />After: &nbsp; &nbsp; ' + AccountName + ' &nbsp; &nbsp; (Id='+ Account+ ')'; 
                                 //a.Account__c = Account;
                                 
                            }
                            
                            if( a.MetroclientProductGeography__c !=Record_Id ){
                               
                                sMailMessage +=  '<br /><strong>Product Geography Changed</strong>';
                                if( !a.Override__c)
                                {
                                    sMailMessage += '<font style="color:red"> *** </font>';
                                    bHighP = true;  
                                }
                                sMailMessage +=  ' &nbsp; In SFDC: &nbsp;'+ a.MetroclientProductGeography__r.Name;  //  +' &nbsp; &nbsp; (Id=' + a.MetroclientProductGeography__c + ')' + '<br />After:  &nbsp; &nbsp; ' + ProdGeoName + ' &nbsp; &nbsp; (Id=' + Record_Id +')' ; 
                                                                                        
                             } 
                          
                            if( !a.Override__c && bUpdate)
                                UpdateList.add(a);                           
                            
                            if(a.Override__c)
                                 sMailMessage +=  '<br />Override set to TRUE. No update to provisioning was made.';
                                                                
                        } else{
                            sMailMessageEnd += '<br />' + SubscriptionName+ ' | ' + ChargeNumber;
                        }                       
                                  
                        break;             
                      }
                } 
                if(bFound==false &&   bValid == true  && ((ChargeType!='OneTime' && ChargeType!='One-Time')|| SubscriptionOnly==true))
                {                  
                    
                    if(AccountName + SubscriptionName!=lastSub )
                    {
                          if(lastSub!='')
                             sMailMessage += '<hr style="color:gray;width:100%;size:1pt;" />';
                          sMailMessage += '<br /><br /><strong>' + AccountName + '</strong>';                                  
                    }      
                    lastSub =AccountName + SubscriptionName;
                    
                    System.debug('*** *** *** *** *** *** *** *** *** Insert Account Provisioning *** *** *** *** *** *** *** *** ***' + ProdGeoName ); 
                    sMailMessage +='<br /><br />' + SubscriptionName + ' | ' + ChargeNumber  + ' <strong>- New Provisioning</strong>';
                    sMailMessage +='<br />' + ProdGeoName + '<br />Dates: &nbsp; ' + formatDateString(startDate)+ ' - ' + formatDateString(endDate);
                    MetroclientAccountProductGeography__c newRecord = new MetroclientAccountProductGeography__c();
                    newRecord.Name = SubscriptionName + ' | ' + ChargeNumber;
                    newRecord.Account__c = Account;
                    newRecord.StartDate__c = startDate;
                    newRecord.EndDate__c = endDate;
                    newRecord.MetroclientProductGeography__c = Record_Id;
                    newRecord.ChargeNumber__c = ChargeNumber;
                    newRecord.SubscriptionName__c= SubscriptionName;
                    InsertList.add(newRecord);  
                }  
            }
       
        if(sMailMessage =='' && sMailMessageEnd =='')
                sMailMessage = '<br />No modified subscriptions were found.';
                
                        
         if(!bUpdateProvisioning)
         {
             sMailMessage = '<br /><br />* * * Provisioning set to not update.  No changes were made to Provisioning. * * *<br /><br />' + sMailMessage;
            
         }else{
            try{      
               if (InsertList.isEmpty() == false)
                    Database.insert(InsertList);                
            }catch (Exception ex) {
               
                 System.debug('Insert Exception' + ex);
                 sMailMessage += '<br /><br />' + 'Insert Exception' + ex;
                 bFailed=true;
            
            }
            
            try{      
              if (UpdateList.isEmpty() == false) 
                    Database.update(UpdateList); 
                
            }catch (Exception ex) {
                 
                  System.debug('Update Exception' + ex);
                  sMailMessage += '<br /><br />' + 'Update Exception' + ex;
                     bFailed=true;
            }           
       }   
        
    }catch (Exception ex) {         
         System.debug('Exception Line#'+ ex.getLineNumber() + ' Details:' + ex);
         sMailMessage += '<br /><br />' + 'Exception Line#'+ ex.getLineNumber() + ' Details:' + ex;
         bFailed=true;
    }
    
    sMailMessage += '<br /><hr style="color:gray;width:100%;size:1pt;" />';
    string Subject = 'Results: SubscriptionUpdateLastCheck';
    if(bHighP==true)
     {
         Subject = '***' + Subject;         
         sMailMessage+='<br /><br /><font style="color:red">*** When a subscription account or product geography is changed, provisioning is not automatically updated.';
         sMailMessage+=' Please manually update provisioning where needed.</font></br>';
     }
     
     
      sMailMessage='Account Provisioning Changes between ' + LastCheck.formatLong() + ' and '+NewDate.formatLong()  + '<br />' + sMailMessage;
      
      
      if(sMailMessageEnd!='')
            sMailMessageEnd='<br /><br />Subscriptions modified but provisioning not changed:' + sMailMessageEnd;
            
    sMailMessageEnd +='<br /><br /><br /><i>Automated email sent from SFDC Class MetroclientAccountProvisionBatchUpdate</i>.';
           
    sMailMessage=sMailMessage+ sMailMessageEnd;
         
    SendEmail(Subject,sMailMessage, sTo, sCc);
        
    if(bFailed==false && bUpdateProvisioning && !Test.isRunningTest())
    {
            mps.SubscriptionUpdateLastCheck__c = NewDate ;
            update mps;
            System.Debug('SubscriptionUpdateLastCheck__c updated to:  ' + NewDate );
     }
     
   }

    private string formatDateString(Date d)
    {
        if(d==null)
            return '[blank]';
        else
            return d.format();       }

   


    private void SendEmail(string sSubject, string sBody, string sTo, string sCc){
      
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
                System.debug('EMAIL Error -Line#'+ ex.getLineNumber() + '-----' + ex  );
                 System.debug('email message: ' + sBody);
         } 
    
   }
}