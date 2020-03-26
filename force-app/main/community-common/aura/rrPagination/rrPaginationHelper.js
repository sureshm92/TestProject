({
    setTotalPages: function (component) {
        var entriesOnPage = component.get("v.entriesOnPage");
        var totalObjects = component.get("v.allObjects");

        if (!(+entriesOnPage)) {
            entriesOnPage = totalObjects.length;
            component.set("v.entriesOnPage", entriesOnPage);
        }

        component.set("v.totalPages", Math.ceil(totalObjects.length / entriesOnPage));
    },
    setCurrentPage: function (component) {

        var entriesOnPage = +component.get("v.entriesOnPage");
        var currentPage = +component.get("v.currentPage");
        var totalObjects = component.get("v.allObjects");
        var currentObjects = [];
        var startIndex = (entriesOnPage * currentPage) - entriesOnPage;

        for (var i = startIndex; i < (startIndex + entriesOnPage) && i < totalObjects.length; i++) {
            currentObjects.push(totalObjects[i]);
        }

        component.set("v.currentObjects", currentObjects);
    }
})