({
    doInit: function (component, event, helper) {
        var wrapper = component.get('v.clinicWrapper');
        var enrollsByStudy = {};//studyName, enrolments[]
        var enrollments = []; //enrollsByStudy[]
        console.log('wrapper>>', JSON.parse(JSON.stringify(wrapper)));
        console.log('clinicWrapper>>', JSON.parse(JSON.stringify(component.get('v.clinicWrapper'))));
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
        console.log('ssId>>', component.get('v.ssId'));
        console.log('enrollmentsByStudy',JSON.parse(JSON.stringify(component.get('v.enrollmentsByStudy'))));
    }
})