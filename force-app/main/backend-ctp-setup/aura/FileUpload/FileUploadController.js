({
    doInit: function (component, event, helper) {
        var urlValue = window.location.href;
        component.find('spinner').show();
        if (sessionStorage) {
            if (sessionStorage.getItem('validationfailed')) {
                component.set('v.showErrorMessage', true);
            }
        }
        if (component.get('v.docIds') && component.get('v.docIds') !== '') {
            component.set('v.documentIdList', component.get('v.docIds').split(','));
        }
        communityService.executeAction(
            component,
            'getResourceFiles',
            {
                resourceId: component.get('v.recordId'),
                docIds: component.get('v.documentIdList')
            },
            function (fileWrapper) {
                component.set('v.validate', function () {
                    if (component.get('v.fileWrapper').listOfFiles.length >= 1) {
                        if (sessionStorage) {
                            sessionStorage.removeItem('validationfailed');
                        }
                        return { isValid: true };
                    } else {
                        if (sessionStorage) {
                            sessionStorage.setItem('validationfailed', true);
                            component.set('v.isNext', true);
                        }
                        return { isValid: false, errorMessage: '' };
                    }
                });
                component.set('v.fileWrapper', fileWrapper);
                component.find('spinner').hide();
            }
        );
    },

    previewFile: function (component, event, helper) {
        var recordId = event.currentTarget.id;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [recordId]
        });
    },

    saveFile: function (component, event, helper) {
        component.find('spinner').show();
        var uploadedFiles = event.getParam('files');
        var docIdList = component.get('v.documentIdList');
        docIdList.push(uploadedFiles[0]['documentId']);
        component.set('v.documentIdList', docIdList);
        component.set('v.docIds', docIdList.toString());
        communityService.executeAction(
            component,
            'updateContentDocument',
            {
                documentId: uploadedFiles[0]['documentId'],
                codeValue: component.get('v.fileWrapper.currentLanguageCode'),
                resourceId: component.get('v.recordId'),
                docIds: component.get('v.documentIdList')
            },
            function (fileWrapper) {
                component.set('v.showErrorMessage', false);
                component.set('v.fileWrapper', fileWrapper);
                component.find('spinner').hide();
            }
        );
    },

    deleteSelectedFile: function (component, event, helper) {
        component.find('spinner').show();
        var docIdList = component.get('v.documentIdList');
        communityService.executeAction(
            component,
            'deleteContentDocument',
            {
                documentId: event.target.id,
                resourceId: component.get('v.recordId'),
                docIds: component.get('v.documentIdList')
            },
            function (fileWrapper) {
                if (docIdList.indexOf(event.target.id) > -1) {
                    docIdList.splice(docIdList.indexOf(event.target.id), 1);
                }
                component.set('v.documentIdList', docIdList);
                component.set('v.docIds', docIdList.toString());
                component.set('v.fileWrapper', fileWrapper);
                component.find('spinner').hide();
            }
        );
    }
});
