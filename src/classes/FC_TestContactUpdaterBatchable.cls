@isTest
private class FC_TestContactUpdaterBatchable {
    private static final Date SCHEDULED_DATE = Date.newInstance(2022, 9, 3);
    
    static testMethod void testCurrentAndNullCustomerStatus() {
        loadSetupData();
        Contact inactiveContact = [select Id from Contact limit 1];
        delete [select Id from MetroclientContactProductGeography__c where Contact__c = :inactiveContact.Id];
        
        Test.startTest();
        scheduleContactUpdater();
        // Database.executeBatch(new FC_ContactUpdaterBatchable()); 
        Test.stopTest();
        
        for (Contact cont : [select Customer_Status__c from Contact]) {
            if (cont.Id == inactiveContact.Id) {
                System.assert(String.isBlank(cont.Customer_Status__c));
            } else {
                System.assertEquals('Current', cont.Customer_Status__c);
            }
        }
    }
    
    static testMethod void testPastCustomerStatus() {
        loadSetupData();
        Contact inactiveContact = [select Id from Contact limit 1];
        delete [select Id from MetroclientContactProductGeography__c where Contact__c = :inactiveContact.Id];
        
        MetroclientAccountProductGeography__c[] accProdGeos = [select EndDate__c from MetroclientAccountProductGeography__c];
        for (MetroclientAccountProductGeography__c accProdGeo : accProdGeos) {
            // this will set the start date to something in the future which will cause the customer to be a 'Past' customer
            accProdGeo.StartDate__c = Date.today().addDays(-10);
            accProdGeo.EndDate__c = Date.today().addDays(-1);
        }
        update accProdGeos;
        
        MetroclientContactProductGeography__c[] contProdGeos = 
            [select Name, Contact__c, ContactAccountName__c, MetroclientProductGeography__c, ProductGeographyAccount__c, 
                MetroclientProductGeographyType__c, Status__c from MetroclientContactProductGeography__c];
        for (MetroclientContactProductGeography__c cpg : contProdGeos) {
            if (cpg.Contact__c != inactiveContact.Id) {
                System.debug(logginglevel.error, 'cpg: ' + cpg.Status__c);
            }
        }
        
        Test.startTest();
        scheduleContactUpdater();
        // Database.executeBatch(new FC_ContactUpdaterBatchable()); 
        Test.stopTest();
        
        for (Contact cont : [select Customer_Status__c from Contact]) {
            if (cont.Id == inactiveContact.Id) {
                System.assert(String.isBlank(cont.Customer_Status__c));
            } else {
                System.assertEquals('Past', cont.Customer_Status__c);
            }
        }
    }
    
    static testMethod void testProdGeoRollup() {
        loadSetupData();
        Contact firstContact = [select Id from Contact limit 1];
        MetroclientProductGeography__c[] prodGeos = [select Name from MetroclientProductGeography__c];
        for (MetroclientProductGeography__c prodGeo : prodGeos) {
            prodGeo.Name = 'aaaa | bbbb | ccc ccc';
        }
        update prodGeos;
        
        Test.startTest();
        Database.executeBatch(new FC_ContactUpdaterBatchable()); 
        Test.stopTest();
        
        firstContact = [select Product_Geographies__c from Contact where Id = :firstContact.Id];
        System.assertEquals('aaaa|bbbb|ccc ccc', firstContact.Product_Geographies__c);
    }
    
