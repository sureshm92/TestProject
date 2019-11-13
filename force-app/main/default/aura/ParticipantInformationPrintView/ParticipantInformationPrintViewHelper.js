/**
 * Created by Kryvolap
 */
({
    preparePathItems: function (component) {
        var statuses = component.get('v.peStatusesPathList');
        var pe = component.get('v.pe');
        var statusesMap = component.get('v.peStatusStateMap');
        var currentPEState = statusesMap[pe.Participant_Status__c];
        var pathList = [];
        var iconMap = {
            success: 'icon-check',
            failure: 'icon-close',
            neutral: 'icon-minus',
            in_progress: 'icon-minus'
        };
        for (var i = 0; i < statuses.length; i++) {
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
        component.set('v.pathItems', pathList);
    }
})