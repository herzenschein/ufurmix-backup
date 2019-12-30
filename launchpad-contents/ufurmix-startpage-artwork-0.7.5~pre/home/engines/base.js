var apiUrl = "http://go.infinise.com/api/2.5/";


/*	GOOGLE
	----------------------------------------------------- */

eng.google = {
	pageTitle: "Google",
	logo: "google.png",
	places: {
		'Web'    : ["http://www.google.com/search?q=%query%&hl=en",		apiUrl+"?eng=google&timestamp=%time%&q=%query%"],
		'Images' : ["http://images.google.com/images?q=%query%&hl=en",	apiUrl+"?eng=google&timestamp=%time%&q=%query%"],
		'Maps'   : ["http://maps.google.com/maps?q=%query%",			false]
	}
};


/*	WIKIPEDIA
	----------------------------------------------------- */
	
eng.wikipedia = {
	pageTitle: "Wikipedia",
	logo: "wikipedia.png",
	places: {
		'Go to Article' : ["http://%lang%.wikipedia.org/wiki/Special:Search?search=%query%&go=Go",				apiUrl+"?eng=wikipedia&timestamp=%time%&q=%query%&hl=%lang%"],
		'Search'        : ["http://%lang%.wikipedia.org/wiki/Special:Search?search=%query%&fulltext=Search",	apiUrl+"?eng=wikipedia&timestamp=%time%&q=%query%&hl=%lang%"],
	},
	languages: {
		'': 'en'

	}
};


/*	UFURMIX
	----------------------------------------------------- */

eng.ufurmix = {
	pageTitle: "Furry Remix",
	logo: "ufurmix.png",
	places: {
		'Ubuntu Documentation' : ["https://help.ubuntu.com/search.html?cof=FORID%3A9&cx=004599128559784038176%3Avj_p0xo-nng&ie=UTF-8&q=%query%&sa=Search", false],
		'Furry Remix FAQs' : ["https://answers.launchpad.net/ufurmix/+faqs?field.search_text=%query%&field.actions.search=Search", false]
	},
};


/*	WIKIFUR
	----------------------------------------------------- */

eng.wikifur = {
	pageTitle: "WikiFur",
	logo: "wikifur.png",
	places: {
		'Go to article' : ["http://%lang%.wikifur.com/wiki/Special:Search?search=%query%&go=Go", false],
		'Search'        : ["http://%lang%.wikifur.com/wiki/Special:Search?search=%query%&fulltext=Search", false],
	},
	languages: {
		'': 'en'
	}
};
