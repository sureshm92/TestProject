/**
 * Created by user on 3/11/2020.
 */

({
    doInit: function (component, event, helper) {
        var action = component.get("c.getCPRALink");
        action.setParams({ strCommunityType : 'GSK' });
        action.setCallback(this, function(response) {
            console.log('>>>responseback>>'+response.getReturnValue());
            if(response.getReturnValue())
            {
                var getReturnValueMD = response.getReturnValue();
                component.set('v.isCPRAavailable',true);
                var labelReference = $A.getReference("$Label.c." + getReturnValueMD.CPRA_Label__c);
 
                component.set('v.CPRAlabel', labelReference); 
                component.set('v.CPRALinkToredirect',getReturnValueMD.Link_to_redirect__c); 
            }
            else {
                component.set('v.isCPRAavailable',false); 
            }
            let title = component.get('v.title');
        component.set('v.translatedSubTitle', $A.get('$Label.c.GSK_Login_Sub_Title'));
        if (title === 'Email Sent') {
            component.set('v.translatedSubTitle', $A.get('$Label.c.PG_Email_Sent_Sub_Title'));
        }
    
        });
        $A.enqueueAction(action);

        
    },

    onLinkClick: function (component) {
        var link = component.get('v.CPRALinkToredirect'); 
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            url: link
        });
        urlEvent.fire();
    }
});