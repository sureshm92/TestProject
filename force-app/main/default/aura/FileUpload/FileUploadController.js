({
	doInit : function(component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getResourceFiles', {
            'resourceId' : component.get('v.recordId')
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
        var selectedLanguage = '';
        var recordId = component.get('v.recordId');
        var uploadedFiles = event.getParam('files');

        if(component.find('selectedOption').get('v.value') === '' || component.find('selectedOption').get('v.value') === undefined){
            selectedLanguage = component.get('v.fileWrapper')['listOfLanguages'][0];
        } else{
            selectedLanguage = component.find('selectedOption').get('v.value');
        }
        communityService.executeAction(component, 'updateContentDocument', {
            'documentId' : uploadedFiles[0]['documentId'],
            'codeValue' : component.find('selectedOption').get('v.value'),
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