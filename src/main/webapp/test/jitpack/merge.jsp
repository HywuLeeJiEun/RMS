<%@page import="com.cloudmersive.client.invoker.ApiException"%>
<%@page import="java.io.File"%>
<%@page import="com.cloudmersive.client.MergeDocumentApi"%>
<%@page import="com.cloudmersive.client.invoker.auth.ApiKeyAuth"%>
<%@page import="com.cloudmersive.client.invoker.Configuration"%>
<%@page import="com.cloudmersive.client.invoker.ApiClient"%>
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


//Uncomment the following line to set a prefix for the API key, e.g. "Token" (defaults to null)
//Apikey.setApiKeyPrefix("Token");
MergeDocumentApi apiInstance = new MergeDocumentApi();
File inputFile1 = new File("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\1.pptx"); // File | First input file to perform the operation on.
File inputFile2 = new File("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx"); // File | Second input file to perform the operation on (more than 2 can be supplied).
try {
byte[] result = apiInstance.mergeDocumentPptx(inputFile1, inputFile2);
System.out.println(result);
} catch (ApiException e) {
System.err.println("Exception when calling MergeDocumentApi#mergeDocumentPptx");
e.printStackTrace();
}

%>
</body>
</html>