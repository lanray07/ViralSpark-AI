import Foundation

enum LoadingState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
    case limitReached
}
