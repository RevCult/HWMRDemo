/**
*********************************************************************************************************************
* Module Name   : UpdateOpportunityTeam
* Description     
* Throws        : <Any Exceptions/messages thrown by this class/triggers>
* Calls         : <Any classes/utilities called by this class | None if it does not call>
* Test Class    :  
*                      HANLEYNetwork
* Organization  : Rainmaker Associates LLC
* 
* Revision History:-
* Version  Date           Author           WO#         Description of Action
* 1.0      04/24/2014     Milligan          1649            Initial Version
* Select o.UserOrGroupId, o.RowCause, o.OpportunityId, o.OpportunityAccessLevel, o.LastModifiedDate, o.Id From OpportunityShare o  where o.OpportunityId= '006S0000007NUyRIAW'
*   Select o.id,  o.UserId, o.TeamMemberRole, o.OpportunityId, o.OpportunityAccessLevel, o.LastModifiedDate From OpportunityTeamMember o where opportunityID = '006S0000007NUyRIAW'
*******************************************************************************************************************
**/
trigger UpdateOpportunityTeam on OpportunityLineItem (before insert, before update) {
    
    Set<Id> oppIds = new Set<Id>();
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    
    Set<Id> priceIds = new Set<Id>();
    List<PricebookEntry> priceList = new List<PricebookEntry>();
    
    Map<Id, PricebookEntry> priceMap = new Map<Id, PricebookEntry>();
    
    List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
    
    // Frontera 2/23/2018 - Not needed since user query results are being cached.
    // List<User> marketingUserList = new List<User>();
    // List<User> metroUserList = new List<User>();
    
    User marketUser = new User();
    User metroUser = new User();
    
    List<OpportunityShare> osList = new List<OpportunityShare>();
    
    for(OpportunityLineItem oli: Trigger.new){
        
        oppIds.add(oli.OpportunityId);
        priceIds.add(oli.PricebookEntryId);
        
    }

    // Frontera 2/23/2018 - Not needed since user query results are being cached.
    // String marketUserName = '';
    // marketUserName =  System.Label.MarketingUserForOTM;
    //
    // String metroUserName = '';
    // metroUserName =  System.Label.MetroUserForOTM;
    //
    //
    // marketingUserList = [SELECT Name, IsActive, Id, Email, Department FROM User u WHERE Name =: marketUserName];
    // metroUserList = [SELECT Name, IsActive, Id, Email, Department FROM User u WHERE Name =: metroUserName];
    //
    // if(!marketingUserList.IsEmpty()){
    //     marketUser = marketingUserList.get(0);      
    // }
    //    
    // if(!metroUserList.IsEmpty()){
    //     metroUser = metroUserList.get(0);       
    // }   

    // Frontera 2/23/2018 - Caching user query results.
    Map<String, User> marketAndMetroUserMap = FC_UserCache.findByNames(new Set<String> { System.Label.MarketingUserForOTM, System.Label.MetroUserForOTM });
    if (marketAndMetroUserMap.containsKey(System.Label.MarketingUserForOTM)) {
        marketUser = marketAndMetroUserMap.get(System.Label.MarketingUserForOTM);
    }
    if (marketAndMetroUserMap.containsKey(System.Label.MetroUserForOTM)) {
        metroUser = marketAndMetroUserMap.get(System.Label.MetroUserForOTM);
    }
    
    // Frontera 3/7/2018 - Optimize this map creation.
    //oppMap = new Map<Id, Opportunity>([SELECT id, RecordTypeId, RecordType.Name FROM Opportunity WHERE  RecordTypeId = '01280000000BiIi' and id IN: oppIds]);
    Map<Id, Opportunity> opportunityLookupMap = FC_OpportunityCache.findByIds(oppIds);
    for (Opportunity opportunityRecord : opportunityLookupMap.values()) {
        if (opportunityRecord.RecordType.DeveloperName == 'Network_Opportunity') {
            oppMap.put(opportunityRecord.Id, opportunityRecord);
        }
    }
    
    if(!oppMap.IsEmpty()){
        
        System.debug('## Number of Opportunity in map with correct Record ID --> ' + oppMap.size());
        
        priceMap = new Map<Id, PricebookEntry>([SELECT id, Product2.MetroStudy_Product__c, Product2.Marketing_Product__c, Product2Id FROM PricebookEntry WHERE id IN: priceIds]);   

        for(OpportunityLineItem oli: Trigger.new){
            
            if(oppMap.containsKey(oli.OpportunityId)){
                
                System.debug('@@  Found Opportunity In Map --> ' + oli.OpportunityId);
                
                
                if(priceMap.containsKey(oli.PricebookEntryId)){
                    
                    PricebookEntry p =  priceMap.get(oli.PricebookEntryId);
                    System.debug('@@  Found PricebookEntry In Map MetroStudy --> ' + p.Product2.MetroStudy_Product__c + ' Marketing --> ' + p.Product2.Marketing_Product__c);
                    
                    if(marketUser.id <> null){
                    //Select o.UserId, o.TeamMemberRole, o.OpportunityId, o.OpportunityAccessLevel From OpportunityTeamMember o
                        if(p.Product2.Marketing_Product__c){
                            OpportunityTeamMember tm = new OpportunityTeamMember();
                            tm.OpportunityId = oli.OpportunityId;
                            tm.UserId = marketUser.Id;
                            tm.TeamMemberRole = 'Network Liaison Marketing';
                            otm.add(tm);
                            
        
                        
                        }
                    } else {
                        System.debug('%%%  Marketing User for OTM - Not Found *** Check Custom Label *** --> ');
                        
                    }
                
                    if(metroUser.id <> null){
                    
                        if(p.Product2.MetroStudy_Product__c){
                        
                            OpportunityTeamMember tm = new OpportunityTeamMember();
                            tm.OpportunityId = oli.OpportunityId;
                            tm.UserId = metroUser.Id;
                            tm.TeamMemberRole = 'Network Liaison MetroStudy';   
                            
                            otm.add(tm);                    
                        }                   
                    } else{
                        System.debug('%%%  Metro User for OTM - Not Found *** Check Custom Label *** --> ');
                        
                    }   
                
                }
            }
        
 
        }       
        
    } else {
        System.debug('@@ No Opportunity in map with correct Record ID!!!');
    }
    
    
    if(!otm.IsEmpty()){
        
            try{
                System.debug(LoggingLevel.INFO,'--> ***** Saving new OpportunityTeamMember');
                        
                Integer i = 0;  
                Database.SaveResult[] lsr = Database.insert(otm, false);
                for(Database.SaveResult sr:lsr){
                    if(!sr.isSuccess()){
                        Database.Error err = sr.getErrors()[0];
                        System.debug(LoggingLevel.INFO,'-->***** Insert OpportunityTeamMember Error: ' + err.getMessage());
                        
                    }else{
                         System.debug('--> ***** New OpportunityTeamMember Id: ' + otm.get(i).Id);
                    }
                    
                         i += 1;
                  }
               }catch(Exception ex){
                    System.debug('-->***** Insert OpportunityTeamMember process error: ' + ex.getMessage());
               }

        
        Set <Id> otmIds = new Set<Id>();
        Map<id, List<OpportunityShare>> osMap = new Map<id, List<OpportunityShare>>();
        
        for(OpportunityTeamMember ot: otm){
            
            if(ot.id <> null){
                
                //Could also create the OppShare rec but seem bet to update OppShar SF creates automatically
                //SF will not create a new OPPShar if one already exists
                // uncomment if you choose to add
                
                //OpportunityShare s = new OpportunityShare();
                //s.OpportunityAccessLevel = 'Edit';
                //s.OpportunityId   = ot.OpportunityId;
                //s.RowCause = 'Team';
                //s.UserOrGroupId = ot.UserId;
                //osList.add(s);    
                
                otmIds.add(ot.OpportunityId);               
                
            }
        }
        
        if(!otmIds.IsEmpty()){
            
            osList = [SELECT UserOrGroupId, OpportunityId, OpportunityAccessLevel From OpportunityShare WHERE RowCause = 'Team' AND OpportunityId IN: otmIds];
            
            if(!osList.IsEmpty()){
                
                for(OpportunityShare os: osList){
                
                    if(osMap.containsKey(os.UserOrGroupId)){
                        List<OpportunityShare>  crList = osMap.get(os.UserOrGroupId);                   
                        crList.add(os);
                        osMap.remove(os.UserOrGroupId);
                        osMap.put(os.UserOrGroupId, crList);
                    } else{
                        List<OpportunityShare> crList = new List<OpportunityShare>();                   
                        crList.add(os);
                        osMap.put(os.UserOrGroupId, crList);                    
                    }           
                }  //for
                
                osList.clear();
                
                for(OpportunityTeamMember ot: otm){
                    
                    if(osMap.containsKey(ot.UserId)){
                        List<OpportunityShare>  oList = osMap.get(ot.UserId);
                        OpportunityShare s = oList.get(0);
                        s.OpportunityAccessLevel = 'Edit';  
                        osList.add(s);
                    }
                }
            }//!osList.IsEmpty()                
                
        } //!otmIds.IsEmpty()
        
            if(!osList.IsEmpty()){
        
            try{
                System.debug(LoggingLevel.INFO,'--> ***** Saving  OpportunityShare');
                        
                Integer i = 0;  
                Database.SaveResult[] lsr = Database.update(osList, false);
                
                for(Database.SaveResult sr:lsr){
                    if(!sr.isSuccess()){
                        Database.Error err = sr.getErrors()[0];
                        System.debug(LoggingLevel.INFO,'-->***** Update OpportunityShare Error: ' + err.getMessage());
                        
                    }else{
                         System.debug('--> ***** OpportunityShare Id: ' + osList.get(i).Id);
                    }
                    
                         i += 1;
                  }
               }catch(Exception ex){
                    System.debug('-->***** Update OpportunityShare process error: ' + ex.getMessage());
               }        
            }
        
    }
}