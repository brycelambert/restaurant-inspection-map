$(function() {
	var apiKey  = 'e835cf86df4c4575ac7be175cca8bba9',
	    styleID = '997',
	    southWest = new L.LatLng(42.252215, -71.198273),
	    northEast = new L.LatLng(42.392589, -71.005325),
	    bounds = new L.LatLngBounds(southWest, northEast),
	    center = new L.LatLng(42.351074, -71.066008),
	    map_options = { center: center, zoom: 15, maxBounds: bounds },
			map = new L.map('map', map_options),
			tile_url = 'http://{s}.tile.cloudmade.com/' + apiKey +'/'+ styleID +'/256/{z}/{x}/{y}.png',
			tile_layer_options = { attribution: 'attribution', maxZoom: 18, detectRetina: true},
			circle_options = { color: 'red', fillColor: '#a03', fillOpacity: 1 };

	L.tileLayer(tile_url, tile_layer_options).addTo(map);
	
	var plotRestaurants = function() {
		for (var i = 0; i < restaurant_data.length; i++) {
			var long = restaurant_data[i].long,
					lat = restaurant_data[i].lat,
					name = restaurant_data[i].businessname,
					address = restaurant_data[i].address,
					city = restaurant_data[i].city,
					
					// move to ruby??
					//Plot w/ id for dom selection?
					//https://groups.google.com/forum/#!topic/leaflet-js/DY5G3Os2EzE
					//http://labs.easyblog.it/maps/leaflet-search/
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
					"</div> \
					</div>";

			var marker = L.circle([long, lat], 5, circle_options);
			marker.bindPopup(marker_text);
			marker.on('mouseover', function(evt){ evt.target.openPopup(); });
			map.addLayer(marker)
		};
	};
	plotRestaurants();

});