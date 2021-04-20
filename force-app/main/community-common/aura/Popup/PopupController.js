({
    doInit: function (component, event, helper) {
        svg4everybody();
        component._closeModal = $A.getCallback(function (e) {
            var escKey = 27;
            if (!component.isValid()) {
                window.removeEventListener('keyup', component._closeModal);
            } else if (e.which === escKey || e.keyCode === escKey) {
                component.set('v.closeButtonClicked', !component.get('v.closeButtonClicked'));
                component.set('v.showModal', false);
            }
        });
        //window.addEventListener('keyup', component._closeModal);
    },

    show: function (component) {
        component.set('v.showModal', true);
    },

    hide: function (component, event, helper) {
        component.set('v.showModal', false);
        component.set('v.closeButtonClicked', !component.get('v.closeButtonClicked'));
    },

    clickedPrimary: function (component, event, helper) {
        component.set('v.primaryButtonClicked', !component.get('v.primaryButtonClicked'));
        component.set('v.showModal', false);
    },

    clickedSecondary: function (component, event, helper) {
        component.set('v.secondaryButtonClicked', !component.get('v.secondaryButtonClicked'));
        component.set('v.showModal', false);
    },

    showChanged: function (component) {
        var isShow = component.get('v.showModal');
        if (isShow) {
            if (component._closeModal) window.addEventListener('keyup', component._closeModal);
        } else {
            if (component._closeModal) window.removeEventListener('keyup', component._closeModal);
        }
    },

    doPreventScrollEvent: function (component, event) {
        event.preventDefault();
    },

    doCancel: function (component, event) {
        component.hide();
        var closeCallback = component.get('v.closeCallback');
        if (closeCallback) closeCallback();
        var isListView = component.get('v.isListView');
        if(isListView==true){
            var parent = component.get('v.parent');
            if(parent!=undefined){
                parent.refreshTable();
            }
        }
        console.log('>>>closeCallback111>>>'+closeCallback);
        console.log('>>>childpopup111>>>'+component.get('v.childpopup'));
        console.log('>>>actionpopupcc>>>'+component.get('v.actionpopupcc'));
        if (component.get('v.childpopup')) {
            var cmpEvent = component.getEvent('cmpEvent');
            cmpEvent.setParams({
                closeAllPopup: 'closewarningpopup'
            });
            cmpEvent.fire();
        }
        if (component.get('v.actionpopupcc')) { 
            //alert('h');
            var cmpEvents = component.getEvent('CloseCCSSInfoEvent');
            cmpEvents.fire();//alert('fire');
        }
         
    }
});