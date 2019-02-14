({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var tabId = communityService.getUrlParameter("tab");
        if(tabId && (tabId === "feedback" || tabId === "problem" || tabId === "help"))  component.set("v.currentTab", tabId);
        component.set('v.userMode', communityService.getUserMode());
        component.set("v.isInitialized", true);

    },

    submitRequest: function (component, event, helper) {
        var description = component.get("v.description");
        if(!description) {
            communityService.showToast("warning", "warning", $A.get("$Label.c.TST_Complete_description"));
            return;
        }

        var currentTab = component.get("v.currentTab");
        var type;

        if(currentTab === "feedback"){
            type = "Feedback";
        } else if (currentTab === "problem") {
            type = "Problem";
        } else {
            communityService.showToast("error", "error", $A.get("$Label.c.TST_Incorrect_user_data"));
            return;
        }
        helper.createNewCase(component, description, type);
    },

    onFileSelect: function (component, event, helper) {
        var files = event.target.files;
        helper.handleFileSelection(component, files);
    },

    onDragOver: function (component, event, helper) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';

        var files = event.dataTransfer.files;
        helper.handleFileSelection(component, files);
    },

    handleRemoveFile: function (component, event, helper) {
        event.preventDefault();
        var tmpId = event.getSource().get('v.name');
        console.log("tmpId= " + tmpId);
        var fileList = component.get("v.fileList");
        var newList = [];

        for(var i = 0; i < fileList.length; i++){
            if(fileList[i].tmpId === tmpId) continue;
            newList.push(fileList[i]);
        }
        component.set("v.fileList", newList);
    }
})