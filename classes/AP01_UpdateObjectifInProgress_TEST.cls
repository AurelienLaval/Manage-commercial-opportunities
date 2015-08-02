/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AP01_UpdateObjectifInProgress_TEST {

	static List<Commercial_objectif__c> commercialsObjectifsList;
	static List<Opportunity> opportunityList;
	static String stageName = 'Prospecting';
	static Decimal amount1 = 100;
	static Decimal amount2 = 400;
	static Decimal amount3 = 200;
	static Decimal objectif1 = 1000;
	static Decimal objectif2 = 1025;
	static Decimal objectif3 = 7500;
	static Date todayDate = Date.today();
	static map<Integer, String> monthMap = new map<Integer, String>{
		1 => 'January',
		2 => 'February',
		3 => 'March',
		4 => 'April',
		5 => 'May',
		6 => 'June',
		7 => 'July',
		8 => 'August',
		9 => 'September',
		10 => 'October',
		11 => 'November',
		12 => 'December'
	};

	static void init(){
		/** Commercials objectifs **/
			commercialsObjectifsList = new List<Commercial_objectif__c>();
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month()),
				Objectif__c = objectif1
			));
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month() + 2),
				Objectif__c = objectif2
			));
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month() + 3),
				Objectif__c = objectif3
			));
			
			insert commercialsObjectifsList;
			
		/** Opportunities **/
			opportunityList = new List<Opportunity>();
			opportunityList.add(new Opportunity(
				Name = 'Test opportunity 1',
				CloseDate = Date.newInstance(todayDate.year(), todayDate.month(), 1),
				Amount = amount1,
				Commercial_objectif__c = commercialsObjectifsList[0].Id,
				StageName = stageName
			));
			opportunityList.add(new Opportunity(
				Name = 'Test opportunity 2',
				CloseDate = Date.newInstance(todayDate.year(), todayDate.month(), 1),
				Amount = amount1,
				Commercial_objectif__c = commercialsObjectifsList[1].Id,
				StageName = stageName
			));
			opportunityList.add(new Opportunity(
				Name = 'Test opportunity 3',
				CloseDate = Date.newInstance(todayDate.year(), todayDate.month(), 1),
				Amount = amount1,
				Commercial_objectif__c = commercialsObjectifsList[2].Id,
				StageName = stageName
			));
	}

	/** Test creation **/
    static testMethod void testCreate() {
        init();
        
        Test.startTest();
        
        insert opportunityList;
        
        Test.stopTest();
        
        Commercial_objectif__c theCommercialObjectif = [
        	SELECT Id, Objectif_in_progress__c
        	FROM Commercial_objectif__c
        	WHERE Id = :commercialsObjectifsList[0].Id
        ];
        
        System.assertEquals(amount1, theCommercialObjectif.Objectif_in_progress__c);
    }
    
    /** Test updating **/
    static testMethod void testUpdate() {
        init();
        
        insert opportunityList;
        
        Test.startTest();
        
        opportunityList[0].Amount = amount3;
        
        opportunityList.add(new Opportunity(
        	Name = 'Test opportunity 2',
        	CloseDate = Date.newInstance(todayDate.year(), todayDate.month(), 15),
			Amount = amount2,
			Commercial_objectif__c = commercialsObjectifsList[0].Id,
			StageName = stageName
        ));
        
        upsert opportunityList;
        
        Test.stopTest();
        
        Commercial_objectif__c theCommercialObjectif = [
        	SELECT Id, Objectif_in_progress__c
        	FROM Commercial_objectif__c
        	WHERE Id = :commercialsObjectifsList[0].Id
        ];
        
        System.assertEquals((amount2 + amount3), theCommercialObjectif.Objectif_in_progress__c);
    }
}