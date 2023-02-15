<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>
	<%
		// 부여된 세션을 삭제함.
		session.invalidate();
	%>
	<script>
		alert("로그아웃 되었습니다.");
		location.href="login.jsp";
	</script>
</body>
</html>