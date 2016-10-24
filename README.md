# TasksServer
Kitura Sample Project

# Usage
1. Clone this repository
2. Change current directory to the repository
3. Run `swift build`
4. Run `.build/debug/TasksServer`

# API
## Projects
### GET /projects

Get projects

This end point has no parameters.

#### Request & Response

GET http://localhost:8090/projects

```JSON
[
  {
    "id" : "5",
    "name" : "Lang-8",
    "tasks" : [

    ]
  },
  {
    "id" : "6",
    "name" : "HiNative",
    "tasks" : [
      {
        "title" : "Write an issue",
        "deadline" : 58853,
        "id" : "3",
        "project_id" : "6",
        "completed" : false
      }
    ]
  }
]
```

### GET /projects/:id

Get a project information

#### Parameters

- :id - UInt64, required

#### Request & Response

GET http://localhost:8090/projects/6

```JSON
{
  "id" : "6",
  "name" : "HiNative",
  "tasks" : [
    {
      "title" : "Write an issue",
      "deadline" : 58853,
      "id" : "3",
      "project_id" : "6",
      "completed" : false
    }
  ]
}
```

### POST /projects

Create new project

#### Query Parameters

- name - String, required

#### Request & Response

POST http://localhost:8090/projects?name=HiNative

```JSON
{
  "id" : "6",
  "name" : "HiNative",
  "tasks" : [
  ]
}
```

### PATCH /projects/:id

Change information of a project

#### Parameters

- :id - UInt64, required

#### Query Parameters

- name - String, required

#### Request & Response

PATCH http://localhost:8090/projects/6?name=NewName

```JSON
{
  "id" : "6",
  "name" : "NewName",
  "tasks" : [
  ]
}
```

### DELETE /projects/:id

Delete a project

#### Parameters

- :id - UInt64, required

## Tasks

### GET /projects/:project_id/tasks/:task_id

Get tasks of a project

#### Parameters

- :project_id - UInt64, required
- :task_id - UInt64, required

#### Request & Response

DELETE http://localhost:8090/projects/1

Response is empty.

### GET /projects/:project_id/tasks/:task_id

Get a task information

#### Parameters

- :project_id - UInt64, required
- :task_id - UInt64, required

#### Request & Response

GET http://localhost:8090/projects/1/tasks/1

```JSON
{
  "title" : "task",
  "deadline" : null,
  "id" : "1",
  "project_id" : "1",
  "completed" : false
}
```

### POST /projects/:project_id/tasks

Create a task of a project

#### Parameters

- :project_id - UInt64, required

#### Query Parameters

- title : String, required
- deadline : Int, time interval from 1970
- completed : Bool, default is false

#### Request & Response

POST http://localhost:8090/projects/6/tasks?title=task&deadline=16284&completed=false

```JSON
{
  "title" : "task",
  "deadline" : 16284,
  "id" : "2",
  "project_id" : "6",
  "completed" : false
}
```

### PATCH /projects/:project_id/tasks/:task_id

Change information of a task

#### Parameters

- :project_id - UInt64, required
- :task_id - UInt64, required

#### Query Parameters

- title - String
- deadline - Int, time interval from 1970
- completed - Bool, default is false

#### Request & Response

PATCH http://localhost:8090/projects/6/tasks/2?title=changed&deadline=21196&completed=false

```JSON
{
  "title" : "changed",
  "deadline" : 21196,
  "id" : "2",
  "project_id" : "6",
  "completed" : false
}
```

### DELETE /projects/:project_id/tasks/:task_id

Delete a task of a project

#### Parameters

- :project_id - UInt64, required
- :task_id - UInt64, required

#### Request & Response

DELETE http://localhost:8090/projects/6/tasks/2

Response is empty.
