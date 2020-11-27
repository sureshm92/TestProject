({
    resetPagination: function (component, event, helper) {
        helper.setTotalPages(component);
        helper.setCurrentPage(component);
        var check = component.get('v.studyVisitPageCheck');
        if (!check) {
            component.set('v.currentPage', 1);
        }
    },
    setPage: function (component, event, helper) {
        helper.setCurrentPage(component);
    },
    previousPage: function (component, event, helper) {
        var currentPage = component.get('v.currentPage');
        if (currentPage > 1) {
            component.set('v.currentPage', --currentPage);
        }
    },
    nextPage: function (component, event, helper) {
        var currentPage = component.get('v.currentPage');
        var totalPages = component.get('v.totalPages');
        if (currentPage < totalPages) {
            component.set('v.currentPage', ++currentPage);
        }
    },
    getPageNumer: function (component) {
        var currentPageNumber = component.get('v.currentPage');
        return currentPageNumber;
    }
});
