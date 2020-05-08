({
	doinit : function(component, event, helper) {
		var siteRankData = component.get('v.siteRankData');
		siteRankData.site_Name = component.get('v.siteRankData.site_Name');
		component.set('v.siteRankData', siteRankData);
	}
})