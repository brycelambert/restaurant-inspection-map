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
					businessname = restaurant_data[i].businessname;

			var marker = L.circle([long, lat], 15, circle_options);
			marker.bindPopup(businessname);
			marker.on('mouseover', function(evt){ evt.target.openPopup(); });
			map.addLayer(marker)
		};
	};
	plotRestaurants();

});