public class MetroclientAccountProvisioningUpdate{
    
/* called when a quote's status changes to SENT TO Z-BILLING
string Subscription='2c92c0f946d184c30146de3943ea4b3e';
string Account = '0018000000rVSgfAAG';
string SubType = 'New Subscription';
string SubName = 'New Subscription';
string ExistSubId = null;
string QuoteId = null;
*/

    @future(callout=true)
    public static void UpdateAccountProvisioningFromZuora(string Subscription, string SubName, string ExistSubId, string SubType, ID QuoteId, string Account){
       
   
    
    
    System.debug('Passed into UpdateAccountProvisioningFromZuora:');
    System.debug('Subscription=' + Subscription + ', SubName=' + SubName + ', ExistSubId=' + ExistSubId );
    System.debug('SubType=' + SubType + ', QuoteId=' + QuoteId + ', Account=' + Account );
    
    string SubscriptionName;
    string PreviousSubscriptionId;
    string queryAmendment='';
    dateTime CancelledDateDt;
    dateTime SubscriptionEndDateDt;
    dateTime AmendmentEffectiveDateDt;

    if(SubType == 'New Subscription')
    {
        Subscription = Subscription;
        List<Zuora.zObject> Sub3 = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name, SubscriptionEndDate from Subscription Where id = \'' + Subscription + '\' ');
        SubscriptionName= (String)Sub3[0].getValue('Name');
         SubscriptionEndDateDt = (dateTime)Sub3[0].getValue('SubscriptionEndDate'); 
    }
    if(SubType == 'Cancel Subscription')
    {
        List<Zuora.zObject> Sub1 = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name,CancelledDate from Subscription Where id = \'' + ExistSubId + '\' ');
        String Name = (String)Sub1[0].getValue('Name');        
        System.debug('Name: ' + Name);
    
