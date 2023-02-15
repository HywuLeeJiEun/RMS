<%@page import="rmsrept.rmsedps"%>
<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.text.Format"%>
<%@page import="net.sf.jasperreports.engine.type.CalculationEnum"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.Arrays"%>
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
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<link rel="stylesheet" href="../css/index.css">
<style>
.ui-tooltip{
	white-space: pre-line;
}
.ui-tooltip-content {
	white-space: pre-line;
}
</style>
<title>RMS</title>
</head>


<body>
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)

		
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
		 
		//받아온 bbsDeadline을 사용함!
		String rms_dl = request.getParameter("rms_dl");
		if(request.getParameter("rms_dl") == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('잘못된 접근입니다. 해당 요약본을 찾을 수 없습니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		//금주데이터
		ArrayList<rmssumm> tlist = sumDAO.getSumDiv(pl, rms_dl, "T");
		//차주데이터
		ArrayList<rmssumm> nlist = sumDAO.getSumDiv(pl, rms_dl, "N");
		
		if(pl.equals("") || pl == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		String str = "미승인 - 관리자의 미승인 상태<br>";
		str += "승인 - 관리자가 확정한 상태<br>";
		str += "마감 - 기한이 지나 승인된 상태";
		
		
		//erp 데이터가 있는지 확인
		//erp_data
		ArrayList<rmsedps> erp = rms.geterpData(rms_dl);
		
		//전체 리스트에서 미승인이 있는지 확인
		ArrayList<rmssumm> sum = sumDAO.getSumSgin(pl, "미승인", pageNumber); //미승인 상태만 불러옴!
	
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
							<li><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
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
								<li class="active"><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
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
								<li><a href="/BBS/admin/summaryadRk.jsp">조회</a></li>
								<li><a href="/BBS/admin/summaryadAdmin.jsp">작성</a></li>
								<li><a href="/BBS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li>
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

		
	<br>
	<div class="container-fluid" style="width:1200px">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " data-html="true" class="form-control" data-toggle="tooltip" data-placement="bottom" title="승인 및 마감 상태에선<br> 수정/삭제가 불가합니다." > <%= pl %> 요약본(Summary) </th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	<!-- 메인 게시글 영역 -->
	<%
	// 즉, summary가 없다면, 
	if(tlist.isEmpty() || tlist == null) {
	%>
	<br><br><br>
	<div class="container-fluid" style="width:1200px">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" class="form-control" data-toggle="tooltip" data-placement="bottom" title="요약본 작성으로 이동하기" > <a href="/BBS/pl/bbsRk.jsp">작성된 요약본(Summary)이 없습니다. </a></th>
				</tr>
			</thead>
		</table>
	</div>
	
	<%
	} else {
		// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		//bbsDeadline 찾아오기
		String dl = rms_dl;
		Date time = new Date();
		String timenow = dateFormat.format(time);

		Date dldate = dateFormat.parse(dl);
		Date today = dateFormat.parse(timenow);
	%>
	<!-- 목록 조회 table -->
	<div class="container" id="jb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="complete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="proceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="incomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
			 <%-- <tr>
			 	<td>업무 담당자 인원 : <%= plist.size() %></td>
			 </tr> --%> 
		 </table>
	 </div>
	 
	<div class="container-fluid" style="width:1200px">
	<form method="post" action="/BBS/pl/action/bbsRkUpdate.jsp" id="bbsRk">
		<div class="row">
			<div class="container-fluid">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>			
							<td style="background-color:#f9f9f9;" colspan="1" style="align:left;" >요약본</td>
							<td style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title=""> [<%= pl %>] - summary (<%= dl %>)</td>
							<td colspan="2"  style="background-color:#f9f9f9;"><textarea id="rms_dl" name="rms_dl" style="display:none"><%= tlist.get(0).getRms_dl() %></textarea>
								<textarea id="pl" name="pl" style="display:none"><%= tlist.get(0).getUser_fd() %></textarea> 
								<textarea id="sign" name="sign" style="display:none"><%= tlist.get(0).getSum_sign() %></textarea>
								<textarea id="chk" name="chk" style="display:none"><%= tlist.size() %></textarea>
								<textarea id="nchk" name="nchk" style="display:none"><%= nlist.size() %></textarea>
							<td  style="background-color:#f9f9f9;" colspan="1" style="txet:center">상태</td>
							<td  style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title="<%= str %>" ><%= tlist.get(0).getSum_sign() %></td>
						</tr>
						<tr>
							<td></td>
						</tr>
						<tr>
							<th colspan="6" style="background-color:#D4D2FF; align:left; border:none;" > &nbsp;금주 업무 실적</th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="6%" style="text-align: center; border: 1px solid">구분</th>
							<th width="50%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="8%" style="text-align: center; border: 1px solid">완료일</th>
							<th width="10%" style="text-align: center; border: 1px solid">진행율</th>
							<th width="5%" style="text-align: center; border: 1px solid">상태</th>
							<th width="25%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid"><%= tlist.get(0).getUser_fd() %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < tlist.size(); i++) {%>
								<textarea required name="content<%= i %>" maxlength="500" id="content<%= i %>" style="resize: none; width:100%;"><%= tlist.get(i).getSum_con() %></textarea>
							<% } %>
							</td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < tlist.size(); i++) {%>
								<textarea required name="end<%= i %>" maxlength="10" id="end<%= i %>" style="resize: none; width:100%;"><%= tlist.get(i).getSum_enta() %></textarea>
							<% } %>	
							</td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid">
								<select name="progress" id="progress" style="height:45px; width:95px; text-align-last:center;" onchange="selectPro()">
									 <option <%= tlist.get(0).getSum_pro().equals("완료")?"selected":"" %>> 완료 </option>
									 <option <%= tlist.get(0).getSum_pro().equals("진행중")?"selected":"" %>> 진행중 </option>
									 <option <%= tlist.get(0).getSum_pro().equals("미완료")?"selected":"" %>> 미완료 </option>
								</select>	
								<!-- <textarea required name="progress" id="progress" style="resize: none; width:100%; height:100px"></textarea> -->
							</td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="state"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea maxlength="500" name="note" id="note" style="resize: none; width:100%; height:100px"><%= tlist.get(0).getSum_note() %></textarea></td>
						</tr>
						<tr>
							<td></td>
						</tr>
					</tbody>
				</table>
				
				<!-- 차주 업무 계획 테이블 -->
				<table  class="table" style="text-align: center;">
					<thead>
						<tr>
							<td></td>
						</tr>
						<tr>
							<th colspan="4" style="background-color:#FF9900; align:left; border:none" > &nbsp;차주 업무 계획</th>
						</tr>
					</thead>
					<tbody style="border: 1px solid">
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="6%" style="text-align: center; border: 1px solid">구분</th>
							<th width="50%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="8%" style="text-align: center; border: 1px solid">완료예정</th>
							<th width="50%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">
								<textarea id="pl" name="pl" style="display:none"><%= nlist.get(0).getUser_fd() %></textarea><%= nlist.get(0).getUser_fd() %>
							</td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < nlist.size(); i++) { %>
								<textarea required name="ncontent<%= i %>" maxlength="500" id="ncontent<%= i %>" style="resize: none; width:100%;"><%= nlist.get(i).getSum_con() %></textarea>
							<% } %>
							</td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < nlist.size(); i++) { %>	
								<textarea required name="ntarget<%= i %>" maxlength="10" id="ntarget<%= i %>" style="resize: none; width:100%;"><%= nlist.get(i).getSum_enta() %></textarea>
							<% } %>	
							</td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="nnote" maxlength="500" id="nnote" style="resize: none; width:100%; height:100px"><%= nlist.get(0).getSum_note() %></textarea></td>
						</tr>
					</tbody>
				</table>
				
			<!-- erp_bbs가 존재한다면, (bbsDeadline에 해당하는) -->
			<!-- erp_bbs에 자료가 있는 경우 하단 출력! -->
				<%
						if(erp.size() != 0 && pl.equals("ERP")) { //erp가 비어있지 않다면, 하단 출력 (ERP 담당자에게만)
						%>
				<table style="margin-bottom:50px;">
					<tbody>
						<tr>
							<th colspan="5" style="background-color: #ccffcc; border:none" align="center" data-toggle="tooltip" title="해당 데이터는 수정이 불가합니다!">ERP 디버깅 권한 신청 처리 현황</th>
						</tr>
						<tr style="background-color: #FF9933; border: 1px solid">
							<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date</th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
							<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
							<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
						</tr>
						<%
						for (int i=0; i < erp.size(); i++) {
						%>
						<tr>
							<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white"> 
							  <textarea class="textarea" style="display:none" name="erp_size"><%= erp.size() %></textarea>
							  <textarea class="textarea" id="erp_date<%= i %>" style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date<%= i %>" readonly><%= erp.get(i).getErp_date() %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_user<%= i %>" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user<%= i %>" readonly><%= erp.get(i).getErp_user() %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_stext<%= i %>" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext<%= i %>" readonly><%= erp.get(i).getErp_text() %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_authority<%= i %>" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority<%= i %>" readonly><%= erp.get(i).getErp_anum() %></textarea></td>
						  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
							  <textarea class="textarea" id="erp_division<%= i %>" style=" width:130px; border:none; resize:none " placeholder="구분(일반/긴급)" name="erp_division<%= i %>" readonly><%= erp.get(i).getErp_div() %></textarea></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
				<%
					}
				%>	
			</div>
			<%
			if(sum.size() == 0) { //sign이 미승인인 요약본이 없을 경우!
			%>
			<button type="button" class="btn btn-primary pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="location.href='/BBS/pl/summaryRk.jsp'">목록</button> 
			<%
			}else {
			%>
				<button type="button" class="btn btn-primary pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="location.href='/BBS/pl/summaryUpdateDelete.jsp'">목록</button> 
			<% } %>
			<%
			if(tlist.get(0).getSum_sign().equals("미승인")) {
				//if(sumad_id == null || sumad_id.isEmpty()) { //sumad가 생기면, 삭제가 불가함!
			%>
				<button type="button" class="btn btn-danger pull-right" style="width:50px; margin-left:10px; text-align:center; align:center" onclick="if(confirm('삭제하시겠습니까?')){location.href='/BBS/pl/action/bbsRkDelete.jsp?rms_dl=<%= rms_dl %>&pluser=<%= pl %>'}" class="form-control" data-toggle="tooltip" data-placement="bottom" title="관리자가 요약본을 저장할 경우, 삭제가 불가합니다.">삭제</button> 
			<% //} %>
				<button type="button" class="btn btn-info pull-right" style="width:50px; text-align:center; align:center" id="update" name="update" onclick="update()">수정</button> 
			<%
			}
			%>
		</div>
	</form>
	</div>
	<br><br><br>	
	
<%
	}
