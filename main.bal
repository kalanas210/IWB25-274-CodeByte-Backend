import ballerina/http;
import ballerina/log;
import ballerina/time;

configurable int PORT = 9090;

listener http:Listener httpListener = new (PORT, config = {
    requestInterceptors: [new CorsRequestInterceptor()],
    responseInterceptors: [new CorsResponseInterceptor()]
});

// Health endpoint
service / on httpListener {
    resource function get health() returns json {
        return {
            success: true,
            message: "Socyads Ballerina API is running",
            timestamp: time:currentTime().toString()
        };
    }
}

// Auth service (public)
// See: auth_service.bal
service /api/auth on httpListener = new AuthService();

// Protected services with JWT interceptor
// See: auth_middleware.bal
service /api/users on httpListener = new UsersService(new AuthInterceptor());
service /api/gigs on httpListener = new GigService(new AuthInterceptor());
service /api/orders on httpListener = new BookingService(new AuthInterceptor());
service /api/escrow on httpListener = new EscrowService(new AuthInterceptor());
service /api/reviews on httpListener = new ReviewService(new AuthInterceptor());
service /api/admin on httpListener = new AdminService(new AuthInterceptor());
service /api/ai on httpListener = new AiService();


