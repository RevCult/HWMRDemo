@isTest
public class TestFactoryMetroclient {

  
  public static Account makeAccount(string aName) {

    Account testAcc = new Account();
    testAcc.Name = aName;
    testAcc.BillingCity = 'Houston';
    testAcc.BillingState = 'TX';
    testAcc.BillingPostalCode = '12345';
    testAcc.ShippingStreet ='123 Main St.';
    testAcc.ShippingCity = 'Houston';
    testAcc.ShippingState = 'TX';  
    testAcc.ShippingPostalCode='77002';
    testAcc.ShippingCountry ='United States';
    insert testAcc;
    return testAcc;
  }
  
  public static MetroclientGeographyType__c makeGeographyType(string sName, Decimal sId) {
    MetroclientGeographyType__c  testGeoType = new MetroclientGeographyType__c();
    testGeoType.Name = sName;
    testGeoType.GeographyTypeId__c= sId;  
    insert testGeoType ;
    return testGeoType ;    
  }
  public static MetroclientGeography__c makeGeography(MetroclientGeographyType__c geoType, string GeoName, string GeoFIPS) {

    MetroclientGeography__c testGeo = new MetroclientGeography__c();
    testGeo.Name = GeoName;
    testGeo.Geography_FIPS__c= GeoFIPS;  
    testGeo.GeographyType__c  =geoType.Id;
    insert testGeo;
    return testGeo;    
  }
  
  
  public static MetroclientProduct__c makeProduct(string pName, boolean pSubscrpitionOnly) {

    MetroclientProduct__c testProd = new MetroclientProduct__c();
    testProd.Name = pName;
    if(pName.length()>20)
        pName=pName.SubString(0,20);
    testProd.ProductAbbreviation__c =pName;
    testProd.SubscriptionOnly__c  = pSubscrpitionOnly;    
    insert testProd;
    return testProd;    
  }
  
  public static MetroclientProductGeographyType__c makeProductGeographyType(MetroclientProduct__c  prod, MetroclientGeographyType__c  geoType) {

    MetroclientProductGeographyType__c testProdGeoType = new MetroclientProductGeographyType__c();
    testProdGeoType.Name = 'Test Product Geography Type';
    testProdGeoType.GeographyType__c= geoType.Id ;
    testProdGeoType.Product__c= prod.Id;      
    insert testProdGeoType ;
    return testProdGeoType ;    
  }  
  
   public static MetroclientProductGeography__c makeProductGeography(MetroclientProductGeographyType__c prodGeoType, MetroclientGeography__c  geo, string sName) {

    MetroclientProductGeography__c testProdGeo = new MetroclientProductGeography__c();
    testProdGeo.Name = sName;
    testProdGeo.Active__c= True;
    testProdGeo.ProductGeographyType__c =prodGeoType.Id;
    testProdGeo.Geography__c= geo.ID; 
    insert testProdGeo ;
    return testProdGeo ;    
  }
  
  
  public static MetroclientAccountProductGeography__c  makeAccountProductGeography(Account testAcc, MetroclientProductGeography__c prodGeo, Zuora__Subscription__c  testSub, Zuora__SubscriptionProductCharge__c  testCharge, boolean bOrr, boolean bDel ) { 
  
     MetroclientAccountProductGeography__c testAccPG = new MetroclientAccountProductGeography__c ();
     testAccPG.Account__c= testAcc.Id;
     testAccPG.Deleted__c = bDel;
     testAccPG.Override__c= bOrr;
     testAccPG.StartDate__c=testCharge.Zuora__EffectiveStartDate__c.AddDays(-1);
     testAccPG.MetroclientProductGeography__c = prodGeo.ID;
     testAccPG.ChargeNumber__c = testCharge.Name;
     testAccPG.SubscriptionName__c = testSub.Name;
     insert testAccPG;
     return testAccPG;
   }
   
    
  public static MetroclientAccountProductGeography__c  makeAccountProductGeographySameDates(Account testAcc, MetroclientProductGeography__c prodGeo, Zuora__Subscription__c  testSub, Zuora__SubscriptionProductCharge__c  testCharge, boolean bOrr, boolean bDel ) { 
  
     MetroclientAccountProductGeography__c testAccPG = new MetroclientAccountProductGeography__c ();
     testAccPG.Account__c= testAcc.Id;
     testAccPG.Deleted__c = bDel;
     testAccPG.Override__c= bOrr;
     testAccPG.StartDate__c=testCharge.Zuora__EffectiveStartDate__c;
     testAccPG.EndDate__c=testCharge.Zuora__EffectiveEndDate__c;
     testAccPG.MetroclientProductGeography__c = prodGeo.ID;
     testAccPG.ChargeNumber__c = testCharge.Name;
     testAccPG.SubscriptionName__c = testSub.Name;
     insert testAccPG;
     return testAccPG;
   }
   
   
   
   public static Zuora__SubscriptionProductCharge__c makeSubscriptionProductCharge (Zuora__Subscription__c  testSub,MetroclientProductGeography__c prodGeo,string sName, date dStart, date dEnd, string sFreq){
        Zuora__SubscriptionProductCharge__c testSubProdCharge = new Zuora__SubscriptionProductCharge__c ();
        testSubProdCharge.Name = sName;
        testSubProdCharge.Zuora__ChargeNumber__c = sName;
        testSubProdCharge.CreatedDate = System.Now();
        testSubProdCharge.LastModifiedDate = System.Now();
        testSubProdCharge.Zuora__Type__c = sFreq;
        testSubProdCharge.Zuora__Subscription__c = testSub.Id;
        testSubProdCharge.Record_Id__c = prodGeo.Id;
        testSubProdCharge.Zuora__EffectiveEndDate__c = dStart;
        testSubProdCharge.Zuora__EffectiveStartDate__c = dEnd;
       insert testSubProdCharge;
       return testSubProdCharge; 
   }
   
