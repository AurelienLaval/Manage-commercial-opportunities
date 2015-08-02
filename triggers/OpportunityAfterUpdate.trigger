trigger OpportunityAfterUpdate on Opportunity (after update) {

	List<Opportunity> opportunitiesToExecute = new List<Opportunity>();
	
	for(Opportunity anOpportunity : Trigger.new){
		
		if(anOpportunity.Amount != NULL){
			opportunitiesToExecute.add(anOpportunity);
		}
	}
	
	if(opportunitiesToExecute.size() > 0){
		System.debug('*** Des opportunités ! : ' + opportunitiesToExecute.size());
		
		AP01_UpdateObjectifInProgress.updateObjectifInProgress(opportunitiesToExecute);
	}
}