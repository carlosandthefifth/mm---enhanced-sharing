trigger opportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
	if (trigger.isAfter) {
        if (trigger.isInsert) {
            customPublicGroupSharingHandler.onInsert(trigger.new,'Opportunity');
        }
        if (trigger.isUpdate) {
            customPublicGroupSharingHandler.onUpdate(trigger.new,'Opportunity');
        }
    }
}