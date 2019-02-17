/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        var iconsMap = {
            'Home': 'clinical-trial',
            'Dashboard': 'dashboard',
            'My Referrals': 'referrals',
            'My Referring Clinics': 'referred-clinic',
            'Reports': 'reports',
            'Library': 'resources',
            'Help': 'help',
            'My Patients' : 'referred-patient',
            'Medical Record Review Log' : 'chart-review-sent',
            'My Study Sites' : 'referred-clinic'
        };
        var menuLabel = component.get('v.menuLabel');
        component.set('v.iconName', iconsMap[menuLabel]);
    }
})