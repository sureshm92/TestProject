({
    doInit: function (component, event, helper) {
        helper.showSpinner(component);
        let resourceMode = component.get("v.resourceMode");
        component.find("select-view").set("v.value", component.get("v.viewMode"));
        communityService.executeAction(component, 'getStudyDocuments', null, function (returnValue) {
            if (!returnValue.errorMessage) {
                component.set("v.resourceWrappers", returnValue.wrappers);
                component.set("v.errorMessage", "");
                if (component.get('v.viewMode') === 'icons-view') {
                    helper.castWrappers(component, returnValue.wrappers);
                } else {
                    helper.hideSpinner(component);
                }
            } else {
                component.set("v.errorMessage", returnValue.errorMessage);
                helper.hideSpinner(component);
            }
        });
    },

    navigateToPage: function (component, event, helper) {
        var resourceType = event.currentTarget.dataset.type;
        var resourceId = event.currentTarget.dataset.id;
        var recId = communityService.getUrlParameter('id');
        console.log('------ ' + "resources?resourceType=" + resourceType + "&id=" + recId + '&resId=' + resourceId + '&ret=' + communityService.createRetString());
        communityService.navigateToPage("resources?resourceType=" + resourceType + "&id=" + recId + '&resId=' + resourceId + '&ret=' + communityService.createRetString());
    },

    onViewChange: function (component, event, helper) {
        var mode = component.find("select-view").get("v.value");
        component.set('v.viewMode', mode);
        if (mode === "icons-view") {
            if (component.get('v.currentPageResourceWrappers') == null && component.get('v.resourceWrappers') != null) {
                helper.castWrappers(component, component.get('v.resourceWrappers'));
            } else {
                helper.renderAll(component);
            }
        }
    },

    nextPage: function (component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");
        if (currentPage < totalPages) {
            component.set("v.currentPage", ++currentPage);
            component.set("v.currentPageResourceWrappers", component.get("v.pageListResourceWrappers")[component.get("v.currentPage") - 1]);
            helper.renderAll(component);
        }
    },

    prevPage: function (component, event, helper) {
        var currentPage = component.get("v.currentPage");
        if (currentPage > 1) {
            component.set("v.currentPage", --currentPage);
            component.set("v.currentPageResourceWrappers", component.get("v.pageListResourceWrappers")[component.get("v.currentPage") - 1]);
            helper.renderAll(component);
        }
    }
})