     public static Zuora__SubscriptionProductCharge__c makeSubscriptionProductCharge_BadRecordId (Zuora__Subscription__c  testSub,string sName, date dStart, date dEnd, string sFreq){
        Zuora__SubscriptionProductCharge__c testSubProdCharge = new Zuora__SubscriptionProductCharge__c ();
        testSubProdCharge.Name = sName;
        testSubProdCharge.Zuora__ChargeNumber__c = sName;
        testSubProdCharge.CreatedDate = System.Now();
        testSubProdCharge.LastModifiedDate = System.Now();
        testSubProdCharge.Zuora__Type__c = sFreq;
        testSubProdCharge.Zuora__Subscription__c = testSub.Id;
        testSubProdCharge.Record_Id__c = 'I-am-A-bad-RecordId';
        testSubProdCharge.Zuora__EffectiveEndDate__c = dStart;
        testSubProdCharge.Zuora__EffectiveStartDate__c = dEnd;
       insert testSubProdCharge;
       return testSubProdCharge; 
   }
   
   
  
   
   public static Zuora__Subscription__c makeSubscription (Account acc, string sName, date dStart, date dEnd, string sStatus){
       Zuora__Subscription__c testSub = new Zuora__Subscription__c ();
       testSub.Name = sName;
       testSub.Zuora__SubscriptionStartDate__c = dStart;
       testSub.Zuora__SubscriptionEndDate__c = dEnd;
       testSub.Zuora__Status__c= sStatus;
       testSub.Zuora__Account__c = acc.Id;
       insert testSub;
       return testSub;  
   }
   
   
    public static MetroclientSubscriptionAmendmentLog__c makeAmendmentLog(string sName, Zuora__Subscription__c  testSub, Zuora__SubscriptionProductCharge__c  testCharge, string sAmendmentType, date dEffectiveDate){
       MetroclientSubscriptionAmendmentLog__c testAmdLog = new MetroclientSubscriptionAmendmentLog__c();
       testAmdLog.Name = sName;
       testAmdLog.EffectiveDate__c = dEffectiveDate;
       testAmdLog.AmendmentType__c = sAmendmentType;
       testAmdLog.SubscriptionName__c = testSub.Name;
       testAmdLog.ChargeNumber__c =  testCharge.Name;
       testAmdLog.UniqueName__c = sName + ' | ' + testSub.Name + ' | ' +  testCharge.Name;
       testAmdLog.ProvisioningUpdated__c = false;
       insert testAmdLog ;
       return testAmdLog ;  
   }
   
   
   
    public static void ProductGeographyFactory() {

    MetroclientProduct__c prodMM = TestFactoryMetroclient.makeProduct('Metrostudy Membership (Test)',true);
    MetroclientProduct__c prodHBD = TestFactoryMetroclient.makeProduct('Home Builder Database Package (Test)',false);
    
    MetroclientGeographyType__c geoTypeMkt = TestFactoryMetroclient.makeGeographyType('Market',20);
    MetroclientGeographyType__c geoTypeCBSA = TestFactoryMetroclient.makeGeographyType('CBSA',30);
    
    MetroclientGeography__c geoMkt1= TestFactoryMetroclient.makeGeography(geoTypeMkt,'Test Market 1','T1');
    MetroclientGeography__c geoMkt2= TestFactoryMetroclient.makeGeography(geoTypeMkt,'Test Market 2','T2');
    MetroclientGeography__c geoCBSA1= TestFactoryMetroclient.makeGeography(geoTypeMkt,'Test CBSA 1','T0001');
    MetroclientGeography__c geoCBSA2= TestFactoryMetroclient.makeGeography(geoTypeMkt,'Test CBSA 2','T0002');
    
    
    MetroclientProductGeographyType__c prodGeoTypeMmMkt= TestFactoryMetroclient.makeProductGeographyType(prodMM,geoTypeMkt );    
    MetroclientProductGeographyType__c prodGeoTypeHbdCBSA= TestFactoryMetroclient.makeProductGeographyType(prodHBD ,geoTypeCBSA); 
    MetroclientProductGeography__c testProdGeo = new MetroclientProductGeography__c();
    
     makeProductGeography(prodGeoTypeMmMkt, geoMkt1 , 'TestProdGeo1');
     makeProductGeography(prodGeoTypeMmMkt, geoMkt2 , 'TestProdGeo2');
     makeProductGeography(prodGeoTypeHbdCBSA, geoCBSA1, 'TestProdGeo3');
     makeProductGeography(prodGeoTypeHbdCBSA, geoCBSA2, 'TestProdGeo4');

    
 }
  
   
 /* public static Zuora__CustomerAccount__c makeBillingAccount (Account acc){  
       Zuora__CustomerAccount__c testBillAcct  =new Zuora__CustomerAccount__c();
       testBillAcct.Name='Test Billing Account';
       testBillAcct.Zuora__BillToState__c='TX';
       testBillAcct.Zuora__Account__c = acc.Id;
       insert testBillAcct;
       return testBillAcct;
   
   }*/   

  
 }