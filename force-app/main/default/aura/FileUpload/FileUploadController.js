({
	doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getResourceFiles', {
            'resourceId' : component.get('v.recordId')
        }, function (listOfUploadedFiles) {
            component.set('v.containsAnyFiles', true);
            component.set('v.listOfUploadedFiles', listOfUploadedFiles);
        });
	},

    previewFile :function(component,event,helper){
        var recordId = event.currentTarget.id;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [recordId]
        });
    },
    
    save : function(component, event, helper){
        var canFileBeSaved = true;
        var selectedLanguage = '';

        if(component.find('selectedOption').get('v.value') === '' || component.find('selectedOption').get('v.value') === undefined){
            selectedLanguage = component.get('v.languagePickListValues')[0];
        } else{
            selectedLanguage = component.find('selectedOption').get('v.value');
        }
        for(var value in component.get('v.listOfUploadedFiles')){
            if(selectedLanguage === component.get('v.listOfUploadedFiles')[value]['ContentDocument']['Title']){
                canFileBeSaved = false;
                break;
            }
        }
        if(canFileBeSaved){
            communityService.executeAction(component, 'updateContentDocument', {
                'documentId' : component.get('v.uploadedFileId'),
                'codeValue' : component.find('selectedOption').get('v.value')
            }, function () {
                helper.openPopup(component, event, helper);
                $A.get('e.force:refreshView').fire();
            });
        } 
    },
    
    handleUpload : function(component, event, helper){
        var recordId = component.get('v.recordId');
        var uploadedFiles = event.getParam('files');
        component.set('v.uploadedFileId', uploadedFiles[0].documentId);
        helper.openPopup(component, event, helper);

        communityService.executeAction(component, 'prepareListOfLanguages', null, function (listOfLanguages) {
            component.set('v.languagePickListValues', listOfLanguages);
        });
    },

    deleteFile : function(component, event, helper){
        helper.openPopup(component, event, helper);
        communityService.executeAction(component, 'deleteContentDocument', {
            'documentId' : component.get('v.uploadedFileId')
        }, function () {});
    },

    deleteSelectedFile : function(component, event, helper){
        communityService.executeAction(component, 'deleteContentDocument', {
            'documentId' : event.target.id
        }, function () {
            $A.get('e.force:refreshView').fire();
        });
    }
    
})