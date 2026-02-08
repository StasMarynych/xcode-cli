import Foundation
import Testing

@testable import xcode_cli

@Suite("Configuration Error Field Identification Tests")
struct ConfigurationErrorFieldIdentificationTests {
    
    @Test("Configuration error field identification for missing required field")
    func configurationErrorFieldIdentificationMissingRequiredField() {
        let error = ConfigurationError.missingRequiredField(field: "scheme")
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(error.fieldName == "scheme", "Field name should match the missing field")
        #expect(
            error.description.contains("scheme"),
            "Error description should contain the field name"
        )
    }
    
    @Test("Configuration error field identification for invalid field type")
    func configurationErrorFieldIdentificationInvalidFieldType() {
        let error = ConfigurationError.invalidFieldType(
            field: "parallel_testing_workers", expected: "integer")
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName == "parallel_testing_workers", "Field name should match the invalid field"
        )
        #expect(
            error.description.contains("parallel_testing_workers"),
            "Error description should contain the field name"
        )
    }
    
    @Test("Configuration error field identification for conflicting fields")
    func configurationErrorFieldIdentificationConflictingFields() {
        let error = ConfigurationError.conflictingFields(fields: ["project_path", "workspace_path"])
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName == "project_path, workspace_path",
            "Field name should contain all conflicting fields"
        )
        #expect(
            error.description.contains("project_path"),
            "Error description should contain the first conflicting field"
        )
        #expect(
            error.description.contains("workspace_path"),
            "Error description should contain the second conflicting field"
        )
    }
    
    @Test("Configuration error field identification for missing project or workspace")
    func configurationErrorFieldIdentificationMissingProjectOrWorkspace() {
        let error = ConfigurationError.missingProjectOrWorkspace
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName == "project_path or workspace_path",
            "Field name should indicate the missing fields"
        )
        #expect(
            error.description.contains("project") || error.description.contains("workspace"),
            "Error description should mention project or workspace"
        )
    }
    
    @Test("Configuration error field identification for both project and workspace specified")
    func configurationErrorFieldIdentificationBothProjectAndWorkspaceSpecified() {
        let error = ConfigurationError.bothProjectAndWorkspaceSpecified
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName == "project_path, workspace_path", "Field name should contain both fields"
        )
        #expect(
            error.description.contains("project") && error.description.contains("workspace"),
            "Error description should mention both project and workspace"
        )
    }
    
    @Test("Configuration error field identification for missing scheme")
    func configurationErrorFieldIdentificationMissingScheme() {
        let error = ConfigurationError.missingScheme
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(error.fieldName == "scheme", "Field name should be scheme")
        #expect(
            error.description.contains("scheme"),
            "Error description should contain the field name"
        )
    }
    
    @Test("Configuration error field identification for invalid export method")
    func configurationErrorFieldIdentificationInvalidExportMethod() {
        let error = ConfigurationError.invalidExportMethod(method: "invalid-method")
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(error.fieldName == "export_method", "Field name should be export_method")
        #expect(
            error.description.contains("export method") || error.description.contains("invalid-method"),
            "Error description should mention export method"
        )
    }
    
    @Test("Configuration error field identification for missing signing identity")
    func configurationErrorFieldIdentificationMissingSigningIdentity() {
        let error = ConfigurationError.missingSigningIdentity
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(error.fieldName == "signing.identity", "Field name should be signing.identity")
        #expect(
            error.description.contains("signing") || error.description.contains("identity"),
            "Error description should mention signing identity"
        )
    }
    
    @Test("Configuration error field identification for invalid parallel testing workers")
    func configurationErrorFieldIdentificationInvalidParallelTestingWorkers() {
        let error = ConfigurationError.invalidParallelTestingWorkers(count: -1)
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName == "parallel_testing_workers", "Field name should be parallel_testing_workers"
        )
        #expect(
            error.description.contains("parallel") || error.description.contains("workers"),
            "Error description should mention parallel testing workers"
        )
    }
    
    @Test("Configuration error field identification for multiple provisioning profile fields")
    func configurationErrorFieldIdentificationMultipleProvisioningProfileFields() {
        let error = ConfigurationError.multipleProvisioningProfileFieldsSpecified
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(
            error.fieldName
            == "provisioning_profile.uuid, provisioning_profile.name, provisioning_profile.path",
            "Field name should contain all provisioning profile fields"
        )
        #expect(
            error.description.contains("provisioning"),
            "Error description should mention provisioning profile"
        )
    }
    
    @Test("Configuration error field identification for invalid code sign style")
    func configurationErrorFieldIdentificationInvalidCodeSignStyle() {
        let error = ConfigurationError.invalidCodeSignStyle(style: "invalid-style")
        
        #expect(error.fieldName != nil, "Configuration error should have a field name")
        #expect(error.fieldName == "signing.style", "Field name should be signing.style")
        #expect(
            error.description.contains("sign") || error.description.contains("style"),
            "Error description should mention code sign style"
        )
    }
    
    @Test("Configuration error field identification all errors have field names")
    func configurationErrorFieldIdentificationAllErrorsHaveFieldNames() {
        // Test that all configuration errors that should have field names do have them
        let errorsWithFields: [ConfigurationError] = [
            .missingRequiredField(field: "test"),
            .invalidFieldType(field: "test", expected: "string"),
            .conflictingFields(fields: ["field1", "field2"]),
            .missingProjectOrWorkspace,
            .bothProjectAndWorkspaceSpecified,
            .missingScheme,
            .invalidExportMethod(method: "test"),
            .missingSigningIdentity,
            .invalidParallelTestingWorkers(count: 0),
            .multipleProvisioningProfileFieldsSpecified,
            .invalidCodeSignStyle(style: "test"),
        ]
        
        for error in errorsWithFields {
            #expect(
                error.fieldName != nil,
                "Configuration error \(error) should have a field name"
            )
            #expect(
                !error.fieldName!.isEmpty,
                "Field name for error \(error) should not be empty"
            )
        }
    }
    
    @Test("Configuration error field identification error formatter includes field name")
    func configurationErrorFieldIdentificationErrorFormatterIncludesFieldName() {
        let error = ConfigurationError.missingRequiredField(field: "scheme")
        let cliError = CLIError.configurationError(error)
        
        let formattedError = ErrorFormatter.format(cliError, verbose: false)
        
        #expect(
            formattedError.contains("Field:"),
            "Formatted error should include 'Field:' label"
        )
        #expect(
            formattedError.contains("scheme"),
            "Formatted error should include the field name"
        )
    }
    
    @Test("Configuration error field identification error formatter with multiple fields")
    func configurationErrorFieldIdentificationErrorFormatterWithMultipleFields() {
        let error = ConfigurationError.conflictingFields(fields: ["project_path", "workspace_path"])
        let cliError = CLIError.configurationError(error)
        
        let formattedError = ErrorFormatter.format(cliError, verbose: false)
        
        #expect(
            formattedError.contains("Field:"),
            "Formatted error should include 'Field:' label"
        )
        #expect(
            formattedError.contains("project_path"),
            "Formatted error should include the first field name"
        )
        #expect(
            formattedError.contains("workspace_path"),
            "Formatted error should include the second field name"
        )
    }
    
    @Test("Configuration error field identification error formatter with suggestion")
    func configurationErrorFieldIdentificationErrorFormatterWithSuggestion() {
        let error = ConfigurationError.missingRequiredField(field: "scheme")
        let cliError = CLIError.configurationError(error)
        
        let formattedError = ErrorFormatter.format(cliError, verbose: false)
        
        #expect(
            formattedError.contains("Suggestion:"),
            "Formatted error should include 'Suggestion:' label"
        )
        #expect(
            formattedError.contains("scheme"),
            "Suggestion should mention the field name"
        )
    }
}
