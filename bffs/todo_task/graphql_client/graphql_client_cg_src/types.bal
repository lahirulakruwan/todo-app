public type TodoTask record {
    string? task?;
    int? id?;
    string? record_type?;
};

public type AddTodoTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? task;
    |}? add_todo_task;
|};

public type UpdateTodoTaskResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? task;
    |}? update_todo_task;
|};

public type GetTodoTaskListResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? task;
    |}[] todo_task_list;
|};

public type GetTodoTaskByIdResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? task;
    |}? todo_task_by_id;
|};

public type GetPersonResponse record {|
    map<json?> __extensions?;
    record {|
        int? id;
        string? full_name;
        string? asgardeo_id;
        string? jwt_sub_id;
        string? jwt_email;
        string? digital_id;
        string? email;
        string? created;
        string? updated;
    |}? person_by_digital_id;
|};

public type Person record {
    int? id?;
    string? full_name?;
    string? asgardeo_id?;
    string? jwt_sub_id?;
    string? jwt_email?;
    string? digital_id?;
    string? email?;
    string? created?;
    string? updated?;
    string? record_type?;
};
