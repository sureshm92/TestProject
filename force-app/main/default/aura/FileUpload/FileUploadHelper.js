({
	getResourceFiles : function(component, recordId) {
		var action = component.get('c.getResourceFiles');
        action.setParams({
                resourceId: recordId
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var listOfFiles = response.getReturnValue();
                if(listOfFiles !== undefined && listOfFiles.length !== 0){
                    component.set('v.containsAnyFiles', true);
                    component.set('v.listOfUploadedFiles', response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
	},

    getLanguages : function(component){
        var action = component.get('c.prepareListOfLanguages');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var listOfLanguages = response.getReturnValue();
                if(listOfLanguages != undefined && listOfLanguages.length != 0){
                    component.set('v.languagePickListValues', listOfLanguages);
                }
            }
        });
        $A.enqueueAction(action);
    },

    saveFileWithLanguage : function(component){
        var documentIdToUpdate = component.get('v.uploadedFileId');
        var action = component.get('c.updateContentDocument');
        action.setParams( {
                documentId: documentIdToUpdate,
                codeValue: component.find('selectedOption').get("v.value")
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {}
        });
        $A.enqueueAction(action);
    },

    deleteFile : function(component){
	    var documentIdToDelete = component.get('v.uploadedFileId');
        var action = component.get('c.deleteContentDocument');
        action.setParams( {
                documentId: documentIdToDelete
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {}
        });
        $A.enqueueAction(action);
    }
})