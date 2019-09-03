/**
 * Created by Igor Malyuta on 03.09.2019.
 */

({
    peBySession: {},

    isToastDisplayed : function (peId) {
        var isDisplayed = this.peBySession[peId] !== undefined;
        this.peBySession[peId] = peId;
        return isDisplayed;
    }
});