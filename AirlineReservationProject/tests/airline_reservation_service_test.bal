import ballerina/test;
import ballerina/http;

// HTTP Client
http:Client clientEP = check new ("http://localhost:9091/airline");

@test:Config {}
public function equalsIgnoreCaseTest() {

    string string1 = "Foo";
    string string2 = "foo";
    test:assertTrue(equalIgnoreCase(string1, string2));

    string string3 = "bar";
    test:assertFalse(equalIgnoreCase(string1, string3));
}

@test:Config {}
public function reserveTicketTest() {

    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"Business"
    };

    // Define expected payload
    json expectedPayload = {
        "Status":"Success"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.message());
    }
}

@test:Config{}
public function incompletePayloadTest() {
    
    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "DepartureDate":"13-04-2018",
        "Preference":"Business"
    };

    // Define expected payload
    json expectedPayload = {
        "Message":"Internal Server Error - Error while processing request parameters"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.message());
    }
}

@test:Config{}
public function endpointErrorTest() {
    
    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"First"
    };

    // Define expected payload
    json expectedPayload = {
        "Status":"Failed"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.message());
    }
}
