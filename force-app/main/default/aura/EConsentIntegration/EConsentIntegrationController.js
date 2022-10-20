({
	doInit: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getPermission',
            {
                ctpId: component.get('v.recordId')
            },
            function (initData) {
                component.set('v.userPermission', initData.userPermission);
                component.set('v.usrPermission', initData.userPermission);
                component.set('v.usrProfilePermission', initData.userProfilePermission);
                component.set('v.usrStudySiteSize', initData.ssListSize );
                if(!initData.econsentpermissioncheck){
                     component.set('v.userPermission', 'Disabled');
                     component.set('v.econsentPermission', false);
                }else{
                     component.set('v.econsentPermission', true);
                }
                if(component.get('v.usrPermission') == 'View'){
                     component.set('v.isreadonly', true);
                }else{
                     component.set('v.isreadonly', false);
                }
                component.find('spinner').hide();
            }
        );
    },
    handleEvents : function(cmp, event) {
        if(cmp.get('v.usrPermission') != 'Disabled') {
            if(cmp.get('v.econsentPermission')){
                cmp.set('v.econsentPermission', false);
            }else{
                cmp.set('v.econsentPermission', true);
            }
            if(cmp.get('v.econsentPermission')){
                cmp.set('v.userPermission',cmp.get('v.usrPermission'));
            }else{
                cmp.set('v.userPermission','Disabled');
            }
        }
    }
})