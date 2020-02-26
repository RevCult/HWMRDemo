@isTest
public class FC_TestProductRatePlanChargeHandler {
    
    private static final String SIMPLE_PRODUCT_NAME = 'Test Simple Product';
    private static final String SIMPLE_PRODUCT_RATE_PLAN_NAME = 'Test Simple Product Rate Plan';
    private static final String SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test Simple Product Rate Plan Charge';
    private static final String CONSULTING_PRODUCT_NAME = 'Test Consulting Product';
    private static final String CONSULTING_PRODUCT_RATE_PLAN_NAME = 'Test Consulting Product Rate Plan';
    private static final String CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test Consulting Product Rate Plan Charge';
    private static final String ONE_TIME_CHARGE_PRODUCT_NAME = 'Test One-Time Charge Product';
    private static final String ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME = 'Test One-Time Charge Product Rate Plan';
    private static final String ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME = 'Test One-Time Charge Product Rate Plan Charge';
    
    private static testmethod void testInsert() {
        TestDataStruct testData = setup();
        enableTriggerHandlers();
        Test.startTest();
        Map<String, zqu__ProductRatePlanCharge__c> testProductRatePlanChargesMap = new Map<String, zqu__ProductRatePlanCharge__c> {
                SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(SIMPLE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', 
                        zqu__ZuoraId__c = '0'),
                CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(CONSULTING_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', 
                        zqu__ZuoraId__c = '1'),
                ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'One-Time',
                        zqu__ZuoraId__c = '2') };
        insert testProductRatePlanChargesMap.values();
        Test.stopTest();
        zqu__ProductRatePlanCharge__c[] testProductRatePlanCharges = [select Id, FC_Lookup_Key__c, Name, zqu__ProductRatePlan__r.Name, 
                                                                      zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c 
                                                                      from zqu__ProductRatePlanCharge__c where Id in :testProductRatePlanChargesMap.values()];
        for (zqu__ProductRatePlanCharge__c testProductRatePlanCharge : testProductRatePlanCharges) {
            System.assertEquals(testProductRatePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c + '^' + 
                                testProductRatePlanCharge.zqu__ProductRatePlan__r.Name + '^' +
                                testProductRatePlanCharge.Name, testProductRatePlanCharge.FC_Lookup_Key__c);
        }
    }
    
    private static testmethod void testUpdate() {
        TestDataStruct testData = setup();
        enableTriggerHandlers();
        Map<String, zqu__ProductRatePlanCharge__c> testProductRatePlanChargesMap = new Map<String, zqu__ProductRatePlanCharge__c> {
                SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = SIMPLE_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(SIMPLE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', 
                        zqu__ZuoraId__c = '0'),
                CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = CONSULTING_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(CONSULTING_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'Recurring', 
                        zqu__ZuoraId__c = '1'),
                ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME => new zqu__ProductRatePlanCharge__c(Name = ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_CHARGE_NAME, 
                        zqu__ProductRatePlan__c = testData.productRatePlansMap.get(ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME).Id, zqu__Type__c = 'One-Time',
                        zqu__ZuoraId__c = '2') };
        insert testProductRatePlanChargesMap.values();
        Test.startTest();
        for (zqu__ProductRatePlanCharge__c testProductRatePlanCharge : testProductRatePlanChargesMap.values()) {
            testProductRatePlanCharge.zqu__ZuoraId__c = testProductRatePlanCharge.zqu__ZuoraId__c + 'TEST';
        }
        update testProductRatePlanChargesMap.values();
        Test.stopTest();
        zqu__ProductRatePlanCharge__c[] testProductRatePlanCharges = [select Id, FC_Lookup_Key__c, Name, zqu__ProductRatePlan__r.Name, 
                                                                      zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c 
                                                                      from zqu__ProductRatePlanCharge__c where Id in :testProductRatePlanChargesMap.values()];
        for (zqu__ProductRatePlanCharge__c testProductRatePlanCharge : testProductRatePlanCharges) {
            System.assertEquals(testProductRatePlanCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c + '^' + 
                                testProductRatePlanCharge.zqu__ProductRatePlan__r.Name + '^' +
                                testProductRatePlanCharge.Name, testProductRatePlanCharge.FC_Lookup_Key__c);
        }
    }
    
    private static void enableTriggerHandlers() {
        fcf.TriggerHandlerSettings.enable('FC_ProductRatePlanChargeHandler');
    }
    
    private static TestDataStruct setup() {
        
        Map<String, zqu__ZProduct__c> testProductsMap = new Map<String, zqu__ZProduct__c> {
                SIMPLE_PRODUCT_NAME => new zqu__ZProduct__c(Name = SIMPLE_PRODUCT_NAME, zqu__SKU__c = 'SKU-0', zqu__ZuoraId__c = '0'),
                CONSULTING_PRODUCT_NAME => new zqu__ZProduct__c(Name = CONSULTING_PRODUCT_NAME, zqu__SKU__c = 'SKU-1', zqu__ZuoraId__c = '1'),
                ONE_TIME_CHARGE_PRODUCT_NAME => new zqu__ZProduct__c(Name = ONE_TIME_CHARGE_PRODUCT_NAME, zqu__SKU__c = 'SKU-2', zqu__ZuoraId__c = '2') };
        upsert testProductsMap.values();
        
        Map<String, zqu__ProductRatePlan__c> testProductRatePlanMap = new Map<String, zqu__ProductRatePlan__c> {
                SIMPLE_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = SIMPLE_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(SIMPLE_PRODUCT_NAME).Id, zqu__ZuoraId__c = '0'),
                CONSULTING_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = CONSULTING_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(CONSULTING_PRODUCT_NAME).Id, zqu__ZuoraId__c = '1'),
                ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME => new zqu__ProductRatePlan__c(Name = ONE_TIME_CHARGE_PRODUCT_RATE_PLAN_NAME,
                        zqu__ZProduct__c = testProductsMap.get(ONE_TIME_CHARGE_PRODUCT_NAME).Id,  zqu__ZuoraId__c = '2')};
        upsert testProductRatePlanMap.values();
        
        TestDataStruct result = new TestDataStruct();
        result.productsMap.putAll(testProductsMap);
        result.productRatePlansMap.putAll(testProductRatePlanMap);
        return result;
    }
    
    private class TestDataStruct {
        public Map<String, zqu__ZProduct__c> productsMap = new Map<String, zqu__ZProduct__c>();
        public Map<String, zqu__ProductRatePlan__c> productRatePlansMap = new Map<String, zqu__ProductRatePlan__c>();
    }
    
}