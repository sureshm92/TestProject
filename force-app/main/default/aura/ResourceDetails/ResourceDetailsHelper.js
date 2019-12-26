/**
 * Created by Slav on 26.12.2019.
 */

({

        //----------------------------------------------------------//
        // build a Resource__c object and assign to the "res" attr  //
        //----------------------------------------------------------//
        buildResource: function (component) {
            var res = {
                Title__c         : component.get("v.res_title"),
                document_type__c : component.get("v.res_doctype"),
                Description__c   : component.get("v.res_description"),
                Video__c         : component.get("v.res_video"),
                Language__c      : component.get("v.res_language"),
                Version_Date__c  : component.get("v.res_version")
            };
            component.set("v.res", res);
        },

});