/**
 * Created by Leonid Bartenev
 */
({
    doNavigateToPage: function(component, event){
        var pagesMap = {
            "My Referrals" : 'my-referrals',
            "My Studies" : '',
            "My Patients" : 'my-patients',
            "My Referring Clinics" : 'my-referring-clinics'
        };
        var pageTitle = event.currentTarget.dataset.pageTitle;
        if(pageTitle){
            communityService.navigateToPage(pagesMap[pageTitle]);
        }
    }
})