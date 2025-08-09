import ballerina/http;

service class UsersService {
    *http:Service;

    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function get profile(http:Request req) returns http:Response|error {
        // In production, extract user ID from JWT claims. For scaffolding, read `x-user-id` header.
        string|() uidHeader = req.getHeader("x-user-id");
        if uidHeader is () {
            return error("Missing x-user-id header (scaffolding mode)", "MISSING_USER", 400);
        }
        int userId = check int:fromString(uidHeader);
        User? u = check getUserById(userId);
        if u is () {
            return error("User not found", "NOT_FOUND", 404);
        }
        return success({ user: u });
    }

    resource function put profile(@http:Payload json payload, http:Request req) returns http:Response|error {
        // Placeholder: implement update query
        return success({ updated: true }, "Profile updated (scaffold)");
    }

    function getInterceptors() returns http:RequestInterceptor[] {
        return [self.interceptor];
    }
}


