<%@ CodePage=65001 Language=JavaScript%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Navigation Message</title>
</head>
<body>
    <span id="Message" >Navigating... Please view your Sage CRM tab</span>
</body>
</html>
<script>
    //used as part of the process to open urls in the existing sage crm instance
    //previously we opened each in a new tab
    const SID = localStorage.getItem('ct_SID');
    const urlParams = new URLSearchParams(document.location.search);
    const sagecrmurl = urlParams.get('sagecrmurl');
    localStorage.setItem('ct_entityidurl', sagecrmurl);

	//check user is logged into CRM
    if (localStorage.getItem('ct_SID')!=null)
	{
		setTimeout("window.close()", 1000);
	}else{
		document.getElementById("Message").innerHTML="It does not look like Sage CRM is open and logged into.<br>This is required for inline links to work.";
	}
</script>