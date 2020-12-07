({
    // Your renderer method overrides go here
    unrender: function (component, event) {
        this.superUnrender();
        if (sessionStorage) {
            if (!component.get('v.isNext')) {
                sessionStorage.removeItem('validationfailed');
            }
        }
    }
});
