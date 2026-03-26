
import Foundation

struct Recipe {
    var name : String
    var image : String
    var id : Int
    var summary: String = ""
    var sourceURL: String = ""
    var readyInMinutes: Int? = nil
    var servings: Int? = nil
    var ingredients: [String] = []
    var instructions: [String] = []
    var calories: String = ""
    var matchScore: Int = 0
}
