/**
 * Created by AlexKetch on 4/16/2019.
 */
({
    enqueue: function (component, actionName, actionParams) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get(actionName);
            action.setParams(actionParams || {});
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    resolve(result);
                } else if (state === 'ERROR') {
                    reject(response.getError());
                }
            });
            // Initiate process;
            $A.enqueueAction(action);
        }));
    },
    navigateToRecord: function (recordId) {
        const navigationEvt = $A.get("e.force:navigateToSObject");
        navigationEvt.setParams({
            "recordId": recordId
        });
        navigationEvt.fire();
    },
    showCustomModal: function (modalParams) {
        debugger;
        $A.createComponent("lightning:overlayLibrary", {},
            function(overlayLib, status) {
                if (status === "SUCCESS") {
                    const customCloseCallback = modalParams.closeCallback;
                    modalParams.closeCallback = function () {
                        if (!!customCloseCallback) {
                            // Execute custom callback function if present;
                            customCloseCallback();
                        }
                        // Destroy modal component;
                        overlayLib.destroy();
                    };
                    console.log('modalParams',modalParams);
                    overlayLib.showCustomModal(modalParams)
                }
            });
    },
    notify: function (params) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(params);
        toastEvent.fire();
    },
});