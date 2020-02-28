({
    topLevelFolderId: '',
    isTopLevelFolder: true,
    setCurrentFolderItems: function(component, folderId){

        console.log("folderId= " + folderId);

        var action = component.get('c.getFolderItems');
        action.setParams({
            userMode: component.get('v.userMode'),
            folderId: folderId ? folderId : null
        });

        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS" && response.getReturnValue()) {

                var result = JSON.parse(response.getReturnValue());
                component.set("v.folderItems", result);

                if(!result.length) {
                    component.set("v.emptyListMessage", $A.get("$Label.c.Doc_L_Oh_no_there_are_no_items_here"));
                }

                //populate topLevelFolderId
                if(!this.topLevelFolderId && result.length) {
                    this.topLevelFolderId = result[0].ParentContentFolderId;
                    this.isTopLevelFolder = true;
                }

                if(folderId) this.isTopLevelFolder = (folderId === this.topLevelFolderId);

                if(this.isTopLevelFolder) {
                    component.set("v.currentFolderId", '');
                } else if(folderId) {
                    console.log("1");
                    component.set("v.currentFolderId", folderId);
                }


                console.log("this.isTopLevelFolder= " + this.isTopLevelFolder);
                console.log("currentFolderId= " + component.get("v.currentFolderId"));
            } else {
                this.showErrorToast("Error:" + response.getError()[0].message);
            }
            component.set("v.showSpinner", false);
            console.log("this.topLevelFolderId= " + this.topLevelFolderId);
        });
        $A.enqueueAction(action);
    },
    toParentFolder: function (component, currentFolderId) {
        console.log("folderId= " + currentFolderId);
        var action = component.get('c.getParentFolderId');
        action.setParams({
            userMode: component.get('v.userMode'),
            folderId: currentFolderId
        });
        action.setCallback(this, function (response) {
            console.log("id=" + response.getReturnValue());
            if (response.getState() === "SUCCESS" && response.getReturnValue()) {
                var parentId = JSON.parse(response.getReturnValue());

                this.setCurrentFolderItems(component, parentId);
            } else {
                this.showErrorToast("Error:" + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    showErrorToast: function (message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": message,
            "type": "error",
            "duration": 10000
        });
        toastEvent.fire();
    }
})