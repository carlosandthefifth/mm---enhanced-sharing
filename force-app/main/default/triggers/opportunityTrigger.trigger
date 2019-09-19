trigger opportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
	if (trigger.isAfter) {
        if (trigger.isInsert) {
            enhancedOpportunitySharing.calcOpportunityShareInsert(trigger.new);
        }
        if (trigger.isUpdate) {
            enhancedOpportunitySharing.calcOpportunityShareUpdate(trigger.new);
        }
    }
}