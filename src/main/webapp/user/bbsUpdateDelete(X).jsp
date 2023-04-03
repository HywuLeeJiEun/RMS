<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.ArrayList" %>
<% request.setCharacterEncoding("utf-8"); %>



<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="../css/index.css">
<title>RMS</title>
</head>

<body>
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록

		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		int pageNumber = 1; //기본은 1 페이지를 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'pageNumber'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'pageNumber'변수에 저장한다
		if(request.getParameter("pageNumber") != null){
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../login.jsp'");
			script.println("</script>");
		}
		
	
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		String workSet;
		ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력(rmsmgrs에 접근하여, task_num을 가져옴.)
		List<String> works = new ArrayList<String>();
		
		if(code.size() == 0) {
			//1. 담당 업무가 없는 경우,
			workSet = "";
		} else {
			//2. 담당 업무가 있는 경우
			for(int i=0; i < code.size(); i++) {
				if(i < code.size()-1) {
					//task_num을 받아옴.
					String task_num = code.get(i);
					// task_num을 통해 업무명을 가져옴.
					String manager = userDAO.getManager(task_num);
					works.add(manager+"/"); //즉, work 리스트에 모두 담겨 저장됨
				} else {
					//task_num을 받아옴.
					String task_num = code.get(i);
					// task_num을 통해 업무명을 가져옴.
					String manager = userDAO.getManager(task_num);
					works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
				}
			}
			workSet = String.join("\n",works) + "\n";
		}
		
		// 사용자 정보 담기
		ArrayList<rmsuser> ulist = userDAO.getUser(id);
		String password = ulist.get(0).getUser_pwd();
		String name = ulist.get(0).getUser_name();
		String rank = ulist.get(0).getUser_rk();
		//이메일  로직 처리
		String Staticemail = ulist.get(0).getUser_em();
		String[] email;
		email = Staticemail.split("@");
		String pl = ulist.get(0).getUser_fd();
		String rk = ulist.get(0).getUser_rk();
		//사용자의 AU(Authority) 권한 가져오기 (일반/PL/관리자)
		String au = ulist.get(0).getUser_au();
		
				
		//기존 데이터 불러오기 (미승인인 주간보고를 불러옴.)
		//rmsrept에서 sign이 미승인인 데이터만 불러오기!
		ArrayList<rmsrept> rmslist = rms.getrmsSign(id, pageNumber);
		
		//미승인 -> 미제출로 변경
		String[] sign = new String[rmslist.size()];
		for(int i=0; i < rmslist.size(); i++) {
			if(rmslist.get(i).getRms_sign().equals("미승인")) {
				sign[i] = "미제출";
			} else if(rmslist.get(i).getRms_sign().equals("승인")){
				sign[i] = "제출";						
			} else {
				sign[i] = rmslist.get(i).getRms_sign();						
			}
		}
		
		// [bbsDeadline, sign, pluser] 다음 목록이 있는지 확인
		ArrayList<rmsrept> afrmslist = rms.getrmsSign(id, pageNumber+1);
		
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
			<a class="navbar-brand" href="/RMS/user/bbs.jsp">Report Management System</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav navbar-left">
					<li class="dropdown">
						<a href="#" class="dropdown-toggle"
							data-toggle="dropdown" role="button" aria-haspopup="true"
							aria-expanded="false">주간보고<span class="caret"></span></a>
						<!-- 드랍다운 아이템 영역 -->	
						<ul class="dropdown-menu">
							<li><a href="/RMS/user/bbs.jsp">조회</a></li>
							<li><a href="/RMS/user/bbsUpdate.jsp">작성</a></li>
							<li class="active"><a href="/RMS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(au.equals("PL")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= pl %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><h5 style="background-color: #e7e7e7; height:40px; margin-top:-20px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %></h5></li>
								<li><a href="/RMS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="/RMS/pl/summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/RMS/pl/bbsRkwrite.jsp">작성</a></li>
								<li><a href="/RMS/pl/summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li id="summary_nav"><a href="/RMS/pl/summaryRkSign.jsp">조회 및 출력</a></li>
							</ul>
							</li>
						<%
							}
						%>
						<%
							if(au.equals("관리자") || au.equals("PL")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">summary<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><h5 style="background-color: #e7e7e7; height:40px; margin-top:-20px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li><a href="/RMS/admin/summaryadRk.jsp">조회 및 승인</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; AMS 주간보고</h5></li>
								<li><a href="/RMS/admin/ams/attachment.jsp">첨부 및 출력</a></li>
								<!-- <li><a href="/RMS/admin/summaryadAdmin.jsp">작성</a></li>
								<li><a href="/RMS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li> -->
								<!-- <li data-toggle="tooltip" data-html="true" data-placement="right" title="승인처리를 통해 제출을 확정합니다."><a href="bbsRkAdmin_backup.jsp">승인</a></li> -->
							</ul>
							</li>
						<%
							}
						%>
				</ul>
			
		
			
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li><a data-toggle="modal" href="#UserUpdateModal" style="color:#2E2E2E"><%= name %>(님)</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(au.equals("관리자")||au.equals("PL")) {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a></li>
						<li><a href="/RMS/admin/work/workChange.jsp">담당업무 변경</a></li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a>
						
						</li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	
	<!-- 모달 불러오기 -->
	<div id="modalCall">
		<textarea style="display:none" id="ui"><%= id %></textarea>
		<textarea style="display:none" id="pw"><%= password %></textarea>
		<textarea style="display:none" id="nm"><%= name %></textarea>
		<textarea style="display:none" id="rn"><%= rank %></textarea>
		<textarea style="display:none" id="em"><%= email[0] %></textarea>
		<textarea style="display:none" id="ws"><%= workSet %></textarea>
		<jsp:include page="../modal.html" flush="false" />
	</div>	
	
	<%
	if(rmslist.isEmpty()) {
		/* PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('모든 보고가 승인(또는 마감)처리 되었습니다.')");
		script.println("location.href='bbs.jsp'");
		script.println("history.back()");
		script.println("</script>"); */
	%>
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; " data-toggle="tooltip" data-html="true" data-placement="bottom" title="'미제출'된 주간보고를 <br>수정/삭제/제출할 수 있습니다.">주간보고 수정 및 제출
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
			</thead>
		</table>
	</div>
	<div class="container">
		<table class="table" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr valign="top" style="height:150px">
				</tr>
				<tr valign="bottom" style="height:150px">
					<th colspan="5" style=" text-align: center; color:black ">미제출된 주간보고가 없습니다. <br><br><br><br></th>
				</tr>

			</thead>
		</table>
		<button style="margin:5px" class="btn btn-primary pull-right" onclick="location.href='/RMS/user/bbs.jsp'">목록</button>
	</div>
	
	<% 
	} else {
	%>
		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; " data-toggle="tooltip" data-html="true" data-placement="bottom" title="'미승인'된 주간보고를 <br>수정/삭제/승인할 수 있습니다.">주간보고 수정 및 제출
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table id="bbsTable" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<!-- <th style="background-color: #eeeeee; text-align: center;">번호</th> -->
						<th style="background-color: #eeeeee; text-align: center;">제출일</th>
						<th style="background-color: #eeeeee; text-align: center;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;제목</th>
						<th style="background-color: #eeeeee; text-align: center;">작성자</th>
						<th style="background-color: #eeeeee; text-align: center;">작성일(수정일)</th>
						<th style="background-color: #eeeeee; text-align: center;">담당</th>
						<th style="background-color: #eeeeee; text-align: center;">상태</th>
						<th style="background-color: #eeeeee; text-align: center;">처리</th>
					</tr>
				</thead>
				<tbody>
					<%
						
						// 미승인 (마감, 승인 제외)인 bbs만을 가져옴!
						for(int i = 0; i < rmslist.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							
							String dl = rmslist.get(i).getRms_dl();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
							
					%>

						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= rmslist.get(i).getRms_dl() %> </td>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/RMS/user/update.jsp?rms_dl=<%= rmslist.get(i).getRms_dl() %>">
							<%= rmslist.get(i).getRms_title() %></a></td>
						<td><%= name %></td>
						<td><%= rmslist.get(i).getRms_time().substring(0, 11) + rmslist.get(i).getRms_time().substring(11, 13) + "시"
							+ rmslist.get(i).getRms_time().substring(14, 16) + "분" %></td>
						<td><%= pl %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td><%= rmslist.get(i).getRms_sign() %></td>
						<td data-toggle="tooltip" data-html="true" data-placement="right" title="제출시, <br>수정 및 삭제가 불가합니다.">
							<a class="btn btn-success" style="font-size:12px" href="/RMS/user/action/signOnAction.jsp?rms_dl=<%= rmslist.get(i).getRms_dl() %>" onclick="return confirm('제출하시겠습니까?\n제출시, 수정/삭제가 불가합니다.');"> 제출 </a>
						</td>
					</tr>
					<%
						}
					%>
				</tbody>
			</table>

			<!-- 페이징 처리 영역 -->
			<%
				if(pageNumber != 1){
			%>
				<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(afrmslist.size() != 0){
			%>
				<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					id="next" class="btn btn-success btn-arraw-left">다음</a>
			<%
				}
			%>
			
			<a href="/RMS/user/bbs.jsp" class="btn btn-primary pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="주간보고 조회">목록</a>
		</div>
	</div>
	<!-- 게시판 메인 페이지 영역 끝 -->
	<%
	}
	%>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchField');
			
		}
	</script>
	
	<!-- 보고 개수에 따라 버튼 노출 (list.size()) -->
	<script>
	var trCnt = $('#bbsTable tr').length; 
	
	if(trCnt < 11) {
		$('#next').hide();
	}
	</script>
	
</body>
</html>