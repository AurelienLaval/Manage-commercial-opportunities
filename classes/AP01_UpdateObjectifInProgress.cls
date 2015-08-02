public with sharing class AP01_UpdateObjectifInProgress{

	/** Set the objectif of the commercials **/
	public static void updateObjectifInProgress(List<Opportunity> theOpportunityList){
        Set<String> commercialObjectifIdSet = new Set<String>();
        
        for(Opportunity anOpportunity : theOpportunityList){
        
            if(!commercialObjectifIdSet.contains(anOpportunity.Commercial_objectif__c)){
                commercialObjectifIdSet.add(anOpportunity.Commercial_objectif__c);
            }
        }
        
        List<Commercial_objectif__c> commercialsObjectifsList = [
        	SELECT Id, Year__c, Month__c, Objectif__c, Objectif_in_progress__c, User__c, (SELECT Id, Amount FROM Opportunities__r WHERE Amount != NULL)
        	FROM Commercial_objectif__c
        	WHERE Id IN :commercialObjectifIdSet
        ];
        
        if(commercialsObjectifsList.size() > 0){
        	
	        for(Commercial_objectif__c aCommercialObjectif : commercialsObjectifsList){
	        	
	        	aCommercialObjectif.Objectif_in_progress__c = 0;
	        	
	        	for(Opportunity anOpportunity : aCommercialObjectif.Opportunities__r){
        
	        		// Set the commercial objectif
	                aCommercialObjectif.Objectif_in_progress__c += anOpportunity.Amount;
		        }
	        }
	        
	        update commercialsObjectifsList;
        }	
    }
}