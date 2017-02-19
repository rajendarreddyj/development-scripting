<%
Function addzero(intIn)
      if CInt(IntIn) < 10 then
            addzero = "0" & intIn
      else
            addzero = intIn
      end if
end Function
dim f, fs, filePath, fileName, archiveFilePath, archiveSize, archiveFileName,archiveFileExtension, webServiceUrl, strConfigLine, fConFile, EqPos, strLen, varName, varVal,objxml,xmlhttp
set fs=Server.CreateObject("Scripting.FileSystemObject")
SET fConFile = fs.OpenTextFile(Server.MapPath("config.properties"))
WHILE NOT fConFile.AtEndOfStream
strConfigLine = fConFile.ReadLine
strConfigLine = TRIM(strConfigLine)
IF (INSTR(1,strConfigLine,"#",1) <> 1 AND LEN(strConfigLine) <> 0) THEN
	EqPos = INSTR(1,strConfigLine,"=",1)
	strLen = LEN(strConfigLine)
	varName = LCASE(TRIM(MID(strConfigLine, 1, EqPos - 1)))
	varVal = TRIM(MID(strConfigLine, EqPos + 1, strLen - EqPos))
	SELECT CASE varName
		CASE LCASE("FilePath")
			IF varVal <> "" THEN filePath = varVal
		CASE LCASE("FileName")
			IF varVal <> "" THEN fileName = varVal
		CASE LCASE("ArchiveFilePath")
			IF varVal <> "" THEN archiveFilePath = varVal
		CASE LCASE("ArchiveFileName")
			IF varVal <> "" THEN archiveFileName = varVal
		CASE LCASE("ArchiveFileExtension")
			IF varVal <> "" THEN archiveFileExtension = varVal
		CASE LCASE("ArchiveSize")
			IF varVal <> "" THEN archiveSize = varVal
		CASE LCASE("WebServiceUrl")
			IF varVal <> "" THEN webServiceUrl = varVal	
	END SELECT
END IF
WEND
fConFile.Close
Set xmlhttp = Server.CreateObject ("Msxml2.ServerXMLHTTP.3.0")
xmlhttp.open "GET", webServiceUrl, false
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
if fs.FileExists(filePath & fileName) then
  set f=fs.GetFile(filePath & fileName)
  if f.size > CInt(archiveSize) then
	If fs.FolderExists(archiveFilePath) = false Then
		set f=fs.CreateFolder(archiveFilePath)
	End If
	fs.MoveFile filePath & fileName, archiveFilePath & archiveFileName & addzero(month(Date())) &  addzero(day(Date())) & Year(Date()) & addzero(hour(Time())) & addzero(minute(Time())) & addzero(second(Time())) & archiveFileExtension
  end if
  set f=fs.OpenTextFile(filePath & fileName,8,true)
else 
	If fs.FolderExists(filePath) = false Then
		set f=fs.CreateFolder(filePath)
	End If
set f=fs.CreateTextFile(filePath & fileName,true)
end if
f.Write(Request.ServerVariables("http_referer"))
f.Write("|")
f.Write(Request.ServerVariables("http_user_agent"))
f.Write("|")
f.Write(Request.ServerVariables("remote_addr"))
f.Write("|")
f.Write(Request.ServerVariables("remote_host"))
f.Write("|")
f.Write(Request.ServerVariables("request_method"))
f.Write("|")
f.Write(Request.ServerVariables("server_name"))
f.Write("|")
f.Write(Request.ServerVariables("server_port"))
f.Write("|")
f.Write(Request.ServerVariables("server_software"))
f.Write("|")
f.Write(accountNo)
f.Write("|")
f.Write(accountName)
f.Write("|")
f.Write(firstName)
f.Write("|")
f.Write(accounttype)
f.Write("|")
f.Write(etcAccountId)
f.Write("|")
f.Write(sessionId)
f.Write("|")
f.Write(sessionDesc)
f.Write("|")
f.WriteLine("")
f.Close
set f=nothing
set fileName=nothing
set filePath=nothing
set archiveFileName=nothing
set archiveFilePath=nothing
set archiveSize=nothing
set archiveFileExtension=nothing
set strConfigLine=nothing
set webServiceUrl=nothing
set fConFile=nothing
set EqPos=nothing
set strLen=nothing
set varName=nothing
set varVal=nothing
set fs=nothing
%>