    private static void loadSetupData() {
        MetroclientGeographyType__c geoType = new MetroclientGeographyType__c(Name = 'some geo type', GeographyTypeId__c = 123);
        insert geoType;
        MetroclientGeography__c geography = new MetroclientGeography__c(Name = 'Country', GeographyType__c = geoType.Id);
        insert geography;
        MetroclientProduct__c product = new MetroclientProduct__c(Name = 'Product', ProductAbbreviation__c = 'abc');
        insert product;
        MetroclientProductGeographyType__c prodGeoType = new MetroclientProductGeographyType__c(Name = 'some geo type',
            GeographyType__c = geoType.Id, Product__c = product.Id);
        insert prodGeoType;
        
        MetroclientProductGeography__c[] prodGeos = new List<MetroclientProductGeography__c>();
        prodGeos.add(generateProductGeography('All HWMI Reports | Country | United States', geography, prodGeoType));
        prodGeos.add(generateProductGeography('Insight, Analytics & PA | Country | United States', geography, prodGeoType));
        prodGeos.add(generateProductGeography('Shaw Report | Country | United States', geography, prodGeoType));
        insert prodGeos;
        
        
        Account msAccount = FC_TestDataGenerator.loadMetroStudyAccount();
        MetroclientAccountProductGeography__c[] accProdGeos = loadAccountProductGeographies(msAccount, prodGeos);
        
        Map<Id, MetroclientAccountProductGeography__c> prodGeoToAccProdGeo = new Map<Id, MetroclientAccountProductGeography__c>();
        for (MetroclientAccountProductGeography__c accProdGeo : accProdGeos) {
            prodGeoToAccProdGeo.put(accProdGeo.MetroclientProductGeography__c, accProdGeo);
        }
        
        Contact[] contacts = FC_TestDataGenerator.generateContacts(5);
        insert contacts;
        MetroclientContactProductGeography__c[] contProdGeos = loadContactProductGeographies(contacts, prodGeos, prodGeoToAccProdGeo);
		
	}
	
	private static void scheduleContactUpdater() {
	    FC_ContactUpdaterSchedulable schedulable = new FC_ContactUpdaterSchedulable();
        String cronExp = '0 0 0 ' + SCHEDULED_DATE.day() + ' ' + SCHEDULED_DATE.month() + ' ? ' + SCHEDULED_DATE.year();
        Id jobId = System.schedule('test batch process', cronExp, schedulable);
        doScheduledJobAsserts(jobId);
        
        Database.executeBatch(new FC_ContactUpdaterBatchable());
	}
	
	private static void doScheduledJobAsserts(Id jobId) {
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
	        FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);

        System.assertEquals(SCHEDULED_DATE, ct.NextFireTime.date());
	}
	
	private static MetroclientProductGeography__c generateProductGeography(
	        String geoName, MetroclientGeography__c geography, MetroclientProductGeographyType__c geoType) {
	    return new MetroclientProductGeography__c(Name = geoName,
	        Active__c = true,
	        Geography__c = geography.Id, 
	        ProductGeographyType__c = geoType.Id);
	}
	
	private static MetroclientAccountProductGeography__c[] loadAccountProductGeographies(Account acc, MetroclientProductGeography__c[] prodGeos) {
	    MetroclientAccountProductGeography__c[] accProdGeos = new List<MetroclientAccountProductGeography__c>();
	    for (MetroclientProductGeography__c prodGeo : prodGeos) {
	        accProdGeos.add(new MetroclientAccountProductGeography__c(Name = prodGeo.Name,
	            MetroclientProductGeography__c = prodGeo.Id,
	            StartDate__c = Date.newInstance(2000, 1, 1)));
	    }
	    insert accProdGeos;
	    return accProdGeos;
	}
	
	private static MetroclientContactProductGeography__c[] loadContactProductGeographies(Contact[] contacts, 
	        MetroclientProductGeography__c[] prodGeos, 
	        Map<Id, MetroclientAccountProductGeography__c> prodGeoToAccProdGeo) {
	            
	    MetroclientContactProductGeography__c[] contProdGeos = new List<MetroclientContactProductGeography__c>();
	    for (Contact cont : contacts) {
    	    for (MetroclientProductGeography__c prodGeo : prodGeos) {
    	        contProdGeos.add(new MetroclientContactProductGeography__c(Name = cont.Name,
    	            Contact__c = cont.Id,
    	            MetroclientProductGeography__c = prodGeo.Id,
    	            MetroclientProductGeographyType__c = prodGeo.ProductGeographyType__c,
    	            MetroclientAccountProductGeography__c = prodGeoToAccProdGeo.get(prodGeo.Id).Id));
    	    }
	    }
	    insert contProdGeos;
	    return contProdGeos;
	}
}