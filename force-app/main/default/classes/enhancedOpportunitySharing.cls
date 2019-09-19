/*
    PROGRAMMER: Daniel Gustafson

	This is the first draft of an opportunity share class that allows for sharing of more than 300 groups.  There does not seem to be a physical
	cap on the sharing limit when doing this through Apex.

	This will be invoked through the opportunity trigger
 */
public without sharing class enhancedOpportunitySharing {
    

    public static void calcOpportunityShareInsert(List<Opportunity> opportunities) {
        /*
            Handles record group sharing
        */

        if (opportunities.size() <= 0) return; // nothing to see here

        integer DMLLimit = Limits.getLimitDMLRows();  // total DML that can be processed in a single transaction

        // Aggregate all owner ids in the list of opportunities that we have
        List<ID> OwnerIDs = new List<ID>();
        for (Opportunity o : opportunities) OwnerIDs.add(o.OwnerID);

        // Grab all group member records that apply to the owners (user id) of these records
        try {
            List<groupMember> gps = [select groupId, UserOrGroupID FROM GroupMember WHERE UserOrGroupID IN :OwnerIDs LIMIT :DMLLimit];

            List<OpportunityShare> share_records = new List<OpportunityShare>();

            for (groupmember g : gps) {
                for (opportunity o : opportunities) {
                    if (g.UserOrGroupId == o.ownerID)  {
                        OpportunityShare share_record = new OpportunityShare(OpportunityId=o.id, UserOrGroupID=g.groupID, OpportunityAccessLevel='read');
                        share_records.add(share_record);
                    }
                }
            }
            insert share_records;
            
        } catch (Exception e) {
            system.debug('enhancedOpportunitySharing class - calcOpportunityShareInsert method - adding to share records ' + e);
        }

    }

   public static void calcOpportunityShareUpdate(List<Opportunity> new_opportunities) {

        calcOpportunityShareInsert(new_opportunities);
   }
}