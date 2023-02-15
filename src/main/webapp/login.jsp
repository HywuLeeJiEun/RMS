<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
   
<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="css/index.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<title>RMS</title>
</head>



<body>
<%

/* ********* 세션(session)을 통한 클라이언트 정보 관리 ********* */
// 현재 세션 상태를 체크
String id = null;
if(session.getAttribute("id") != null){
	id = (String)session.getAttribute("id");
}
// 로그인 완료시, 재로그인이 불가하게 함!
if(id != null){
	PrintWriter script = response.getWriter();
	script.println("<script>");
	script.println("alert('현재 로그인 중입니다.')");
	script.println("location.href='/BBS/user/bbs.jsp'");
	script.println("</script>");
}

%>
    <!-- ************ 상단 네비게이션바 영역 ************* -->
	<nav class="navbar navbar-default"> 
		<div class="navbar-header"> 
			<!-- 네비게이션 상단 박스 영역 -->
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<!-- 이 삼줄 버튼은 화면이 좁아지면 우측에 나타난다 -->
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="login.jsp">Report Management System</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
						<li><a href="login.jsp" style=" text-decoration: underline;" >로그인</a></li>
			</ul>
		</div>
	</nav>
	
	<div class="container" style="justify-content: center; align-items: center; ">	
	</div>
	<!-- ********** 로그인 영역 *********** -->
	<div class="container" style="justify-content: center; align-items: center; ">	
		<div class="col-lg-3">
		</div>	
		<div class="col-lg-6">	
			<!-- 점보트론은 특정 컨텐츠, 정보를 두드러지게 하기 위한 큰 박스 -->
			<div class="jumbotron" style="padding-top: 20px; vertical-align: middle;">
				<form method="post" action="loginAction.jsp">
					<h3 style="text-align: center;">login</h3>
					<div class="form-group">
						<input type="text" class="form-control" placeholder="아이디" name="id" maxlength="20">
					</div>
					<div class="form-group">
						<input type="password" class="form-control" placeholder="비밀번호" name="password" maxlength="20">
					</div>
					<input type="submit" class="btn btn-primary form-control" value="로그인">
				</form>
			</div>
		</div>	
	</div>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="css/js/bootstrap.js"></script>
</body>