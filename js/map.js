$(function() {
	apiKey ='e835cf86df4c4575ac7be175cca8bba9',
	styleID = '997',
	southWest = new L.LatLng(42.252215, -71.198273),
  northEast = new L.LatLng(42.392589, -71.005325),
  bounds = new L.LatLngBounds(southWest, northEast),
  center = new L.LatLng(42.351074, -71.066008),
  map_options = { center: center, zoom: 15, maxBounds: bounds },
	map=  L.map('map', map_options),
	tile_url = 'http://{s}.tile.cloudmade.com/' + apiKey +'/'+ styleID +'/256/{z}/{x}/{y}.png',
	tile_layer_options = { attribution: 'attribution', maxZoom: 18, detectRetina: true },
	circle_options = { color: 'red', fillColor: '#a03', fillOpacity: 1};

	L.tileLayer(tile_url, tile_layer_options).addTo(map);
		
	plotRestaurants = function() {
		for (var i = 0; i < restaurant_data.length; i++) {
			var long = restaurant_data[i].long,
					lat = restaurant_data[i].lat,
					name = restaurant_data[i].businessname,
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
					"</div> \
					</div>";

			var marker = L.circle([long, lat], 5, circle_options);

			marker.bindPopup(marker_text);
			map.addLayer(marker);

	     var popupWindow = function(index){
				var dataIndex = index;
				return function(){
					$('#overlay').show()
					$('#popup').show();
					fillPopupWindow(dataIndex);
				};
			};

			var createMouseOverHandler = function(){
				var dataIndex = i;
				return function(evt){
					evt.target.openPopup();
					$('.right').on('click', function(evt){
						$('#popup').show();
						fillPopupWindow(dataIndex);
					});
				};
			};

			marker.on('mouseover', createMouseOverHandler());

			map.on('click', function(){
				closeWindows();
			});

			$(document).on('click', function(){
				closeWindows();
			});

			$(document).keyup(function(evt) {
				if (evt.keyCode == 27) {
					closeWindows()
					map.closePopup()
				};
			});

		};
	};

	plotRestaurants();

	var fillPopupWindow = function(index){
		var violation_data = restaurant_data[index].violations,
				name = restaurant_data[index].businessname,
				violation_list_head = "<h4>" + name + "</h4>";
		$('.violations_list').html(violation_list_head)
		for (var i = 0; i < violation_data.length; i++) {
			var level = violation_data[i].level;
					description = violation_data[i].description,
					comments = violation_data[i].comments,
					dttm = violation_data[i].violation_dttm,
					violation_html = 
					"<li><p>" + description + "</p> \
					<p>" + comments + "</p> \
					<p class='subtext'>date/time: " + dttm +
					"&nbsp;&nbsp;&nbsp;&nbsp;level: " + level + "</li>";
			$('.violations_list').append(violation_html)
		};
	};

	var closeWindows = function(){
		if ( $('#popup').is(':visible') ) {
			$('#popup').hide();
			$('#overlay').hide();
		}
	};
});