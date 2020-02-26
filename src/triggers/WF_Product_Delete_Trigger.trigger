trigger WF_Product_Delete_Trigger on OpportunityLineItem (after delete) {

    List<WF_Archived_Project__c> archievedPrjList = new List<WF_Archived_Project__c>();
    for(OpportunityLineItem oppLineItem : Trigger.Old){
        if(oppLineItem.WF_Project_ID__c!= null){
            WF_Archived_Project__c archievePrj = new WF_Archived_Project__c();
            archievePrj.Opportunity__c = oppLineItem.OpportunityId;
            archievePrj.WF_Project_Id__c = oppLineItem.WF_Project_ID__c;
            archievePrj.Line_Item_ID__c = oppLineItem.HW_Line_Item_ID__c;
            archievedPrjList.add(archievePrj);
        }
    }
    
    if(archievedPrjList.size() > 0){
        insert archievedPrjList;
    }

}