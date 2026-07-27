<!-- #include file ="..\accpaccrm.js" -->
<% 
	var reqResponse = "";
	var count = 0;
	try {

		if(Request.QueryString("entity").Count !== 0) {
			var entity = Request.QueryString("entity");
			var screen = "";
			
			if (entity == "oppo") {
				screen = "OpportunityMobileExtra";
			} else if (entity == "person"){
				screen = "PersonMobileExtra";
			}
			
			if(screen != "") {
				var userLanguage = CRM.GetContextInfo("selecteduser", "User_Language");
				var qryClient = eWare.CreateQueryObj('', sInstallName );
				var sSQL = "SELECT CS.SeaP_ColName, CC.Capt_" + userLanguage + " FROM vCustom_Screens CS " +
				"LEFT JOIN Custom_Captions CC ON  CS.SeaP_ColName = CC.Capt_Code AND CC.capt_family = 'ColNames'" +
				"WHERE SeaP_SearchBoxName = '" + screen + "' " +
				"ORDER BY SeaP_Order ASC";
				//Response.Write(sSQL);
				qryClient.SQL = sSQL;
				qryClient.SelectSQL();
				reqResponse = "["
				while(!qryClient.eof)
				{
					if (count > 0) {
						reqResponse += ",";
					}
					reqResponse += "{\"" + escapreForJSON(qryClient("SeaP_ColName")) + "\":\"" + escapreForJSON(qryClient("Capt_" + userLanguage)) + "\"}";
					qryClient.next();
					count++;
				}
				qryClient.close;
				reqResponse += "]";
			}
		}
		if (count == 0) {
			reqResponse = "Empty";
		}
	}
	catch (error) {
		reqResponse = "Error";
	}

	//Escape characters, the only characters that MUST be escaped in JSON are \ and "
	function escapreForJSON(unescapedString){ 
		var escapedString = "" + unescapedString;
		escapedString = escapedString.replace("\"","\\u0022");
		escapedString = escapedString.replace("\\","\\u005C");
		return escapedString;
	}
	
	Response.Write(reqResponse);
%>