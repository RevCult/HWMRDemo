/**
 * Created by mikegill on 12/10/2017.
 */

global class ApexUtils {

    global static String getObjectFields (String objectAPIName) {

        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String, Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();

        String soqlQuery = '';

        for (String field : mfields.keySet()) {
            soqlQuery += field + ', ';

        }

        soqlQuery = soqlQuery.replaceAll(', $', '');

        return soqlQuery;

    }

}