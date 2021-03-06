var healthCodeMap = healthCodeMap || {};

var healthCodeMap = {

	initMap: function() {
		var apiKey = 'e835cf86df4c4575ac7be175cca8bba9',
		styleID = '997',
		southWest = new L.LatLng(42.252215, -71.198273),
		northEast = new L.LatLng(42.392589, -71.005325),
		bounds = new L.LatLngBounds(southWest, northEast),
		center = new L.LatLng(42.351074, -71.066008),
		map_options = { center: center, zoom: 15, maxBounds: bounds },
		attribution = 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
		tile_url = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
		tile_layer_options = { attribution: attribution, maxZoom: 18, detectRetina: true };
		healthCodeMap.map = L.map('map', map_options);
		L.tileLayer(tile_url, tile_layer_options).addTo(healthCodeMap.map);
	},

	markers: [],

	plotRestaurants: function() {
		var circle_options = { color: 'red', fillColor: '#a03', fillOpacity: 1};
		var markers = healthCodeMap.markers;
		for (var i = 0; i < restaurant_data.length; i++) {
			var lng = restaurant_data[i].lng,
					lat = restaurant_data[i].lat,
					name = restaurant_data[i].label,
					address = restaurant_data[i].address,
					city = restaurant_data[i].city,
					owner = restaurant_data[i].owner,
					violations_count = restaurant_data[i].violations_count,
					marker_text =
					"<p class='restaurant-name'>" + name + "</p> \
					<div class='popup-wrapper'> \
					<div class='left'> \
					<p class='address'>" + address + "<br />" + city + "</p> \
					<p class='owner'><strong>Owner:</strong> " + owner +
					"</div> \
					<div class='right'> \
					<p class='violations_heading'>Violations</p> \
					<p class='violations_count'>" + violations_count +
					"<p class = 'violations_click_notice'>(click for list)</p> \
					</div> \
					</div>";

			markers[i] = L.circle([lat, lng], 5, circle_options);

			markers[i].bindPopup(marker_text);
			healthCodeMap.map.addLayer(markers[i]);

			var createMouseOverHandler = function(){
				var index = i;
				return function(evt){
					evt.target.openPopup();
					$('.right').on('click', function(evt){
						$('#popup').show();
						$('#overlay').show();
						healthCodeMap.fillPopupWindow(index);
					});
				};
			};
			markers[i].on('mouseover', createMouseOverHandler());
		};
	},

	closeWindows: function(){
		if ( $('#popup').is(':visible') ) {
			$('#popup').hide();
			$('#overlay').hide();
		};
	},

	startEventListeners: function(){
		healthCodeMap.map.on('click', function(){
			healthCodeMap.closeWindows();
		});

		$(document).on('click', function(evt){
			if (evt.target.className != 'popup-text') {
				healthCodeMap.closeWindows();
			};
		});

		$(document).keyup(function(evt) {
			if (evt.keyCode == 27) {
				healthCodeMap.closeWindows()
				healthCodeMap.map.closePopup()
			};
		});
	},

	fillPopupWindow: function(i){
		var violation_data = restaurant_data[i].violations,
				name = restaurant_data[i].label,
				violation_list_head = "<h4 class='popup-text'>" + name + "</h4>";
		$('.violations_list').html(violation_list_head)
		for (var i = 0; i < violation_data.length; i++) {
			var level = violation_data[i].level;
					description = violation_data[i].description,
					// comments = violation_data[i].comments,
					dttm = violation_data[i].violation_dttm,
					violation_html = 
					"<li><p class='popup-text'>" + description + "</p> \
					<p class='subtext popup-text'>date/time: " + dttm +
					"&nbsp;&nbsp;&nbsp;&nbsp;level: " + level + "</li>";
			$('.violations_list').append(violation_html)
		};
	},

	restaurantZoom: function(restaurant) {
		var latLng = new L.LatLng(restaurant.lat, restaurant.lng);
		healthCodeMap.map.setView(latLng, 18);
		healthCodeMap.markers[restaurant.id].openPopup();
		$('.right').on('click', function(evt){
			$('#popup').show();
			$('#overlay').show();
			healthCodeMap.fillPopupWindow(restaurant.id);
		});
	},

	restaurantSearch: function() {
		$('#search-field').autocomplete({
			source: function(request, response) {
				var results = $.ui.autocomplete.filter(restaurant_data, request.term);
				response(results.slice(0,15));
			},
			minLength: 2,
			delay:150,
			select: function(event, ui) {
				$('#search-field').val(ui.item.label);
				healthCodeMap.restaurantZoom(ui.item);
				return false;
			}
		})
		.data('ui-autocomplete')._renderItem = function(ul, item) {
			return $('<li>')
				.append( "<a>" + item.label + "<em>" + item.address + "</em>" )
				.appendTo(ul);
		};
	}
};

$(function() {
	healthCodeMap.initMap();
	healthCodeMap.plotRestaurants();
	healthCodeMap.startEventListeners();
	healthCodeMap.restaurantSearch();
});