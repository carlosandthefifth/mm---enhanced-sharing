Sharing Rules Enhancement

Description:
Client needs a way to extend sharing rule limits.  Currently the limit is 300 rules with up to 50 criteria based rules, if available for the object.

Currently groups have 3-4 users and client is looking to have up to 3000+ users which would mean that we would need 750+ rules for each group

When a record is created, a share record is automatically create for the owner by Salesforce.  In order to share a record with a group, we need to add it to the share object for that record.  When we add the share details to the group for the record, Salesforce automatically creates the share record for any other group that the record owner is a member of.  This means if the record owner is a member of group1, group2 and group3 and we create a share record for group1, share records for group2 and group3 are automatically created.  This is significant because if a group member leaves the group, Salesforce does not recognize it and the records would still be shared with the group.  In order to make this like Salesforce sharing rules, we need to build our own methods for detecting those record shares and deleting them.

If the owner ID is changed on a record, the shares that connected the record to that group are automatically deleted.


Requirements:

•	Accounts object must be private.  If not, the record share will not be available, and the installation will fail 
    o	To do: detect share settings 

In order to make this work like standard Salesforce:

Implementation:

Obstacles: 
Group members that leave the group do not have triggers associated with them.  The change is on the groupmember object.  This means that if they leave the group, their records are still shared with that group.
	
Solution: 
Build our interface that handles group creation, membership and access level.  We will build off of Salesforce's existing platform.  There is a potential impact that if a user goes to Setup | Public groups and moves a member or changes the group name, the share records will stayed shared and will require manual intervention to remove the share.  Only user with profiles or permission sets that include the Manage Users permission have the ability to create public groups.  

Testing:

Additional Information:
TRIGGER IMPACT ON PERFORMANCE
A. Environment has 100 accounts.
B. We are inserting 20500 opportunities
C. Each account has 205 opportunities 

WITH TRIGGER DISABLED:
non-bulk batch 200
1.  20500 successful records 

bulk batch 2000
2.  11100 successful and 9400 errors Row lock errors

Bulk batch serial enabled 
3.   20500 all records inserted successfully


WITH TRIGGER ENABLED
non-bulk batch 200
1.  20500 successful inserts

bulk batch 2000
2.  13500 inserted successfully 7000 unsuccessful row lock

bulk batch 2000 serial enabled
3.  20500 all records insert successfully 

Successful inserts take about 3.5 minutes which means that it should take less time for a production environment.

Remember:
Add help page with instructions and video# mm---enhanced-sharing
