public class WF_Loginresponse{
    public cls_data data;
    public class cls_data {
        public String userID;   //56b4d0bc0024d04ea8d5101d1f50925a
        public String sessionID;    //460cc40c1fda4ef09734216cd5c9d583
        public cls_versionInformation versionInformation;
        public String locale;   //en_US
        public String timeZone; //US/Mountain
        public String timeZoneName; //Mountain Standard Time
        public String iso3Country;  //USA
        public String iso3Language; //eng
        public cls_currency objcurrency;
    }
    class cls_versionInformation {
        public String currentAPI;   //v5.0
        public String buildNumber;  //963b2bed623a06c6aa2e3f21f6f451e7c6acb980
        public cls_apiVersions apiVersions;
        public String lastUpdated;  //2016/06/06 20:18:35
        public String release;  //R16
        public String version;  //4.0
    }
    class cls_apiVersions {
        public String v1; ///attask/api/v1.0/
        public String v2; ///attask/api/v2.0/
        public String v3; ///attask/api/v3.0/
        public String v4; ///attask/api/v4.0/
        public String v5; ///attask/api/v5.0/
    }
    class cls_currency {
        public boolean useNegativeSign;
        public Integer fractionDigits;  //2
        public String symbol;   //$
        public String ID;   //USD
        public String groupingSeparator;    //,
        public String decimalSeparator; //.
    }
    public static WF_Loginresponse parse(String json){
        return (WF_Loginresponse) System.JSON.deserialize(json, WF_Loginresponse.class);
    }

}