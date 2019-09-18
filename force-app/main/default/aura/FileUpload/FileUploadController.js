({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getResourceFiles', {
            'resourceId': component.get('v.recordId')
        }, function (fileWrapper) {
            helper.handleInit(component, fileWrapper);
        });
    },

    previewFile :function(component,event,helper){
        var recordId = event.currentTarget.id;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [recordId]
        });
    },
    
    saveFile : function(component, event, helper){
        component.find('spinner').show();
        var uploadedFiles = event.getParam('files');
        communityService.executeAction(component, 'updateContentDocument', {
            'documentId' : uploadedFiles[0]['documentId'],
            'codeValue' : component.get('v.fileWrapper.currentLanguageCode'),
            'resourceId' : component.get('v.recordId')
        }, function (fileWrapper) {
            helper.handleInit(component, fileWrapper);
        });
    },

    deleteSelectedFile : function(component, event, helper){
        component.find('spinner').show();
        communityService.executeAction(component, 'deleteContentDocument', {
            'documentId' : event.target.id,
            'resourceId' : component.get('v.recordId')
        }, function (fileWrapper) {
            helper.handleInit(component, fileWrapper);
        });
    }
    
})