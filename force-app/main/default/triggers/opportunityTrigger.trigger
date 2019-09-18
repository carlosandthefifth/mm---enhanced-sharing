trigger opportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
	if (trigger.isAfter) {
        if (trigger.isInsert) {
            enhancedOpportunitySharing.updateOpportunityShare(trigger.new);
        }
        if (trigger.isUpdate) {
            enhancedOpportunitySharing.updateOpportunityShare(trigger.new);
        }
    }
}