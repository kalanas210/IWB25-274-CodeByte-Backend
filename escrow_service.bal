import ballerina/http;
import ballerina/time;

type HoldPayload record {|
    int orderId;
    decimal amount;
|};

type ReleasePayload record {|
    int orderId;
|};

service class EscrowService {
    *http:Service;
    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function post hold(@http:Payload HoldPayload payload) returns http:Response|error {
        // Placeholder: persist escrow hold in DB transaction
        return success({ orderId: payload.orderId, status: "HELD", amount: payload.amount }, "Funds held in escrow (scaffold)");
    }

    resource function post release(@http:Payload ReleasePayload payload) returns http:Response|error {
        // Demonstrate async release using start
        _ = start releaseEscrowAsync(payload.orderId);
        return success({ orderId: payload.orderId, status: "RELEASING" }, "Escrow release initiated");
    }

    isolated function releaseEscrowAsync(int orderId) {
        // Simulate background processing delay
        time:sleep(2);
        // Placeholder: perform DB transaction to transfer funds and mark order as COMPLETED
    }

    function getInterceptors() returns http:RequestInterceptor[] { return [self.interceptor]; }
}


