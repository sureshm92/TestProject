({
    doInit: function (cmp, event) {
        cmp.set('v.communityName', communityService.getCurrentCommunityName());
        setTimeout(function () {
            if (
                'my-referrals' == cmp.get('v.currentPage') ||
                'my-patients' == cmp.get('v.currentPage')
            ) {
                document.getElementsByClassName('active')[0].click();
            }
        }, 1000);
    }
});
