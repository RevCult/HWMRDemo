public class FC_GroupMemberCache {

    private static String[] GROUP_MEMBER_FIELDS = new String[] { 'Id', 'GroupId', 'UserOrGroupId', 'Group.DeveloperName', 'Group.Name' };

    private static final Map<ID, GroupMember> BY_ID_MAP = new Map<ID, GroupMember>();
    private static final Map<ID, Set<ID>> USER_OR_GROUP_IDS_BY_GROUP_ID_MAP = new Map<ID, Set<ID>>();
    private static final Map<String, Set<ID>> USER_OR_GROUP_IDS_BY_GROUP_DEVELOPER_NAME_MAP = new Map<String, Set<ID>>();

    private static final String SOQL_BASE;
    
    static {
        SOQL_BASE = String.format('select {0} from GroupMember', 
                                  new String[] { String.join(GROUP_MEMBER_FIELDS, ', ') });              
    }
    
    public static void clearCache() {
        BY_ID_MAP.clear();
        USER_OR_GROUP_IDS_BY_GROUP_ID_MAP.clear();
        USER_OR_GROUP_IDS_BY_GROUP_DEVELOPER_NAME_MAP.clear();
    }
    
    public static Map<String, Set<ID>> findUserIdsByGroupDeveloperNames(Set<String> groupDeveloperNames) {        
        Map<String, Set<ID>> results = new Map<String, Set<ID>>();
        Set<String> groupDeveloperNamesToQuery = new Set<String>();
        for (String groupDeveloperName : groupDeveloperNames) {
            if (USER_OR_GROUP_IDS_BY_GROUP_DEVELOPER_NAME_MAP.containsKey(groupDeveloperName)) {
                results.put(groupDeveloperName, USER_OR_GROUP_IDS_BY_GROUP_DEVELOPER_NAME_MAP.get(groupDeveloperName));
            } else {
                groupDeveloperNamesToQuery.add(groupDeveloperName);
            }
        }
        if (groupDeveloperNamesToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Group.DeveloperName in :groupDeveloperNamesToQuery';
            for (GroupMember groupMemberRecord : Database.query(soql)) {
                Set<ID> userOrGroupIds = results.get(groupMemberRecord.Group.DeveloperName);
                if (userOrGroupIds == null) {
                    userOrGroupIds = new Set<ID>();
                    results.put(groupMemberRecord.Group.DeveloperName, userOrGroupIds);
                }
                userOrGroupIds.add(groupMemberRecord.UserOrGroupId);
                USER_OR_GROUP_IDS_BY_GROUP_DEVELOPER_NAME_MAP.put(groupMemberRecord.Group.DeveloperName, userOrGroupIds);
                USER_OR_GROUP_IDS_BY_GROUP_ID_MAP.put(groupMemberRecord.GroupId, userOrGroupIds);
                BY_ID_MAP.put(groupMemberRecord.Id, groupMemberRecord);
            }
        }
        return results;
    }
    
}