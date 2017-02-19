<%
dim fs, filePath, fileName, archiveFilePath, archiveSize, archiveFileName,archiveFileExtension, strConfigLine, fConFile, EqPos, strLen, varName, varVal
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
	END SELECT
END IF
WEND
Response.Write filePath
Response.Write "<br>" 
Response.Write fileName
Response.Write "<br>" 
Response.Write archiveFilePath
Response.Write "<br>" 
Response.Write archiveFileName
Response.Write "<br>" 
Response.Write archiveFileExtension
Response.Write "<br>" 
Response.Write archiveSize
Response.Write "<br>" 
fConFile.Close
set fileName=nothing
set filePath=nothing
set archiveFileName=nothing
set archiveFilePath=nothing
set archiveSize=nothing
set archiveFileExtension=nothing
set strConfigLine=nothing
set fConFile=nothing
set EqPos=nothing
set strLen=nothing
set varName=nothing
set varVal=nothing
set fs=nothing
%>
