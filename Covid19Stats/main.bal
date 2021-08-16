import ballerinax/covid19;
import ballerinax/worldbank;
import ballerina/io;
import ballerina/lang.value as Value;

covid19:Client covid19Client = check new ();
worldbank:Client worldBankClient = check new ();

public function main() {
    string country = io:readln("Enter country code : ");
    io:println(getCasesPerMillion(country));
}

# Get number of cases per million in the given country.
#
# + country - Country code
# + return - Return number of cases per million or an error message as a string
public function getCasesPerMillion(string country) returns string {

    // Get Population of country via worldBankClient
    worldbank:CountryPopulation[]|error populationByCountry = worldBankClient->getPopulationByCountry(country);

    if (populationByCountry is worldbank:CountryPopulation[]) {
        int population = <int>populationByCountry[0]?.value;

        // Get Covid19 statistics via covid19Client
        covid19:CovidCountry|error statusByCountry = covid19Client->getStatusByCountry(country);

        if (statusByCountry is covid19:CovidCountry) {
            int totalCases = <int>statusByCountry?.cases;
            if (population > 1000000) {
                return Value:toString(<int>(totalCases / (population / 1000000)));
            } else {
                return Value:toString(totalCases);
            }
        } else {
            return "Error retrieving Covid19 data : " + statusByCountry.message();
        }
    } else {
        return "Error retrieving Population data : " + populationByCountry.message();
    }
}
