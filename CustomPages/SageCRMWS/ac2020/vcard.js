<%
	//
	//File: vcard.js
	//
	function escapeDoubleQuotes(inputString) {
		if (!Defined(inputString))
			return "";
		// Replace double quotes with escaped double quotes
		return inputString.replace(/"/g, '\\"');
	}
function getPersonValue(fieldname) {
	var res = escapeDoubleQuotes(pRec.item(fieldname));
	res=undefinedToBlank(res);
	return res;
}
function getPersonPhone() {
	var res = getPersonValue("Pers_PhoneCountryCode") +
		getPersonValue("Pers_PhoneAreaCode") +
		getPersonValue("Pers_PhoneNumber");
	res=undefinedToBlank(res);
	return res;
}
function getPersonMobilePhone() {
	var res = "";
	try {
		res=getPersonValue('phon_MobileFullNumber');
	} catch (e) {
		//ignore...old db's dont have this
	}
	res=undefinedToBlank(res);
	return res;
}

function getPersonFax() {
	var res = getPersonValue("Pers_FaxCountryCode") +
		getPersonValue("Pers_FaxAreaCode") +
		getPersonValue("Pers_FaxNumber");
	res=undefinedToBlank(res);		
	return res;
}
function getPersonWebsite() {
	var res = getPersonValue("pers_website");
	res=undefinedToBlank(res);
	if (res.length<5)
	{
		res = getPersonValue("comp_website");		
		res=undefinedToBlank(res);
	}
	if (res.length<5)
	{
		res="";
	}	
	return res;
}

function getCompanyValue(fieldname) {
	var res= escapeDoubleQuotes("");//to do
	res=undefinedToBlank(res);
	return res;
}
function getUserVCARD() {
	var res = {
		"version": "3.0",
		"type": "person",
		"firstName": getUserValue('user_firstname'),
		"middleName": "",
		"lastName": getUserValue('user_lastname'),
		"organization": getCompanyValue('companyname'),
		"title": getUserValue('user_title'),
		"home": {
			"eMail": "",
			"phone": "",
			"street": "",
			"city": "",
			"zip": "",
			"state": "",
			"country": "",
			"url": ""
		},
		"work": {
			"eMail": getUserValue('User_EmailAddress'),
			"phone": getUserValue('User_Phone'),
			"fax": getUserValue('User_Fax'),
			"street": getCompanyValue('companystreet'),
			"city": getUserValue('user_location'),
			"zip": getCompanyValue('companyzip'),
			"state": getCompanyValue('companystate'),
			"country": getCompanyValue('companycountry'),
			"url": getCompanyValue('companyurl')
		},
		"mobilePhone": getUserValue('User_MobilePhone'),
		"birthday": null
	};
	return JSON.stringify(res);
}
function getPersonVCARD() {
	var res = {
		"version": "3.0",
		"type": "person",
		"firstName": getPersonValue('pers_firstname'),
		"middleName": "",
		"lastName": getPersonValue('pers_lastname'),
		"organization": getPersonValue('comp_name'),
		"title": getPersonValue('pers_title'),
		"home": {
			"eMail": "",
			"phone": "",
			"street": "",
			"city": "",
			"zip": "",
			"state": "",
			"country": "",
			"url": ""
		},
		"work": {
			"eMail": getPersonValue('pers_EmailAddress'),
			"phone": getPersonPhone(),
			"fax": getPersonFax(),
			"street": getPersonValue('Addr_Address1')+' ' + getPersonValue('Addr_Address2')+' ' + getPersonValue('Addr_Address3')+' ' + getPersonValue('Addr_Address4'),
			"city": getPersonValue('Addr_City'),
			"zip": getPersonValue('Addr_PostCode'),
			"state": getPersonValue('Addr_State'),
			"country": CRM.GetTrans("Addr_Country", getPersonValue('Addr_Country')),
			"url": getPersonWebsite()
		},
		"mobilePhone": getPersonMobilePhone(),
		"birthday": null
	};

	return JSON.stringify(res);
}

%>