bimport ballerina/http;

type CreateOrderPayload record {|
    int gigId;
    string requirements;
|};

service class BookingService {
    *http:Service;
    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function post .(@http:Payload CreateOrderPayload payload, http:Request req) returns http:Response|error {
        // Placeholder: write order into DB and return order id
        return success({ orderId: 1, status: "PENDING", gigId: payload.gigId }, "Order created (scaffold)");
    }

    resource function get .() returns http:Response|error {
        // Placeholder list
        return success({ items: [] });
    }

    function getInterceptors() returns http:RequestInterceptor[] { return [self.interceptor]; }
}


