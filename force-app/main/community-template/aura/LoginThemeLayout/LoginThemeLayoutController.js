/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var title = component.get('v.title');
        const path = window.location.pathname;
        let forgotPath = path && path.indexOf('/s/login/ForgotPassword') > -1;
        let sentPath = path && path.indexOf('/s/login/CheckPasswordResetEmail') > -1;
        let loginPath = !forgotPath && !sentPath && path && path.indexOf('/s/login') > -1;

        var rtl_language = $A.get('$Label.c.RTL_Languages');
        var paramLanguage = communityService.getUrlParameter('language');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));

        if (title === 'Login' || loginPath) {
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Login_Title'));
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Login_Sub_Title'));
        } else if (title === 'Email Sent' || sentPath || component.get('v.showUsrName')) {
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Email_Sent_Title'));
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Email_Sent_Sub_Title'));
        } else if (title === 'Forgot Password' || forgotPath) {
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Forgot_Password_Title'));
            component.set('v.translatedSubTitle', $A.get(''));
        }
    },
    handleMessage: function (component, message, helper) {
        alert('inside --- handling message-->' + message.getParam('recordId'));
        // Read the message argument to get the values in the message payload
        if (message != null) {
            component.set('v.showUsrName', message.getParam('recordId'));
            component.set('v.translatedTitle', $A.get('$Label.c.PG_Email_Sent_Title'));
            component.set(
                'v.translatedSubTitle',
                $A.get('$Label.c.PG_Email_Sent_Sub_Title') + ' ' + component.get('v.shforowUsrName')
            );
        }
        alert('---us in handle' + component.get('v.showUsrName'));
    }
});
