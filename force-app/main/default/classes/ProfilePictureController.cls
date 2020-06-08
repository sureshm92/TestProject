public with sharing class ProfilePictureController {
    @AuraEnabled
    public static string getProfilePicture(Id parentId) {
        
        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            //return null;
        }
        
        return [SELECT Id, Name, FullPhotoUrl FROM User 
                WHERE Id=:UserInfo.getUserId()].FullPhotoUrl;
        
    }
    
    @AuraEnabled
    public static String saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 
       
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        User userval=[SELECT Id, Name, FullPhotoUrl,ContactId FROM User 
                WHERE Id=:UserInfo.getUserId()];
      
        Blob blobValue=EncodingUtil.base64Decode(base64Data);
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, contentType, fileName);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), UserInfo.getUserId(), photoFileInput);
        String  photolink = ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), UserInfo.getUserId()).fullEmailPhotoUrl;
        return [SELECT Id, Name, FullPhotoUrl FROM User 
                WHERE Id=:UserInfo.getUserId()].FullPhotoUrl;
        
    }
}