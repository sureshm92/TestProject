/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var title = component.get('v.title');
        if(title === 'Login'){
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Login_Title'));
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Login_Sub_Title'));
        } else if(title === 'Email Sent'){
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Email_Sent_Title'));
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Email_Sent_Sub_Title'));
        } else if(title === 'Forgot Password'){
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Forgot_Password_Title'));
            component.set('v.translatedSubTitle', $A.get(''));

        }
    }
})