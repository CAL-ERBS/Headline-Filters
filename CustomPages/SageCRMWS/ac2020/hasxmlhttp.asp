<%@ CodePage=65001 Language=JavaScript%>
<%
    //testing for xmlhttps

	var xmlhttp;
    var error="";
	var linex="";
    var ServerXMLHTTPInfo="";
	try {
	    xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.6.0");
        ServerXMLHTTPInfo="MSXML: 6.0 found";
	}
	catch(e) {
		try
		{
    		xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.4.0");
            ServerXMLHTTPInfo="MSXML: 4.0 found";
		} 
		catch(e) 
		{
			error= "MSXML2 issue-object missing maybe:"+e2.message;
		}
	}	
    try {

        var protocol = "";
        if (Request.ServerVariables("HTTPS") == "off") {
            protocol = "http://"
        } else {
            protocol = "https://"
        }
		linex="1";
        var clearcachelink = new String(protocol + Request.ServerVariables("SERVER_NAME") + ":" + Request.ServerVariables("SERVER_PORT") + Request.ServerVariables("SCRIPT_NAME"));
        linex="2";
		clearcachelink = clearcachelink.replace("hasxmlhttp.asp", "clearcache.asp");
		linex="3";
        xmlhttp.open("GET", clearcachelink, false);
		linex="4";
        xmlhttp.send();
		linex="5";	
        var xx = xmlhttp.responseText;	
		linex="6";
    }
    catch(e2) 
	{
		//ignore if this is the case
		if (linex!="5")
			error= "MSXML2 needs to be re-installed: Line:"+linex+" Message:"+e2.message;
		else 
			error= "Clear Cache Link Issue: "+clearcachelink;
    }


     

Response.Write("<span style='color:blue' >"+ServerXMLHTTPInfo+"</span><span style='color:red' >"+error+"</span>");

%>