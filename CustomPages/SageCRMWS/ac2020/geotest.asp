<!DOCTYPE html>
<html>

<head>
	<title>Get Current Position</title>
</head>

<body>
	<h2>Welcome To GFG</h2>
	<div>
		<button onclick="geolocator()">click me</button>
		<p id="paraGraph"></p>

	</div>
	<script>
		var paraGraph = document.getElementById("paraGraph");
		var user_loc = navigator.geolocation;
	
		function geolocator() {
		paraGraph.innerHTML ="......";
		
		paraGraph.innerHTML =JSON.stringify(user_loc);
		
			if(user_loc) {
			paraGraph.innerHTML ="a";
				user_loc.getCurrentPosition(success,geoerr);
				paraGraph.innerHTML ="b";
			} else {
				paraGraph.innerHTML ="Your browser doesn't support geolocation API";
			}
		}
	
		function success(data) {
			paraGraph.innerHTML +"1";
			var lat = data.coords.latitude;
			paraGraph.innerHTML +"2";
			var long = data.coords.longitude;
			paraGraph.innerHTML = "Latitude: "			+ lat			+ "<br>Longitude: "			+ long;
		}
		
		function geoerr(errobj) {
			paraGraph.innerHTML +="geoerr...";
			paraGraph.innerHTML +=errobj.message;
			paraGraph.innerHTML +="...code:"+errobj.code;
		}
		
	</script>
</body>

</html>
