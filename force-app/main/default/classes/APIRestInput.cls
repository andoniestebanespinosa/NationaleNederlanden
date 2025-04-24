public class APIRestInput {
	//Inputs for country layer
    public class CountryData {
        public String name;
        public String alpha2Code;
        public String alpha3Code;
        public String capital;
        public String region;
        public List<RegionalBloc> regionalBlocs;
    }

    public class RegionalBloc {
        public String acronym;
    }
}