/**
 * Created by Kryvolap on 15.09.2018.
 */
({
    doExecute: function (component, event) {
        var params = event.getParam('arguments');
        var delegate = params.delegate;
        var userMode = component.get('v.userMode');
        var refreshSource = params.refreshSource;
        var isCreate = params.isCreate;
        var mainspinner = refreshSource.find('mainSpinner');
        mainspinner.show();
        component.set('v.delegate', delegate);
        component.set('v.refreshSource', refreshSource);
        component.set('v.saveInProgress', true);
        communityService.executeAction(component, 'saveDelegateLevelChanges', {
            userMode: userMode,
            delegate: JSON.stringify(delegate)
        }, function (returnValue) {
            if(isCreate){
                communityService.showToast("success","success",$A.get("$Label.c.TST_You_have_successfully_created_permissions_for") + " " +
                    (delegate.delegateContact.FirstName || "") + " " + delegate.delegateContact.LastName + ".") ;
            }
            else{
                communityService.showToast("success","success",$A.get("$Label.c.TST_You_have_successfully_updated_permissions_for") + " " +
                    (delegate.delegateContact.FirstName || "") + " " + delegate.delegateContact.LastName + ".") ;
            }

            refreshSource.refresh();
        }, null, function () {
            component.set('v.saveInProgress', false);
            mainspinner.hide();
        });

    },
})