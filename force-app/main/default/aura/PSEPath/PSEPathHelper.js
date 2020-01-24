/**
 * Created by Leonid Bartenev
 */
({
    updatePathSteps: function (component) {
        var pathItems = [];
        var currentIndex = 100;
        var steps = component.get('v.steps');
        var pe = component.get('v.pe');
        if(!steps) return;
        for(var i = 0; i < steps.length; i++){
            if(pe.Participant_Status__c === steps[i].value) {
                currentIndex = i;
                break;
            }
        }
        for(i = 0; i < steps.length; i++){
            var item = {
                name: steps[i].label,
                left : 'neutral',
                right : 'neutral',
                state : 'neutral',
                isCurrent : (i === currentIndex)
            };
            if(i <= currentIndex){
                item.left = 'success';
                item.state = 'success';
                if(i !== currentIndex) item.right = 'success';
            }
            pathItems.push(item);
        }
        component.set('v.pathItems', pathItems);
    },

    preparePathItems: function (component) {
        console.log('helper');
        var statuses = component.get('v.peStatusesPathList');
        console.log('statuses', JSON.parse(JSON.stringify(statuses)));
        var pe = component.get('v.pe');
        var statusesMap = component.get('v.peStatusStateMap');
        console.log('statusesMap', JSON.parse(JSON.stringify(statusesMap)));
        if(!statusesMap.hasOwnProperty(pe.Participant_Status__c)){
            currentPEState = statusesMap['Enrollment Success'];
        } else{
            var currentPEState = statusesMap[pe.Participant_Status__c];
        }

        //console.log('currentPEState', JSON.parse(JSON.stringify(currentPEState)));
        /*component.set('v.showPath', currentPEState !== undefined && !(communityService.getUserMode() === 'PI' && pe.Participant_Status__c === 'Referral Sent to PI'));
        component.set('v.userMode', communityService.getUserMode());
        var additionalName = [];
        if (pe.Participant_Name__c) additionalName.push(pe.Participant_Name__c);
        if (pe.Participant_Surname__c) additionalName.push(pe.Participant_Surname__c);
        if (additionalName.length > 0) component.set('v.peAdditionalName', additionalName.join(' '));*/
        var pathList = [];
        var iconMap = {
            success: 'icon-check',
            failure: 'icon-close',
            neutral: 'icon-minus',
            in_progress: 'icon-minus'
        };
        console.log('iconMap', JSON.parse(JSON.stringify(iconMap)));
        for (var i = 0; i < statuses.length; i++) {
            console.log('i>',i);
            var num = i + 1;
            //default values for path item:
            var pathItem = {
                name: statuses[i],
                state: 'neutral',
                left: 'neutral'
            };
            if (currentPEState) {
                if (num < currentPEState.order) {
                    pathItem.left = 'success';
                    pathItem.state = 'success';
                } else if (num === currentPEState.order) {
                    pathItem.left = currentPEState.state;
                    pathItem.state = currentPEState.state;
                    pathItem.isCurrent = true;
                }
            }
            pathItem.iconName = iconMap[pathItem.state];
            pathList.push(pathItem);
            if (i > 0) {
                pathList[i - 1].right = pathItem.left;
                pathList[i - 1].nextState = pathItem.state;
            }
        }
        component.set('v.enrollmentPathItems', pathList);
        return pathList;
    }
})