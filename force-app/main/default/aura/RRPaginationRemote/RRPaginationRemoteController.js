/**
 * Created by Leonid Bartenev
 */
({
    doCalcTotalPages: function (component) {
        var allRecordsCount = component.get('v.allRecordsCount');
        var pageRecordsCount = component.get('v.entriesOnPage');
        var pagesCount = Math.ceil(allRecordsCount / pageRecordsCount);
        component.set('v.totalPages', pagesCount);

    },

    doNextPage: function (component) {
        var currentPage = component.get('v.currentPage');
        var totalPages = component.get('v.totalPages');
        if(currentPage < totalPages)
        component.set('v.currentPage',currentPage + 1);
    },

    doPrevPage: function(component){
        var currentPage = component.get('v.currentPage');
        if(currentPage > 1)
            component.set('v.currentPage',currentPage - 1);
    }
})