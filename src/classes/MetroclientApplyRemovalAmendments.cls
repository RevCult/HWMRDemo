global class MetroclientApplyRemovalAmendments implements Schedulable {
 
global void execute(SchedulableContext ctx) { 
     /*  SchedulableContext sc = null;
         MetroclientApplyRemovalAmendments b = new MetroclientApplyRemovalAmendments ();
         b.execute(sc);    */
     

    boolean bFailed=false; 
    boolean bFound=false;
    date AmendmentEffectiveDate;
    string SubscriptionName;
    string ChargeNumber;    
    string AmendmentCode; 
    string whereCharges  = '\'PreventEmpty\'';
    string sMailMessage ='';      
    
     MetrostudyProvisionSettings__c mps = MetrostudyProvisionSettings__c.getOrgDefaults();
        string  sTo=mps.SendEmailTo__c;
        string  sCc=mps.SendEmailCc__c;
        boolean bUpdateProvisioning=mps.UpdateProvisioning__c;
        if (Test.isRunningTest()) 
             bUpdateProvisioning=true;
             
  
    try{    
   
       
            
        List<MetroclientAccountProductGeography__c>  ListUpdateProv = new List<MetroclientAccountProductGeography__c>(); 
        List<MetroclientSubscriptionAmendmentLog__c> ListUpdateLog= new List<MetroclientSubscriptionAmendmentLog__c>();         
        
        /* 
        1) Get everything from MetroclientSubscriptionAmendmentLog__c where ProvisioningUpdated__c = False ; Populate string with charge numbers */    
              
                
        List<MetroclientSubscriptionAmendmentLog__c >  ListLog = [Select Name, SubscriptionName__c, ChargeNumber__c , EffectiveDate__c from MetroclientSubscriptionAmendmentLog__c where
        AmendmentType__c = 'RemoveProduct' and ProvisioningUpdated__c=False ];
          
        System.debug('Get string of charge numbers to narrow down queries and avoid reaching limits');       
           
        for(MetroclientSubscriptionAmendmentLog__c item: ListLog )
        {
             ChargeNumber= item.ChargeNumber__c ;
             if( ChargeNumber!= null && ChargeNumber!='')                     
                     whereCharges  =  whereCharges  +   ',\'' + ChargeNumber + '\'';          
                                  
        }            
        System.debug('whereCharges   = ' + whereCharges  );
                
        
          /*   2) get all account provisioning from those charge numbers ; Compare end date.  Update end date and ammendment field if needed.   */
          
         List<MetroclientAccountProductGeography__c> AccountProvision = Database.query('Select Name, ChargeNumber__c , SubscriptionName__c, EndDate__c , RemovalAmendment__c FROM  MetroclientAccountProductGeography__c Where  Deleted__c=false  and Override__c=false AND ChargeNumber__c in (' + whereCharges  +')');
         Map<string, MetroclientAccountProductGeography__c> mapAccountProvision = new Map<string, MetroclientAccountProductGeography__c>(AccountProvision);        
       
         for(MetroclientSubscriptionAmendmentLog__c item: ListLog )
         {
                ChargeNumber= item.ChargeNumber__c ;
                SubscriptionName = item.SubscriptionName__c;
                AmendmentEffectiveDate = item.EffectiveDate__c ;
                AmendmentCode=  item.Name;
                bFound = false;                
                System.debug('Loop Log:' + item.Name + '....SubscriptionName=' + SubscriptionName  + '...ChargeNumber=' + ChargeNumber);
                
                For(MetroclientAccountProductGeography__c  a: mapAccountProvision.values())
                {                
                   
                    if(a.ChargeNumber__c ==ChargeNumber  && a.SubscriptionName__c==SubscriptionName )
                    {
                          bFound = true;
                          if(a.EndDate__c!=AmendmentEffectiveDate|| a.RemovalAmendment__c != AmendmentCode )
                          {  
                             System.debug(' -Update EndDate__c from ' + a.EndDate__c + ' ....to: ' +  AmendmentEffectiveDate);                   
                             System.debug(' -Update RemovalAmendment__c from ' + a.RemovalAmendment__c  + ' ....to: ' +  AmendmentCode ); 
                             a.EndDate__c=AmendmentEffectiveDate ;  
                             a.RemovalAmendment__c =AmendmentCode;                  
                             ListUpdateProv.add(a);     
                          }else{
                               System.debug('End date already matches removal amendment');
                          }               
                          
                          item.ProvisioningUpdated__c = true;
                          ListUpdateLog.add(item);
                          break;
                    }                   
                
                }  // end loop of Account Provisioning 
                
                if(!bFound )
                    System.debug(' ............................  Provisioning could not be found ');                
                
            
         }   // end loop of Remove Product Amendment Log      
            
        
             
         
           try{      
              if (!ListUpdateProv.isEmpty()) 
                    Database.update(ListUpdateProv); 
               if (!ListUpdateLog.isEmpty()) 
                    Database.update(ListUpdateLog);  
            }catch (Exception ex) {
                 
                 sMailMessage += '<br /><br />' + 'Exception Line#'+ ex.getLineNumber() + ' Details:' + ex;      
                 System.debug('Exception: ' + ex + '....Line # ' + ex.getLineNumber()); 
                 bFailed=true;
            }           
        
        
         if(!bFailed && bUpdateProvisioning)
         {      
              DateTime LastRun =  mps.ApplyRemovalAmendmentsLastRun__c;
              DateTime NewDate = System.now();
              mps.ApplyRemovalAmendmentsLastRun__c= NewDate;  /**  Update date of last run **/
              update mps;
              System.Debug('ApplyRemovalAmendmentsLastRun__c changed from ' + LastRun +  '  to:  ' + NewDate);
         }
            
    }
    catch (Exception ex) {            
         System.debug('Exception: ' + ex + '....Line # ' + ex.getLineNumber()); 
         bFailed= true;  
         sMailMessage += '<br /><br />' + 'Exception Line#'+ ex.getLineNumber() + ' Details:' + ex;      
    }  
           
   
   
    
    if(bFailed)
    {
       SendEmail('**MetroclientApplyRemovalAmendments',sMailMessage, sTo, sCc);
    }
           
}   

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
                System.debug('EMAIL Error -Line#'+ ex.getLineNumber() + '-----' + ex );
         } 
    
   }
    
}