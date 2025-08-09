import ballerina/http;

type CreateReviewPayload record {|
    int targetUserId;
    int orderId;
    int rating;
    string comment?;
|};

service class ReviewService {
    *http:Service;
    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function post .(@http:Payload CreateReviewPayload payload) returns http:Response|error {
        // Placeholder: insert review into DB
        return success({ reviewId: 1 }, "Review created (scaffold)");
    }

    resource function get user([int userId]) returns http:Response|error {
        // Placeholder: list reviews for a user
        return success({ items: [] });
    }

    function getInterceptors() returns http:RequestInterceptor[] { return [self.interceptor]; }
}


