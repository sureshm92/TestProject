public with sharing class ProfilePictureController {
    public static String loggedInUserMode;
    public static final String USER_MODE_HCP = 'HCP';
    @AuraEnabled
    public static string getProfilePicture(Id parentId,String userMode) {
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            //return null;
        }
        loggedInUserMode = userMode;
        Contact currentContact = new Contact();
        currentContact = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact
            WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())
            LIMIT 1
        ];

        if (loggedInUserMode != USER_MODE_HCP && currentContact.userCommunityDelegateId__c != null) {
            currentContact = ContactService.getContact(currentContact.userCommunityDelegateId__c);
        }

        return [
            SELECT Id, Name, FullPhotoUrl, SmallPhotoUrl
            FROM User
            WHERE ContactId = :currentContact.Id
        ]
        .SmallPhotoUrl;
    }

    @AuraEnabled
    public static String saveAttachment(
        Id parentId,
        String fileName,
        String base64Data,
        String contentType
    ) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        User userval = [
            SELECT Id, Name, FullPhotoUrl, ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        Blob blobValue = EncodingUtil.base64Decode(base64Data);
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(
            blobValue,
            contentType,
            fileName
        );
        ConnectApi.UserProfiles.setPhoto(
            Network.getNetworkId(),
            UserInfo.getUserId(),
            photoFileInput
        );
        String photolink = ConnectApi.UserProfiles.getPhoto(
                Network.getNetworkId(),
                UserInfo.getUserId()
            )
            .fullEmailPhotoUrl;
        return [SELECT Id, Name, FullPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()]
        .FullPhotoUrl;
    }

    @AuraEnabled
    public static void deletePicture(Id parentId) {
        ConnectApi.UserProfiles.deletePhoto(Network.getNetworkId(), UserInfo.getUserId());
    }
}
