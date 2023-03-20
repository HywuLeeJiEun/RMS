<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsrept.rmsrept"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%

	RmsreptDAO rms = new RmsreptDAO();

	String rms_dl = "2023-03-20";
	String id = "jelee01";
	rms.WritePptx(rms_dl, id);

%>
</body>
</html>