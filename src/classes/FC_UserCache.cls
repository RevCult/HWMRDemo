public class FC_UserCache {

    private static String[] SELECT_FIELDS = new String[]{
            'Id', 'Department', 'Email', 'IsActive', 'Name'
    };

    private static final Map<Id, User> BY_ID_MAP = new Map<Id, User>();
    private static final Map<String, User> BY_NAME_MAP = new Map<String, User>();

    private static final String SOQL_BASE;

    static {
        SOQL_BASE = String.format('select {0} from User',
                new String[]{
                        String.join(SELECT_FIELDS, ', ')
                });
    }

    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_NAME_MAP.clear();
    }

    public static Map<Id, User> findByIds(Set<Id> userIds) {
        Map<Id, User> results = new Map<Id, User>();
        Set<Id> userIdsToQuery = new Set<Id>();
        for (Id userId : userIds) {
            if (BY_ID_MAP.containsKey(userId)) {
                results.put(userId, BY_ID_MAP.get(userId));
            } else {
                userIdsToQuery.add(userId);
            }
        }
        if (userIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Id in :userIdsToQuery';
            for (User userRecord : Database.query(soql)) {
                BY_ID_MAP.put(userRecord.Id, userRecord);
                BY_NAME_MAP.put(userRecord.Name, userRecord);
                results.put(userRecord.Id, userRecord);
            }
        }
        return results;
    }


    public static Map<String, User> findByNames(Set<String> names) {
        Map<String, User> results = new Map<String, User>();
        Set<String> namesToQuery = new Set<String>();
        for (String name : names) {
            if (BY_NAME_MAP.containsKey(name)) {
                results.put(name, BY_NAME_MAP.get(name));
            } else {
                namesToQuery.add(name);
            }
        }
        if (namesToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Name in :namesToQuery';
            for (User userRecord : Database.query(soql)) {
                BY_ID_MAP.put(userRecord.Id, userRecord);
                BY_NAME_MAP.put(userRecord.Name, userRecord);
                results.put(userRecord.Name, userRecord);
            }
        }
        return results;
    }

}