import ballerina/http;

// Service endpoint
listener http:Listener airlineEP = new (9091);

// Available flight classes
final string ECONOMY = "Economy";
final string BUSINESS = "Business";
final string FIRST = "First";

service /airline on airlineEP {

    resource function post reserve(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};
        var payload = request.getJsonPayload();
        // Try parsing the JSON payload from the request
        if (payload is json) {
            // Valid JSON payload
            reqPayload = payload;
        } else {
            // NOT a valid JSON payload
            response.statusCode = 400;
            response.setJsonPayload({"Message": "Invalid payload - Not a valid JSON payload"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        json|error name = reqPayload.Name;
        json|error arrivalDate = reqPayload.ArrivalDate;
        json|error departDate = reqPayload.DepartureDate;
        json|error preferredClass = reqPayload.Preference;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (name is error || arrivalDate is error || departDate is error || preferredClass is error) {
            response.statusCode = 500;
            response.setJsonPayload({"Message": "Internal Server Error - Error while processing request parameters"});
            var result = caller->respond(response);
            handleError(result);
            return;
        } else {
             // If request is for an available flight class, send a reservation successful status
            string preferredClassStr = preferredClass.toString();
            if (equalIgnoreCase(preferredClassStr, ECONOMY) || equalIgnoreCase(preferredClassStr, BUSINESS)) {
                response.setJsonPayload({"Status": "Success"});
            } else {
                // If request is not for an available flight class, send a reservation failure status
                response.setJsonPayload({"Status": "Failed"});
            }

            // Send the response
            var result = caller->respond(response);
            handleError(result);

        }
    }
}
