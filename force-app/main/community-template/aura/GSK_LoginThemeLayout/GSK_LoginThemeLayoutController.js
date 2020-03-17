/**
 * Created by user on 3/11/2020.
 */

({
    doInit: function (component, event, helper) {
        let title = component.get('v.title');
        let translatedTitle = '', translatedSubTitle = '';
        if (title === 'Login' || title === 'Forgot Password'){
            translatedSubTitle = $A.get('$Label.c.GSK_Login_Sub_Title');
        } else if(title === 'Email Sent'){
            translatedSubTitle = $A.get('$Label.c.PG_Email_Sent_Sub_Title');
        }
        component.set('v.translatedTitle', translatedTitle);
        component.set('v.translatedSubTitle', translatedSubTitle);
    }
});