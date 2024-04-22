import ballerina/graphql;

public isolated client class GraphqlClient {
    final graphql:Client graphqlClient;
    public isolated function init(string serviceUrl, ConnectionConfig config = {}) returns graphql:ClientError? {
        graphql:ClientConfiguration graphqlClientConfig = {auth: config.oauth2ClientCredentialsGrantConfig, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                graphqlClientConfig.http1Settings = {...settings};
            }
            if config.cache is graphql:CacheConfig {
                graphqlClientConfig.cache = check config.cache.ensureType(graphql:CacheConfig);
            }
            if config.responseLimits is graphql:ResponseLimitConfigs {
                graphqlClientConfig.responseLimits = check config.responseLimits.ensureType(graphql:ResponseLimitConfigs);
            }
            if config.secureSocket is graphql:ClientSecureSocket {
                graphqlClientConfig.secureSocket = check config.secureSocket.ensureType(graphql:ClientSecureSocket);
            }
            if config.proxy is graphql:ProxyConfig {
                graphqlClientConfig.proxy = check config.proxy.ensureType(graphql:ProxyConfig);
            }
        } on fail var e {
            return <graphql:ClientError>error("GraphQL Client Error", e, body = ());
        }
        graphql:Client clientEp = check new (serviceUrl, graphqlClientConfig);
        self.graphqlClient = clientEp;
    }

    remote isolated function deleteTodoTask(int id) returns json|error {
        string query = string `mutation deleteTodoTask($id: Int!){delete_todo_task(id:$id)}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        map<json> responseMap = <map<json>>graphqlResponse;
        json responseData = responseMap.get("data");
        json|error row_count = check responseData.delete_todo_task;
        return row_count;
    }
    remote isolated function addTodoTask(TodoTask todo_task) returns AddTodoTaskResponse|graphql:ClientError {
        string query = string `mutation addTodoTask($todo_task:TodoTask!) {add_todo_task(todo_task:$todo_task) {id task}}`;
        map<anydata> variables = {"todo_task": todo_task};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <AddTodoTaskResponse> check performDataBinding(graphqlResponse, AddTodoTaskResponse);
    }
    remote isolated function updateTodoTask(TodoTask todo_task) returns UpdateTodoTaskResponse|graphql:ClientError {
        string query = string `mutation updateTodoTask($todo_task:TodoTask!) {update_todo_task(todo_task:$todo_task) {id task}}`;
        map<anydata> variables = {"todo_task": todo_task};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <UpdateTodoTaskResponse> check performDataBinding(graphqlResponse, UpdateTodoTaskResponse);
    }
    remote isolated function getTodoTaskList() returns GetTodoTaskListResponse|graphql:ClientError {
        string query = string `query getTodoTaskList {todo_task_list {id task}}`;
        map<anydata> variables = {};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetTodoTaskListResponse> check performDataBinding(graphqlResponse, GetTodoTaskListResponse);
    }
    remote isolated function getTodoTaskById(int id) returns GetTodoTaskByIdResponse|graphql:ClientError {
        string query = string `query getTodoTaskById($id:Int!) {todo_task_by_id(id:$id) {id task}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetTodoTaskByIdResponse> check performDataBinding(graphqlResponse, GetTodoTaskByIdResponse);
    }
    remote isolated function getPerson(string id) returns GetPersonResponse|graphql:ClientError {
        string query = string `query getPerson($id:String!) {person_by_digital_id(id:$id) {id full_name asgardeo_id jwt_sub_id jwt_email digital_id email created updated}}`;
        map<anydata> variables = {"id": id};
        json graphqlResponse = check self.graphqlClient->executeWithType(query, variables);
        return <GetPersonResponse> check performDataBinding(graphqlResponse, GetPersonResponse);
    }
}
