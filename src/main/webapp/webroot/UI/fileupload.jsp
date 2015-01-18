<!DOCTYPE html>
<html lang="en">
<head>
    <title>File Upload</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<form method="POST" action="../uploadfile.jsp" enctype="multipart/form-data" >

    <input type="text" value="USE IT TO RENAME IF EXISTS" name="rename-file" hidden="true"/>
    <table>

    <tr><td>Destination</td><td> <input type="text" value="/tmp" name="destination"/></td></tr>
    <tr><td>File:      </td><td> <input type="file" name="file" id="file" /></td></tr>


    </br>
    </table>
    <input type="submit" value="Upload" name="upload" id="upload" />

</form>
</body>
</html>