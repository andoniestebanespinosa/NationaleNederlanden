public class InsertCountriesQueueable implements Queueable {

    private List<APIRestInput.CountryData> countries;

    public InsertCountriesQueueable(List<APIRestInput.CountryData> countries) {
        this.countries = countries;
    }

    public void execute(QueueableContext context) {
        List<Country_Layer__c> countriesToInsert = new List<Country_Layer__c>();

        for (APIRestInput.CountryData cd : countries) {
            system.debug('@regionalblocks ' + cd.regionalBlocs);
            //Regional blocks are not found in WS
            String blocs = cd.regionalBlocs != null && !cd.regionalBlocs.isEmpty()
                ? String.join(cd.regionalBlocs, ',') : '';

            Country_Layer__c country = new Country_Layer__c(
                Name = cd.name,
                Alpha2Code__c = cd.alpha2Code,
                Alpha3Code__c = cd.alpha3Code,
                Capital__c = cd.capital,
                Region__c = cd.region,
                RegionalBlocs__c = blocs,
                Last_Updated_From_API__c = System.now()
            );

            countriesToInsert.add(country);
        }

        if (!countriesToInsert.isEmpty()) {
            insert countriesToInsert;
        }
    }
}