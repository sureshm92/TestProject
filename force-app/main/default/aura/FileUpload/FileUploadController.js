({
	doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        helper.getResourceFiles(component, recordId);

	},
    
    openPopup : function(component, event, helper){
        var isPopupOpen = component.get('v.isPopupOpen');
        component.set('v.isPopupOpen', !isPopupOpen);
    },

    previewFile :function(component,event,helper){
        var recordId = event.currentTarget.id;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [recordId]
        });
    },
    
    save : function(component, event, helper){
        var isPopupOpen = component.get('v.isPopupOpen');
        component.set('v.isPopupOpen', !isPopupOpen);
        helper.saveFileWithLanguage(component);
        $A.get('e.force:refreshView').fire();

    },
    
    handleUpload : function(component, event, helper){
        var isPopupOpen = component.get('v.isPopupOpen');
        var recordId = component.get('v.recordId');
        var uploadedFiles = event.getParam('files');
        component.set('v.uploadedFileId', uploadedFiles[0].documentId);
        component.set('v.isPopupOpen', !isPopupOpen);
        helper.getLanguages(component);
    },

    deleteFile : function(component, event, helper){
        var isPopupOpen = component.get('v.isPopupOpen');
        component.set('v.isPopupOpen', !isPopupOpen);
        helper.deleteFile(component);
    }
    
})