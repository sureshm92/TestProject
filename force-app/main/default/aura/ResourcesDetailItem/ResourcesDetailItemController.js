/**
 * Created by Yehor Dobrovolskyi on 20.02.2019.020.
 */
({
        doInit: function (component, event, helper) {

            var resourceType = component.get("v.resourceType");
            // var resourceType = component.get("v.pageReference").state.resourceType;
            // alert(component.get("v.pageReference").state.resourceType);

            if (resourceType === "Video") {
                component.set("v.resourceImagePosterPath", "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007ofw&oid=00D0n0000000lXG&lastMod=1550657625000");
                // component.set("v.resourceVideoPath", "https://d1kjcxpfvx81dd.cloudfront.net/IQVIA/CRCP/CRCP+participant.mp4");
                component.set("v.resourceVideoPath", "http://players.brightcove.net/2766624905001/default_default/index.html?videoId=6002350973001");
                component.set("v.resourceTitle", "Diet Drinks and Your Health");
                component.set("v.resourceDescription", "Artificially sweetened beverages may increase the risk of stroke.");
                component.set("v.resourceDate", "Monday, February 11th 2019");
                component.set("v.isFavorite", "true");

            } else {
                component.set("v.resourceImagePath", "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007ofr&oid=00D0n0000000lXG&lastMod=1550657643000");
                component.set("v.resourceTitle", "Diet and Inflammation");
                component.set("v.resourceDescription", "What foods to eat and avoid for patients who have rheumatoid arthritis");
                component.set("v.resourceDate", "Monday, February 11th 2019");
            }

        },

        doLike: function (component, event, helper) {
            component.set('v.numberOfLikes', (component.get('v.numberOfLikes') + 1));
        },

        doDisLike: function (component, event, helper) {
            component.set('v.numberOfDislike', (component.get('v.numberOfDislike') + 1));
        },

        doFavorite: function (component, event, helper) {
            component.set('v.isFavorite', (!component.get('v.isFavorite')));
        },

        doRender: function (component, event, helper) {
            var frames = document.getElementsByClassName("my_iframe");

            for (var i = 0; i < frames.length; i++) {
                var frame = frames[i];
                frame.setAttribute("allowfullscreen", "allowfullscreen");
            }
        },
    }
)