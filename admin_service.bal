import ballerina/http;

service class AdminService {
    *http:Service;
    private final http:RequestInterceptor interceptor;

    public function init(http:RequestInterceptor interceptor) {
        self.interceptor = interceptor;
    }

    resource function get dashboard() returns http:Response|error {
        // Placeholder: aggregate platform stats
        json stats = {
            users: 0,
            gigs: 0,
            orders: 0,
            revenue: 0
        };
        return success({ stats });
    }

    function getInterceptors() returns http:RequestInterceptor[] { return [self.interceptor]; }
}


