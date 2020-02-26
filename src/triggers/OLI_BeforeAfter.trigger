/*********************************************************************************************************************
** Module Name   : OLI_BeforeAfter
** Description   : Update Product Type
** Throws        : None
** Calls         : None
** Test Class    : <Name of the test class that is used test this class>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author      WO#         Description of Action
** 1.0      9/11/2013    RMA-KL    XxXX            Initial Version
*******************************************************************************************************************/
trigger OLI_BeforeAfter on OpportunityLineItem (before insert,before update) {

    List<String> dsmProductIDList = new List<String>();
    
        for (OpportunityLineItem oli : Trigger.new) {
            dsmProductIDList.add(oli.HW_DC_DSM_Product_ID__c);
        }
   
            
        List<DSM_Products__c> PList =  [select id, SOW_Term__c, WF_Template_ID__c, Product_ID__c, Product_Type__c from DSM_Products__c 
                                        where Product_ID__c in :dsmProductIDList];
        Map<String,DSM_Products__c> productTypeMap = new Map<String,DSM_Products__c>();
        for (DSM_Products__c p: PList) {
            productTypeMap.put(p.Product_ID__c,p);
        }
    
        for (OpportunityLineItem oli : Trigger.new) {
            try {
                if(productTypeMap.containsKey(oli.HW_DC_DSM_Product_ID__c)){
                    oli.Product_Type__c = productTypeMap.get(oli.HW_DC_DSM_Product_ID__c).Product_Type__c;
                    oli.DSM_Product_Lookup__c = productTypeMap.get(oli.HW_DC_DSM_Product_ID__c).Id; //Updated 30-06-2016 [Suggested by Todd]
                }
            } catch (NullPointerException ex) {
                //Okay to get a null pointer exception
            }
        
         }
 }