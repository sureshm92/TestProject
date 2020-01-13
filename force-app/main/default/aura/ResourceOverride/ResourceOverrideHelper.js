/**
 * Created by Slav on 26.12.2019.
 */

({
        //----------------------------------------------------------//
        // Assigns Component related metadata to its attributes     //
        //----------------------------------------------------------//
        parseMetadata: function (component, returnValue) {
            component.set("v.docTypes",             returnValue.docTypes);
            component.set("v.languageNames",        returnValue.languageNames);
            component.set("v.languageLabels",       returnValue.languageLabels);
            component.set("v.contentClasses",       returnValue.contentClasses);
            component.set("v.thirdPartySources",    returnValue.thirdPartySources);
            component.set("v.countries",            returnValue.countries);
            component.set("v.videoLinkHelp",        returnValue.videoLinkHelp);
            component.set("v.imageLinkHelp",        returnValue.imageLinkHelp);
            component.set("v.defaultLanguage",      returnValue.defaultLanguage);
            component.set("v.defaultDocType",       returnValue.defaultDocType);
            component.set("v.recTypeId",            returnValue.recTypeId);
            component.set("v.recTypeName",          returnValue.recTypeName);
            component.set("v.recTypeDevName",       returnValue.recTypeDevName);
        },

        //----------------------------------------------------------//
        // Performs field level validation on the form              //
        //----------------------------------------------------------//
        validateForm: function (component, event, helper) {
            var form = component.find("form");
            var inputs = form.find({ instancesOf : "lightning:input" });
            inputs = inputs.concat(form.find({ instancesOf : "lightning:select" }));
            inputs = inputs.concat(form.find({ instancesOf : "lightning:textarea" }));

            var valid = true;
            for(var i=0; i < inputs.length; i++) {
                inputs[i].showHelpMessageIfInvalid();
                valid &= inputs[i].get("v.validity").valid;
            }

            if (!valid) {
                component.set('v.isError', true);
                component.set('v.message', 'Review the errors on this page');
            } else {
                helper.resetMessages(component);
            }

            return valid;
        },

        //----------------------------------------------------------//
        // Resets all fields on the form                            //
        //----------------------------------------------------------//
        resetForm: function (component) {
            component.set("v.recordId",                 null);
            component.set('v.record',                   null);
            component.set("v.Title__c",                 null);
            component.set("v.document_type__c",         component.get("v.defaultDocType"));
            component.set("v.Description__c",           null);
            component.set("v.Video__c",                 null);
            component.set("v.Language__c",              component.get("v.defaultLanguage"));
            component.set("v.Version_Date__c",          null);
            component.set("v.Subtitle__c",              null);
            component.set("v.Image__c",                 null);
            component.set("v.Image_Title__c",           null);
            component.set("v.Content_Class__c",         null);
            component.set("v.Posting_Date__c",          null);
            component.set("v.Expiration_Date__c",       null);
            component.set("v.Updated_Date__c",          null);
            component.set("v.Body__c",                  null);
            component.set("v.Author_s_Name__c",         null);
            component.set("v.Source__c",                null);
            component.set("v.Copyright__c",             null);
            component.set("v.X3rd_Party_Source__c",     null);
            component.set("v.Therapeutic_Areas__c",     null);
            component.set("v.Image_Subtitle__c",        null);
            component.set("v.Byline__c",                null);
            component.set("v.URL_Part__c",              null);
            component.set("v.article_external_link__c", null);
            component.set("v.Remove_sharing__c",        false);
            component.set("v.URL__c",                   null);
            component.set("v.Countries__c",             null);
        },

        //----------------------------------------------------------//
        // Resets all messages on the form                          //
        //----------------------------------------------------------//
        resetMessages: function (component) {
            component.set('v.isInfo',       false);
            component.set('v.isSuccess',    false);
            component.set('v.isError',      false);
        },

        //----------------------------------------------------------//
        // build a Resource__c record and assign to the "record"    //
        //----------------------------------------------------------//
        buildRecord: function (component) {
            var country = component.get("v.Countries__c").join(';');
            if(component.get("v.Countries__c").length > 0)
            var record = {
                Title__c                    : component.get("v.Title__c"),
                document_type__c            : component.get("v.document_type__c"),
                Description__c              : component.get("v.Description__c"),
                Video__c                    : component.get("v.Video__c"),
                Language__c                 : component.get("v.Language__c"),
                Version_Date__c             : component.get("v.Version_Date__c"),
                Subtitle__c                 : component.get("v.Subtitle__c"),
                Image__c                    : component.get("v.Image__c"),
                Image_Title__c              : component.get("v.Image_Title__c"),
                Content_Class__c            : component.get("v.Content_Class__c"),
                Posting_Date__c             : component.get("v.Posting_Date__c"),
                Expiration_Date__c          : component.get("v.Expiration_Date__c"),
                Updated_Date__c             : component.get("v.Updated_Date__c"),
                Body__c                     : component.get("v.Body__c"),
                Author_s_Name__c            : component.get("v.Author_s_Name__c"),
                Source__c                   : component.get("v.Source__c"),
                Copyright__c                : component.get("v.Copyright__c"),
                X3rd_Party_Source__c        : component.get("v.X3rd_Party_Source__c"),
                Therapeutic_Areas__c        : component.get("v.Therapeutic_Areas__c"),
                Image_Subtitle__c           : component.get("v.Image_Subtitle__c"),
                Byline__c                   : component.get("v.Byline__c"),
                URL_Part__c                 : component.get("v.URL_Part__c"),
                article_external_link__c    : component.get("v.article_external_link__c"),
                Remove_sharing__c           : component.get("v.Remove_sharing__c"),
                URL__c                      : component.get("v.URL__c"),
                Countries__c                : country
            };
            component.set("v.record", record);
        },
});