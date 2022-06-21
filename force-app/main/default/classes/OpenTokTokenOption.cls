/**
 * Defines values for the OpenTokTokenOptions parameter of the
 * OpenTok.generateToken(String sessionId, OpenTokTokenOptions tokenOptions) method
 * and the OpenTokHttpClient.generateToken(OpenTokTokenOptions tokenOptions) method.
 */
public with sharing class OpenTokTokenOption {
    public OpenTokRoles role { get; set; }
    public Double expireTime { get; set; }
    public String connectionData { get; set; }

    public OpenTokTokenOption(OpenTokRoles role, Double expireTime, String connectionData) {
        this.role = role != null ? role : OpenTokRoles.PUBLISHER;
        this.expireTime = expireTime;
        this.connectionData = connectionData;
    }
}