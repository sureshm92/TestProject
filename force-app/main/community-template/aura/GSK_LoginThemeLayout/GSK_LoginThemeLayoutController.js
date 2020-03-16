/**
 * Created by user on 3/11/2020.
 */

({
    doInit: function (component, event, helper) {
        let title = component.get('v.title');
        let translatedTitle = '', translatedSubTitle = '';
        if (title === 'Login'){
            //translatedTitle = $A.get('$Label.c.PG_Login_Title');
            translatedSubTitle = $A.get('$Label.c.GSK_Login_Sub_Title');
        }
        if(title === 'Email Sent'){
            //translatedTitle = $A.get('$Label.c.PG_Email_Sent_Title');
            translatedSubTitle = $A.get('$Label.c.PG_Email_Sent_Sub_Title');
        }
        if(title === 'Forgot Password'){
            //translatedTitle = $A.get('$Label.c.PG_Forgot_Password_Title');
        }
        component.set('v.translatedTitle', translatedTitle);
        component.set('v.translatedSubTitle', translatedSubTitle);
    }
});