import ballerina/http;
import ballerina/graphql;
import ballerina/log;


public function initClientConfig() returns ConnectionConfig{
    ConnectionConfig _clientConig = {};
    if (GLOBAL_DATA_USE_AUTH) {
        _clientConig.oauth2ClientCredentialsGrantConfig =  {
            tokenUrl: CHOREO_TOKEN_URL,
            clientId:GLOBAL_DATA_CLIENT_ID,
            clientSecret:GLOBAL_DATA_CLIENT_SECRET
        };
    } else { 
        _clientConig = {};
    }
    return _clientConig;
}


final GraphqlClient globalDataClient = check new (GLOBAL_DATA_API_URL,
    config = initClientConfig()
);

# A service representing a network-accessible API
# bound to port `9091`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get greeting(string name) returns string|error {
        // Send a response back to the caller.
        if name is "" {
            return error("name should not be empty!");
        }
        return "Hello, " + name;
    }

    resource function get person(string digital_id) returns Person|error {

        GetPersonResponse|graphql:ClientError getPersonResponse = globalDataClient->getPerson(digital_id);
        if(getPersonResponse is GetPersonResponse) {
            Person|error person_record = getPersonResponse.person_by_digital_id.cloneWithType(Person);
            if(person_record is Person) {
                return person_record;
            } else {
                log:printError("Error while processing Application record received1", person_record);
                return error("Error while processing Person record received2: " + person_record.message() + 
                    ":: Detail: " + person_record.detail().toString());
            }
        } else {
            log:printError("Error while fetching person records application3", getPersonResponse);
            return error("Error while fetching person records application4: " + getPersonResponse.message() + 
                ":: Detail: " + getPersonResponse.detail().toString());
        }
    }

    resource function post add_todo_task(@http:Payload TodoTask todoTask) returns TodoTask|error {
        AddTodoTaskResponse|graphql:ClientError addTodoTaskResponse = globalDataClient->addTodoTask(todoTask);
        if(addTodoTaskResponse is AddTodoTaskResponse) {
            TodoTask|error todo_task_record = addTodoTaskResponse.add_todo_task.cloneWithType(TodoTask);
            if(todo_task_record is TodoTask) {
                return todo_task_record;
            } else {
                log:printError("Error while processing Application record received", todo_task_record);
                return error("Error while processing Application record received: " + todo_task_record.message() + 
                    ":: Detail: " + todo_task_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", addTodoTaskResponse);
            return error("Error while creating application: " + addTodoTaskResponse.message() + 
                ":: Detail: " + addTodoTaskResponse.detail().toString());
        }
    }

    resource function put update_todo_task(@http:Payload TodoTask todoTask) returns TodoTask|error {
        UpdateTodoTaskResponse|graphql:ClientError updateTodoTaskResponse = globalDataClient->updateTodoTask(todoTask);
        if(updateTodoTaskResponse is UpdateTodoTaskResponse) {
            TodoTask|error todo_task_record = updateTodoTaskResponse.update_todo_task.cloneWithType(TodoTask);
            if(todo_task_record is TodoTask) {
                return todo_task_record;
            }
            else {
                return error("Error while processing Application record received: " + todo_task_record.message() + 
                    ":: Detail: " + todo_task_record.detail().toString());
            }
        } else {
            log:printError("Error while creating evaluation", updateTodoTaskResponse);
            return error("Error while creating evaluation: " + updateTodoTaskResponse.message() + 
                ":: Detail: " + updateTodoTaskResponse.detail().toString());
        }
    }

    resource function delete delete_todo_task/[int id]() returns json|error {
        json|error delete_count = globalDataClient->deleteTodoTask(id);
        return  delete_count;
    }
    
    resource function get todo_tasks() returns TodoTask[]|error {
        GetTodoTaskListResponse|graphql:ClientError getTodoTaskListResponse = globalDataClient->getTodoTaskList();
        if(getTodoTaskListResponse is GetTodoTaskListResponse) {
            TodoTask[] todoTasksList = [];
            foreach var todo_task_record  in getTodoTaskListResponse.todo_task_list {
                TodoTask|error todoTaskRecord  = todo_task_record.cloneWithType(TodoTask);
                if(todoTaskRecord is TodoTask) {
                    todoTasksList.push(todoTaskRecord);
                } else {
                    log:printError("Error while processing Application record received",todoTaskRecord);
                    return error("Error while processing Application record received: " + todoTaskRecord.message() + 
                        ":: Detail: " + todoTaskRecord.detail().toString());
                }
            }

            return todoTasksList;
            
        } else {
            log:printError("Error while getting application", getTodoTaskListResponse );
            return error("Error while getting application: " + getTodoTaskListResponse.message() + 
                ":: Detail: " + getTodoTaskListResponse.detail().toString());
        }
    }

    resource function get todo_task_by_id/[int id]() returns TodoTask|error {
        GetTodoTaskByIdResponse|graphql:ClientError getTodoTaskByIdResponse = globalDataClient->getTodoTaskById(id);
        if(getTodoTaskByIdResponse is GetTodoTaskByIdResponse) {
            TodoTask|error todo_task_record = getTodoTaskByIdResponse.todo_task_by_id.cloneWithType(TodoTask);
            if(todo_task_record is TodoTask) {
                return todo_task_record;
            } else {
                log:printError("Error while processing Application record received", todo_task_record);
                return error("Error while processing Application record received: " + todo_task_record.message() + 
                    ":: Detail: " + todo_task_record.detail().toString());
            }
        } else {
            log:printError("Error while creating application", getTodoTaskByIdResponse);
            return error("Error while creating application: " + getTodoTaskByIdResponse.message() + 
                ":: Detail: " + getTodoTaskByIdResponse.detail().toString());
        }
    }
}
