<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../../css/css/bootstrap.css">
<link rel="stylesheet" href="../../css/index.css">

<title>RMS</title>
</head>



<body>
<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보

		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		}
		
		// ********** 유저를 가져오기 위한 메소드 *********** 
		//String workset;
		//works 리스트에 저장됨!
		//user_id => 현재 탐색중인 사원의 이름
		String user_id = request.getParameter("user_id");
		
		if(user_id == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('대상자가 없습니다. 사원의 이름을 확인해주십시오.')");
			script.println("location.href='/BBS/admin/work/workChange.jsp'");
			script.println("</script>");
		}
		//str이 user 목록에 있는지 확인.
		if(userDAO.getUser(user_id) == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('대상자가 없습니다. 사원의 이름을 확인해주십시오.')");
			script.println("location.href='/BBS/admin/work/workChange.jsp'");
			script.println("</script>");
		} 
	
		ArrayList<String> getcode = userDAO.getCode(user_id); //코드 리스트 출력
		List<String> getworks = new ArrayList<String>();
		String str=" ";
		String workset ="";
		
		if(getcode == null) {
			str = "";
			workset ="";
		} else {
			for(int i=0; i < getcode.size(); i++) {
				// code 번호에 맞는 manager 작업을 가져와 저장해야함!
				String manager = userDAO.getManager(getcode.get(i));
				getworks.add(manager); //즉, work 리스트에 모두 담겨 저장됨
			}
			
			workset = String.join("/",getworks);
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
				//task_num을 받아옴.
				String task_num = code.get(i);
				// task_num을 통해 업무명을 가져옴.
				String manager = userDAO.getManager(task_num);
				works.add(manager+"\n"); //즉, work 리스트에 모두 담겨 저장됨
			}
			workSet = String.join("/",works);
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
		
		//모든 사용자 아이디 가져오기!
		ArrayList<String> fuser = userDAO.getidfull();
		//중복값 제거
		for(int i=0; i < fuser.size(); i++) {
			if(fuser.get(i) != null && fuser.get(i).equals("user_id")) {
				fuser.remove(i);
			} else if(fuser.get(i) == null || fuser.get(i).equals("미정")) {
				fuser.remove(i);
			}
		}
	%>
	<!-- 모달 영역! -->
	   <div class="modal fade" id="UserUpdateModal" role="dialog">
		   <div class="modal-dialog">
		    <div class="modal-content">
		     <div class="modal-header">
		      <button type="button" class="close" data-dismiss="modal">×</button>
		      <h3 class="modal-title" align="center">개인정보 수정</h3>
		     </div>
		     <!-- 모달에 포함될 내용 -->
		     <form method="post" action="../../ModalUpdateAction.jsp" id="modalform">
		     <div class="modal-body">
		     		<div class="row">
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">ID </label>
		     				<input type="text" maxlength="20" class="form-control" readonly style="width:100%" id="updateid" name="updateid"  value="<%= id %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
						<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label"> Password </label>
		     				<input type="password" maxlength="20" required class="form-control" style="width:100%" id="password" name="password" value="<%= password %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<i class="glyphicon glyphicon-eye-open" id="icon" style="right:20%; top:35px;" ></i>
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">name </label>
		     				<input type="text" maxlength="20" required class="form-control" style="width:100%" id="name" name="name"  value="<%= name %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">rank </label>
		     				<input type="text" required class="form-control" data-toggle="tooltip" data-placement="bottom" title="직급 변경은 관리자 권한이 필요합니다." readonly style="width:100%" id="rank" name="rank"  value="<%= rank %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-4 form-outline">
		     				<label class="col-form-label">email </label>
		     				<input type="text" maxlength="30" required class="form-control" style="width:100%" id="email" name="email"  value="<%= email[0] %>"> 
		     			</div>
		     			<div class="col-md-3" align="left" style="top:5px; right:20px">
		     				<label class="col-form-label" > &nbsp; </label>
		     				<div><i>@ s-oil.com</i></div>
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			
		     			
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label">duty </label>
		     				<input type="text" required class="form-control" readonly data-toggle="tooltip" data-placement="bottom" title="업무 변경은 관리자 권한이 필요합니다." style="width:100%" id="duty" name="duty" value="<%= workSet %>">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     		</div>	
		     </div>
		     <div class="modal-footer">
			     <div class="col-md-3" style="visibility:hidden">
     			</div>
     			<div class="col-md-6">
			     	<button type="submit" class="btn btn-primary pull-left form-control" id="modalbtn" >수정</button>
		     	</div>
		     	 <div class="col-md-3" style="visibility:hidden">
	   			</div>	
		    </div>
		    </form>
		   </div>
	  </div>
	</div>
	
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
			<a class="navbar-brand" href="/BBS/user/bbs.jsp">Report Management System</a>
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
							<li><a href="/BBS/user/bbs.jsp">조회</a></li>
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
								<li><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/BBS/pl/bbsRkwrite.jsp">작성</a></li>
								<li><a href="/BBS/pl/summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li id="summary_nav"><a href="/BBS/pl/summaryRkSign.jsp">조회 및 출력</a></li>
							</ul>
							</li>
						<%
							}
						%>
						<%
							if(au.equals("관리자")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">summary<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><a href="/BBS/admin/summaryadRk.jsp">조회 및 승인</a></li>
								<!-- <li><a href="/BBS/admin/summaryadAdmin.jsp">작성</a></li>
								<li><a href="/BBS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li> -->
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
					if(au.equals("관리자") || au.equals("PL")) {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a></li>
						<li class="active"><a href="/BBS/admin/work/workChange.jsp">담당업무 변경</a></li>
						<li><a href="../../logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a>
						
						</li>
						<li><a href="../../logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
	
	<%		
		
		// 모든 업무 목록을 불러옴. ( ERP,HR, 의 형태로)
		ArrayList<String> jobs = userDAO.getManagerAll();
	%>

	

	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<form method="post" name="search" action="/BBS/admin/work/workChangesearch.jsp">
				<table class="pull-left">
					<tr>
					<td><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i>&nbsp; <b>담당자</b> &nbsp;</td>
						<td><select class="form-control" name="searchField" id="searchField" onchange="if(this.value) location.href=(this.value);">
							<option><%= userDAO.getName(user_id) %></option>
							<% for(int i=0; i < fuser.size(); i++) {%>
								<option value="/BBS/admin/work/workChangesearch.jsp?user_id=<%= fuser.get(i) %>"><%= userDAO.getName(fuser.get(i)) %></option>
							<% } %>
							</select></td>
					</tr>

				</table>
			</form>
		</div>
	</div>
	
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
					<th colspan="5" style=" text-align: center; color:blue "></th>
				</tr>
			</thead>
		</table>
	</div>
		
	<div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
			<tr>
				<th colspan="5" style="text-align: center;"> 담당자 업무 변경 </th>
			</tr>
			<tr>
				<th colspan="5" style="text-align: center;">현재 [ <%= userDAO.getName(user_id) %> ](님)의 담당 업무를 변경중입니다.</th>
			</tr>
			</table>
			
		</div>
	</div>
			
			
	<div class="container d-flex align-items-start" style="text-align:center;">
			<div class="flex-grow-1" style="display:inline-block; width:45%;">
				<table class="table" style="text-align: center; border: 1px solid #dddddd">
					<tr>
						<th colspan="2" style="text-align:center">담당업무</th>
					</tr>
					<%
						if(workset.equals("")) {
					%>
						<tr>
							<td colspan="1" style="text-align:center"><input type=text style="border:0; width:50%; text-align:center" readonly value="담당 업무 해당이 없습니다."></td>
						</tr>
					<% 
						} else {
						// 직업의 개수 만큼 for문을 돌림.
							for(int i=0; i< getworks.size(); i++ ) {
					%>
					<tr>
						<td colspan="1" style="text-align:center"><input type=text name="<%= i %>" style="border:0; width:50%; text-align:center" readonly value="<%= getworks.get(i) %>"></td>
						<td colspan="1"><a type="submit" style="margin-right:50%" class="btn btn-danger pull-left" href="workDeleteActionSh.jsp?work=<%= getworks.get(i) %>&user_id=<%= user_id %>" >삭제</a></td>
					</tr>
					<%
							} if (getworks.size() == 10) {
					%>
						<tr>
							<td colspan="2" style="text-align:center"><input type=text style="border:0; width:100%; text-align:center; color:blue" readonly value="업무 지정은 최대 10개까지만 가능합니다."></td>
						</tr>
					<%
							}
						}
					%>
				</table>
			</div>
			
			<div class="align-self-start" style="display:inline-block; width:5%">
				<table class="table" style="text-align: center; border: 1px solid #dddddd">
				</table>
			</div>
			
			<div class="align-slef-start" style="display:inline-block; width:45%;">
				<form method="post" action="workActionSh.jsp?user_id=<%= user_id %>">
					<table class="table" style="text-align: center; border: 1px solid #dddddd">
						<tr>
							<th colspan="2" style="text-align:center"><input type=text name="user" style="border:0; width:15%; text-align:right" readonly value="<%= userDAO.getName(user_id) %>">(님) 업무관리</th>
						</tr>
						<tr style="border:none">
							<td style="border-bottom:none">
								<select id="workValue" class="form-control pull-right" name="workValue" onchange="selectValue()" style="margin-left:30px; width:70%; text-align-last:center;">
										<%
											for(int i=0; i<jobs.size(); i++) {
										%>
										<option value="<%= jobs.get(i) %>"><%= jobs.get(i) %></option> 
										<%
											}
										%>
								</select>
							</td>
								<td><button type="submit" class="btn btn-primary pull-left" style="margin-light:50%;"  >추가</button></td>
						</tr>
						<% 
						for(int i=0; i<works.size()-1; i++) {
						%>
							<tr style="border:none">
								<td colspan="1" style="border:none"><button style="margin-right:30%; visibility:hidden; border-top:none; border:none" class="btn btn-danger" formaction=""> 가나다  </button></td>
							</tr>	
						<%
							} if (works.size() == 10) {
						%>
							<tr style="border:none">
								<td colspan="1" style="border:none"><button style="margin-right:30%;border:none; visibility:hidden" class="btn btn-danger" formaction=""> 가나다  </button></td>
							</tr>
						<%
								}
						%>
					</table>
				</form>
			</div>
	</div>
	
	
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../../css/js/bootstrap.js"></script>
	
	<!-- modal 내, password 보이기(안보이기) 기능 -->
		<script>
		$(document).ready(function(){
		    $('#icon').on('click',function(){
		    	console.log("hello");
		        $('#password').toggleClass('active');
		        if($('#password').hasClass('active')){
		            $(this).attr('class',"glyphicon glyphicon-eye-close")
		            $('#password').attr('type',"text");
		        }else{
		            $(this).attr('class',"glyphicon glyphicon-eye-open")
		            $('#password').attr('type','password');
		        }
		    });
		});
	</script>
	
	<!-- 모달 툴팁 -->
	<script>
		$(document).ready(function(){
			$('[data-toggle="tooltip"]').tooltip();
		});
	</script>
	
	
	<!-- 모달 submit -->
	<script>
	$('#modalbtn').click(function(){
		$('#modalform').text();
	})
	</script>
	
	<!-- 모달 update를 위한 history 감지 -->
	<script>
	window.onpageshow = function(event){
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)){ //history.back 감지
			location.reload();
		}
	}
	</script>
</body>