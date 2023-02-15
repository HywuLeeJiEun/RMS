<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.tomcat.util.buf.StringUtils"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>   

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<title>RMS</title>
<link href="../css/index.css" rel="stylesheet" type="text/css">
</head>



<body>
	<!--  ********* 세션(session)을 통한 클라이언트 정보 관리 *********  -->
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
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
		
		//현재날짜 구하기
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		LocalDate nowdate = LocalDate.now();
		String now = nowdate.format(formatter);
		
		
		//기존 데이터 불러오기 (가장 최근에 작성된 rms 조회)
		String rms_dl = rms.getMaxDL(id);
		if(rms_dl == null || rms_dl.isEmpty()){ //만약, bbsDeadline이 비어있다면, -> 작성한 글이 없음!
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/user/main.jsp'");
			script.println("</script>");
		}
		
		//RMEREPT 내용 조회 (금주, 차주 나눠서 조회!)
		//금주
		ArrayList<rmsrept> tlist = rms.getRmsOne(rms_dl, id,"T");
		//차주
		ArrayList<rmsrept> nlist = rms.getRmsOne(rms_dl, id,"N");

		
		// 7일 더하기
		String DDline = tlist.get(0).getRms_dl();
		LocalDate date = LocalDate.parse(DDline, formatter);
		date = date.plusWeeks(1); //일주일을 더하는 것.
	%>
	<c:set var="works" value="<%= works %>" />
	<input type="hidden" id="work" value="<c:out value='${works}'/>">
	
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
							<li class="active"><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
							<li><a href="/BBS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
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
							if(au.equals("관리자") || au.equals("PL")) {
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
					if(au.equals("관리자")||au.equals("PL")) {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a></li>
						<li><a href="/BBS/admin/work/workChange.jsp">담당업무 변경</a></li>
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
	
	<!-- ********** 게시판 글쓰기 양식 영역 ********* -->
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
				<form method="post" action="/BBS/user/action/mainAction.jsp" id="main" name="main" onsubmit="return false">
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="6" style="background-color: #eeeeee; text-align: center;">주간보고 작성</th>
							</tr>
						</thead>
						<tbody id="tbody">
							<tr>
									<td colspan="2"> 
									주간보고 명세서 <input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= tlist.get(0).getRms_title() %>"></td>
									<td colspan="1"></td>
									<td colspan="3">  주간보고 제출일 <input type="date" max="9999-12-31" required style="width:80%; margin-left:20px" class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= date %>"></td>
							</tr>
									<tr>
										<th colspan="6" style="background-color: #D4D2FF;" align="center">금주 업무 실적</th>
									</tr>
									<tr style="background-color: #FFC57B;">
										<!-- <th width="6%">|  담당자</th> -->
										<th width="50%">| &nbsp; 업무내용</th>
										<th width="10%">| &nbsp; 접수일</th>
										<th width="10%">| &nbsp; 완료목표일</th>
										<th width="10%">| &nbsp;&nbsp; 진행율<br>&nbsp;&nbsp;&nbsp;&nbsp;/완료일</th>
										<th></th>
										<th></th>
									</tr>
									
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= name %></textarea></td> 
									</tr>
									<tr>
										 <td>
										 	<div style="float:left">
											 <select name="jobs0" id="jobs0" style="height:45px; width:120px; text-align-last:center;">
													 <option> [시스템] </option>
													 <%
													 for(int count=0; count < works.size(); count++) {
													 %>
													 	<option> <%= works.get(count) %> </option>
													 <%
													 }
													 %>
													 <option> 기타 </option>
												 </select>
											 </div>
											 <div style="float:left">
											 <textarea class="textarea con" wrap="hard" id="bbsContent0" maxlength="500" required style="height:45px;width:160%; border:none; resize:none " placeholder="업무내용" name="bbsContent0"></textarea>
											 </div>
										 </td>
										 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsStart0" class="form-control" placeholder="접수일" name="bbsStart0" value="<%= now %>" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget0" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget0" ></td>		
										 <td><textarea class="textarea" id="bbsEnd0" style="height:45px; width:100%; border:none; resize:none"  placeholder="진행율&#13;&#10;/완료일" maxlength="10" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd0" ></textarea></td>
										 <td><button type="button" style="margin-bottom:5px; margin-top:5px; visibility:hidden" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button></td>
										 <td><button type="button" id="paste0" class="btn btn-default" style="margin-bottom:5px; margin-top:5px;" onclick="paste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button></td>
									</tr>
									</tbody>
								</table>
									<div id="wrapper" style="width:100%; text-align: center;">
										<button type="button" id="add" style="margin-bottom:15px; margin-right:30px" onclick="addRow()" class="btn btn-primary"> + </button>
									</div>	 			


				<!-- 차주 업무 계획  -->
				<table class="table" id="bbsNTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
				<thead>
				</thead>
				<tbody id="tbody">
							<tr>
								<th colspan="6" style="background-color: #D4D2FF;" align="center">차주 업무 계획</th>
							</tr>
							<tr style="background-color: #FFC57B;">
								<th width="50%">| &nbsp; 업무내용</th>
								<th width="10%">| &nbsp; 접수일</th>
								<th width="10%">| &nbsp; 완료목표일</th>
								<th></th>
								<th></th>
							</tr>
							<tr>
							<td><div style="float:left">
								<select name="njobs0" id="njobs0" style="height:45px; width:120px; text-align-last:center;">
									<option> [시스템] </option>
									<%
									 for(int count=0; count < works.size(); count++) {
									 %>
									 	<option> <%= works.get(count) %> </option>
									 <%
									 }
									 %>
									<option> 기타 </option>
								</select>
								</div>
								<div style="float:left">
								<textarea wrap="hard" class="textarea ncon" maxlength="500" id="bbsNContent0" required style="height:45px;width:160%; resize:none; border:none; " placeholder="업무내용" name="bbsNContent0"></textarea>
							</div> </td>
								 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsNStart0" class="form-control" placeholder="접수일" name="bbsNStart0" value="<%= now %>" ></td>
								 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget0" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget0" value=""></td>	
								 <td><button type="button" style="margin-bottom:5px; margin-top:5px; visibility:hidden" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>
								 <td><button type="button" id="npaste0" class="btn btn-default" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button></td>
							</tr>
							</tbody>
						</table>
						<div id="wrapper" style="width:100%; text-align: center;">
								<button type="button" id="nadd" style="margin-bottom:5px; margin-top:5px; margin-right:35px; margin-bottom:50px;" onclick="addNRow()" class="btn btn-primary"> + </button>
						</div>
						
						<!-- '계정 관리가 있을 경우, 생성' -->
						<table class="table" id="accountTable" style="text-align: center; cellpadding:50px; display:none;" >
							<tbody id="tbody">
							<tr>
								<th colspan="6" style="background-color: #ccffcc;" align="center">ERP 디버깅 권한 신청 처리 현황</th>
							</tr>
							<tr style="background-color: #FF9933; border: 1px solid">
								<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
								<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px"></th>
							</tr>
							
							</tbody>
						</table>
						<div id="wrapper_account" style="width:100%; text-align: center; display:none">
							<button type="button" style="margin-bottom:15px; margin-right:33px" onclick="addRowAccount()" class="btn btn-primary " data-toggle="tooltip" data-placement="bottom" title="ERP 디버깅 권한 신청 처리 작성"> + </button>
						</div>
						<!-- 계정 관리 끝 -->
						<div id="wrapper" style="width:100%; text-align: center;">
							<!-- 저장 버튼 생성 -->
							<button type="button" id="save" style="margin-bottom:50px; margin-left:20px" class="btn btn-primary pull-right" onclick="saveData()" data-toggle="tooltip" data-placement="bottom" title="작성된 내용을 저장합니다."> 저장 </button>		
							<button type="button" style="margin-bottom:50px" class="btn btn-info pull-right" onClick="empty()" data-toggle="tooltip" data-placement="bottom" title="작성된 내용을 지웁니다."> 비우기 </button>									
							<button type="Submit" id="save_sub" style="margin-bottom:50px; display:none" class="btn btn-primary pull-right"> 저장 </button>	
						</div>					
				</form>
			</div>
		</div>


	<!-- 현재 날짜에 대한 데이터 -->
	<textarea class="textarea" id="now" style="display:none " name="now"><%= now %></textarea>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	

	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('input keyup keydown focusin focusout blur mousemove', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
			
		});
	</script>	
	
	<script>
	var con = 0;
	var trCnt = 1;
		function addRow() {
			var work = "";
			var strworks ="";
			
			work = document.getElementById("work").value;
			work = work.replace("[","");
			work = work.replace("]","");
			work = work.replace(/\n/g,"");
			work = work.split(',');		
		
			
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			 	//console.log(work[count]);
			} 
				//var trCnt = $('#bbsTable tr').length;
				//var trCnt = parseInt(document.getElementById("len").value) + parseInt($('#bbsTable tr').length) + 1 - parseInt($('#bbsTable tr').length);
				
				//console.log(trCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				if(trCnt < 30) {
				
				var now = document.getElementById("now").value;

				//앞에 생성된 데이터의 숫자 가져오기
				if(document.getElementsByClassName('con').length != 0) {
				var	conName = document.getElementsByClassName('con');
					con = conName[conName.length-1].getAttribute('name');
					con = Number(con.replace('bbsContent',''));
					con += 1;
				}
				var c = "";
				if(document.getElementsByClassName('con').length != 0) {
					c = con;
				}else {
					c = trCnt;
				}
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="jobs'+c+'" id="jobs'+c+'" style="height:45px; width:120px; text-align-last:center;">';
	            innerHtml += '			<option> [시스템] </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += ' <div style="float:left">';
	            innerHtml += ' <textarea wrap="hard" class="textarea con" maxlength="500" id="bbsContent'+c+'" required style="height:45px;width:160%; border:none; resize:none" placeholder="업무내용" name="bbsContent'+c+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsStart'+c+'" class="form-control" placeholder="접수일" name="bbsStart'+c+'"  value="'+now+'"></td>';
	            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget'+c+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsTarget'+c+'" ></td>';
	            innerHtml += '  <td><textarea class="textarea" id="bbsEnd'+c+'" style="height:45px; resize:none; width:100%; border:none;" maxlength="10" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다."  placeholder="진행율\n/완료일" name="bbsEnd'+c+'" ></textarea></td>'; 
	            innerHtml += '    <td>';
	            innerHtml += '<button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '    <td>';
	            innerHtml += '<button type="button" id="paste'+c+'" class="btn btn-default" style="margin-bottom:5px; margin-top:5px;" onclick="paste(this.id)"><span class="glyphicon glyphicon-arrow-down"></span></button>';
	            innerHtml += '    </td>';
	            innerHtml += '</tr>'; 
	            trCnt += 1;
	            $('#bbsTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}
		};
	</script>
	
	<script>
	$(document).on("click","button[name=delRow]", function() {
		var trHtml = $(this).parent().parent();
		trHtml.remove();
		trCnt --;
	});
	</script>
	
	
	<script>
	var ncon = 0;
	var trNCnt = 1;
		function addNRow() {
			var work = "";
			var strworks ="";
			
			work = document.getElementById("work").value;
			work = work.replace("[","");
			work = work.replace("]","");
			work = work.replace(/\n/g,"");
			work = work.split(',');
				
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			} 
				//var trNCnt = parseInt(document.getElementById("nlen").value) + parseInt($('#bbsNTable tr').length) + 1 - parseInt($('#bbsNTable tr').length);
				
				if(trNCnt < 30) {
				//console.log(trNCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				if(document.getElementsByClassName('ncon').length != 0) {
				var now = document.getElementById("now").value;
				//앞에 생성된 데이터의 숫자 가져오기
					var nconName = document.getElementsByClassName('ncon');
					ncon = nconName[nconName.length-1].getAttribute('name');
					ncon = Number(ncon.replace('bbsNContent',''));
					ncon += 1;
				}
				var n = "";
				if(document.getElementsByClassName('ncon').length != 0) {
					n = ncon;
				}else {
					n = trNCnt;
				}
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="njobs'+n+'" id="njobs'+n+'" style="height:45px; width:120px; text-align-last:center;">';
	            innerHtml += '			<option> [시스템] </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += ' <div style="float:left">';
	            innerHtml += ' <textarea wrap="hard" class="textarea ncon" maxlength="500" id="bbsNContent'+n+'" required style="height:45px;width:160%; resize:none; border:none; " placeholder="업무내용" name="bbsNContent'+n+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNStart'+n+'" class="form-control" placeholder="접수일" name="bbsNStart'+n+'" value="'+now+'"></td>';
	            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget'+n+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsNTarget'+n+'" ></td>';
	            innerHtml += '<td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '<td><button type="button" id="npaste'+n+'" class="btn btn-default" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)"><span class="glyphicon glyphicon-arrow-down"></span></button></td>';
	            innerHtml += '</tr>'; 
	            trNCnt += 1;
	            $('#bbsNTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 30개를 넘을 수 없습니다.");
				}

		};
	</script>
	
	<script>
		$(document).on("click","button[name=delNRow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trNCnt --;
		});
		</script>
	

	<textarea class="textarea" id="workSet" name="workSet" style="display:none;" readonly><%= workSet %></textarea>
	<script>
	//'계정관리' 업무를 담당하고 있다면, 
	$(document).ready(function() {
		var workSet = document.getElementById("workSet").value;
		if(workSet.indexOf("계정관리") > -1) {
			// accountTable 보이도록 설정
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	//줄개수(count)
	var acon = 0;
	var trACnt = 0;
	//'계정관리' 업무를 추가함.
	function addRowAccount() {
		//처음 작업시, erp 디버깅 권한 신청 처리 현황을 보이게 함.
		document.getElementById("accountTable").style.display="block";
		
		if(trACnt < 2) {//최대 5개까지 증진
			if(document.getElementsByClassName('acon').length != 0) {
				var aconName = document.getElementsByClassName('acon');
				acon = aconName[aconName.length-1].getAttribute('name');
				acon = Number(acon.replace('erp_date',''));
				acon += 1;
			}
			var a = "";
			if(document.getElementsByClassName('acon').length != 0) {
				a = acon;
			}else {
				a = trACnt;
			}
		var innerHtml = "";
		var now = document.getElementById("now").value;
		innerHtml += '<tr>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">';
		//innerHtml += '<textarea class="textarea acon" required maxlength="10" id="erp_date'+a+'"  style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date'+a+'"></textarea></td>';
		innerHtml += '<input type="date" class="acon" max="9999-12-31" required name="erp_date'+a+'" value="'+now+'"></td>'; 
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px"> ';
		innerHtml += '<textarea class="textarea" required maxlength="10" id="erp_user'+a+'"  style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="150" id="erp_stext'+a+'"  style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="20" id="erp_authority'+a+'"  style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid;">  ';
		//innerHtml += '<textarea class="textarea" required maxlength="2" id="erp_division'+a+'"  style=" width:130px; border:none; resize:none" placeholder="구분(일반/긴급)" name="erp_division'+a+'"></textarea></td>';
		innerHtml += '<select name="erp_division'+a+'"><option>일반</option><option>긴급</option></select></td>';
		innerHtml += '<td style="border: 1px solid;"><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delARow" name="delARow" class="btn btn-danger"> 삭제 </button>';
        innerHtml += '    </td>';
		innerHtml +='</tr>';
		trACnt += 1;
		$('#accountTable > tbody:last').append(innerHtml);
		} else {
			alert("계정관리 업무는 최대 2개까지 작성 가능합니다.");
			}
	};
	</script>
	
	<script>
		$(document).on("click","button[name=delARow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trACnt --;
		}); 
	</script>
	
	<script>
	/* document.main.addEventListener("keydown", evt => {
		if((evt.keyCode || evt.which) === 13) {
			evt.preventDefault();
		}
	}); */
	// 데이터 보내기 (몇줄을 사용하는지!) <trCnt, trNCnt>
   // $(document).on('click', "#id" ,function(){
	//$("#save").on('click',function(){
	function saveData() {
		var innerHtml = "";
		innerHtml += '<tr style="display:none">';
		innerHtml += '<td><textarea class="textarea" id="trCnt" name="trCnt" readonly>'+trCnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="trNCnt" name="trNCnt" readonly>'+trNCnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="trACnt" name="trACnt" readonly>'+trACnt+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="con" name="con" readonly>'+con+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="ncon" name="ncon" readonly>'+ncon+'</textarea></td>';
		innerHtml += '<td><textarea class="textarea" id="acon" name="acon" readonly>'+acon+'</textarea></td>';
		innerHtml += '</tr>';
        $('#bbsNTable > tbody> tr:last').append(innerHtml);
        $("#save_sub").trigger("click");
        
        var form = document.getElementById("main");
        if(form.checkValidity()) {
        	form.action = "/BBS/user/action/mainAction.jsp";
            form.mathod = "post";
            form.submit(); 
        }
    }
	
	
	function empty() {
		var check = confirm("작성된 내용이 삭제됩니다. 정말 비우시겠습니까?");
		if(check ){
			location.href='/BBS/user/bbsUpdate_empty.jsp';
		}
	}
	</script>
	<script>
	function paste(id) {
		//alert(id); //pasteX
		const regex = /[^0-9]/g;
		var num = id.replace(regex,"");
		//선택된 업무 내용 읽기
		var a = document.getElementById("jobs"+num);
		var jobs = a.options[a.selectedIndex].value;
		//작성된 접수일 내용
		var start = document.getElementById("bbsStart"+num).value;
		//작성된 완료목표일 내용
		var target = document.getElementById("bbsTarget"+num).value;
		
		//데이터를 계승함! 
		var tr = $("#bbsContent"+num).parent().parent().parent();
		var nexttr = tr.next();
		if(nexttr.length != 0){ //다음 데이터가 있다면, (다음 주간보고 작성이 있다는 것!)
			var b = nexttr.get(0).querySelector(".con").id;
			var unum = b.replace(regex,"");
				//1. 데이터 삽입
					//업무 내용 넣기
				$("#jobs"+(Number(unum))).val(jobs).prop("selected", true);
					//작성된 접수일 넣기
				$("#bbsStart"+(Number(unum))).val(start);
					//작성된 완료목표일 넣기
				$("#bbsTarget"+(Number(unum))).val(target);
				
		} else {
			 document.getElementById("add").click();
			 paste(id);
		}
	}
	
	function npaste(id) {
		//alert(id); //pasteX
		const regex = /[^0-9]/g;
		var num = id.replace(regex,"");
		//선택된 업무 내용 읽기
		var a = document.getElementById("njobs"+num);
		var jobs = a.options[a.selectedIndex].value;
		//작성된 접수일 내용
		var start = document.getElementById("bbsNStart"+num).value;
		//작성된 완료목표일 내용
		var target = document.getElementById("bbsNTarget"+num).value;
		
		//데이터를 계승함! 
		var tr = $("#bbsNContent"+num).parent().parent().parent();
		var nexttr = tr.next();
		if(nexttr.length != 0){ //다음 데이터가 있다면, (다음 주간보고 작성이 있다는 것!)
			var b = nexttr.get(0).querySelector(".ncon").id;
			var unum = b.replace(regex,"");
				//1. 데이터 삽입
					//업무 내용 넣기
				$("#njobs"+(Number(unum))).val(jobs).prop("selected", true);
					//작성된 접수일 넣기
				$("#bbsNStart"+(Number(unum))).val(start);
					//작성된 완료목표일 넣기
				$("#bbsNTarget"+(Number(unum))).val(target);
				
		} else {
			 document.getElementById("nadd").click();
			 npaste(id);
		}
	}
	</script>
	
</body>