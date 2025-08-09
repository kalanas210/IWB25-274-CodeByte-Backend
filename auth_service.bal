import ballerina/http;
import ballerina/log;
import ballerina/crypto;

// Config for simplistic token issuance (development)
configurable string JWT_SECRET = "change-me-in-prod";
configurable string JWT_ISSUER = "socyads";
configurable string JWT_AUDIENCE = "socyads_frontend";

type RegisterPayload record {|
    string email;
    string password;
    string username?;
    string fullName?;
|};

type LoginPayload record {|
    string email;
    string password;
|};

service class AuthService {
    *http:Service;

    resource function post register(@http:Payload RegisterPayload payload) returns http:Response|error {
        string pwdHash = getHash(payload.password);
        User u = check createUser(payload.email, pwdHash, payload.username ?: "", payload.fullName ?: "");
        return success({ user: u }, "Registered successfully");
    }

    resource function post login(@http:Payload LoginPayload payload) returns http:Response|error {
        string pwdHash = getHash(payload.password);
        User? user = check findUserByEmailAndPassword(payload.email, pwdHash);
        if user is () {
            return error("Invalid credentials", "INVALID_CREDENTIALS", 401);
        }
        string accessToken = issueDevToken(user.id.toString());
        json data = { user, accessToken, tokenType: "Bearer", expiresIn: 3600 };
        return success(data, "Login successful");
    }
}

function getHash(string input) returns string {
    // Non-cryptographic demo hash for scaffolding. Replace with bcrypt/argon2 when integrating.
    byte[] bytes = input.toBytes();
    byte[] h = crypto:sha256(bytes);
    return h.toBase16();
}

function issueDevToken(string sub) returns string {
    // Minimal opaque token for development; replace with standards-compliant JWT issuance if needed.
    return (sub + ":" + JWT_ISSUER + ":" + JWT_AUDIENCE + ":" + JWT_SECRET).toBytes().toBase64();
}


