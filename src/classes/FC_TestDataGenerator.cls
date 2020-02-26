@isTest
public class FC_TestDataGenerator {
    public static Contact[] generateContacts(Integer count) {
        Contact[] contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(new Contact(FirstName = 'Test ' + i, 
                LastName = 'Last ' + i,
                Metrostudy_User__c = true));
        }
        return contacts;
    }
    
    public static Account[] generateAccounts(Integer count) {
        Account[] accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, BillingPostalCode = '12345'));
        }
        return accounts;
    }
    
    // Count is the number of contact product geographies PER contact
    public static MetroclientContactProductGeography__c[] 
            generateContactProductGeographies(Contact[] contacts, 
            MetroclientProductGeography__c[] prodGeos,
            MetroclientAccountProductGeography__c[] accProdGeos,
            MetroclientProductGeographyType__c[] prodGeoTypes) {
                
        MetroclientContactProductGeography__c[] cpGeos = new List<MetroclientContactProductGeography__c>();
        
        Account metrostudyAccount = loadMetrostudyAccount();
        
        for (Contact cont : contacts) {
            for (Integer i = 0; i < prodGeos.size(); i++) {
                cpGeos.add(new MetroclientContactProductGeography__c(
                    Name = cont.Name,
                    MetroclientAccountProductGeography__c = accProdGeos[i].Id,
                    MetroclientProductGeographyType__c = prodGeoTypes[i].Id,
                    MetroclientProductGeography__c = prodGeos[i].Id));
            }
        }
        return cpGeos;
    }
    
    public static MetroclientAccountProductGeography__c generateAccProdGeo(Account acc, MetroclientProductGeography__c prodGeo) {
        String randomStr = generateRandomString(5);
        MetroclientAccountProductGeography__c accProdGeo = new MetroclientAccountProductGeography__c(
            Account__c = acc.Id,
            ChargeNumber__c = 'CN-' + randomStr,
            SubscriptionName__c = 'S-' + randomStr,
            MetroclientProductGeography__c = prodGeo.Id,
            Metroclient_cl_prod_id_TEMP_DNU__c = randomStr);
        return accProdGeo;
    }
    
    public static MetroclientProductGeography__c generateProdGeo(MetroclientProductGeographyType__c prodGeoType) {
        MetroclientProductGeography__c prodGeo = new MetroclientProductGeography__c(Name = 'Test',
            Active__c = true,
            Geography__c = generateGeo(generateGeoTypes(1)[0]).Id,
            ProductGeographyType__c = prodGeoType.Id);
        return prodGeo;
    }
    
    public static MetroclientProductGeographyType__c generateProdGeoType() {
        MetroclientGeographyType__c geoType = generateGeoTypes(1)[0];
        insert geoType;
        
        MetroclientProduct__c product = generateMetroclientProducts(1)[0];
        insert product;
        
        MetroclientProductGeographyType__c prodGeoType = new MetroclientProductGeographyType__c(Name = 'test',
            GeographyType__c = geoType.Id,
            Product__c = product.Id);
        return prodGeoType;
    }
    
    public static MetroclientGeography__c generateGeo(MetroclientGeographyType__c geoType) {
        MetroclientGeography__c geo = new MetroclientGeography__c(Name = geoType.Name,
            GeographyType__c = geoType.Id,
            Geography_FIPS__c = '1');
        return geo;
    }
    
    public static MetroclientGeographyType__c[] generateGeoTypes(Integer count) {
        MetroclientGeographyType__c[] geoTypes = new List<MetroclientGeographyType__c>();
        for (Integer i = 0; i < count; i++) {
            geoTypes.add(new MetroclientGeographyType__c(Name = 'Geo Type ' + i, GeographyTypeId__c = i));
        }
        return geoTypes;
    }
    
    public static MetroclientProduct__c[] generateMetroclientProducts(Integer count) {
        MetroclientProduct__c[] mcProducts = new List<MetroclientProduct__c>();
        for (Integer i = 0; i < count; i++) {
            mcProducts.add(new MetroclientProduct__c(Name = 'product name ' + i,
                ProductAbbreviation__c = 'pm' + i,
                ProvisionFlag__c = true));
        }
        return mcProducts;
    }
    
    // contact product geography
        // MetroclientProductGeographyType__c
        // MetroclientAccountProductGeography__c
        // MetroclientProductGeography__c
    
    // product geography types
        // Product
        // Geography Type
    
    // product geography
        // Geography
    
    // account product geography
        // account
    
    public static Account loadMetrostudyAccount() {
        Account acc = new Account(Name = 'Metrostudy, a Hanleywood Company', BillingPostalCode = '12345');
        insert acc;
        return acc;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}