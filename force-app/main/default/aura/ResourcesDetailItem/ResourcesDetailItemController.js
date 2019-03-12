/**
 * Created by Yehor Dobrovolskyi on 20.02.2019.020.
 */
({
        doInit: function (component, event, helper) {

        },

        doLike: function (component, event, helper) {
            var resource = component.get('v.resource');
            resource.isVoted = !resource.isVoted;
            helper.setResourceAction(component, resource);
        },

        doFavorite: function (component, event, helper) {
            let resource = component.get('v.resource');
            resource.isFavorite = !resource.isFavorite;
            helper.setResourceAction(component, resource);
        },

        doRender: function (component, event, helper) {
            let frames = document.getElementsByClassName("my_iframe");

            for (let i = 0; i < frames.length; i++) {
                let frame = frames[i];
                frame.setAttribute("allowfullscreen", "allowfullscreen");
            }
        },
    }
)