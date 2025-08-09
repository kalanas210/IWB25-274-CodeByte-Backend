import ballerina/http;

configurable boolean AUTH_DISABLE = true;

final string BEARER_PREFIX = "Bearer ";

public class AuthInterceptor {
    *http:RequestInterceptor;

    public isolated function interceptRequest(http:RequestContext ctx, http:Request req)
            returns http:NextService|http:Response|error {
        if AUTH_DISABLE {
            return ctx.next();
        }

        string? authz = req.getHeader("authorization");
        if authz is () || !authz.startsWith(BEARER_PREFIX) {
            return unauthorized("Missing or invalid Authorization header");
        }

        string token = authz.substring(BEARER_PREFIX.length());
        if token.trim().length() == 0 {
            return unauthorized("Empty bearer token");
        }

        // In production, validate the JWT signature, issuer, audience and expiry here.
        // This scaffold accepts any non-empty token when AUTH_DISABLE is false.
        return ctx.next();
    }
}

function unauthorized(string message) returns http:Response {
    http:Response res = new;
    res.statusCode = 401;
    json body = {
        success: false,
        error: { message, code: "UNAUTHORIZED" }
    };
    res.setJsonPayload(body);
    return res;
}


