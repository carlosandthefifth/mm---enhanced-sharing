/*
    PROGRAMMER: Daniel Gustafson

	This is the first draft of an opportunity share class that allows for sharing of more than 300 groups.  There does not seem to be a physical
	cap on the sharing limit when doing this through Apex.

	This will be invoked through the opportunity trigger
 */
public without sharing class enhancedOpportunitySharing {
	
    public static void updateOpportunityShare(List<Opportunity> opportunities) {
        /*
           This method expects a userid and a list of opportunities owned by that user.  Checking for ownership is done before calling this routine.
        */
        // Which groups does this user belong to
        
        // 50,000 record limit.  If we have 3000 group members, then they can be members of 16 different groups
        // Get all groupmembers.  We do it this way because we can only make 100 SOQL queries in a synchronous process
        
        integer queryRowLimit = Limits.getLimitQueryRows();// total number of rows we can get in an apex transaction
        
        ID uID = UserInfo.getUserId();
        List<GroupMember> groupmembers = [select GroupID, UserOrGroupID FROM GroupMember WHERE  UserOrGroupId = :uId LIMIT :queryRowLimit];
        
        if (groupMembers.size() <=0) return; // no opportunities shared through groups
        
        // Set up a map where we feed it a User ID and get a list of groupmember records
        Map<ID, List<GroupMember>> groupMembersMapped_byUserId = new Map<ID,List<GroupMember>>();
        groupMembersMapped_byUserId.put(uID, groupmembers);

        
/*
        1st Method:
        I was sorting the data this way because I wanted to avoid too many SOQL queries, but the time added to perform this operation causes CSV non-bulk imports to fail because it takes more that 26 seconds to run.  


        // Temp variable to be used with map variable type for grouping
        List<GroupMember> forgroupMembersmapped_byUserId = new List<GroupMember>();

        // Sort each list of groups into a separate user id for easy reference
        ID uID = opportunities[0].ownerID;

        for (GroupMember gm : groupmembers){
            // Make sure that the userorgroupid we are talking about is a user
            
            if (gm.UserOrGroupID.getsObjectType() == Schema.User.sObjectType) {
                if (uID == gm.UserOrGroupId) {
                    // This user belongs to this group.  Add it to the grouping variable 
                    forgroupMembersmapped_byUserId.add(gm);		                
                }
            }
        }    

        if (forgroupMembersmapped_byUserId != null) {
            if (forgroupMembersmapped_byUserId.size() > 0 ) {
                // Gather all groups for this user id
                groupMembersMapped_byUserId.put(uID,forgroupMembersmapped_byUserId);
            }
        }

  */      

            
        
        if (groupMembersMapped_byUserId.size() <= 0) return; // user is not part of a group
        
        // Get all share records
        List<OpportunityShare> share_opportunities = [SELECT ID, OpportunityAccessLevel, UserOrGroupId, OpportunityID FROM OpportunityShare LIMIT :queryRowLimit];
        

        // Group each opportunity share by opportunity id
        Map<ID, List<OpportunityShare>> groupOpportunityShare_byOppID = new Map<ID, List<OpportunityShare>>();
        List<OpportunityShare> shares_groupby_OpID = new List<OpportunityShare>();
        List<OpportunityShare> shares_opp_toAdd = new List<OpportunityShare>();

        // We need to group these manually.  A SOQL query like this [SELECT ID, OpportunityAccessLevel, UserOrGroupId, OpportunityID FROM OpportunityShare WHERE opportunityid=:ID LIMIT :queryRowLimit], but we only have 100 SOQL queries available, meaning that over 100 opportunities will fail for syncronous calls.  Asychronous calls allow 200, but we cannot pass object list into future methods.
        
        if (share_opportunities.size() > 0) {
            system.debug('are we looping here');
            // Group all shares by opportunity id
            for (Opportunity o : opportunities) {
                for (OpportunityShare share_opportunity : share_opportunities) {
                    // We share opportunities through groups.  Make sure that we have a group id for UserOrGroupID
                    
                    if ((share_opportunity.OpportunityId == o.id) && (share_opportunity.UserOrGroupID.getsObjectType() != Schema.User.sObjectType)) {
                        shares_groupby_OpID.add(share_opportunity);
                    }
                    if (shares_groupby_OpID.size()>0) { 
                        // Gather all opportunity shares for this opportunity id
                        groupOpportunityShare_byOppID.put(o.id, shares_groupby_OpID);
                    }
                }
            }		
        }

        // All groupmembers are grouped by User ID and all Opportunity Shares are grouped by Opportunity ID
        // We want to compare the groupId of the groupmember to the UserOrGroupId of the Opportunityshare to determine if the 
        // Opportunity is in the group
        List<groupmember> groupMembersFromMap = new List<groupmember>();
        List<opportunityShare> sharedOpps = new List<opportunityShare>();
        List<ID> groupIds = new List<ID>();
        List<ID> groupOrUserIDs = new List<ID>();


        if (groupOpportunityShare_byOppID.size() > 0) {
            // We have opportunities that are shared in groups
            for (opportunity o : opportunities) {
                groupMembersFromMap = groupMembersMapped_byUserId.get(o.OwnerId);
                for (groupMember gmm : groupMembersFromMap) {
                    // Gather all groupmember Id for this user
                    ID agroupID = gmm.GroupId;
                    groupIds.add(agroupID);
                }
        		sharedOpps = groupOpportunityShare_byOppID.get(o.id); ///***
                for (OpportunityShare so : sharedOpps) {
                    ID groupOrUserID = so.UserOrGroupID;
                    groupOrUserIds.add(groupOrUserID);
                    if (!groupIds.contains(so.UserOrGroupID)) {
                        OpportunityShare shareopp = new OpportunityShare(UserOrGroupId = so.UserOrGroupID, OpportunityID=O.id, OpportunityAccessLevel='read');
                    	shares_opp_toAdd.add(shareopp);
                	}
                }
            }
        } // if(groupOpportunityShare_byOppID
        else {
            // We don't have any opportunity share records, but we do have users that a apart of a group
            for (ID userID : groupMembersMapped_byUserId.keyset()) {
                for (GroupMember gm : groupMembersMapped_byUserId.get(userID)) {
                    for (Opportunity o : opportunities) {
                        OpportunityShare oshare = new OpportunityShare(UserOrGroupId = gm.GroupId, OpportunityId=o.id, OpportunityAccessLevel='Read');
                        shares_opp_toAdd.add(oshare);
                    }
                }
            }
        }
        
        if (shares_opp_toAdd.size() > 0) {
            try {
                insert shares_opp_toAdd;
            } catch (Exception e) {
                system.debug(e);
            }
        }
        // find the groups the user is associated with 
        // Determine access Level - for right now read only
        // share the opportunity with the group if it is not there
        // all removing of sharing is handled by Salesforce automatically
        
        
    }
}