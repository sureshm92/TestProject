({
    FILE_SIZE_LIMIT: 2000000,
    FILE_TOTAL_SIZE_LIMIT: 10000000,

    handleFileSelection: function (component, files) {
        for (var i = 0; i < files.length; i++) this.addFile(component, files[i]);
    },

    addFile: function (component, file) {
        if (file.size > this.FILE_SIZE_LIMIT) {
            communityService.showToast(
                'error',
                'error',
                $A.get('$Label.c.TST_Screenshot_size_limit_2MB_exceeded')
            );
            return;
        }

        var fr = new FileReader();
        var helper = this;
        fr.onloadend = $A.getCallback(function () {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);

            var newFile = {};
            newFile.fileName = file.name;
            newFile.base64Data = fileContents;
            newFile.contentType = file.type;
            newFile.size = file.size;
            newFile.tmpId = '' + Math.floor(Math.random() * 1000000);

            var fileList = component.get('v.fileList');
            if (!fileList) fileList = [];
            if (!helper.checkSizeLimit(helper, fileList)) return;
            fileList.push(newFile);
            component.set('v.fileList', fileList);
        });
        fr.readAsDataURL(file);
    },

    createNewCase: function (component, text, type) {
        var fileList = component.get('v.fileList');
        if (fileList) if (!this.checkSizeLimit(this, fileList)) return;
        var spinner = component.find('spinner');
        spinner.show();

        communityService.executeAction(
            component,
            'createCase',
            {
                description: text,
                type: type,
                files: fileList ? JSON.stringify(fileList) : ''
            },
            function () {
                component.set('v.fileList', []);
                spinner.hide();
                if (type === 'Problem') {
                    communityService.showSuccessToast(
                        null,
                        $A.get(
                            '$Label.c.TST_Thank_you_for_logging_a_problem_We_will_investigate_and_get_back_to_you'
                        )
                    );
                } else if (type === 'Feedback') {
                    communityService.showSuccessToast(
                        null,
                        $A.get('$Label.c.TST_Thank_you_for_your_feedback')
                    );
                } else if (type === 'Privacy') {
                    communityService.showSuccessToast(
                        null,
                        $A.get('$Label.c.PG_HLP_Req_Data_Poput_Mess')
                    );
                }
            },
            function (error) {
                communityService.showErrorToast(null, $A.get('$Label.c.TST_Something_went_wrong'));
                communityService.logErrorFromResponse(error);
            }
        );
    },

    checkSizeLimit: function (helper, files) {
        var totalSize = 0;
        for (var i = 0; i < files.length; i++) totalSize += files[i].size;

        if (totalSize > helper.FILE_TOTAL_SIZE_LIMIT) {
            communityService.showErrorToast(
                null,
                $A.get('$Label.c.TST_Screenshots_size_limit_10MB_exceeded')
            );
            return false;
        }
        return true;
    },

    clearFieldAfterSubmit: function (attributeName, component) {
        component.set('v.' + attributeName, '');
    }
});
