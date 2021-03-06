/*
* WDMBTL object for API interactions, etc
*/

(function(window, $) {

	'use strict';

	var baseUrl = 'http://whatdoesmybeertastelike.com',
			apiUrl = baseUrl + ':8808/review',
      bitlyUrl = 'http://bit.ly/wdmbtl',
			twitterUrl = "http://twitter.com/share",
			facebookUrl = "http://www.facebook.com/sharer.php";

	window.WDMBTL = window.WDMBTL || {

		getReview: function() {
			var defer;
      defer = $.Deferred();
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
      var url, shortReview;
			if (typeof review !== 'string' ||
					typeof hashtag !== 'string') {
				return false;
			}
			url = twitterUrl;
      shortReview = review.substr(0, (140 - (hashtag.length + bitlyUrl.length) - 8));
      if (shortReview.length < review.length) {
        shortReview += '...';
      }
			url += '?text=' + shortReview;
			url += '&hashtags=' + hashtag;
			url += '&url=' + bitlyUrl;
			return url;
		},

		getFacebookUrl: function(review) {
      var url;
			if (typeof review !== 'string') {
				return false;
			}
			url = facebookUrl;
			url += '?t=' + review;
			url += '&u=' + baseUrl;
			return url;
		}

	};

})(window, jQuery);

/*
*	WDMBTL App 
*/

(function(window, $) {

	'use strict';
				
	var $review, 
			$refill, 
			$tweet, 
			$facebook,
			review = "",
			hashtag = "MyBeerTastesLike";

	$(document).ready(function() {
		$review = $('#review');
		$refill = $('#refill').on('click', getReview);
		$tweet = $('#tweet').on('click', tweetThis);
		$facebook = $('#facebook').on('click', facebookThis);
		getReview();
	});

	function getReview() {
		$review.html('Loading...');
		$refill.attr('disabled', true);
		WDMBTL.getReview()
		.done(function(response) {
			review = response;
      review += ".";
			$review.text(review);
		})
		.fail(function(error) {
			$review.text("Uh-oh, something broke");
		})
		.always(function() {
			$refill.removeAttr('disabled');
		});
	}

	function tweetThis() {
		var url = WDMBTL.getTwitterUrl(review, hashtag);
		shareThis(url);
	}

	function facebookThis() {
		var url = WDMBTL.getFacebookUrl(review);
		shareThis(url);
	}

	function shareThis(url) {
		if (typeof url === 'string') {
			window.open(url, '_blank');
		}
	}

})(window, jQuery);
