/**
 * Created by Nargiz Mamedova on 10/14/2019.
 */

public with sharing class ChangePasswordController {

    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}

    public ChangePasswordController() {}

    public PageReference changePassword() {
        try{
            return Site.changePassword(newPassword, verifyNewPassword, oldPassword);
        }catch (Exception e){
            ApexPages.addMessages(e);
            return null;
        }
    }
}