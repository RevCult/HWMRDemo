public class MetroclientContactEntitlement{

    private final Contact contact;
    
    // The extension constructor initializes the private member variable acct by using the getRecord method from the standard controller.
    public MetroclientContactEntitlement(ApexPages.StandardController stdController) {       
        this.contact= (Contact)stdController.getRecord();
    }
    
    public static String GeneratePassword(){  
        Integer max = 10;
        String password = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,max).toUpperCase();      
        return password;
    }    
}