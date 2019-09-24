trigger accountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
	if (trigger.isAfter) {
        if (trigger.isInsert) {
            customPublicGroupSharingHandler.onInsert(trigger.new,'Account');
        }
        if (trigger.isUpdate) {
            customPublicGroupSharingHandler.onUpdate(trigger.new,'Account');
        }
    }
}