import ballerina/test;
import ballerina/http;
import ballerinax/covid19;
import ballerinax/worldbank;

configurable string covid19casesURL = "http://localhost:9090";
http:Client covid19casesClient = check new (covid19casesURL);

@test:BeforeSuite
function beforeSuit() {
    covid19Client = test:mock(covid19:Client);
    worldBankClient = test:mock(worldbank:Client);
}

@test:Config {}
public function test_NormalCase() {

    covid19:CovidCountry mockCovidCases = {
        cases : 43000
    };
    test:prepare(covid19Client).when("getStatusByCountry").thenReturn(mockCovidCases);

    worldbank:CountryPopulation[] mockPopulation = [{
        value : 5000000
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(mockPopulation);

    http:Response|http:ClientError response = covid19casesClient->get("/getCasesPerMillion/normalCase");

    json expectedPayload = {"casesPerMillion":8600};
    
    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload);
    } else {
        test:assertFail();
    }
}

@test:Config {
    dependsOn: [test_NormalCase]
}
public function test_lowPopulation() {

    worldbank:CountryPopulation[] lowPopulation = [{
        value : 10000
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").withArguments("lowPopulation").thenReturn(lowPopulation);

    http:Response|http:ClientError response = covid19casesClient->get("/getCasesPerMillion/lowPopulation");

    json expectedPayload = { "message":"Population less that a million", "cases":43000 };
    
    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload);
    } else {
        test:assertFail();
    }
}

@test:Config {
    dependsOn: [test_lowPopulation]
}
public function test_NoCovidCases() {

    covid19:CovidCountry mockCovidCases = {
        cases : 0
    };
    test:prepare(covid19Client).when("getStatusByCountry").thenReturn(mockCovidCases);

    worldbank:CountryPopulation[] mockPopulation = [{
        value : 10
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(mockPopulation);

    http:Response|http:ClientError response = covid19casesClient->get("/getCasesPerMillion/noCovidCases");

    json expectedPayload = { "message":"No covid cases registered for given country"};
    
    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload);
    } else {
        test:assertFail();
    }
}
