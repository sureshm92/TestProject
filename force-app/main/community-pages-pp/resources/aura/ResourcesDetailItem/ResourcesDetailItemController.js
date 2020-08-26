/**
 * Created by Yehor Dobrovolskyi on 20.02.2019.020.
 */
({
        doInit : function (component, event, helper) {
            component.set('v.subDomain', communityService.getSubDomain());
            component.set('v.userMode', communityService.getUserMode());
        },

        doLike : function (component, event, helper) {
            let resourceWrapper = component.get('v.resourceWrapper');
            resourceWrapper.isVoted = !resourceWrapper.isVoted;
            helper.setResourceAction(component, resourceWrapper);
        },

        doFavorite : function (component, event, helper) {
            let resourceWrapper = component.get('v.resourceWrapper');
            resourceWrapper.isFavorite = !resourceWrapper.isFavorite;
            helper.setResourceAction(component, resourceWrapper);
        },

        doRender : function (component, event, helper) {
            let frames = document.getElementsByClassName("my_iframe");

            for (let i = 0; i < frames.length; i++) {
                let frame = frames[i];
                frame.setAttribute("allowfullscreen", "allowfullscreen");
            }
        },
    }
)