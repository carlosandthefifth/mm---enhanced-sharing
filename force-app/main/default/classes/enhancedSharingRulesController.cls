public class enhancedSharingRulesController {
    private static List<String> allowedObjectNames = new List<String>{'Account','Opportunity', 'Property'};  // contacts has a trigger that needs to be re-written
    private static List<User>   selectedUsers = new List<User>();
    private static List<User>   availableUsers = new List<User>();
    private static List<User>   AllUserNames  = new List<User>();

    public enhancedSharingRulesController() {
        // nothing to do here
    }

    @AuraEnabled
    public static List<String> getObjectNames(){
        return allowedObjectNames;
    }

    private static String get_IDPrefix(String  objectName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        String Prefix = targetType.getDescribe().getKeyPrefix();
        return Prefix;
    }

    @AuraEnabled
    public static List<String> createPublicGroup(String Name, String AccessLevel, String Type, String forObject){
        
        String Prefix = get_IDPrefix(forObject);


        // There is a 40 character length for group names.  We need some of the space to identify the object with the group.  I decided ot use
        // prefix since it only take three characters
        // format is like groupname_objectprefix
        // REMEMBER Prefixes are case sensitive
    
        Name = Name + '_' + Prefix;
        if (AccessLevel == 'Read/Write') Name = Name + 'e'; // edit flag

        try {
            Group aGroup = new Group(name=Name, Type=Type, DeveloperName=Name);
            insert aGroup;
        } catch (Exception e) {
            system.debug('enhancedSharingRulesController class - createPublicGroup method: ' + e.getMessage());
        }
        return getPublicGroupNames(forObject);
    }

    @AuraEnabled
    public static List<String> deletePublicGroup(String Name, String forObject){
        
        
        String Prefix = get_IDPrefix(forObject);

        String groupName = Name+'_'+Prefix;

        group aGroup = [SELECT ID FROM Group where name = :groupName][0];
        delete aGroup;

        return getPublicGroupNames(forObject);
    }

    @AuraEnabled
    public static List<string> getPublicGroupNames(String objectName){
        List<Group> groups  = [SELECT Name FROM Group where Name != ''];
        String Prefix = get_IDPrefix(objectName);
        
        List<String> groupNames = new List<String>();

        for (group g : groups) {
            if (g.name != null) {
                if(g.name.indexOf('_') >= 0) {
                    List<String> extractName = g.name.split('_');

                    if (extractName[1] == Prefix)
                        groupNames.add(extractName[0]);
                }
            }

        }
        return groupNames;
    }

    @AuraEnabled 
    public static void removeFromMembership(List<ID> UserIDsRemoved, String GroupName, String ObjectType) {
        String fullGroupName = GroupName + '_006';
        Group aGroup = [SELECT ID FROM Group where Name = :fullGroupName][0];
        List<groupMember> groupMembers = [SELECT ID, UserOrGroupID FROM groupMember WHERE UserOrGroupID IN :UserIDsRemoved];
        for (groupMember gm : groupMembers) {
            system.debug('gm.id: ' + gm.id);
            system.debug('gm.userorgroupid: ' + gm.userorgroupid);
        }
        delete groupMembers;

        List<Opportunity> opportunities = [SELECT ID, OwnerID FROM Opportunity WHERE OwnerID IN :UserIDsRemoved];

        List<ID> OppIDs = new List<ID>();
        List<ID> OwnerIDs = new List<ID>(); 
        for (opportunity o : opportunities) {
            OppIDS.add(o.id);
            OwnerIDs.add(o.ownerId);
        }

  //      List<OpportunityShare> opportunityShares = [SELECT ID FROM opportunityShare where OpportunityID IN :OppIDS AND UserOrGroupID NOT IN :OwnerIDs];
    //    delete opportunityShares;
        
        updateSharing(OppIDS);

    }

    @AuraEnabled 
    public static void addToMembership(List<ID> UserIDsAdded, String GroupName, String ObjectType) {
        String fullGroupName = GroupName + '_' + get_IDPrefix(ObjectType);
        Group aGroup = [SELECT ID FROM Group where Name = :fullGroupName][0];
        List<GroupMember> groupMembers = new List<GroupMember>();
        for (ID UserID : UserIDsAdded) {
            groupMember gm = new groupMember(GroupID=aGroup.id, UserORGroupId=UserID);
            system.debug('groupid: ' + aGroup.id);
            system.debug('userId: ' + UserID);
            groupMembers.add(gm);
        }
        insert groupMembers;
        system.debug('groupMembers: ' + groupMembers);

        List<Opportunity> opportunities = [SELECT ID, OwnerID FROM Opportunity WHERE OwnerID IN :UserIDsAdded];


        List<ID> OppIDs = New List<ID>();
        for (opportunity o : opportunities) {
            OppIDS.add(o.id);
        }

       // List<OpportunityShare> opp_shares = [SELECT ID FROM OpportunityShare WHERE OpportunityID IN :OppIDS];
       // delete opp_shares;

        // future call to avoid mixed_dml_operation error
        updateSharing(OppIDS);
    }

    @AuraEnabled
    public static List<User> getAvailableUsers(List<user> users){
        system.debug('inside getavailableusers');
        try {
            List<ID> selectedUserIDs = new List<ID>();

            for (user u : users) {
                selectedUserIDs.add(u.id);
            }
            system.debug('selectedUserIDs.size(): ' + selectedUserIDs.size());
            integer queryLimit = LIMITS.getLimitQueryRows() - LIMITS.getQueryRows();  
            
            availableUsers = [SELECT firstName, lastName, Id, userName FROM User WHERE Id NOT IN :selectedUserIDs AND isActive = true ORDER BY lastName ASC LIMIT :queryLimit];
            system.debug('availableUsers.size(): ' + availableUsers.size());
        } catch (Exception e) {
            system.debug('enhancedSharingRulesController class - getAvailableUsers method ' + e.getMessage());
        }
        return availableUsers;
    }

    @AuraEnabled
    public static List<User> getSelectedUsers(string groupName, string objectName){
        try {
            integer queryLimit = LIMITS.getLimitQueryRows() - LIMITS.getQueryRows();        
 
            groupName = groupName + '_' + get_IDPrefix(objectName);

            Group aGroup = [SELECT ID FROM Group WHERE Name =:groupName LIMIT 1][0];
            system.debug('aGroup.id: ' + aGroup.ID);

            List<groupMember> groupMembers = [SELECT ID, UserOrGroupID, GroupId FROM groupMember WHERE GroupId =:agroup.ID LIMIT :queryLimit];
            system.debug('groupMembers.size(): ' + groupMembers.Size());
            List<ID> selectedUserIDs = new List<ID>();

            for (groupMember g : groupmembers) {
                selectedUserIDs.add(g.UserOrGroupID);
            }

            queryLimit = LIMITS.getLimitQueryRows() - LIMITS.getQueryRows();    

            selectedUsers = [SELECT firstName, lastName, Id, userName FROM user WHERE ID in :selectedUserIDs AND isActive=true ORDER BY lastName LIMIT :queryLimit];

            for (user u : selectedUsers) {
                system.debug('u.userName: ' + u.userName);
            }

        } catch (Exception e) {
            system.debug('enhancedSharingRulesController class - getSelectedUsers method ' + e.getMessage());
        }
        system.debug('selectedUsers.Size(): ' + selectedUsers.size());
        return selectedUsers;
    }

    @future 
    private static void updateSharing(List<ID> IDs) {
        List<Opportunity> opportunities = [SELECT ID, OwnerID FROM Opportunity WHERE ID IN :IDs];
        customPublicGroupSharingHandler.onInsert(opportunities,'Opportunity');
    }
}
