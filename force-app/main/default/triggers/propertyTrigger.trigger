trigger propertyTrigger on Property__c (before insert, after insert, before update, after update, before delete, after delete) {
	if (trigger.isAfter) {
        if (trigger.isInsert) {
            customPublicGroupSharingHandler.onInsert(trigger.new,'Asset');
        }
        if (trigger.isUpdate) {
            customPublicGroupSharingHandler.onUpdate(trigger.new,'Asset');
        }
    }
}