public class GaugeChartControllerQTD_User {
    public String ExecId {get;set;}
    public String UserId {get;set;}
    public String UserName {get;set;}
    public String dashboardId {get;set;}
    public String dateRange {get;set;}
    
    public List<SelectOption> UserOptions { get;set; }
    
    public Integer minVal = 0;
    public Integer maxVal = 1000;   // real value calculated in code
    
    public Double salesVal = 0;
    public Double percentVal = 0;
    
    public Object objQuota;
    public Object UserResult;
    public Object objOpportunityRollupClosed;
    public Dashboard dashboardResults;
    public Dashboard runAs;
    
    public GaugeChartControllerQTD_User(){
        getData();
        }
        
    public void getData() {
       dashboardId = '01Z34000001CFZm';
         
       Map<String, String> family = new Map<String, String>{'INFO' => 'Direct', 'BPMS' => 'BPM', 'CONS' => 'Consultant'};
       
       Integer thisMonth = date.Today().month();
       Integer thisYear = date.Today().Year();
       
       Date qryEndDate = date.newinstance(thisYear, 12, 31);
       Date qryBegDate = date.newinstance(thisYear, 1, 1);
       
      if(thisMonth <= 3){
        qryEndDate = date.newinstance(thisYear, 3, 31);
        qryBegDate = date.newinstance(thisYear, 1, 1);
       }
      else if(thisMonth <= 6){
        qryEndDate = date.newinstance(thisYear, 6, 30);
        qryBegDate = date.newinstance(thisYear, 4, 1);
            }
      else if(thisMonth <= 9){
        qryEndDate = date.newinstance(thisYear, 9, 30);
        qryBegDate = date.newinstance(thisYear, 7, 1);
            }
      else if(thisMonth <= 12){
        qryEndDate = date.newinstance(thisYear, 12, 31);
        qryBegDate = date.newinstance(thisYear, 10, 1);
            }
            
       
       ExecId = (ExecId == null) ? 'All' : ExecId;    // default to 'All'
       
       Dashboard[] dashboardResults = [
               SELECT Id, runningUser.id, runningUser.name 
               FROM Dashboard 
               WHERE id = :dashboardId
               ];
       
       UserId = (dashboardResults == null || dashboardResults.size() == 0) ? UserInfo.getUserId() : dashboardResults[0].runningUser.id;    // default to current user (need to have a valid user ID)
       UserName = (dashboardResults == null || dashboardResults.size() == 0) ? UserInfo.getUserName() : dashboardResults[0].runningUser.name;
       
       //overwrite them for the logged in user
       //UserId = UserInfo.getUserId();    // default to current user (need to have a valid user ID)
       //UserName = UserInfo.getUserName();
       
       ///////////////////////////////////////////////////////////////
       //Grab the opty totals or actuals
       if(ExecId.containsIgnoreCase('All')) {   // all was implicitly selected
            //Act Values
            AggregateResult[] groupedResults = [Select SUM(Opportunity.FC_DBD_Revenue__c) TotalPrice
            FROM Opportunity WHERE Id IN (SELECT opportunityId
            FROM OpportunityLineItem 
           WHERE 
            Opportunity.One_time_Sale_Type__c != ''
            AND Opportunity.Amount != 0
            AND Opportunity.StageName NOT IN ('Renewal','Price Increase')
            AND Opportunity.Purchase_Type__c != 'Price Increase Only'
            AND (Opportunity.Renewal__c = False
            OR  (Opportunity.Renewal__c = True
            AND FC_Pay_DBD__c = True))
            AND Opportunity.One_time_Sale_Type__c NOT IN ('Consulting/Engagement','Land Planning Optimization') 
            AND (FC_New_Revenue__c != 0
            OR (FC_Pay_DBD__c = True
            AND FC_New_Revenue__c = 0))
            AND Opportunity.Purchase_Type__c != 'Restructure'
            
            AND ((Opportunity.Probability = 100
            AND Opportunity.RecordType.Name NOT IN ('Metrostudy Renewal Oppty Record Type'))
            
            OR (Opportunity.Probability IN (0,100)
            AND Opportunity.RecordType.Name IN ('Metrostudy Renewal Oppty Record Type')))
            
            AND Opportunity.MS_Territory_Owner__c = :UserId
            AND Opportunity.CloseDate >= :qryBegDate
            AND Opportunity.CloseDate <= :qryEndDate
            )            
            
            ];       
            objOpportunityRollupClosed = groupedResults[0].get('TotalPrice');
            
            //Max Values
            AggregateResult[] quotaResults = [
            SELECT SUM(QuotaAmount) Quota 
            FROM ForecastingQuota 
            WHERE QuotaOwnerId = :UserId 
            AND StartDate >= :qryBegDate 
            AND StartDate <= :qryEndDate
            AND (ProductFamily = :family.get('INFO')
            OR ProductFamily = :family.get('BPM')
            OR ProductFamily = :family.get('Consultant'))
            
            ];
            objQuota = quotaResults[0].get('Quota');
            maxVal = Integer.valueOf(objQuota);      
            
            }
       else {   // A Dept Was Selected
            AggregateResult[] groupedResults = [Select SUM(FC_DBD_Revenue__c)  TotalPrice
            FROM OpportunityLineItem 
            WHERE 
            Opportunity.Amount != 0
            AND Opportunity.StageName IN ('Active','Closed Won','Rev Reversal')
            AND Opportunity.Channel_Type__c != ''
            AND Opportunity.RecordType.Name IN ('MS Opportunity', 'Metrostudy Opportunity Record Type Admin',
                'Metrostudy Opportunity Record Type Consult','MS - Opportunity BPM','Metrostudy Opportunity - REE',
                'Media - Network')
            
            AND (NOT Opportunity.Purchase_Type__c LIKE '%Price Increase Only%')
            AND Opportunity.MS_Territory_Owner__c = :UserId
            AND FC_Seg3__c = :ExecId

            AND Opportunity.CloseDate >= :qryBegDate 
            AND Opportunity.CloseDate <= :qryEndDate 
            
            //Added 5/9/18 per Howard
            AND (FC_New_Revenue_Formula__c != 0
            OR (FC_New_Revenue_Formula__c = 0
            AND FC_Pay_DBD__c = True))
            //End 5/9/18
            
            AND FC_Purchase_Type__c != 'Restructure'
            AND (Opportunity.Renewal__c = False
            OR  (Opportunity.Renewal__c = True
            AND FC_Pay_DBD__c = True))
            
            ];       
            objOpportunityRollupClosed = groupedResults[0].get('TotalPrice');
            
            String f = family.get(ExecId);

            //Max Values
            AggregateResult[] quotaResults = [
            SELECT SUM(QuotaAmount) Quota 
            FROM ForecastingQuota 
            WHERE QuotaOwnerId = :UserId 
            AND StartDate >= :qryBegDate 
            AND StartDate <= :qryEndDate
            AND ProductFamily = :f
            
            ];
            objQuota = quotaResults[0].get('Quota');
            maxVal = Integer.valueOf(objQuota);      
            
            }
            
            
       salesVal = Integer.valueOf(objOpportunityRollupClosed);    
       salesVal = (salesVal  == null) ? 0 : salesVal ;   
       
       maxVal = (maxVal  == null) ? 0 : maxVal ;   
       
       If(maxVal != 0)
       {
           percentVal = Double.valueOf((salesVal / maxVal) * 100 ).round();
           //percentVal = maxVal;
       }else
       {
           percentVal = 0;
       }
       
    }
    
    
    public void setExecId(String sExecId) {
        ExecId = sExecId;        
        }    

    public Double getSalesVal() {
        return salesVal;
        }
        
    public Integer getMaxValue() {
        return maxVal;
        }
    public Double getPercentVal() {
        return percentVal;
        }


    public void autoRun()
    {          
        UserOptions = new list<SelectOption>();
            
        
        for (User u : [
            SELECT ID,name 
            FROM user 
            WHERE (Username LIKE '%metrostudy%' 
            OR Email LIKE '%metrostudy%')
            AND Profile.Name LIKE '%sales%' 
            AND IsActive = True
            AND Title NOT IN ('Regional Director','Director of Published Research')
            AND MetrostudyIncludeOnWebsite__c = True
            AND (NOT Profile.Name LIKE '%consulting%')
            AND (NOT Profile.Name LIKE '%bpm%')
            AND (NOT Profile.Name LIKE '%management%')
           
            ])
        {
            UserOptions.add(new SelectOption(u.ID,u.Name ) );
        }
    }
    
    public void checkValue()
    {
        System.debug('----------------'+UserId);
    }

 
}