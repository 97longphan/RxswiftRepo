import Resolver

class TestInjectionModel {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.age = age
        self.name = name
    }
}

extension Resolver {
    public static func registerTestInjectionModel() {
        register{TestInjectionModel(name: "Long", age: 25)}
    }
}

