public with sharing class VFC01_OpportunitiesByCommercial {

    public Commercial_objectif__c theFakeCommercialObjectif{get; set;}
    public List<WrapperClass> wrapperList{get; set;}
    private List<User> commercialList;
    private List<Commercial_objectif__c> theObjectifList;
    private Date dateToday;
    public static map<Integer, String> monthMap = new map<Integer, String>{
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
    
    public VFC01_OpportunitiesByCommercial(){
        this.theFakeCommercialObjectif = new Commercial_objectif__c();
        
        this.dateToday = Date.today();
        
        this.setMonthAndYear();
                
        this.commercialList = this.getCommercialList();
                
        this.wrapperList = this.getOpportunitiesByCommercial(theFakeCommercialObjectif.Month__c, theFakeCommercialObjectif.Year__c, this.commercialList);
    }

    /** Get opportunities grouped by commercial **/
    public List<WrapperClass> getOpportunitiesByCommercial(String theSelectedMonth, String theSelectedYear, List<User> theCommercialList){
        List<WrapperClass> result = new List<WrapperClass>();
            
        try{   
            theObjectifList = [
                SELECT Id, User__c, Month__c, Year__c, Objectif__c, Percent_in_progress__c, Objectif_in_progress__c, Objectif_level__c, (SELECT Id, Name, CloseDate, Amount, Account.Id, Account.Name FROM Opportunities__r)
                FROM Commercial_objectif__c
                WHERE User__c IN :theCommercialList
                AND Year__c = :theSelectedYear
                AND Month__c = :theSelectedMonth
            ];
            
            map<Id, Commercial_objectif__c> objectifMap = this.setObjectifMap(theObjectifList);
            
            for(User anUser : theCommercialList){
                
                if(objectifMap.containsKey(anUser.Id)){
                    
                    Commercial_objectif__c anObjectif = objectifMap.get(anUser.Id);
                    
                    result.add(new WrapperClass(
                        anUser,
                        anObjectif.Opportunities__r,
                        anObjectif
                    ));
                }
            }
        }catch(Exception e){
            this.displayErrorMessage(e.getMessage());
        }
        
        return result;
    }
    
    /** Get commercials **/
    public List<User> getCommercialList(){
        return [
            SELECT Id, Name
            FROM User
        ];
    }
    
    /** Set the month and the year **/
    public void setMonthAndYear(){
        if(theFakeCommercialObjectif.Year__c == NULL || theFakeCommercialObjectif.Year__c.equals('')){
            theFakeCommercialObjectif.Year__c = String.valueOf(this.dateToday.year());
        }
        
        if(theFakeCommercialObjectif.Month__c == NULL || theFakeCommercialObjectif.Month__c.equals('')){
            theFakeCommercialObjectif.Month__c = VFC01_OpportunitiesByCommercial.monthMap.get(this.dateToday.month());
        }
    }
    
    /** Refreshing opportunities depending of the month and the year **/
    public PageReference refreshOpportunities(){
        try{
            // Récupére le mois et l'année des opportunités
            this.setMonthAndYear();
            
            // Récupère les objectifs des commerciaux ainsi que leurs opportunités
            this.wrapperList = this.getOpportunitiesByCommercial(theFakeCommercialObjectif.Month__c, theFakeCommercialObjectif.Year__c, this.commercialList);
        }catch(Exception e){
            this.displayErrorMessage(e.getMessage());
        }
        
        return NULL;
    }
    
    /** Update data **/
    public PageReference updateData(){
        try{
            update this.theObjectifList;
            
            this.refreshOpportunities();
        }catch(Exception e){
            this.displayErrorMessage(e.getMessage());
        }
        
        return NULL;
    }
    
    /** Create the commercials objectifs map grouped by commercial **/
    public map<Id, Commercial_objectif__c> setObjectifMap(List<Commercial_objectif__c> theObjectifList){
        map<Id, Commercial_objectif__c> result = new map<Id, Commercial_objectif__c>();
        
        for(Commercial_objectif__c anObjectif : theObjectifList){
            
            result.put(anObjectif.User__c, anObjectif);
        }
        
        return result;
    }
    
    public class WrapperClass{
    
        public User theUser{get; set;}
        public List<Opportunity> theOpportunityList{get; set;}
        public Commercial_objectif__c theObjectif{get; set;}
        
        public WrapperClass(User anUser, List<Opportunity> anOpportunityList, Commercial_objectif__c anObjectif){
            this.theUser = anUser;
            this.theOpportunityList = anOpportunityList;
            this.theObjectif = anObjectif;
        }
    }
    
    /** Display an error message on the Visualforce page **/
    public void displayErrorMessage(String theErrorMessage){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,theErrorMessage));
    }
}