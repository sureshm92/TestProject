({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Title', type: 'text'},
            {label: 'Extension', fieldName: 'FileExtension', type: 'text'},
            {label: 'Date Modified', fieldName: 'LastModifiedDate', type: 'date'}
        ]);

        helper.setCurrentFolderItems(component, component.get('v.currentFolderId'));
    },
    openFolder: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.setCurrentFolderItems(component, event.currentTarget.id);
    },
    doBack: function (component, event, helper) {

        var folderId = component.get("v.currentFolderId");
        if(!folderId) return;

        component.set("v.showSpinner", true);

        helper.toParentFolder(component, folderId);
    }
})