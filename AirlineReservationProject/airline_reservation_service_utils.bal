import ballerina/log;

function handleError(error? result) {
    if (result is error) {
        log:printError(result.message(), 'error = result);
    }
}

function equalIgnoreCase(string string1, string string2) returns boolean {
    return (string1.toLowerAscii() == string2.toLowerAscii());
}
