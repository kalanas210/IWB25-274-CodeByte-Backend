import ballerina/http;

type CreateGigPayload record {|
    string title;
    string description;
    decimal price;
    string category;
|};

service class GigService {
    *http:Service;
    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function get .(string? q, string? category, decimal? minPrice, decimal? maxPrice, string? sortBy, string? sortOrder) returns http:Response|error {
        Gig[] gigs = check listGigs(q, category, minPrice, maxPrice, sortBy, sortOrder);
        return success({ items: gigs });
    }

    resource function post .(@http:Payload CreateGigPayload payload, http:Request req) returns http:Response|error {
        string|() uidHeader = req.getHeader("x-user-id");
        if uidHeader is () { return error("Missing x-user-id header", "MISSING_USER", 400); }
        int sellerId = check int:fromString(uidHeader);
        Gig g = check createGig(sellerId, payload.title, payload.description, payload.price, payload.category);
        return success({ gig: g }, "Gig created");
    }

    resource function put [int id](@http:Payload CreateGigPayload payload, http:Request req) returns http:Response|error {
        string|() uidHeader = req.getHeader("x-user-id");
        if uidHeader is () { return error("Missing x-user-id header", "MISSING_USER", 400); }
        int sellerId = check int:fromString(uidHeader);
        Gig g = check updateGig(id, sellerId, payload.title, payload.description, payload.price, payload.category);
        return success({ gig: g }, "Gig updated");
    }

    resource function delete [int id](http:Request req) returns http:Response|error {
        string|() uidHeader = req.getHeader("x-user-id");
        if uidHeader is () { return error("Missing x-user-id header", "MISSING_USER", 400); }
        int sellerId = check int:fromString(uidHeader);
        boolean ok = check deleteGig(id, sellerId);
        if !ok { return error("Gig not found or not owned by user", "NOT_FOUND", 404); }
        return success({ deleted: true }, "Gig deleted");
    }

    function getInterceptors() returns http:RequestInterceptor[] { return [self.interceptor]; }
}


