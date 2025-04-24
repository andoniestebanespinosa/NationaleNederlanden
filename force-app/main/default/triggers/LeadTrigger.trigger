trigger LeadTrigger on Lead (before insert) {
	TriggerFactory.createAndExecuteHandler(LeadTriggerHandler.class);
}