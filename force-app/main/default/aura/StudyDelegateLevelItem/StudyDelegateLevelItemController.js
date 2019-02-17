/**
 * Created by Kryvolap on 15.09.2018.
 */
({
    doInit: function (component, event, helper) {
        var studyLevel = component.get("v.studyLevel");
        component.set("v.prevValue", studyLevel.delegateLevel);
    },

    onLevelChange: function (component, event, helper) {
        var changedLevels = new Set(component.get("v.changedLevels"));
        if (changedLevels) {
            var studyLevel = component.get("v.studyLevel");
            var prevValue = component.get("v.prevValue");
            if (prevValue == studyLevel.delegateLevel) {
                changedLevels.delete(studyLevel.enrollmentOrStudySiteId);
            }
            else {
                changedLevels.add(studyLevel.enrollmentOrStudySiteId);
            }
            component.set("v.changedLevels", Array.from(changedLevels));
        }
    }
})