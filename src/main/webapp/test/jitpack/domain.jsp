<%@page import="com.cloudmersive.client.invoker.ApiException"%>
<%@page import="com.cloudmersive.client.model.CheckResponse"%>
<%@page import="com.cloudmersive.client.DomainApi"%>
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

DomainApi apiInstance = new DomainApi();
String domain = "cloudmersive.com"; // String | Domain name to check, for example \"cloudmersive.com\"
try {
    CheckResponse result = apiInstance.domainCheck(domain);
    System.out.println(result);
} catch (ApiException e) {
    System.err.println("Exception when calling DomainApi#domainCheck");
    e.printStackTrace();
}

%>
</body>
</html>