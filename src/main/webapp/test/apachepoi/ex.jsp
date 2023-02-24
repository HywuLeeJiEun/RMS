<%@page import="rmsvation.rmsvationDAO"%>
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
rmsvationDAO vacaDAO = new rmsvationDAO(); //휴가 정보

int result = vacaDAO.writeVation("1","1","1","1");	

%>
</body>
</html>