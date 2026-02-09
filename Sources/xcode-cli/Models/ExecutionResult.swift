struct CommandResult {
    let exitCode: Int
    let stdout: String
    let stderr: String
    
    var isSuccess: Bool {
        exitCode == 0
    }
}
