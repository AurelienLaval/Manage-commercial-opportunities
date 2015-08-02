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
private class VFC01_OpportunitiesByCommercial_TEST {

	static Profile aProfile;
	static User anUser;
	static List<Commercial_objectif__c> commercialsObjectifsList;
	static List<Opportunity> opportunityList;
	static String stageName = 'Prospecting';
	static String yearLabel = 'selectedYear';
	static String monthLabel = 'selectedMonth';
	static Decimal amount1 = 100;
	static Decimal amount2 = 400;
	static Decimal amount3 = 200;
	static Decimal objectif1 = 1000;
	static Decimal objectif2 = 1025;
	static Decimal objectif3 = 7500;
	static Date todayDate = Date.today();
	static map<Integer, String> monthMap = VFC01_OpportunitiesByCommercial.monthMap;

	static void init(){
		
		/** Profile **/
			aProfile = [
				SELECT Id
				FROM Profile
				WHERE Name='Standard User'
			]; 
      
		/** User **/
			anUser = new User(
				Alias = 'standt',
				Email='standarduser@testorg.com', 
      			EmailEncodingKey='UTF-8',
      			LastName='Testing',
      			LanguageLocaleKey='en_US', 
		        LocaleSidKey='en_US',
		        ProfileId = aProfile.Id, 
		        TimeZoneSidKey='America/Los_Angeles',
		        UserName='testUser@testTrailhead.com'
      		);
      		
      		insert anUser;
		
		/** Commercials objectifs **/
			commercialsObjectifsList = new List<Commercial_objectif__c>();
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month()),
				Objectif__c = objectif1,
				User__c = anUser.Id
			));
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month() + 2),
				Objectif__c = objectif2,
				User__c = anUser.Id
			));
			commercialsObjectifsList.add(new Commercial_objectif__c(
				Year__c = String.valueOf(todayDate.year()),
				Month__c = monthMap.get(todayDate.month() + 3),
				Objectif__c = objectif3,
				User__c = anUser.Id
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
			
			insert opportunityList;
	}

	/**  **/
    static testMethod void allTest() {
        init();
        
        Test.startTest();
        
    	System.runAs(anUser) {
    		//Use the PageReference Apex class to instantiate a page
	        PageReference pageRef = Page.VF01_OpportunitiesByCommercial;
	        
	        Test.setCurrentPage(pageRef);
	        
	        VFC01_OpportunitiesByCommercial theController = new VFC01_OpportunitiesByCommercial();
	        
	        ApexPages.currentPage().getParameters().put(yearLabel, String.valueOf(todayDate.addYears(1).year()));
	        ApexPages.currentPage().getParameters().put(monthLabel, monthMap.get(todayDate.month()));
	        
	        // Refresh data depending of the month and the year selected
	        theController.refreshOpportunities();
	        
	        // Update data
	        theController.updateData();	
	        
	        // For the code cover
	        theController.displayErrorMessage('Error !');
	        theController.displaySuccessMessage('Success !');
    	}
        
        Test.stopTest();
    }
}