%>
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
	// 상태 색상 지정
	$(document).ready(function() {
		var con = document.getElementById("progress").value; //완료, 진행중, 미완료(문제)
		var state = document.getElementById("state");
		if(con == "완료") {
			state.style.backgroundColor = "#00ff00";
		} else if (con =="진행중") {
			state.style.backgroundColor = "#ffff00";
		} else {
			state.style.backgroundColor = "#ff0000";
		}
	});
	</script>
	
	<!-- 상태 선택을 위한 script -->
	<script>
	$("#state").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#state");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});
	
	var con = document.getElementById("state");
	$("#complete").on('click', function() {
			con.style.backgroundColor = "#00ff00";
	});
	
	$("#proceeding").on('click', function() {
		con.style.backgroundColor = "#ffff00";
	});

	$("#incomplete").on('click', function() {
		con.style.backgroundColor = "#ff0000";
	});
	</script>
	
	<script>
	//진행율(progess)선택을 통한 상태 변경
	function selectPro() {
		var con = document.getElementById("state");
		var select = document.getElementById("progress").value;
		if(select == "완료") {
			con.style.backgroundColor = "#00ff00";
		}else if(select == "진행중") {
			con.style.backgroundColor = "#ffff00";
		}else if(select == "미완료") {
			con.style.backgroundColor = "#ff0000";
		}else {
			con.style.backgroundColor = "#ffffff";
		}
	}
	</script>
	
	
	<script>
	//$("#update").find('[type="submit"]').trigger('click') {
	//function update() {
	$("#update").on('click', function () {
		if(document.getElementById("content0").value == '' || document.getElementById("content0").value == null) {
			alert("금주 업무 실적의 '업무 내용'이 작성되지 않았습니다.");
		} else {
			if(document.getElementById("end0").value == '' || document.getElementById("end0").value == null) {
				alert("금주 업무 실적의 '완료일'이 작성되지 않았습니다.");
			} else {
				if(document.getElementById("progress").value.indexOf("선택") > -1) {
					alert("금주 업무 실적의 '진행율'이 선택되지 않았습니다.");
				} else {
					if(con.style.backgroundColor == '' || con.style.backgroundColor == null) {
						alert("금주 업무 실적의 '상태'가 선택되지 않았습니다.");
					} else {
						//차주
						if(document.getElementById("ncontent0").value == '' || document.getElementById("ncontent0").value == null) {
							alert("차주 업무 계획의 '업무 내용'이 작성되지 않았습니다.");
						} else {
							if(document.getElementById("ntarget0").value == '' || document.getElementById("ntarget0").value == null) {
								alert("차주 업무 계획의 '완료예정'이 작성되지 않았습니다.");
							} else {
								$('#bbsRk').submit();
							}
						}
					}
				}
			}
		}
	});
	</script>
	
</body>
</html>