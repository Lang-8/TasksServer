import Foundation
import SwiftyJSON

var maxTaskID: UInt64 = 1

struct Task: Identified {

    let id: UInt64

    let projectID: UInt64

    let title: String

    let deadline: TimeInterval?

    let completed: Bool

    init(id: UInt64, projectID: UInt64, title: String, deadline: TimeInterval? = nil, completed: Bool = false) {
        self.id = id
        self.projectID = projectID
        self.title = title
        self.deadline = deadline
        self.completed = completed
    }

}

extension Task: Equatable {
    
    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
    
}

func toDictionary(from task: Task) -> [String : Any] {
    let deadline: Any = task.deadline ?? NSNull()
    return ["id" : String(task.id), "project_id" : String(task.projectID), "title" : task.title, "deadline" : deadline, "completed" : task.completed]
}

func createTask(title: String, deadline: TimeInterval? = nil, completed: Bool = false, project: Project) -> Task {
    let task = Task(id: maxTaskID, projectID: project.id, title: title, deadline: deadline, completed: completed)
    maxTaskID += 1
    return task
}

func update(task: Task) -> (String, TimeInterval?, Bool) -> Task {
    return { title, deadline, completed in
        return Task(id: task.id, projectID: task.projectID, title: title, deadline: deadline, completed: completed)
    }
}

func add(to project: Project) -> (Task) -> Project {
    return { task in
        return Project(id: project.id, name: project.name, tasks: project.tasks + [task])
    }
}
