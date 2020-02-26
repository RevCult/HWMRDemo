public with sharing class Utils {
	public static String getSelectStarQueryForSobjectType(String objectType) {
        SObjectType theType = Schema.getGlobalDescribe().get(objectType);
        String theQuery = 'SELECT Id';
        for (String fieldName : getFieldsForObjectType(theType)) {
            theQuery += ','+fieldName;
        }
        theQuery += ' FROM ' + theType;
        return theQuery;
    }

    public static Set<String> getFieldsForObjectType(Schema.SObjectType theType) {
        Set<String> theFields = new Set<String>();
        Map<String, Schema.SObjectField> mapFields = theType.getDescribe().fields.getMap();
        for(String fieldName : mapFields.keySet()) {
            if (fieldName != 'Id' && mapFields.get(fieldName).getDescribe().isAccessible()) {
                theFields.add(fieldName.toLowerCase());
            }
        }
        return theFields;
    }
}