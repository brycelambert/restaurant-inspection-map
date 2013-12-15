$(function() {
	var apiKey  = 'e835cf86df4c4575ac7be175cca8bba9',
	    styleID = '997',
	    southWest = new L.LatLng(50.233152, -6.635742),
	    northEast = new L.LatLng(53.644638, 2.109375),
	    bounds = new L.LatLngBounds(southWest, northEast),
	    center = new L.LatLng(51.5171, 0.1062),
	    map_options = { center: center, zoom: 1, maxBounds: bounds },
			// map = new L.map('map_div', map_options);
			map = L.map('map').setView([51.505, -0.09], 13);

	L.tileLayer('http://{s}.tile.cloudmade.com/' + apiKey +'/997/256/{z}/{x}/{y}.png', {
	    attribution: 'Map data &copy,
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

