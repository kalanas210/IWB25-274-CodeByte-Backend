import ballerina/http;

public function respondJson(json body, int statusCode = 200) returns http:Response {
    http:Response res = new;
    res.statusCode = statusCode;
    res.setJsonPayload(body);
    return res;
}

public function success(anydata data = (), string message = "OK") returns http:Response {
    json body = { success: true, message, data };
    return respondJson(body, 200);
}

public function error(string message, string code = "ERROR", int status = 400, anydata details = ()) returns http:Response {
    json body = { success: false, error: { message, code, details } };
    return respondJson(body, status);
}


