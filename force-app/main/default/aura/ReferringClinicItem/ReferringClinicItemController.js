({
    doInit: function (component, event, helper) {

        if(component.get("v.filterByStudy")){
            
            var wrapper = component.get("v.clinicWrapper");
            var enrollsByStudy = {};//studyName, enrolments[]
            var enrollments = []; //enrollsByStudy[]

            for(var i = 0; i < wrapper.enrollments.length; i++){

                var studyName = wrapper.enrollments[i].enrollment.Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c;

                if(!(studyName in enrollsByStudy)){
                    enrollsByStudy[studyName] = [];
                }
                enrollsByStudy[studyName].push(wrapper.enrollments[i]);
            }

            for(var key in enrollsByStudy){

                var enrollmentWrapper = {};
                enrollmentWrapper.studyName = key;
                enrollmentWrapper.enrollments = enrollsByStudy[key];

                enrollments.push(enrollmentWrapper);
            }

            component.set("v.enrollmentsByStudy", enrollments);
        }
    }
})