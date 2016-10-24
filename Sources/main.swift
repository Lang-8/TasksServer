import Foundation
import Kitura
import SwiftyJSON
import Operadics
import Swiftx
import Swiftz

let queue = DispatchQueue(label: "com.Lang-8.TasksServer.queue")

let router = Router()

var projects: [Project] = []

router.all("/*", middleware: BodyParser())

router.get("/projects") { request, response, next in
    queue.async {
        let json = JSON(projects.map(toDictionary))
        try! response.status(.OK).send(json: json).end()
    }
}

router.get("/projects/:id") { request, response, next in
    queue.async {
        guard let id = request.parameters["id"], let project = fetch(by: id, in: projects) else {
            try! response.status(.notFound).send("Not Found").end()
            return
        }

        let json = JSON(toDictionary(from: project))
        try! response.status(.OK).send(json: json).end()
    }
}

router.post("/projects") { request, response, next in
    queue.async {
        guard let name = request.queryParameters["name"] else {
            try! response.status(.badRequest).send("Invalid parameters").end()
            return
        }
        
        projects = add(to: projects) • createProject <| name
        
        guard let project = projects.last else {
            try! response.status(.internalServerError).send("Internal Server Error").end()
            return
        }
        
        let json = JSON(toDictionary(from: project))
        try! response.status(.OK).send(json: json).end()
    }
}

router.patch("/projects/:id") { request, response, next in
    queue.async {
        guard
            let id = request.parameters["id"],
            let name = request.queryParameters["name"],
            let project = fetch(by: id, in: projects)
            else {
                try! response.status(.badRequest).send("Invalid parameters").end()
                return
        }
        
        projects = replace(in: projects) • updateName(of: project) <| name
        
        guard let updatedProject = fetch(by: id, in: projects) else {
            try! response.status(.internalServerError).send("Internal Server Error").end()
            return
        }
        
        let json = JSON(toDictionary(from: updatedProject))
        try! response.status(.OK).send(json: json).end()
    }
}

router.delete("/projects/:id") { request, response, next in
    queue.async {
        guard
            let id = request.parameters["id"],
            let project = fetch(by: id, in: projects)
            else {
                try! response.status(.badRequest).end()
                return
        }
        
        projects = remove(project, in: projects)
        
        try! response.status(.OK).send("").end()
    }
}

router.get("/projects/:project_id/tasks/:task_id") { request, response, next in
    queue.async {
        guard
            let projectID = request.parameters["project_id"],
            let project = fetch(by: projectID, in: projects),
            let taskID = request.parameters["task_id"],
            let task = fetch(by: taskID, in: project.tasks)
            else {
                try! response.status(.notFound).send("Not Found").end()
                return
        }
        
        let json = JSON(toDictionary(from: task))
        try! response.status(.OK).send(json: json).end()
    }
}

router.post("/projects/:project_id/tasks") { request, response, next in
    queue.async {
        guard
            let projectID = request.parameters["project_id"],
            let project = fetch(by: projectID, in: projects),
            let title = request.queryParameters["title"]
            else {
                try! response.status(.badRequest).send("Invalid parameters").end()
                return
        }
        
        let deadline = TimeInterval(request.queryParameters["deadline"] ?? "")
        let completed = toBool(request.queryParameters["completed"] ?? "false")
        let task = createTask <| (title, deadline, completed, project)
        projects = replace(in: projects) • add(to: project) <| task
        
        let json = JSON(toDictionary(from: task))
        try! response.status(.OK).send(json: json).end()
    }
}

router.patch("/projects/:project_id/tasks/:task_id") { request, response, next in
    queue.async {
        guard
            let projectID = request.parameters["project_id"],
            let project = fetch(by: projectID, in: projects),
            let taskID = request.parameters["task_id"],
            let task = fetch(by: taskID, in: project.tasks)
            else {
                try! response.status(.notFound).send("Not Found").end()
                return
        }
        
        let title = request.queryParameters["title"] ?? task.title
        let deadline = request.queryParameters["deadline"].map(TimeInterval.init) ?? task.deadline
        let completed = toBool(request.queryParameters["completed"] ?? (task.completed ? "true" : "false"))
        
        projects = replace(in: projects) • updateTasks(of: project) • replace(in: project.tasks) • update(task: task) <| (title, deadline, completed)
        
        guard let updatedProject = fetch(by: projectID, in: projects), let updatedTask = fetch(by: taskID, in: updatedProject.tasks) else {
            try! response.status(.internalServerError).send("Internal Server Error").end()
            return
        }
        
        let json = JSON(toDictionary(from: updatedTask))
        try! response.status(.OK).send(json: json).end()
    }
}

router.delete("/projects/:project_id/tasks/:task_id") { request, response, next in
    queue.async {
        guard
            let id = request.parameters["project_id"],
            let project = fetch(by: id, in: projects),
            let taskID = request.parameters["task_id"],
            let task = fetch(by: taskID, in: project.tasks)
            else {
                try! response.status(.badRequest).end()
                return
        }
        
        projects = replace(in: projects) • updateTasks(of: project) <| remove(task, in: project.tasks)
        
        try! response.status(.OK).send("").end()
    }
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
