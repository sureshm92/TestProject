({
    showPage : function(component, event) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var page_type = url.searchParams.get("page_types");
        var show = false;
        if(page_type === 'underage'){
            show = true;
        }
        component.set('v.showUnderAge', show);
    }
})