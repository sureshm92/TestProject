(
	{
		getStubResource : function (resourceType, resourceMode) {

			var stubResource = {
				"imagePath" : "",
				"title" : "Example of the title for a resource",
				"description" : "Example of the text description for a resource. Here comes any text that should highlight the main point of an article or video.",
				"isFavorite" : false,
				"numberOfLikes": Math.round(Math.random()*10)
			};

			if (resourceType === "Videos") {
				stubResource.imagePath = "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007oVI&oid=00D0n0000000lXG&lastMod=1550688756000";
				stubResource.type = "Video";
			} else {
				stubResource.imagePath = "https://quintilesimscmo--hpsdevv3--c.documentforce.com/servlet/servlet.ImageServer?id=0150n0000007oVN&oid=00D0n0000000lXG&lastMod=1550688735000";
				stubResource.type = "Article";
			}

			if(resourceMode === "Favorite") {
				stubResource.isFavorite = true;
			}

			return stubResource;
		},
	}
)