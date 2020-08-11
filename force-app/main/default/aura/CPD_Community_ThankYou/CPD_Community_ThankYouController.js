({
    doInit: function (component, event, helper) {
        helper.showPage(component, event);
        window.onbeforeunload = null;        
    }
})