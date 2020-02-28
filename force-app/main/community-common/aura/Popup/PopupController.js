({
    doInit: function(component, event, helper){
        svg4everybody();
        component._closeModal = $A.getCallback(function(e) {
            var escKey = 27;
            if (!component.isValid()) {
                window.removeEventListener('keyup', component._closeModal);
            } else if((e.which === escKey || e.keyCode === escKey)) {
                component.set("v.closeButtonClicked", !component.get("v.closeButtonClicked"));
                component.set('v.showModal', false);
            }
        });
        //window.addEventListener('keyup', component._closeModal);
    },

    show: function (component) {
        component.set("v.showModal", true);
    },

    scrolling: function (component) {
        document.getElementsByClassName('with-scroll')[0].scrollTop = 0;
        document.getElementsByClassName('with-scroll')[1].scrollTop = 0;
    },

    hide: function(component, event, helper) {
        component.set("v.showModal", false);
        component.set('v.closeButtonClicked', !component.get('v.closeButtonClicked'));
    },

    clickedPrimary: function(component, event, helper) {
        component.set("v.primaryButtonClicked", !component.get("v.primaryButtonClicked"));
        component.set('v.showModal', false);
    },

    clickedSecondary: function(component, event, helper) {
        component.set("v.secondaryButtonClicked", !component.get("v.secondaryButtonClicked"));
        component.set('v.showModal', false);
    },

    showChanged: function (component) {
        var isShow = component.get("v.showModal");
        try{
            if(isShow){
                if(component._closeModal) window.addEventListener('keyup', component._closeModal);
            }else{
                if(component._closeModal) window.removeEventListener('keyup', component._closeModal);
            }
        } catch (e) {
            console.log(e)
        }

    },

    doPreventScrollEvent: function (component, event) {
        event.preventDefault();
    },

    doCancel: function (component) {
        component.hide();
        var closeCallback = component.get('v.closeCallback');
        if(closeCallback) closeCallback();
    }
})