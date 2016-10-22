import Foundation

var maxProjectID: UInt64 = 1

struct Project: Identified {

    let id: UInt64

    let name: String

    let tasks: [Task]

    init(id: UInt64, name: String, tasks: [Task] = []) {
        self.id = id
        self.name = name
        self.tasks = tasks
    }

}

extension Project: Equatable {

    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id
    }

}

func toDictionary(from project: Project) -> [String : Any] {
    return ["id" : String(project.id), "name" : project.name, "tasks" : project.tasks.map(toDictionary)]
}

func createProject(name: String) -> Project {
    let project = Project(id: maxProjectID, name: name)
    maxProjectID += 1
    return project
}

func updateName(of project: Project) -> (String) -> Project {
    return { name in
        return Project(id: project.id, name: name, tasks: project.tasks)
    }
}

func updateTasks(of project: Project) -> ([Task]) -> Project {
    return { tasks in
        return Project(id: project.id, name: project.name, tasks: tasks)
    }
}
