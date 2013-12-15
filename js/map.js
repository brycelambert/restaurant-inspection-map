$(function() {
	var apiKey  = 'e835cf86df4c4575ac7be175cca8bba9',
	    styleID = '997',
	    southWest = new L.LatLng(42.252215, -71.198273),
	    northEast = new L.LatLng(42.392589, -71.005325),
	    bounds = new L.LatLngBounds(southWest, northEast),
	    center = new L.LatLng(42.351074, -71.066008),
	    map_options = { center: center, zoom: 1, maxBounds: bounds },
			map = new L.map('map', map_options);

	L.tileLayer('http://{s}.tile.cloudmade.com/' + apiKey +'/997/256/{z}/{x}/{y}.png', {
	    attribution: 'attribution',
	    maxZoom: 18,
	    detectRetina: true
	}).addTo(map);
});


var circle_options = {
	color: 'red',
	fillColor: '#a03',
	fillOpacity: 1
};


//For loop calling addMarker(long, lat, map) for each datapoint

var addMarker = function(longitude, lattitude, map) {
	var marker = L.circle([longitude, lattitude], 5, circle_options);
	map.addLayer(marker)
};

