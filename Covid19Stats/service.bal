import ballerina/http;
import ballerinax/covid19;
import ballerinax/worldbank;

configurable int port = 9090;
configurable string hostEp = "localhost";

listener http:Listener covid19casesListener = new (port, config = {host : hostEp});
covid19:Client covid19Client = check new ();
worldbank:Client worldBankClient = check new ();

service / on covid19casesListener {

    resource function get getCasesPerMillion/[string country]() returns @http:Payload {mediaType: "application/json"} json|error {
        json response;

        int totalCases = <int> check getCases(country);

        if (totalCases != 0) {
            int population = check getPopulation(country);

            if (population < 1000000) {
                response = { "message" : "Population less that a million", "cases" : totalCases };
            } else {
                int totalCasesPerMillion = <int> (totalCases / (population/1000000));
                response = { casesPerMillion : totalCasesPerMillion};
            }
        } else {
            response = { message : "No covid cases registered for given country" };
        }
        return response;
    }

}

function getCases(string country) returns int|error {
    covid19:CovidCountry statusByCountry = check covid19Client->getStatusByCountry(country);
    return <int> statusByCountry?.cases;
}

function getPopulation(string country) returns int|error {
    worldbank:CountryPopulation[] populationByCountry = check worldBankClient->getPopulationByCountry(country);
    return <int> populationByCountry[0]?.value;
}
