import Foundation

public struct SigningConfiguration: Codable, Equatable {
  public let style: CodeSignStyle?
  public let identity: String?
  public let teamID: String?
  public let provisioningProfile: ProvisioningProfile?

  enum CodingKeys: String, CodingKey {
    case style
    case identity
    case teamID = "team_id"
    case provisioningProfile = "provisioning_profile"
  }

  public init(
    style: CodeSignStyle? = nil,
    identity: String? = nil,
    teamID: String? = nil,
    provisioningProfile: ProvisioningProfile? = nil
  ) {
    self.style = style
    self.identity = identity
    self.teamID = teamID
    self.provisioningProfile = provisioningProfile
  }
}
