<%


function createPersonRecord(_data,wf)
{	
  //person
  var personid=createPerson(_data,null,wf);

  //address
  var addressid=createAddress(_data,null,personid);

  var _libraryfolder=createLibrary(null, personid);
  
  //phone
  createPhone(_data, 13, personid);

  //email
  createEmail(_data, 13, personid);

  updatePerson(null,addressid,personid,_libraryfolder);

  return {
	  entity:"person",
	  entityid:personid
  }  
}

function updatePersonRecord(_entityid, dataObj)
{
  var persondataObj=JSON.stringify(dataObj);
  persondataObj=JSON.parse(persondataObj);
  //remove non-company fields
  for(var tt=0;tt<persondataObj.length;tt++)
  {
	var fieidObj=persondataObj[tt];
	if (fieidObj.name.indexOf("pers_")!=0)
	{
	  persondataObj.length=tt;
	  break;
	}
  }
  var updateRes=updateNamedEntity("person",_entityid,persondataObj);
  updateRes.log+="p1x";
   var _Addr_AddressId="-1";
   
if (!isNumeric(_entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, _entityid is "+_entityid);
  throw "No valid Entity ID found";
}
   
   var persq=CRM.CreateQueryObj("select pers_primaryaddressid from person where pers_personid="+_entityid);
   persq.SelectSQL();
   _Addr_AddressId=persq("pers_primaryaddressid");
   var primaryAddress = CRM.FindRecord("Address", "Addr_AddressId=" +_Addr_AddressId );
    updateRes.log+="p2x"+"Addr_AddressId=" +_Addr_AddressId ;
	if (!primaryAddress.eof) {
		var addressRecord = CRM.FindRecord("Address", "addr_addressid=" + primaryAddress("addr_addressid") );
		for(var i=0; i< dataObj.length;i++) {
			if (dataObj[i].name.indexOf("addr_") == 0 && Defined(dataObj[i].value)) {
				addressRecord(dataObj[i].name) = dataObj[i].value;
			}
		}
		try {
			addressRecord.SaveChangesNoTls();
		} catch(Exception) {
			updateRes.log+="updatePersonRecord Address Exception:"+Exception.message;
		}
	}



  //todo items for version2
 
  
  //phone
  
  //email
  
  
  return updateRes;
}


%>