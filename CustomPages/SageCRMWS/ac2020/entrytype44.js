<%

function getReferenceID(entity, idfield,field)
{
	var res="";
	var strSQL = "SET NOCOUNT ON  DECLARE @ret varchar(20) ";
	strSQL += " EXEC EWARE_DEFAULT_VALUES '"+entity+"','"+idfield+"','"+field+"',"+getUserId()+",'',@ret output";
	strSQL += " select @ret as refid";
	strSQL += " SET NOCOUNT OFF";
	var rec = CRM.CreateQueryObj(strSQL,"");
	rec.SelectSQL();
	res=rec("refid");
	return res;
}

%>