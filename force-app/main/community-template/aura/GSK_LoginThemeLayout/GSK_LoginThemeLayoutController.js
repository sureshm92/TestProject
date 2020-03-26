/**
 * Created by user on 3/11/2020.
 */

({
    doInit: function (component, event, helper) {
        let title = component.get('v.title');
        component.set('v.translatedSubTitle', $A.get('$Label.c.GSK_Login_Sub_Title'));
        if(title === 'Email Sent'){
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Email_Sent_Sub_Title'));
        }
    }
});