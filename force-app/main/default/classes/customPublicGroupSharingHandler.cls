/*
    PROGRAMMER: Daniel Gustafson

	This is the first draft of an opportunity share class that allows for sharing of more than 300 groups.  There does not seem to be a physical
	cap on the sharing limit when doing this through Apex.

	This will be invoked through the opportunity trigger
 */
public without sharing class customPublicGroupSharingHandler {
    
    private static void onInsertAccount(List<Account> accounts){
        if (accounts.size() <= 0) return; // nothing to see here

        integer DMLLimit = Limits.getLimitDMLRows();  // total DML that can be processed in a single transaction

        // Aggregate all owner ids in the list of accounts that we have
        List<ID> OwnerIDs = new List<ID>();
        for (account a : accounts) OwnerIDs.add(a.OwnerID);

        // Grab all group member records that apply to the owners (user id) of these records
        try {

            List<groupMember> gps = [select groupId, UserOrGroupID FROM GroupMember WHERE UserOrGroupID IN :OwnerIDs LIMIT :DMLLimit];
            
            List<accountshare> share_records = new List<accountshare>();

            for (groupmember g : gps) {
                for (account a : accounts) {
                    if (g.UserOrGroupId == a.ownerID)  {
                        accountshare share_record = new accountshare(accountId=a.id, UserOrGroupID=g.groupID, accountAccessLevel='read', OpportunityAccessLevel='none', ContactAccessLevel='none');
                        share_records.add(share_record);
                    }
                }
            }
            insert share_records;
            
        } catch (Exception e) {
            system.debug('enhancedaccountsharing class - calcaccountshareInsert method - adding to share records ' + e);
        }
        
    }

    private static void onInsertContact(List<Contact> contacts){
        if (contacts.size() <= 0) return; // nothing to see here

        integer DMLLimit = Limits.getLimitDMLRows();  // total DML that can be processed in a single transaction

        // Aggregate all owner ids in the list of contacts that we have
        List<ID> OwnerIDs = new List<ID>();
        for (contact c : contacts) OwnerIDs.add(c.OwnerID);

        // Grab all group member records that apply to the owners (user id) of these records
        try {

            List<groupMember> gps = [select groupId, UserOrGroupID FROM GroupMember WHERE UserOrGroupID IN :OwnerIDs LIMIT :DMLLimit];
            
            List<contactShare> share_records = new List<contactShare>();

            for (groupmember g : gps) {
                for (contact c : contacts) {
                    if (g.UserOrGroupId == c.ownerID)  {
                        contactShare share_record = new contactShare(contactId=c.id, UserOrGroupID=g.groupID, contactAccessLevel='read');
                        share_records.add(share_record);
                    }
                }
            }
            insert share_records;
            
        } catch (Exception e) {
            system.debug('enhancedcontactSharing class - calccontactShareInsert method - adding to share records ' + e);
        }
    
    }

    private static void onInsertOpportunity(List<Opportunity> opportunities){
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

    private static void onInsertProperty(List<Asset> properties){
        if (properties.size() <= 0) return; // nothing to see here

        integer DMLLimit = Limits.getLimitDMLRows();  // total DML that can be processed in a single transaction

        // Aggregate all owner ids in the list of properties that we have
        List<ID> OwnerIDs = new List<ID>();
        for (Asset p : properties) OwnerIDs.add(p.OwnerID);

        // Grab all group member records that apply to the owners (user id) of these records
        try {

            List<groupMember> gps = [select groupId, UserOrGroupID FROM GroupMember WHERE UserOrGroupID IN :OwnerIDs LIMIT :DMLLimit];
            
            List<AssetShare> share_records = new List<Assetshare>();

            for (groupmember g : gps) {
                for (Asset p : properties) {
                    if (g.UserOrGroupId == p.ownerID)  {
                        Assetshare share_record = new Assetshare(AssetId=p.id, UserOrGroupID=g.groupID, AssetAccessLevel='read');
                        share_records.add(share_record);
                    }
                }
            }
            insert share_records;
            
        } catch (Exception e) {
            system.debug('enhancedpropertiesharing class - calcproperty__cshareInsert method - adding to share records ' + e);
        }
    }

    public static void onInsert(List<SObject> objects, String objectTypeName) {
        /*
            Handles record group sharing
        */
        if (objectTypeName.toLowerCase() == 'account') {
            onInsertAccount((List<Account>)objects);
        }
        if (objectTypeName.toLowerCase() == 'contact') {
            onInsertContact((List<contact>)objects);
        }
        if (objectTypeName.toLowerCase() == 'opportunity') {
            onInsertOpportunity((List<Opportunity>)objects);
        }
        if (objectTypeName.toLowerCase() == 'Asset') {
            onInsertProperty((List<Asset>)objects);
        }

    }

   public static void onUpdate(List<SObject> objects, string ObjectTypeName) {

        onInsert(objects, ObjectTypeName);
   }
}