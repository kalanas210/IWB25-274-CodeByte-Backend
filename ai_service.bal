import ballerina/http;

type AskPayload record {|
    string userQuery;
|};

service class AiService {
    *http:Service;

    resource function post ask(@http:Payload AskPayload payload) returns http:Response|error {
        json demo = {
            success: true,
            message: "AI recommendations (scaffold)",
            data: {
                query: payload.userQuery,
                recommendations: "## Strategy\n- Focus on creator fit and audience overlap\n- Use multi-platform approach\n",
                creatorsAnalyzed: 42,
                recommendedCreators: []
            }
        };
        return respondJson(demo, 200);
    }
}


