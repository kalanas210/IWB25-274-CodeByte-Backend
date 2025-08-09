import ballerina/http;

final string[] CORS_ALLOW_ORIGINS = ["http://localhost:5173", "http://localhost:3000"];
final string[] CORS_ALLOW_METHODS = ["GET", "POST", "PUT", "DELETE", "OPTIONS"];
final string[] CORS_ALLOW_HEADERS = ["authorization", "content-type", "x-user-id"];

public class CorsRequestInterceptor {
    *http:RequestInterceptor;

    public isolated function interceptRequest(http:RequestContext ctx, http:Request req)
            returns http:NextService|http:Response|error {
        string method = req.getMethod();
        if method.equalsIgnoreCase("OPTIONS") {
            http:Response res = new;
            setCorsHeaders(res);
            res.statusCode = 204; // No Content
            return res;
        }
        return ctx.next();
    }
}

public class CorsResponseInterceptor {
    *http:ResponseInterceptor;

    public isolated function interceptResponse(http:ResponseContext ctx, http:Request req, http:Response res)
            returns http:Response|error? {
        setCorsHeaders(res);
        return;
    }
}

function setCorsHeaders(http:Response res) {
    // For dev, reflect first allowed origin or wildcard when origin matches
    string? origin = res.getHeader("origin");
    string allowOrigin = CORS_ALLOW_ORIGINS[0];
    if origin is string {
        foreach string o in CORS_ALLOW_ORIGINS {
            if origin == o { allowOrigin = o; break; }
        }
    }
    res.setHeader("access-control-allow-origin", allowOrigin);
    res.setHeader("access-control-allow-methods", string:`${CORS_ALLOW_METHODS}`);
    res.setHeader("access-control-allow-headers", string:`${CORS_ALLOW_HEADERS}`);
    res.setHeader("access-control-allow-credentials", "true");
}


