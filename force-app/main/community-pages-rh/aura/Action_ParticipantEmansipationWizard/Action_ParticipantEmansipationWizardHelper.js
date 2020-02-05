/**
 * Created by Alexey Moseev.
 */

({
    preparePathItems : function (component) {

        var statuses = this.getStatuses();
        var statusesMap = this.getStatusesMap();
        var currentImansipationWizardState = statusesMap[statuses[0]];

        component.set('v.showPath', true);

        var pathList = [];
        var iconMap = {
            success : 'icon-check',
            failure : '',
            neutral : '',
            in_progress : ''
        };
        for (var i = 0; i < statuses.length; i++) {

            //default values for path item:
            var pathItem = statusesMap[statuses[i]];
            pathItem.name = statuses[i];

            if (currentImansipationWizardState) {
                if (pathItem.order === currentImansipationWizardState.order) {
                    pathItem.left = 'success';
                    pathItem.state = currentImansipationWizardState.state;
                    pathItem.isCurrent = true;
                } else if (pathItem.order < currentImansipationWizardState.order) {
                    pathItem.left = 'success';
                    pathItem.state = 'success';
                } else {
                    pathItem.state = 'neutral';
                    pathItem.left = 'neutral';
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
    },

    getStatuses : function () {
        return ["Participant", "Delegate(s)", "Provider Access", "Review and Confirm"];
    },

    getStatusesMap : function () {
        return {
            "Participant" : {
                order : 1,
                state : "success"
            },
            "Delegate(s)" : {
                order : 2
            },
            "Provider Access" : {
                order : 3
            },
            "Review and Confirm" : {
                order : 4
            }
        };
    }

});