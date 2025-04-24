public class LeadGateway {

    
    public static map<String,Country_Layer__c> compareCountryData (List<Lead>triggerNew) {

        Set<String> alpha3Codes = new Set<String>();
        for (Lead l : triggerNew) {
            if (l.Country_Code__c != null) {
                alpha3Codes.add(l.Country_Code__c);
            }
        }
    
        if (alpha3Codes.isEmpty()) return null;
    
       
        Map<String, Country_Layer__c> countryMap = new Map<String, Country_Layer__c>(
            [SELECT Alpha3Code__c, Region__c, Capital__c, RegionalBlocs__c
             FROM Country_Layer__c
             WHERE Alpha3Code__c IN :alpha3Codes]
        );
        return countryMap;
    
    }
    
    public static void updateCountryData(Country_Layer__c cl) {
        //update lead fields
        //l.Region__c = cl.Region__c;
        //l.Capital__c = cl.Capital__c;
        //l.Regional_Blocs__c = cl.RegionalBloc__c;
    }
    
}