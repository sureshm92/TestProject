(
	{
		getStubResource : function (resourceType) {

			var stubResource = {
				"imagePath" : "",
				"title" : "Example of the title for a resource",
				"description" : "Example of the text description for a resource. Here comes any text.",
				"isFavorite" : false,
				"numberOfLikes": Math.round(Math.random()*10)
			};

			if (resourceType === "Video") {
				stubResource.imagePath = "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007oVI&oid=00D0n0000000lXG&lastMod=1550688756000";
			} else {
				stubResource.imagePath = "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007oVN&oid=00D0n0000000lXG&lastMod=1550688735000";
			}

			return stubResource;
		},
	}
)