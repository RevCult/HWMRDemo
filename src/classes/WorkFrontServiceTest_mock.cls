@isTest
public with sharing class WorkFrontServiceTest_mock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String Body='{"data":{ "userID":"56b4d0bc0024d04ea8d5101d1f50925a", "sessionID":"460cc40c1fda4ef09734216cd5c9d583", "versionInformation":{ "currentAPI":"v5.0", "buildNumber":"963b2bed623a06c6aa2e3f21f6f451e7c6acb980", "apiVersions":{ "v1.0":"/attask/api/v1.0/", "v2.0":"/attask/api/v2.0/", "v3.0":"/attask/api/v3.0/", "v4.0":"/attask/api/v4.0/", "v5.0":"/attask/api/v5.0/" }, "lastUpdated":"2016/06/06 20:18:35", "release":"R16", "version":"4.0" }, "locale":"en_US", "timeZone":"US/Mountain", "timeZoneName":"Mountain Standard Time", "iso3Country":"USA", "iso3Language":"eng", "currency":{ "useNegativeSign":false, "fractionDigits":2, "symbol":"$", "ID":"USD", "groupingSeparator":",", "decimalSeparator":"." } } }';
        res.setBody(Body);
        res.setStatusCode(200);
        return res;
    }
}