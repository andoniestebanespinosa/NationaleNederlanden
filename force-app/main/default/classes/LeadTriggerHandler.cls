public without sharing class LeadTriggerHandler implements ITrigger {

    Map<String,Country_Layer__c> mapCountryLayers = new Map<String,Country_Layer__c>();
    
    public void bulkBefore() {
		mapCountryLayers = LeadGateway.compareCountryData(trigger.new);
    }

    public void bulkAfter() {
        
    }

    public void beforeInsert(SObject so) {
        Lead newLead = (Lead) so;
        if (newLead.Country_Code__c != null && mapCountryLayers.containsKey(newLead.Country_Code__c)) LeadGateway.updateCountryData(mapCountryLayers.get(newLead.Country_Code__c));
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        Lead oldLead = (Lead) oldso;       
        Lead newLead = (Lead) so;
        if (newLead.Country_Code__c != null && mapCountryLayers.containsKey(newLead.Country_Code__c) && oldLead.Country_Code__c != newLead.country_code__c) LeadGateway.updateCountryData(mapCountryLayers.get(newLead.Country_Code__c));
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
 
    }

    public void afterUpdate(SObject oldSo, SObject so) {

    }

    public void afterDelete(SObject so) {
    }

    public void andFinally() {

    }
    
}