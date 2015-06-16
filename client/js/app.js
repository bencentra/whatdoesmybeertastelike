/*
* WDMBTL object for API interactions
*/

(function(window, $) {

'use strict';

var baseUrl = 'http://whatdoesmybeertastelike.com',
		apiUrl = baseUrl + ':8808/review',
		twitterUrl = "http://twitter.com/share",
		facebookUrl = "http://www.facebook.com/sharer.php";

window.WDMBTL = window.WDMBTL || {

	getReview: function() {
		var defer = $.Deferred();
		$.ajax({
			method: 'GET',
			url: apiUrl,
			dataType: 'text',
			success: function(response) {
				defer.resolve(response);
			},
			error: function(error) {
				defer.reject(error);
			}
		});
		return defer.promise();
	},

	getTwitterUrl: function(review, hashtag) {
		if (typeof review !== 'string' ||
				typeof hashtag !== 'string') {
			return false;
		}
		var url = twitterUrl;
		url += '?text=' + review;
		url += '&hashtags=' + hashtag;
		url += '&url=' + baseUrl;
		return url;
	},

	getFacebookUrl: function(review) {
		if (typeof review !== 'string') {
			return false;
		}
		var url = facebookUrl;
		url += '?t=' + review;
		url += '&u=' + baseUrl;
		return url;
	}

};

})(window, jQuery);