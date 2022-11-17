/**
 * Created by Nargiz Mamedova on 6/25/2020.
 */

({
  doMenuExpand: function (component, event, helper) {
    component.set("v.isOpened", true);
    component.getEvent("onshow").fire();
  },

  doMenuCollapse: function (component, event, helper) {
    component.set("v.isOpened", false);
    /*var compEvent = component.getEvent("onBlurOverlayEvent");
    compEvent.fire();*/
    //component.getEvent('onblur').fire();
  },

  doClose: function (component) {
    component.set("v.isOpened", false);
  },

  doOpen: function (component) {
    component.set("v.isOpened", true);
  }
});