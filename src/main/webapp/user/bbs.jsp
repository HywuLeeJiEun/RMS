<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
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
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="../css/index.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
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
		
		//관리자의 권한을 가진 경우, admin으로 넘김
		if(au.equals("관리자")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/admin/bbsAdmin.jsp'");
			script.println("</script>");
		}
		
		//기존 데이터 불러오기 (가장 최근에 작성된 rms 조회)
		ArrayList<rmsrept> list = rms.getrms(id, pageNumber);
		
		//다음 페이지가 있는지 확인!
		ArrayList<rmsrept> aflist = rms.getrms(id, pageNumber+1);
		
		
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
					<li class="dropdown ">
						<a href="#" class="dropdown-toggle"
							data-toggle="dropdown" role="button" aria-haspopup="true"
							aria-expanded="false">주간보고<span class="caret"></span></a>
						<!-- 드랍다운 아이템 영역 -->	
						<ul class="dropdown-menu">
							<li class="active"><a href="/BBS/user/bbs.jsp">조회</a></li>
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

		
		
	<!-- ***********검색바 추가 ************* -->
	<div class="container">
		<div class="row">
			<table class="pull-left" style="text-align: center; cellpadding:50px; width:60%" >
			<thead>
				<tr>
					<th style=" text-align: left" data-toggle="tooltip" data-html="true" data-placement="bottom" title=""> 
					<br><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i> 주간보고 목록 (개인)
				</th>
				</tr>
			</thead>
			</table>
			<form method="post" name="search" action="/BBS/user/searchbbs.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="rms_dl">제출일</option>
								<option value="rms_title">제목</option>
						</select></td>
						<td><input type="text" class="form-control"
							placeholder="검색어 입력" name="searchText" maxlength="100"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success">검색</button></td>
					</tr>

				</table>
			</form>
		</div>
	</div>
	<br>
	
	
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
					</tr>
				</thead>
				<tbody>
					<%
						for(int i = 0; i < list.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							String dl = list.get(i).getRms_dl();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
					%>

						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= list.get(i).getRms_dl() %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/BBS/user/update.jsp?rms_dl=<%= list.get(i).getRms_dl() %>">
							<%= list.get(i).getRms_title() %></a></td>
						<td><%= name %></td>
						<td><%= list.get(i).getRms_time().substring(0, 11) + list.get(i).getRms_time().substring(11, 13) + "시"
							+ list.get(i).getRms_time().substring(14, 16) + "분" %></td>
						<td><%= pl %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td>
						<%
						String sign = null;
						if((dldate.after(today) || dldate.equals(today)) && list.get(i).getRms_sign().equals("승인")) { //현재 날짜가 마감일을 아직 넘지 않으면,
							//sign = list.get(i).getSign();
							sign="제출";
							//rms에 통합 저장 진행
							//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getPptxRms(list.get(i).getRms_dl(), id);
							if(rmsData == 0) { //작성된 기록이 없다!
								//2. rms 데이터 생성
									//데이터 불러오기 (this, next)
									//금주
									ArrayList<rmsrept> rms_this = rms.getRmsOne(list.get(i).getRms_dl(), id,"T");
									//차주
									ArrayList<rmsrept> rms_next = rms.getRmsOne(list.get(i).getRms_dl(), id,"N");
									//데이터 가공하기
									String bbsManager = workSet + name;
									String bbsContent = "";
									String bbsStart = "";
									String bbsTarget = "";
									String bbsEnd = "";
									String bbsNContent = "";
									String bbsNStart = "";
									String bbsNTarget = "";
									//금주 업무 (this)
									for(int j=0; j < rms_this.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int num = rms_this.get(j).getRms_con().split(System.lineSeparator()).length-1;
										if(j < rms_this.size()-1) {
											if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsContent += "["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con() + System.lineSeparator();
												}
											} else {
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += "- "+rms_this.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsContent += "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con() + System.lineSeparator();
												}
											}
											//bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
											 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
											 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
											 	bbsTarget += "[보류]" + System.lineSeparator();
											 } else {
												 if(rms_this.get(j).getRms_tar().length() > 5) {
												 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
												 }else {
													 bbsTarget += "[보류]" + System.lineSeparator();
												 }
											 }
											 bbsEnd += rms_this.get(j).getRms_end() + System.lineSeparator();
											
											 for(int k=0;k < num; k ++) {
												 bbsStart +=System.lineSeparator();
												 bbsTarget +=System.lineSeparator();
												 bbsEnd +=System.lineSeparator();
											 }
										} else {
											if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += rms_this.get(j).getRms_con();
												} else {
													bbsContent += "["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con();
												}
											} else {
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += "- "+rms_this.get(j).getRms_con();
												} else {
													bbsContent += "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con();
												}
											}
											//bbsContent += rms_this.get(j).getRms_con();
											 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/");
											 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
												 bbsTarget += "[보류]";
											 } else {
												 if(rms_this.get(j).getRms_tar().length() > 5) {
												 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/");
												 } else { 
													 bbsTarget += "[보류]";
												 }
											 }
											 bbsEnd += rms_this.get(j).getRms_end();
											 for(int k=0;k < num; k ++) {
												 bbsStart +=System.lineSeparator();
												 bbsTarget +=System.lineSeparator();
												 bbsEnd +=System.lineSeparator();
											 }
										}
									}
									//차주 (next)
									for(int j=0; j < rms_next.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int nnum = rms_next.get(j).getRms_con().split(System.lineSeparator()).length-1;
										if(j < rms_next.size()-1) {
											if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsNContent += "["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
												}
											} else { // - 가 없는 경우! 
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += "- "+rms_next.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
												}
											} 
											//bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
											 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
											 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
												 bbsNTarget += "[보류]" + System.lineSeparator();
											 } else {
												 if(rms_next.get(j).getRms_tar().length() > 5) {
												 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
												 } else {
													 bbsNTarget += "[보류]" + System.lineSeparator();
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += System.lineSeparator();
												 bbsNTarget += System.lineSeparator();
											 }
										} else {
											if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += rms_next.get(j).getRms_con();
												} else {
													bbsNContent += "["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con();
												}
											} else {
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += "- "+rms_next.get(j).getRms_con();
												} else {
													bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con();
												}
											} 
											//bbsNContent += rms_next.get(j).getRms_con();
											 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/");
											 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
												 bbsNTarget += "[보류]";
											 } else {
												 if(rms_next.get(j).getRms_tar().length() > 5){
												 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/");
												 }else {
													 bbsNTarget += "[보류]";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += System.lineSeparator();
												 bbsNTarget += System.lineSeparator();
											 }
										}
									}
							//3. 데이터 저장하기
							int rmsTSuc = rms.PptxRmsWrite(rms_this.get(0).getUser_id(), rms_this.get(0).getRms_dl(), rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
							int rmsNSuc = rms.PptxRmsWrite(rms_next.get(0).getUser_id(), rms_next.get(0).getRms_dl(), rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
							//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
							
								if(rmsTSuc == -1 || rmsNSuc == -1) {
									PrintWriter script = response.getWriter();
									script.println("<script>");
									script.println("alert('최종 저장에 문제가 발생하였습니다. 관리자에게 문의 바랍니다.')");
									script.println("location.href='../login.jsp'");
									script.println("</script>");
								}
							}
						} else if((dldate.after(today) || dldate.equals(today)) && list.get(i).getRms_sign().equals("미승인")) {
							//sign = list.get(i).getSign();
							sign="미제출";
						}else { // 미승인, 마감 상태일 경우엔 하단 진행.
							// 데이터베이스에 마감처리 진행
							int a = rms.updateSign(id, "마감",list.get(i).getRms_dl());
							if(a != -1) {
								sign="마감";
							} else {
								sign="error"; //DB 마감 수정이 정상적으로 이뤄지지 않음!
							}
							//rms에 통합 저장 진행
							//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getPptxRms(list.get(i).getRms_dl(), id);
							if(rmsData == 0) { //작성된 기록이 없다!
								//2. rms 데이터 생성
									//데이터 불러오기 (this, next)
									//금주
									ArrayList<rmsrept> rms_this = rms.getRmsOne(list.get(i).getRms_dl(), id,"T");
									//차주
									ArrayList<rmsrept> rms_next = rms.getRmsOne(list.get(i).getRms_dl(), id,"N");
									//데이터 가공하기
									String bbsManager = workSet + name;
									String bbsContent = "";
									String bbsStart = "";
									String bbsTarget = "";
									String bbsEnd = "";
									String bbsNContent = "";
									String bbsNStart = "";
									String bbsNTarget = "";
									//금주 업무 (this)
									for(int j=0; j < rms_this.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int num = rms_this.get(j).getRms_con().split(System.lineSeparator()).length-1;
										if(j < rms_this.size()-1) {
											if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsContent += "["+rms_this.get(j).getRms_job()+"]"+ rms_this.get(j).getRms_con() + System.lineSeparator();
												}
											} else {
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += "- "+rms_this.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsContent += "- ["+rms_this.get(j).getRms_job()+"]"+ rms_this.get(j).getRms_con() + System.lineSeparator();
												}
											} 
											//bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
											 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
											 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
											 	bbsTarget += "[보류]" + System.lineSeparator();
											 } else {
												 if(rms_this.get(j).getRms_tar().length() > 5) {
												 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
												 }else {
													 bbsTarget += "[보류]" + System.lineSeparator();
												 }
											 }
											 bbsEnd += rms_this.get(j).getRms_end() + System.lineSeparator();
											
											 for(int k=0;k < num; k ++) {
												 bbsStart +=System.lineSeparator();
												 bbsTarget +=System.lineSeparator();
												 bbsEnd +=System.lineSeparator();
											 }
										} else {
											if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += rms_this.get(j).getRms_con();
												} else {
													bbsContent += "["+rms_this.get(j).getRms_job()+"]"+ rms_this.get(j).getRms_con();
												}
											} else {
												if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
													bbsContent += "- "+rms_this.get(j).getRms_con();
												} else {
													bbsContent += "- ["+rms_this.get(j).getRms_job()+"]"+ rms_this.get(j).getRms_con();
												}
											}
											//bbsContent += rms_this.get(j).getRms_con();
											 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/");
											 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
												 bbsTarget += "[보류]";
											 } else {
												 if(rms_this.get(j).getRms_tar().length() > 5) {
												 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/");
												 } else { 
													 bbsTarget += "[보류]";
												 }
											 }
											 bbsEnd += rms_this.get(j).getRms_end();
											 for(int k=0;k < num; k ++) {
												 bbsStart +=System.lineSeparator();
												 bbsTarget +=System.lineSeparator();
												 bbsEnd +=System.lineSeparator();
											 }
										}
									}
									//차주 (next)
									for(int j=0; j < rms_next.size(); j++) {
										//content, ncotent의 줄바꿈 개수만큼 추가함
										int nnum = rms_next.get(j).getRms_con().split(System.lineSeparator()).length-1;
										if(j < rms_next.size()-1) {
											if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsNContent += "["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
												}
											} else { // - 가 없는 경우! 
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += "- "+rms_next.get(j).getRms_con() + System.lineSeparator();
												} else {
													bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
												}
											} 
											//bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
											 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
											 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
												 bbsNTarget += "[보류]" + System.lineSeparator();
											 } else {
												 if(rms_next.get(j).getRms_tar().length() > 5) {
												 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
												 } else {
													 bbsNTarget += "[보류]" + System.lineSeparator();
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += System.lineSeparator();
												 bbsNTarget += System.lineSeparator();
											 }
										} else {
											if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += rms_next.get(j).getRms_con();
												} else {
													bbsNContent += "["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con();
												}
											} else { // - 가 없는 경우! 
												if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
													bbsNContent += "- "+rms_next.get(j).getRms_con();
												} else {
													bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con();
												}
											}  
											//bbsNContent += rms_next.get(j).getRms_con();
											 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/");
											 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
												 bbsNTarget += "[보류]";
											 } else {
												 if(rms_next.get(j).getRms_tar().length() > 5){
												 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/");
												 }else {
													 bbsNTarget += "[보류]";
												 }
											 }
											 for (int h=0; h < nnum; h++) {
												 bbsNStart += System.lineSeparator();
												 bbsNTarget += System.lineSeparator();
											 }
										}
									}
							//3. 데이터 저장하기
							int rmsTSuc = rms.PptxRmsWrite(rms_this.get(0).getUser_id(), rms_this.get(0).getRms_dl(), rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
							int rmsNSuc = rms.PptxRmsWrite(rms_next.get(0).getUser_id(), rms_next.get(0).getRms_dl(), rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
							//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
							
								if(rmsTSuc == -1 || rmsNSuc == -1) {
									PrintWriter script = response.getWriter();
									script.println("<script>");
									script.println("alert('최종 저장에 문제가 발생하였습니다. 관리자에게 문의 바랍니다.')");
									script.println("location.href='../login.jsp'");
									script.println("</script>");
								}
							}
						}
						%>
						<%= sign %>
						</td>
					</tr>
					<%
						}
					%>
				</tbody>
			</table>
			
			<!-- 페이징 처리 영역 -->
			<!-- <div style="text-align:center"> -->
			<%
				if(pageNumber != 1){
			%>
				<%-- <a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left" style="display:inline-block">이전</a> --%>
					<a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(aflist.size() != 0){
			%>
				<%-- <a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next" style="display:inline-block">다음</a> --%>
					<a href="/BBS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			
			<!-- 글쓰기 버튼 생성 -->
			<a href="/BBS/user/bbsUpdate.jsp" class="btn btn-info pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="주간보고 작성">작성</a>
			<!-- </div> -->
		</div>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 끝 -->
	
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