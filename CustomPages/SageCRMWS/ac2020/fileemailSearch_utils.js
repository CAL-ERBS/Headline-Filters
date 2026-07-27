<%

function findPersonByEmailFilter(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}	
	var SelectSQL = "select top "+_baseConfig.listlength+" ELink_EntityID,ELink_RecordID,Emai_EmailAddress "+
			"from vEmailExchange where 43=43 and Emai_EmailAddress = '"+ emailAddress + "' "+
			"and ELink_EntityID = 13 and ELink_Deleted is null order by emai_updateddate desc";
	var q=CRM.CreateQueryObj(SelectSQL);
	q.SelectSQL();
	var res="-1";
	while(!q.eof)
	{
		if (res!="")
			res+=",";
		res+=q("ELink_RecordID");
		q.NextRecord();
	}
	return res;
}

function findPersonByEmail(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}
	emailAddress=escapeSQL(emailAddress);
	var emailFilter=findPersonByEmailFilter(emailAddress);
	var q=CRM.FindRecord("person,vsummaryperson","80=80 and pers_personid in (" + emailFilter + ") or pers_emailaddress='"+emailAddress+"'");
	q.Orderby="pers_updateddate desc";
	return q;
} 

//////////////


function findCompanyByEmailFilter(emailAddressDomain)
{
	if ((emailAddressDomain==null)||(emailAddressDomain==""))
	{
		emailAddressDomain="__NODATA__";
	}
	var SelectSQL = "select top "+_baseConfig.listlength+" ELink_EntityID,ELink_RecordID,Emai_EmailAddress "+
			"from vEmailExchange where 44=44 and Emai_EmailAddress like '%"+ emailAddressDomain + "' "+
			"and ELink_EntityID = 5 and ELink_Deleted is null order by emai_updateddate desc";
	var q=CRM.CreateQueryObj(SelectSQL);
	q.SelectSQL();
	var res="-1";
	while(!q.eof)
	{
		if (res!="")
			res+=",";
		res+=q("ELink_RecordID");
		q.NextRecord();
	}
	return res;
}

function findCompanyByEmailFilterExact(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}
	var SelectSQL = "select top "+_baseConfig.listlength+" ELink_EntityID,ELink_RecordID,Emai_EmailAddress "+
			"from vEmailExchange where 443=443 and Emai_EmailAddress = '"+ emailAddress + "' "+
			"and ELink_EntityID = 5 and ELink_Deleted is null order by emai_updateddate desc";
	var q=CRM.CreateQueryObj(SelectSQL);
	q.SelectSQL();
	var res="-1";
	while(!q.eof)
	{
		if (res!="")
			res+=",";
		res+=q("ELink_RecordID");
		q.NextRecord();
	}
	return res;
}

function findCompanyByEmail(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}
	var bcompanyfullmatch=useCompanyfullmatch(emailAddress);	
	emailAddress=new String(emailAddress);
	emailAddress=escapeSQL(emailAddress);
	if (bcompanyfullmatch)
	{
		var emailFilter=findCompanyByEmailFilter(emailAddress);
		var q=CRM.FindRecord("company,vsummarycompany","81=81 and comp_companyid in (" + emailFilter + ") or comp_emailaddress = '"+emailAddress+"'");
		q.Orderby="comp_updateddate desc";
		return q;		
	}else{
		var emailAddress_arr=emailAddress.split("@");
		var emailFilter=findCompanyByEmailFilter(emailAddress_arr[1]);
		var q=CRM.FindRecord("company,vsummarycompany","81=81 and comp_companyid in (" + emailFilter + ") or comp_emailaddress like '%"+emailAddress_arr[1]+"'");
		q.Orderby="comp_updateddate desc";
		return q;	
	}
} 

//////////////

function findLeadByEmail(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}
	emailAddress=new String(emailAddress);
	var emailAddress_arr=emailAddress.split("@");
	var q=CRM.FindRecord("lead","89=89 and Lead_PersonEMail like '%"+escapeSQL(emailAddress_arr[1])+"'");
	return q;
} 

function findLeadByEmailExact(emailAddress)
{
	if ((emailAddress==null)||(emailAddress==""))
	{
		emailAddress="__NODATA__";
	}	
	emailAddress=new String(emailAddress);
	emailAddress=escapeSQL(emailAddress);
	var q=CRM.FindRecord("lead","893=893 and Lead_PersonEMail='"+emailAddress+"'");
	return q;
} 

%>