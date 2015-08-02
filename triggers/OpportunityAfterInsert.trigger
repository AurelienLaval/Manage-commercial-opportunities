trigger OpportunityAfterInsert on Opportunity (after insert) {

	List<Opportunity> opportunitiesToExecute = new List<Opportunity>();
	
	for(Opportunity anOpportunity : Trigger.new){
		
		if(anOpportunity.Amount != NULL){
			opportunitiesToExecute.add(anOpportunity);
		}
	}
	
	if(opportunitiesToExecute.size() > 0){
		AP01_UpdateObjectifInProgress.updateObjectifInProgress(opportunitiesToExecute);
	}
}