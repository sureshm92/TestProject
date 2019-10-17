/**
 * Created by Nargiz Mamedova on 10/14/2019.
 */

public with sharing class ProfileIconController {

    @RemoteAction
    public static void upload(String fileName, String fileBody, String contentType) {
        Blob blobValue = EncodingUtil.base64Decode(fileBody);
        ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(blobValue, contentType, fileName);
        ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), UserInfo.getUserId(), photoFileInput);
    }

    @RemoteAction
    public static String getPhotoURL() {
        return ConnectApi.UserProfiles.getPhoto(Network.getNetworkId(), UserInfo.getUserId()).fullEmailPhotoUrl;
    }
}