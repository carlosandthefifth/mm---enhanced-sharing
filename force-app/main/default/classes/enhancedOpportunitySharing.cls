/*
    PROGRAMMER: Daniel Gustafson

	This is the first draft of an opportunity share class that allows for sharing of more than 300 groups.  There does not seem to be a physical
	cap on the sharing limit when doing this through Apex.

	This will be invoked through the opportunity trigger
 */
public without sharing class enhancedOpportunitySharing {
    public static void updateOpportunityShare(List<Opportunity> opportunities) {
        ID UserId = UserInfo.getUserId();
        List<GroupMember> groups_byID = [SELECT GroupID, UserOrGroupID FROM GroupMember WHERE UserOrGroupId = :UserID];
        List<OpportunityShare> OpportunityShares = new List<OpportunityShare>();    

       for (GroupMember agroup : groups_byID) {
           for (Opportunity o : opportunities) {    
               OpportunityShare os = new OpportunityShare(OpportunityId=o.id, UserOrGroupID=agroup.GroupID, OpportunityAccessLevel='Read');
               OpportunityShares.add(os);
           }
       }
        insert OpportunityShares;
    }
}