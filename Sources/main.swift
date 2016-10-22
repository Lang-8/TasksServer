import Foundation
import Kitura
import SwiftyJSON
import Operadics
import Swiftx
import Swiftz

let router = Router()

var projects: [Project] = []

router.all("/*", middleware: BodyParser())

router.get("/projects") {
    request, response, next in
    defer { next() }
    let json = JSON(projects.map(toDictionary))
    response.status(.OK).send(json: json)
}

router.get("/projects/:id") {
    request, response, next in
    defer { next() }
    guard let id = request.parameters["id"], let project = fetch(by: id, in: projects) else {
        response.status(.notFound).send("Not Found")
        return
    }
    
    let json = JSON(toDictionary(from: project))
    response.status(.OK).send(json: json)
}

router.post("/projects") {
    request, response, next in
    defer { next() }
    guard let name = request.queryParameters["name"] else {
        response.status(.badRequest).send("Invalid parameters")
        return
    }
    
    projects = add(to: projects) • createProject <| name
    
    guard let project = projects.last else {
        response.status(.internalServerError).send("Internal Server Error")
        return
    }
    
    let json = JSON(toDictionary(from: project))
    response.status(.OK).send(json: json)
}

router.patch("/projects/:id") {
    request, response, next in
    defer { next() }
    guard
        let id = request.parameters["id"],
        let name = request.queryParameters["name"],
        let project = fetch(by: id, in: projects)
        else {
            response.status(.badRequest).send("Invalid parameters")
            return
    }
    
    projects = replace(in: projects) • updateName(of: project) <| name
    
    guard let updatedProject = fetch(by: id, in: projects) else {
        response.status(.internalServerError).send("Internal Server Error")
        return
    }
    
    let json = JSON(toDictionary(from: updatedProject))
    response.status(.OK).send(json: json)
}

router.get("/projects/:project_id/tasks/:task_id") {
    request, response, next in
    defer { next() }
    guard
        let projectID = request.parameters["project_id"],
        let project = fetch(by: projectID, in: projects),
        let taskID = request.parameters["task_id"],
        let task = fetch(by: taskID, in: project.tasks)
        else {
            response.status(.notFound).send("Not Found")
            return
    }
    
    let json = JSON(toDictionary(from: task))
    response.status(.OK).send(json: json)
}

router.post("/projects/:project_id/tasks") {
    request, response, next in
    defer { next() }
    guard
        let projectID = request.parameters["project_id"],
        let project = fetch(by: projectID, in: projects),
        let title = request.queryParameters["title"]
        else {
            response.status(.badRequest).send("Invalid parameters")
            return
    }
    
    let deadline = TimeInterval(request.queryParameters["deadline"] ?? "")
    let completed = toBool(request.queryParameters["completed"] ?? "false")
    projects = replace(in: projects) • add(to: project) • createTask <| (title, deadline, completed, project)
    
    guard let updatedProject = fetch(by: projectID, in: projects) else {
        response.status(.internalServerError).send("Internal Server Error")
        return
    }
    
    let json = JSON(toDictionary(from: updatedProject))
    response.status(.OK).send(json: json)
}

router.patch("/projects/:project_id/tasks/:task_id") {
    request, response, next in
    defer { next() }
    guard
        let projectID = request.parameters["project_id"],
        let project = fetch(by: projectID, in: projects),
        let taskID = request.parameters["task_id"],
        let task = fetch(by: taskID, in: project.tasks)
        else {
            response.status(.notFound).send("Not Found")
            return
    }
    
    let title = request.queryParameters["title"] ?? task.title
    let deadline = request.queryParameters["deadline"].map(TimeInterval.init) ?? task.deadline
    let completed = toBool(request.queryParameters["completed"] ?? (task.completed ? "true" : "false"))
    
    projects = replace(in: projects) • updateTasks(of: project) • replace(in: project.tasks) • update(task: task) <| (title, deadline, completed)
    
    guard let updatedProject = fetch(by: projectID, in: projects), let updatedTask = fetch(by: taskID, in: updatedProject.tasks) else {
        response.status(.internalServerError).send("Internal Server Error")
        return
    }
    
    let json = JSON(toDictionary(from: updatedTask))
    response.status(.OK).send(json: json)
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
