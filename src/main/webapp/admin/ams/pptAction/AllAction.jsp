<%@page import="java.io.PrintWriter"%>
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
	String rms_dl = request.getParameter("rms_dl");
	int result = -1; 
	if(request.getAttribute("result") != null) {
		result = (int) request.getAttribute("result");
	}
	
	if(result == 1) {
		//정상적으로 제작이 완료됨 (ppt에 필요한 재료)
		response.sendRedirect("mergeAction.jsp?rms_dl="+rms_dl);
	} else {
		request.setAttribute("rms_dl", rms_dl);
		RequestDispatcher dispatcher = request.getRequestDispatcher("titleAction.jsp");
		dispatcher.forward(request, response);
	} 
	
%>

<a><%= rms_dl %></a>
<br>
<textarea><%= result %></textarea>

<textarea>AllAction 페이지입니다 //추가하고 있습니다</textarea>


</body>
</html>