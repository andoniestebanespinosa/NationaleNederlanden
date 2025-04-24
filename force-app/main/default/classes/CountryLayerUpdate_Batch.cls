global class CountryLayerUpdate_Batch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
       
        return Database.getQueryLocator([
            SELECT Id, Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c
            FROM Country_Layer__c
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Country_Layer__c> existingCountries) {

        Map<String, Country_Layer__c> existingMap = new Map<String, Country_Layer__c>();
        for (Country_Layer__c c : existingCountries) {
            existingMap.put(c.Alpha3Code__c, c);
        }

        APIRestOutput.output_Wrapper res = APIRestOutput.getCountryData();

        List<Country_Layer__c> countriesToUpdate = new List<Country_Layer__c>();

        for (ApiRestInput.CountryData apiCountry : res.body) {
            if (existingMap != null && existingMap.containskey(apiCountry.alpha3Code)) {
                Country_Layer__c local = existingMap.get(apiCountry.alpha3Code);

                // Generar string regional blocs
                String blocs = '';
                
                /*
                String blocs = '';
                if (apiCountry.regionalBlocs != null && !apiCountry.regionalBlocs.isEmpty()) {
                    List<String> acronyms = new List<String>();
                    for (CountryService.RegionalBloc rb : apiCountry.regionalBlocs) {
                        acronyms.add(rb.acronym);
                    }
                    blocs = String.join(acronyms, '');
                }*/

                // Comprobar si ha cambiado
                if (
                    local.Name != apiCountry.name ||
                    local.Alpha2Code__c != apiCountry.alpha2Code ||
                    local.Capital__c != apiCountry.capital ||
                    local.Region__c != apiCountry.region ||
                    local.RegionalBlocs__c != blocs
                ) {
                    local.Name = apiCountry.name;
                    local.Alpha2Code__c = apiCountry.alpha2Code;
                    local.Capital__c = apiCountry.capital;
                    local.Region__c = apiCountry.region;
                    local.RegionalBlocs__c = blocs;
                    local.Last_Updated_From_API__c = system.datetime.now();

                    countriesToUpdate.add(local);
                }
            }
        }

        if (!countriesToUpdate.isEmpty()) {
            update countriesToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
       //Add to log
    }
}