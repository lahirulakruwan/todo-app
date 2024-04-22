import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/todo_task.dart';

class TodoListNotifier extends StateNotifier<List<TodoTask>>{

  TodoListNotifier():super(const []);

  Future<List<TodoTask>> loadTodosFromDB() async{
    if(state.isEmpty){
    
      final todos = await fetchTodos();
      state = todos;
      return state;
    }else{
      return state;
    }
    
  }

  void addTodoTask(String task) async{
    
    final newTodo = TodoTask(task: task);

    final createdTodoResponse = await createTodoTask(newTodo);

    newTodo.id = createdTodoResponse.id;

    state = [newTodo,...state];
  }

  void removeTodoTask(String id) async{

    await deleteTodoTask(id.toString());


    state = [...state.where((todo) => todo.id != int.parse(id))];

  }

  void  updateTodoTask(String id,String updatedTodoTask) async{

    final updatedTodoList = <TodoTask>[];

    final update_Todo_Task = TodoTask(
      id: int.parse(id),
      task: updatedTodoTask
    );

    await upgradeTodoTask(update_Todo_Task);

    for(var i=0; i < state.length;i++){
       if(state[i].id.toString() == id){
        updatedTodoList.add(update_Todo_Task);
       }else{
        updatedTodoList.add(state[i]);
       }
    }
    state = updatedTodoList;
  }

  TodoTask? getTodoTaskById(String id){
    for(var i=0; i < state.length;i++){
       if(state[i].id.toString() == id){
         return state[i];
       }
    }
    return null;
  }

  List<TodoTask>? returnTodos(){
    if(state.isEmpty){
      return null;
    }
    return state;
  }
}

final todoListProvider = StateNotifierProvider<TodoListNotifier,List<TodoTask>>(
  (ref) =>TodoListNotifier(),
);
