import ballerina/test;
import ballerinax/covid19;
import ballerinax/worldbank;
import ballerina/http;

@test:BeforeSuite
function beforeSuit() {
    covid19Client = test:mock(covid19:Client);
    worldBankClient = test:mock(worldbank:Client);
}

@test:Config {}
public function test_NormalCase() {

    covid19:CovidCountry mockCovidCases = {cases: 43000};
    test:prepare(covid19Client).when("getStatusByCountry").thenReturn(mockCovidCases);

    worldbank:CountryPopulation[] mockPopulation = [{value: 5000000}];
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(mockPopulation);

    test:assertEquals(getCasesPerMillion("XYZ"), "8600");
}

@test:Config {
    dependsOn: [test_NormalCase]
}
public function test_lowPopulation() {
    worldbank:CountryPopulation[] lowPopulation = [{
        value : 10000
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").withArguments("lowPopulation").thenReturn(lowPopulation);
    test:assertEquals(getCasesPerMillion("lowPopulation"), "43000");
}

@test:Config {}
public function test_NoCovidCases() {
    covid19:CovidCountry mockCovidCases = {
        cases : 0
    };
    test:prepare(covid19Client).when("getStatusByCountry").thenReturn(mockCovidCases);
    worldbank:CountryPopulation[] mockPopulation = [{
        value : 10
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(mockPopulation);
    test:assertEquals(getCasesPerMillion("ABC"), "0");
}

@test:Config {}
public function test_CountryDoesntExist() {
    http:ClientError err_NoSuchCountry = error http:ClientError("Country provided doesnt exist");
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(err_NoSuchCountry);
    
    string err = getCasesPerMillion("Atlantis");
    test:assertEquals(err, "Error retrieving Population data : Country provided doesnt exist");
}

@test:Config {}
public function test_NoStatisticsAvaliable() {
    http:ClientError err_NoStatisticsAvaliable = error http:ClientError("No Covid19 statistics available");
    test:prepare(covid19Client).when("getStatusByCountry").thenReturn(err_NoStatisticsAvaliable);

    worldbank:CountryPopulation[] mockPopulation = [{
        value : 10
    }];
    test:prepare(worldBankClient).when("getPopulationByCountry").thenReturn(mockPopulation);
    
    string err = getCasesPerMillion("Atlantis");
    test:assertEquals(err, "Error retrieving Covid19 data : No Covid19 statistics available");
}
