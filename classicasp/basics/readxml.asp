<%
Dim objxml
Dim xmlhttp
Set xmlhttp = Server.CreateObject ("Msxml2.ServerXMLHTTP.3.0")
xmlhttp.open "GET", "http://localhost/asp/prop.xml", false
xmlhttp.send("")
Response.write xmlhttp.responseText	& "<br>"
'// Get the received XML object directly from the xmlhttp object
set objxml = xmlHttp.ResponseXML
response.write typename(objxml) & "<br/>"
Set xmlhttp = Nothing
'// Check that XML has been recieved
IF not objxml is Nothing THEN
	'// Get the data from the xml
	Set oNode = objxml.selectSingleNode("//eCustomer/accountNo")
	accountNo = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/accountName")
	accountName = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/firstName")
	firstName = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/accounttype")
	accounttype = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/etcAccountId")
	etcAccountId = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/sessionId")
	sessionId = oNode.Text
	Set oNode = objxml.selectSingleNode("//eCustomer/sessionDesc")
	sessionDesc = oNode.Text
ELSE
	Response.Write "Failed to load XML file"
END IF
Response.Write " accountNo = " 
Response.Write(accountNo) & "<br>"
Response.Write " accountName = " 
Response.Write(accountName) & "<br>"
Response.Write " firstName = " 
Response.Write(firstName) & "<br>"
Response.Write " accounttype = " 
Response.Write(accounttype) & "<br>"
Response.Write " etcAccountId = " 
Response.Write(etcAccountId) & "<br>"
Response.Write " sessionId = " 
Response.Write(sessionId) & "<br>"
Response.Write " sessionDesc = " 
Response.Write(sessionDesc) & "<br>"
Set objxml = Nothing
%>
