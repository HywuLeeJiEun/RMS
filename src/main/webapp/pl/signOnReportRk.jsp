<%@page import="rmsrept.rmsedps"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
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
		String pageNumber="1";
		if(request.getParameter("pageNumber") != null)  {
			pageNumber = request.getParameter("pageNumber");
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
		
		//기존 데이터 불러오기 (파라미터로 bbsDeadline 받기)
		String rms_dl = request.getParameter("rms_dl");
		//만약 user_id가 있다면!
		String user_id = request.getParameter("user_id");
		if(user_id == null || user_id.isEmpty()) {
			user_id = id;
		}
		// 만약 넘어온 데이터가 없다면
		if(rms_dl == null || rms_dl.isEmpty()){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script");
		}

		
		//RMEREPT 내용 조회 (금주, 차주 나눠서 조회!)
		//금주
		ArrayList<rmsrept> tlist = rms.getRmsOne(rms_dl, user_id,"T");
		//차주
		ArrayList<rmsrept> nlist = rms.getRmsOne(rms_dl, user_id,"N");
		
		//erp 계정관리 권한이 있는 사용자인지 조회하기 (RMSTASK)
		String task_num = userDAO.getTask("계정관리");
		//user가 해당 권한을 부여받고 있는지 확인하기 (RMSMGRS)
		String rmsmgrs = userDAO.getMgrs(task_num);
		
		//erp_data 가져오기
		ArrayList<rmsedps> erp = null;
		if(rmsmgrs.equals(user_id)) {
		erp = rms.geterp(rms_dl);
		}
		int eSize = 0;
		if(erp != null) {
			eSize = erp.size();
		}
		
		// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		String dl = rms_dl;
		if(dl.isEmpty()) { //삭제 되어 비어있다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('게시글이 제거되거나 수정되었을 수 있습니다. 확인하여 주십시오.')");
			script.println("history.back()");
			script.println("</script>");
		}
		Date time = new Date();
		String timenow = dateFormat.format(time);

		Date dldate = dateFormat.parse(dl);
		Date today = dateFormat.parse(timenow);
		
		//현재날짜 구하기
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		LocalDate nowdate = LocalDate.now();
		String now = nowdate.format(formatter);
		
		//미승인된 rms를 찾아옴.		
		ArrayList<rmsrept> list = rms.getrmsSign(id, 1);
	%>
	<c:set var="works" value="<%= works %>" />
	<input type="hidden" id="work" value="<c:out value='${works}'/>">
	<input type="hidden" id="eSize" value="<%= eSize %>"/>
	<input type="hidden" id="au" value="<%= au %>"/>
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
					<% if(au.equals("관리자")) { %>
						<ul class="dropdown-menu">
							<li class="active"><a href="/BBS/user/bbs.jsp">조회</a></li>
						</ul>
					<% }else { %>
						<ul class="dropdown-menu">
							<li><a href="/BBS/user/bbs.jsp">조회</a></li>
							<li><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
							<li><a href="/BBS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					<% } %>
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
								<li class="active"><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/BBS/pl/bbsRkwrite.jsp>">작성</a></li>
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
				<form method="post"  action="/BBS/user/action/updateAction.jsp" id="main" name="main" onsubmit="return false">
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="100%" style="background-color: #eeeeee; text-align: center;">주간보고 조회</th>
							</tr>
						</thead>
						<tbody id="tbody">
							<tr>
									<td colspan="2"> 
									주간보고 명세서 <input type="text" required readonly class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= tlist.get(0).getRms_title() %>"></td>
									<td colspan="1"></td>
									<td colspan="2">  주간보고 제출일 <input type="date" max="9999-12-31" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" value="<%= tlist.get(0).getRms_dl() %>" readonly><textarea name="rms_sign" style="display:none"><%= tlist.get(0).getRms_sign() %></textarea></td>
							</tr>
									<tr>
										<th colspan="100%" style="background-color: #D4D2FF;" align="center">금주 업무 실적</th>
									</tr>
									<tr style="background-color: #FFC57B;">
										<!-- <th width="6%">|  담당자</th> -->
										<th width="50%">| &nbsp; 업무내용</th>
										<th width="10%">| &nbsp; 접수일</th>
										<th width="10%">| &nbsp; 완료목표일</th>
										<th width="10%">| &nbsp;&nbsp; 진행율<br>&nbsp;&nbsp;&nbsp;&nbsp;/완료일</th>
									</tr>
									
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= name %></textarea></td> 
									</tr>
									<%
									if(tlist.size() != 0){
										for(int i=0; i<tlist.size(); i++) {
									%>
									<tr>
										 <td>
										 <div style="float:left">
											<input style="height:45px; width:110px; text-align:center;" readonly value="<%= tlist.get(i).getRms_job() %>">
										 </div>
										 <div style="float:left">
											 <textarea class="textarea con" wrap="hard" readonly id="bbsContent<%= i %>" maxlength="500" required style="height:45px;width:160%; border:none; resize:none " placeholder="업무내용" name="bbsContent<%= i %>"><%= tlist.get(i).getRms_con() %></textarea>
										 </div>
										 </td>
										 <td><input type="date" max="9999-12-31" readonly required style="height:45px; width:auto;" id="bbsStart<%= i %>" class="form-control" placeholder="접수일" name="bbsStart<%= i %>" value="<%= tlist.get(i).getRms_str() %>" ></td>
										 <td><input type="date" max="9999-12-31" readonly style="height:45px; width:auto;" id="bbsTarget<%= i %>" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget<%= i %>" value="<%= tlist.get(i).getRms_tar() %>"></td>		
										 <td><textarea class="textarea" readonly id="bbsEnd<%= i %>" style="height:45px; width:100%; border:none; resize:none"  placeholder="진행율&#13;&#10;/완료일" maxlength="10" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd<%= i %>" ><%= tlist.get(i).getRms_end() %></textarea></td>
									</tr>
									<%
										}
									}
									%>
									</tbody>
								</table>		


				<!-- 차주 업무 계획  -->
				<table class="table" id="bbsNTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
				<thead>
				</thead>
				<tbody id="tbody">
							<tr>
								<th colspan="100%" style="background-color: #D4D2FF;" align="center">차주 업무 계획</th>
							</tr>
							<tr style="background-color: #FFC57B;">
								<th width="50%">| &nbsp; 업무내용</th>
								<th width="10%">| &nbsp; 접수일</th>
								<th width="10%">| &nbsp; 완료목표일</th>
							</tr>
							<%
							if(nlist.size() != 0){
								for(int i=0; i<nlist.size(); i++) {
							%>
							<tr>
								 <td>
								 	<div style="float:left">
									 <input style="height:45px; width:110px; text-align:center;" readonly value="<%= nlist.get(i).getRms_job() %>">
									 </div>
									 <div style="float:left">
									 <textarea class="textarea ncon" readonly wrap="hard" id="bbsNContent<%= i %>" maxlength="500" required style="height:45px;width:160%; border:none; resize:none " placeholder="업무내용" name="bbsNContent<%= i %>"><%= nlist.get(i).getRms_con() %></textarea>
									 </div>
								 </td>
								 <td><input type="date" readonly max="9999-12-31" required style="height:45px; width:auto;" id="bbsNStart<%= i %>" class="form-control" placeholder="접수일" name="bbsNStart<%= i %>" value="<%= nlist.get(i).getRms_str() %>" ></td>
								 <td><input type="date" readonly max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget<%= i %>" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget<%= i %>" value="<%= nlist.get(i).getRms_tar() %>"></td>		
							</tr>
							<%
								}
							}
							%>
							</tbody>
						</table>
						<!-- '계정 관리가 있을 경우, 생성' -->
						<%
							if(erp != null && erp.size() != 0){
						%>
						<table class="table" id="accountTable" style="text-align: center; cellpadding:50px;" >
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
							</tr>
							<%
							if(erp != null && erp.size() != 0){
								for(int i=0; i<erp.size(); i++) {
							%>
							<tr>
								<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">
								  <textarea class="textarea" id="erp_date0" maxlength="10" style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date<%=i%>"><%= erp.get(i).getErp_date() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea" id="erp_user0" maxlength="10" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user<%=i%>"><%= erp.get(i).getErp_user() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea"  id="erp_stext0" maxlength="100" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext<%=i%>"><%= erp.get(i).getErp_text() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea" id="erp_authority0" maxlength="10" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority<%=i%>"><%= erp.get(i).getErp_anum() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea" id="erp_division0" maxlength="2" style=" width:130px; border:none; resize:none " placeholder="구분(일반/긴급)" name="erp_division<%=i%>"><%= erp.get(i).getErp_div() %></textarea></td>
							</tr>
							<%
								}
							}
							%>
							</tbody>
						</table>
						<% } %>
						<!-- 계정 관리 끝 -->
						<div id="wrapper" style="width:100%; text-align: center;">
						<!-- 목록 -->
						<a href="/BBS/pl/bbsRk.jsp?rms_dl=<%= rms_dl %>&pageNumber=<%= pageNumber %>" class="btn btn-primary pull-right" style="margin-bottom:100px; margin-left:20px">목록</a>
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
		$(document).on("click","button[name=delNRow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trNCnt --;
		});
		</script>
	
	<textarea class="textarea" id="workSet" name="workSet" style="display:none;" readonly><%= workSet %></textarea>
	
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

</body>