        List<Zuora.zObject> Sub2 = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name, CancelledDate, SubscriptionEndDate from Subscription Where Name = \'' + Name + '\' AND status = \'Cancelled\'');
    
        String Sub1Id = (String)Sub2[0].getValue('Id');
        SubscriptionName= (String)Sub2[0].getValue('Name');  
        CancelledDateDt = (dateTime)Sub2[0].getValue('CancelledDate');   
        SubscriptionEndDateDt = (dateTime)Sub2[0].getValue('SubscriptionEndDate');      
        Subscription = Sub1Id;
    }
    if(SubType == 'Renew Subscription' || SubType == 'Amend Subscription')
    {
       List<Zuora.zObject> Sub = ZuoraAPIUtil.zQueryZuora('Subscription','Select Id, Name, PreviousSubscriptionId,SubscriptionEndDate  from Subscription Where Name = \'' + SubName + '\' AND status = \'Active\'');
    
       SubscriptionName= (String)Sub[0].getValue('Name'); 
       String Sub2Id = (String)Sub[0].getValue('Id');              
       Subscription = Sub2Id;
       PreviousSubscriptionId=(String)Sub[0].getValue('PreviousSubscriptionId'); 
       SubscriptionEndDateDt = (dateTime)Sub[0].getValue('SubscriptionEndDate'); 
       System.debug('PreviousSubscriptionId: ' + PreviousSubscriptionId);  
       
       List<Zuora.zObject> zAmm= ZuoraAPIUtil.zQueryZuora('Amendment','select Id, SubscriptionId, Name, Type,EffectiveDate from Amendment WHERE Type=\'RemoveProduct\'  and SubscriptionId = \''+ PreviousSubscriptionId + '\'  ');
       
       for (Zuora.zObject Amm: zAmm)    
       { 
           AmendmentEffectiveDateDt=(dateTime)Amm.getValue('EffectiveDate');
           System.debug('........................Amendment..Name ' + (string)Amm.getValue('Name') + '....Amendment ' + (string)Amm.getValue('Id') );
           System.debug('EffectiveDate ' + AmendmentEffectiveDateDt );
           System.debug('SubscriptionId ' + (string)Amm.getValue('SubscriptionId') );       
           queryAmendment = queryAmendment + ' OR amendmentid = \'' + (string)Amm.getValue('Id') + '\' and AmendmentType!=null ' ;          
       } 
       
       System.debug('AmendmentEffectiveDateDt ' + AmendmentEffectiveDateDt );
    }  
     
  
        
    dateTime startDateDt;
    dateTime endDateDt;    
    date startDate;
    date endDate;    
    string productGeography;
    string Record_Id;
    string ChargeNumber;
    string ChargeType;
    boolean bFound;
    string queryRatePlanChargeWhere = '';
    List<String> myCharges = new List<String>(); 
    String[] listofids= new List<String>();
    string queryRid = '\'PreventEmpty\'';
    string productRatePlanId;
    string RatePlanId;
    string AmendmentType;
    boolean bValid = false;
    boolean SubscriptionOnly = false;
    System.debug('Begin: ' + SubscriptionName + '--- Subscription: ' + Subscription + ' ---Account: ' + Account);
    
    try {   
        List<MetroclientAccountProductGeography__c> InsertList = new List<MetroclientAccountProductGeography__c>();
        List<MetroclientAccountProductGeography__c> UpdateList = new List<MetroclientAccountProductGeography__c>();  
        List<MetroclientAccountProductGeography__c> DeleteList = new List<MetroclientAccountProductGeography__c>();    
        
       List<MetroclientAccountProductGeography__c> AccountProvision = [SELECT Id, Account__c,  Deleted__c,Override__c,
             StartDate__c, EndDate__c ,MetroclientProductGeography__c , ChargeNumber__c , SubscriptionName__c FROM  MetroclientAccountProductGeography__c  WHERE    
             Deleted__c = false  AND  Account__c = :Account AND    SubscriptionName__c= :SubscriptionName ];   
       Map<string, MetroclientAccountProductGeography__c> mapAccountProvision = new Map<string, MetroclientAccountProductGeography__c>(AccountProvision);        
      
        
       string queryRatePlan = 'select Id, SubscriptionId, Name, AmendmentType from RatePlan WHERE SubscriptionId = \'' + Subscription + '\'' + queryAmendment ;
        
       List<Zuora.zObject> zRatePlan= ZuoraAPIUtil.zQueryZuora('RatePlan',queryRatePlan);
       System.debug('Pull rate plans: ' + queryRatePlan);
       for (Zuora.zObject o: zRatePlan)    
       { 
           RatePlanId = (string)o.getValue('Id') ;
           if((string)o.getValue('AmendmentType')=='RemoveProduct' || (string)o.getValue('SubscriptionId') == Subscription)
             {
                  System.debug('RatePlanId ' + RatePlanId );  
                   if(queryRatePlanChargeWhere!='')
                       queryRatePlanChargeWhere =  queryRatePlanChargeWhere + ' OR ';
                queryRatePlanChargeWhere = queryRatePlanChargeWhere + ' RatePlanId = \'' + RatePlanId+ '\'' ;
              }
        }
        
        string queryRatePlanCharge = 'select Id,Name,EffectiveStartDate,EffectiveEndDate,ChargeNumber,Record_Id__c,ChargeType,RatePlanId  from RatePlanCharge Where ' + queryRatePlanChargeWhere;
        System.debug('Pull rate plan charges: ' +queryRatePlanCharge);
        List<Zuora.zObject> zRatePlanCharge  = ZuoraAPIUtil.zQueryZuora('RatePlanCharge',queryRatePlanCharge );
        
           for (Zuora.zObject x: zRatePlanCharge)    
            {
                Record_Id  = (string)x.getValue('Record_Id__c'); 
                System.debug('Record_Id ' + Record_Id );
                if( Record_Id != null && Record_Id !='')
                 {
                     if(queryRid!='')
                         queryRid = queryRid + ',';
                     queryRid =  queryRid +   '\'' + Record_Id + '\'';          
                 }
                
            }
            System.debug('Included Record_Ids ' + queryRid ); 
            System.debug('queryRecordId::::  Select Name, ProductGeographyType__r.Name,ProductGeographyType__r.Product__r.SubscriptionOnly__c FROM  MetroclientProductGeography__c WHERE ProductCatalogRecordId__c in (' + queryRid +')'); 
            List<MetroclientProductGeography__c >   ValidRecordIdList = Database.query('Select Name, ProductGeographyType__r.Name,ProductGeographyType__r.Product__r.SubscriptionOnly__c FROM  MetroclientProductGeography__c WHERE ProductCatalogRecordId__c in (' + queryRid +')');
             
     
            Record_Id = null;
            ChargeNumber = '';
            for (Zuora.zObject x: zRatePlanCharge)    
            {    
                bValid = false;
                SubscriptionOnly = false;
                AmendmentType='';
                startDate = null;
                endDate = null;
                Record_Id  = (string)x.getValue('Record_Id__c');
                ChargeType = (string)x.getValue('ChargeType'); 
                ChargeNumber= (string)x.getValue('ChargeNumber');
                for(MetroclientProductGeography__c r: ValidRecordIdList)
                 {
                    if(Record_Id ==r.Id)
                    {
                        SubscriptionOnly = r.ProductGeographyType__r.Product__r.SubscriptionOnly__c;
                        bValid = true;
                        break;                        
                    }
                  }
                 
                 If(bValid == true  && (ChargeType!='OneTime'|| SubscriptionOnly==true))
                 {  
                                           
                     
                      for (Zuora.zObject r: zRatePlan)    
                      { 
                           if((string)r.getValue('Id')==(string)x.getValue('RatePlanId')) 
                           {
                               AmendmentType=(string)r.getValue('AmendmentType');
                               break;
                           }                         
                          
                        }
                     
                     myCharges.add(ChargeNumber+ '---' + Record_Id  );
                     startDateDt = (dateTime)x.getValue('EffectiveStartDate');
                    
                      if (startDateDt!=null)
                            startDate = startDateDt.Date();
        
                      if(CancelledDateDt!=null && SubType == 'Cancel Subscription')
                            endDateDt= CancelledDateDt; 
                      
                      else if(ChargeType=='OneTime' && AmendmentType=='RemoveProduct')
                             endDateDt= AmendmentEffectiveDateDt;
                             
                      else if(ChargeType=='OneTime')
                             endDateDt= SubscriptionEndDateDt;
                      else 
                            endDateDt = (dateTime)x.getValue('EffectiveEndDate'); 
                      
                       
                       if (endDateDt!=null)
                               endDate = endDateDt.Date();
                               
                               
                               
                     System.debug('ChargeType:' + ChargeType + '......ChargeNumber: ' + ChargeNumber+ '---date range: ' + startDate + ' - ' + endDate );
                     System.debug('Record_Id : ' + Record_Id + '    ...... AmendmentType' + AmendmentType );
                                                         
                                   
                        bFound = false;  
                        For(MetroclientAccountProductGeography__c  a: mapAccountProvision.values())
                        {
                            if(a.ChargeNumber__c ==ChargeNumber  && a.MetroclientProductGeography__c ==Record_Id  && a.Account__c == Account  && a.SubscriptionName__c==SubscriptionName )
                            {
                              bFound = true;
                              if(a.Override__c!=True)
                              {  
                                 System.debug('Already exists in Account Provisioning');
                                 a.StartDate__c=startDate;
                                 a.EndDate__c=endDate;                    
                                 UpdateList.add(a);     
                              }
                              break;
                            }                   
                        
                        }            
                              
                         if(bFound==false)
                         {                  
                                System.debug('Insert Account Provisioning'); 
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
                }else{
                    System.debug('---Did not Provision....bValid='+bValid +' ChargeType='+ChargeType +' SubscriptionOnly='+SubscriptionOnly ); 
               
                }
            
         }
         
        try
        {      
            if (InsertList.isEmpty() == false) {
                Database.insert(InsertList);} // insert AccountProvision;
                
         }catch (Exception ex) {
            System.debug('Insert Exception' + ex);
         }
        
        
        try {
          if (UpdateList.isEmpty() == false) {
              Database.update(UpdateList);
            }
             
        } catch (DmlException e) {
            System.debug('Update DmlException' + e);
        } catch (Exception e) {
            System.debug('Update Exception' + e);
        }       
                
         
       //Delete: Update the "Delete" checkbox " 
      /* List<MetroclientAccountProductGeography__c> DeleteList = [SELECT Id, Account__c,RatePlanId__c ,
             SubscriptionId__c, Deleted__c FROM  MetroclientAccountProductGeography__c  WHERE    
             Deleted__c = false AND SubscriptionId__c =   :Subscription  AND RatePlanId__c Not in :listofids ];
          
        for (MetroclientAccountProductGeography__c o: DeleteList)   
        {           
          o.Deleted__c = true;             
        }*/
        
        
         For(MetroclientAccountProductGeography__c  d: mapAccountProvision.values())
         {
               bFound=false;   
               System.debug('Loop Products' + d.ChargeNumber__c + '---' +d.MetroclientProductGeography__c);                 
                    
               for (String x: myCharges )    
               {
                    if (d.ChargeNumber__c + '---' + d.MetroclientProductGeography__c == x)
                    {
                       bFound=true;
                       System.debug('Found Match!!!'); 
                       break;
                    }
                           
                 }
                 
                if(bFound==false && d.Override__c==false)
                {
                    System.debug('No - Match - delete'); 
                    d.Deleted__c = true; 
                    DeleteList.add(d);     
                }        
        
         }                   
        
        
        try {
            update DeleteList;
        } catch (DmlException e) {
            System.debug('DeleteList DmlException:' + e);
        } catch (Exception e) {
            System.debug('DeleteList Exception:' + e);
        }
        
    }catch (Zuora.zRemoteException ex) {        
        System.debug('zRemoteException:'+ex.code+ '----' + ex.getMessage());
    }catch (Zuora.zAPIException  ex) {
          System.debug('zAPIException:'+ex.getMessage());
    }catch (Zuora.zForceException ex) {
          System.debug('zForceException:'+ex.code+ '----' + ex.getMessage());
    }catch (Exception ex) {
          System.debug('Exception-Line#'+ ex.getLineNumber() + '-----' + ex );
    }

    System.debug('end' );
  
  
  
  
    
        
      
    }       
    
   
  }