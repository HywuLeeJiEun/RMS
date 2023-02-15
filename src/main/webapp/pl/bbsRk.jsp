<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
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
		
		
		//(월요일) 제출 날짜 확인
		String mon = "";
		String day ="";
		
		Calendar cal = Calendar.getInstance(); 
		Calendar cal2 = Calendar.getInstance(); //오늘 날짜 구하기
		SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd");
		
		cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
		//cal.add(Calendar.DATE, 7); //일주일 더하기
		
		 // 비교하기 cal.compareTo(cal2) => 월요일이 작을 경우 -1, 같은 날짜 0, 월요일이 더 큰 경우 1 
		 if(cal.compareTo(cal2) == -1) {
			 //월요일이 해당 날짜보다 작다.
			 cal.add(Calendar.DATE, 7);
			 
			 mon = dateFmt.format(cal.getTime());
			day = dateFmt.format(cal2.getTime());
		 } else { // 월요일이 해당 날짜보다 크거나, 같다 
			 mon = dateFmt.format(cal.getTime());
			day = dateFmt.format(cal2.getTime());
		 }
		 
		 String rms_dl = mon;
		 //만약 넘어온 rms_dl이 있다면,
		 if(request.getParameter("rms_dl") != null && !request.getParameter("rms_dl").isEmpty()) {
			 rms_dl = request.getParameter("rms_dl");
		 }

		 
		//pl 리스트 확인
		ArrayList<String> plist = userDAO.getpluser(pl); //pl 관련 유저의 아이디만 출력
		//pl에 해당하는 user_id 도출(pllist)
		String[] pllist = plist.toArray(new String[plist.size()]); //해당 pllist를 바꿔야함! (제출한 사람만)
		//해당 user_id를 통해 제출된 rms를 조회하기
		ArrayList<rmsrept> flist = rms.getRmsRkfull(rms_dl, pllist);

		// 미제출자 인원 계산 ()
		int psize = plist.size(); //pl 담당 유저의 아이디
		int lsize = flist.size(); //해당 pl을 담당하는 user들의 제출 rms
		int noSub =  psize - lsize;
		
		//기존 데이터 불러오기 (pageNumber를 통해 데이터를 10개까지 조회)
		ArrayList<rmsrept> rmslist = rms.getRmsRk(rms_dl, pllist, pageNumber, psize);
		
		//다음 데이터가 있는지 조회
		ArrayList<rmsrept> afrmslist = rms.getRmsRk(rms_dl, pllist, pageNumber+1, psize);
		
		if(!au.equals("PL")) { //PL 권한이 없다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		if(rmslist.size() == 0) {
			//PrintWriter script = response.getWriter();
			//script.println("<script>");
			//script.println("alert('제출된 주간보고가 없습니다.')");
			//script.println("history.back();");
			//script.println("</script>");
		}
		
		//해당 인원 전원 불러오기 (이름으로 변경)
		ArrayList<String> username = new ArrayList<String>();
		for(int i=0; i<plist.size(); i++) {
			String userName = userDAO.getName(plist.get(i)); //user 이름을 도출.
			username.add(userName);	
		}
		String[] usernamedata = username.toArray(new String[username.size()]);
		Arrays.sort(usernamedata);
		
		String userdata = String.join(", ", usernamedata);
		
		
		//미제출자 인원
		ArrayList<String> noSubname = new ArrayList<String>();
		ArrayList<String> Subname = new ArrayList<String>();

		//제출한 RMS 도출
		for(int i=0; i<flist.size(); i++) {
			Subname.add(flist.get(i).getUser_id()); //제출한 user id 도출. (일반 list(10개 제한이 걸림)가 아닌, 모든 제출자를 확인해야함!)
			//bbsId.add(Integer.toString(flist.get(i).getBbsID()));
		}
		for(int i=0; i<Subname.size(); i++) {
			plist.remove(Subname.get(i));
		}
		//제출 안한 인원 찾기
		for(int i=0; i<plist.size(); i++) {
			String userName = userDAO.getName(plist.get(i)); //user 이름을 도출.
			noSubname.add(userName);	
		}
		
		String[] nousernamedata = noSubname.toArray(new String[noSubname.size()]);
		Arrays.sort(nousernamedata);
		
		String nouserdata = String.join(", ", nousernamedata);
		
		//목록의 모든 rms_dl 불러오기
		 ArrayList<rmsrept> dllist = rms.getAllRms_dl();
		 //중복값을 제거하기 위해, rms_dl 빼기
		 for(int i=0; i < dllist.size(); i++) {
			 if(dllist.get(i).getRms_dl().equals(rms_dl)) {
				 dllist.remove(i);
			 }
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
								<li class="active"><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
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
					if(au.equals("PL")||au.equals("관리자")) {
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

		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-placement="bottom" title="클릭시, 상세 정보가 노출됩니다."> <%= pl %> 업무 담당자 목록 
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
			</thead>
		</table>
	</div>
	
	<!-- ***********검색바 추가 ************* -->
	<div class="container">
		<div class="row">
			<table class="pull-left" style="text-align: center; cellpadding:50px; width:60%" >
			<thead>
				<tr>
					<th style=" text-align: left" data-toggle="tooltip" data-html="true" data-placement="bottom" title=""> 
						<br><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i> 주간보고 목록 [<%= pl %>]
					</th>
				</tr>
			</thead>
			</table>
			<form method="post" name="search">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="if(this.value) location.href=(this.value);">
								<option value="rms_dl" selected="selected"><%= rms_dl %></option>
						<% for(int i=0; i < dllist.size(); i++) { %>
								<option value="/BBS/pl/bbsRk.jsp?rms_dl=<%= dllist.get(i).getRms_dl() %>"><%= dllist.get(i).getRms_dl() %></option>
						<% } %>
						</select></td>
						<!-- <td><button type="submit" style="margin:5px" class="btn btn-success">검색</button></td> -->
					</tr>
				</table>
			</form>
		</div>
	</div>
	
	<div class="container" id="jb-text" style="height:10%; width:20%; display:inline-flex; float:left; margin-left: 41%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="plist">업무 담당자 인원 : <span style="color:blue; text-decoration:underline"><%= psize %></span></td>
			 </tr> 
			 <tr>
			 	<% if(noSub != 0)  {%>
			 	<td id="noSublist">미제출자 인원 : <span style="color:blue; text-decoration:underline"><%= noSub %></span></td>
			 	<% } %>
			 </tr> 
			 <%-- <tr>
			 	<td>업무 담당자 인원 : <%= plist.size() %></td>
			 </tr> --%> 
		 </table>
	 </div>
	 
	 <div class="container" id="plist_list" style="height:10%; width:20%; display:flex; margin-left: 62%; position:absolute; display:none; ">
		<table  class="table" style="text-align: center; border:1px solid #444444; background-color:white; " >
			 <tr>
			 	<td style="background-color:#444444; color:#ffffff"> <%= userdata %></td>
			 </tr> 
		 </table>
	 </div>
	 
	 <div class="container" id="noSublist_list" style="height:10%; width:20%; display:flex; margin-left: 62%; margin-top:2.5%; position:absolute; display:none; ">
		<table  class="table" style="text-align: center; border:1px solid #444444; background-color:white; " >
			 <tr>
			 	<td style="background-color:#444444; color:#ffffff"> <%= nouserdata %> </td>
			 </tr> 
		 </table>
	 </div>
	<br>
	
	
	<%
	if(rmslist.isEmpty()) {
		/* PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('모든 보고가 승인(또는 마감)처리 되었습니다.')");
		script.println("location.href='bbs.jsp'");
		script.println("history.back()");
		script.println("</script>"); */
	%>
	<div class="container">
		<table class="table" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr valign="top" style="height:150px">
				</tr>
				<tr valign="bottom" style="height:150px">
					<th colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-placement="bottom" title="<%= rms_dl %>" >해당일로 제출된 주간보고가 없습니다. <br><br><br><br></th>
				</tr>

			</thead>
		</table>
		<!-- <button style="margin:5px" class="btn btn-primary pull-right" onclick="location.href='/BBS/user/bbs.jsp'">목록</button> -->
	</div>
	
	<% 
	} else {
	%>
	
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
						
						
						for(int i = 0; i < rmslist.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							
							String dl = rmslist.get(i).getRms_dl();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
							
							String name_list = userDAO.getName(rmslist.get(i).getUser_id());
					%>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= rmslist.get(i).getRms_dl() %> </td>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/BBS/pl/signOnReportRk.jsp?rms_dl=<%= rmslist.get(i).getRms_dl() %>&user_id=<%= rmslist.get(i).getUser_id() %>&pageNumber=<%= pageNumber %>">
							<%= rmslist.get(i).getRms_title() %></a></td>
						<td><%= name_list %></td>
						<td><%= rmslist.get(i).getRms_time().substring(0, 11) + rmslist.get(i).getRms_time().substring(11, 13) + "시"
							+ rmslist.get(i).getRms_time().substring(14, 16) + "분" %></td>
						<td><%= pl %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td>
						<%= rmslist.get(i).getRms_sign() %>
						</td>
					</tr>
					<%
						}
					%>
				</tbody>
			</table>
			<% if(pl.equals("ERP")) {%>
			<a href="/BBS/pl/pptx/ppt.jsp?rms_dl=<%=rmslist.get(0).getRms_dl()%>&pluser=<%= pl %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력(ERP)" id="pptx" type="button"> 출력</a>
			<% }  %>
			<% if(pl.equals("WEB")) {%>
			<a href="/BBS/pl/pptx/ppt.jsp?rms_dl=<%=rmslist.get(0).getRms_dl()%>&pluser=<%= pl %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력(WEB)" id="pptx" type="button"> 출력</a>
			<% }  %>
			<% 	
			// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
			SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
			
			String dl = mon;
			Date time = new Date();
			String timenow = dateFormat.format(time);

			Date dldate = dateFormat.parse(dl);
			Date today = dateFormat.parse(timenow);
			
			%>
			<a href="/BBS/pl/bbsRkwrite.jsp?rms_dl=<%=rms_dl%>" style="width:50px; margin-right:20px" class="btn btn-info pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="요약본(Summary) 작성" id="summary"> 작성</a>
		</div>
	</div>
	
	<%
	}
	%>
	
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
	
	<script>
	$("#jb-title").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#jb-title");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});

	
	$("#plist").on('mouseover', function() {
		var con = document.getElementById("plist_list");
			con.style.display = 'block';
	});
	$("#plist").on('mouseout', function() {
		var con = document.getElementById("plist_list");
			con.style.display = 'none';	
	});
	
	
	$("#noSublist").on('mouseover', function() {
		var con = document.getElementById("noSublist_list");
			con.style.display = 'block';
	});
	$("#noSublist").on('mouseout', function() {
		var con = document.getElementById("noSublist_list");
			con.style.display = 'none';
	});
	</script>
	
	
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
	var data = "<%= nouserdata %>";
	//$("#pptx").find('[type="button"]').trigger('click') {
	$("#pptx").on('mousedown', function() {
		//noSub -> 미제출자
		if(<%= noSub %> != 0) { //즉, 미제출자가 있다면!
			var go;
			go = confirm("미제출자가 있습니다.\n"+"["+data+"]"+"\n\n출력 하시겠습니까?");
			
			if(go) { //출력 o
				document.getElementById("pptx").click();
			} else { //출력 x
				
			}
		
		}
	});
	
	
	$("#summary").on('mousedown', function() {
		//noSub -> 미제출자
		if(<%= noSub %> != 0) { //즉, 미제출자가 있다면!
			var go;
			go = confirm("미제출자가 있습니다.\n"+"["+data+"]"+"\n\n요약본을 작성 하시겠습니까?");
			
			if(go) { //출력 o
				document.getElementById("summary").click();
			} else { //출력 x
				
			}
		
		}
	});
	
	<%-- $("#summary_nav").on('mousedown', function() {
		//noSub -> 미제출자
		if(<%= noSub %> != 0) { //즉, 미제출자가 있다면!
			var go;
			go = confirm("미제출자가 있습니다.\n"+"["+data+"]"+"\n\n요약본을 작성 하시겠습니까?");
			
			if(go) { //출력 o
				document.getElementById("summary").click();
			} else { //출력 x
				
			}
		
		}
	}); --%>
	</script>
</body>
</html>