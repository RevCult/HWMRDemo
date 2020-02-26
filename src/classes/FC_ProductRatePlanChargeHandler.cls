global without sharing class FC_ProductRatePlanChargeHandler extends fcf.TriggerAdapter {

    private Map<ID, zqu__ProductRatePlan__c> productRatePlanMap = new Map<ID, zqu__ProductRatePlan__c>();
    
    global override void bulkBefore() {
   	
    	Set<ID> productRatePlanIds = new Set<ID>();
        for (SObject so : Trigger.new) {
            zqu__ProductRatePlanCharge__c newCharge = (zqu__ProductRatePlanCharge__c) so;
            if (newCharge.zqu__ProductRatePlan__c != null) {
                productRatePlanIds.add(newCharge.zqu__ProductRatePlan__c);
            }
        }
        productRatePlanMap = new Map<ID, zqu__ProductRatePlan__c>([select Id, Name, zqu__ZProduct__r.zqu__SKU__c 
				from zqu__ProductRatePlan__c where Id in :productRatePlanIds]);
        
    }
    
    global override void beforeInsert(SObject so) {
	   	zqu__ProductRatePlanCharge__c newCharge = (zqu__ProductRatePlanCharge__c) so;
    	populateFcLookupKey(newCharge);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
	   	zqu__ProductRatePlanCharge__c newCharge = (zqu__ProductRatePlanCharge__c) so;
    	populateFcLookupKey(newCharge);
    }
    
    private void populateFcLookupKey(zqu__ProductRatePlanCharge__c charge) {
        zqu__ProductRatePlan__c ratePlan = productRatePlanMap.get(charge.zqu__ProductRatePlan__c);
        if (ratePlan != null) {
        	charge.FC_Lookup_Key__c = String.join(new String[] { ratePlan.zqu__ZProduct__r.zqu__SKU__c,
	            	rateplan.Name, charge.Name }, '^');
        }
    }
    
}