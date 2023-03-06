<%@page import="java.io.File"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="../../css/index.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->

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
		script.println("location.href='../../login.jsp'");
		script.println("</script>");
	}
	
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
	
	String str = "주간보고 작성을 위한<br>";
	str += "데이터를 수집합니다.";
	
	String pptx_str = "PPTX File(ERP,WEB,SUM),<br>";
	pptx_str += "Calendar, EXcel 저장시,<br>";
	pptx_str += "주간보고 AMS 출력";
	pptx_str += "<br>(총 5개의 파일)";

	
	//목록의 모든 rms_dl 불러오기
	 ArrayList<rmsrept> dllist = rms.getAllRms_dl();
	 //중복값을 제거하기 위해, rms_dl 빼기
	 for(int i=0; i < dllist.size(); i++) {
		 if(dllist.get(i).getRms_dl().equals(rms_dl)) {
			 dllist.remove(i);
		 }
	 }
	 
	 
	//파일이 있는지 확인, (Calendar)
	String[] dl = rms_dl.split("-");
	
	int cfexists = -1;
	String cfilename = "없음";
	String cfilePath = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\calendar"+dl[1]+".pptx";
	File f = new File(cfilePath);
	if(f.exists()) {
		if(!f.isDirectory()) {
			cfexists = 1;
			cfilename = f.getName();
		}
	}
	
	
	//파일이 있는지 확인, (Excel)
	int efexists = -1;
	String efilename = "없음";
	String efilePath = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[0]+dl[1]+".xlsx";
	f = new File(efilePath);
	if(f.exists()) {
		if(!f.isDirectory()) {
			efexists = 1;
			efilename = f.getName();
		}
	}
	
	
	//세부 위치에 파일이 있는지 확인 (파일 목록 보여주기)
	int erp = -1;
	int web = -1;
	int summary = -1;
	
	String dir = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2];
	File chkf = new File(dir);
	String[] filelist = chkf.list();
	if(chkf.exists()) {
		// 파일 리스트 가져오기		
		 for(int i=0; i < filelist.length; i++) {
			String chkfile = filelist[i];
			if(chkfile.contains("erp")) {
				erp = 1;
			} 
			if(chkfile.contains("web")) {
				web = 1;
						}
			if(chkfile.contains("summary")) {
				summary = 1;
			}
			
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
			<a class="navbar-brand" href="/RMS/user/bbs.jsp">Report Management System</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav navbar-left">
					<li class="dropdown ">
						<a href="#" class="dropdown-toggle"
							data-toggle="dropdown" role="button" aria-haspopup="true"
							aria-expanded="false">주간보고<span class="caret"></span></a>
						<!-- 드랍다운 아이템 영역 -->	
						<% if(au.equals("관리자")) { %>
						<ul class="dropdown-menu">
							<li class="active"><a href="/RMS/user/bbs.jsp">조회</a></li>
						</ul>
						<% }else { %>
							<ul class="dropdown-menu">
								<li><a href="/RMS/user/bbs.jsp">조회</a></li>
								<li><a href="/RMS/user/bbsUpdate.jsp">작성</a></li>
								<li><a href="/RMS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
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
								<li class="active"><a href="/RMS/admin/ams/attachment.jsp">첨부 및 출력</a></li>
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
					if(au.equals("관리자") || au.equals("PL")) {
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
		<jsp:include page="../../modal.html" flush="false" />
	</div>

	
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= str %>">AMS 주간보고 작성
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
						<br><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i> RMS 제출일
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
								<option value="/RMS/admin/ams/attachment.jsp?rms_dl=<%= dllist.get(i).getRms_dl() %>"><%= dllist.get(i).getRms_dl() %></option>
						<% } %>
						</select></td>
						<td><button type="button" style="margin:10px;" class="btn btn-success" onclick="amspptx()" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= pptx_str %>">출력</button></td>
					</tr>
				</table>
			</form>
		</div>
	</div>
	<br>
	
	<!-- 게시판 메인 페이지 영역 시작 (Calendar) -->
	<div class="container">
		<div class="row">	
			<div class="col-6 col-md-6">
			<hr>
		 	<form action="Calendar_upload.jsp?rms_dl=<%= rms_dl %>" method="post" enctype="multipart/form-data">
			 	<fieldset>
					<legend>Calendar</legend>
					<p><label for="formFileSm" class="form-label">파일 선택(ppt, pptx)</label> 
					<input class="form-control form-control-sm" type="file" name="file" accept=".pptx, .ppt" required></p>
					<p><input class="btn btn-primary pull-left" type="submit" value="upload"></p>	 	
			 	</fieldset>
			 </form>
			</div>
			
			<div class="col-6 col-md-6 flex-container.flex-start">
			<hr>
			<fieldset>
				<legend>File</legend>
				<table style="text-align:center; border: 1px solid #dddddd" class="table table-striped">
					<tr>
						<th style="text-align:center;">파일명</th>
						<th></th>
					</tr>
					<tr>
						<td align="center" width="200"><%= cfilename %></td>
					<% if(cfexists != -1) {%>
						<td align="center" width="200"><a href="Calendar_download.jsp?fileName=<%= cfilename %>&rms_dl=<%= rms_dl %>">다운로드</a></td>
					<% } else { %>
						<td align="center" width="200"><a href="#"></a> - </td>
					<% } %>
					</tr>	
				</table>
			</fieldset>
			</div>
		
		</div>
		</div>
		
		
		<!-- 게시판 메인 페이지 영역 시작 (Excel) -->
	<div class="container">
		<div class="row">	
			<div class="col-6 col-md-6">
			<hr>
		 	<form action="Excel_upload.jsp?rms_dl=<%= rms_dl %>" method="post" enctype="multipart/form-data">
			 	<fieldset>
					<legend>Excel</legend>
					<p><label for="formFileSm" class="form-label">파일 선택(xlsx)</label> 
					<input class="form-control form-control-sm" type="file" name="file" accept=".xlsx" required></p>
					<p><input class="btn btn-primary pull-left" type="submit" value="upload"></p>	 	
			 	</fieldset>
			 </form>
			</div>
			
			<div class="col-6 col-md-6">
			<hr>
			<fieldset>
				<legend>File</legend>
				<table style="text-align:center; border: 1px solid #dddddd" class="table table-striped">
					<tr>
						<th style="text-align:center;">파일명</th>
						<th></th>
					</tr>
					<tr>
						<td align="center" width="200"><%= efilename %></td>
					<% if(efexists != -1) {%>
						<td align="center" width="200"><a href="Excel_download.jsp?fileName=<%= efilename %>&rms_dl=<%= rms_dl %>">다운로드</a></td>
					<% } else { %>
						<td align="center" width="200"><a href="#"></a> - </td>
					<% } %>
					</tr>	
				</table>
			</fieldset>
			</div>
		
		</div>
		</div>
		
		
		<!-- 게시판 메인 페이지 영역 시작 (전체 파일 목록) -->
	<div class="container">
		<div class="row">	
			<div>
			<hr>
			<fieldset>
				<legend>PPTX File</legend>
				<table style="text-align:center; border: 1px solid #dddddd" class="table table-striped">
					<tr>
						<th style="text-align:center;">파일명</th>
						<th></th>
					</tr>
					<% if(filelist != null && filelist.length > 0) {
							for(int i=0; i < filelist.length; i++) {
								if(!filelist[i].contains("title")) {
					%>
					<tr>
						<td align="center" width="200"><%= filelist[i] %></td>
						<td align="center" width="200"><a href="Excel_download.jsp?fileName=<%= filelist[i] %>&rms_dl=<%= rms_dl %>">다운로드</a></td>
					<% } } } else { //pptx가 없는 경우, 
					%>
						<% if(erp == -1) {%>
						<% } %>
						<td align="center" width="200"><a href="#"></a> - </td>
						<td> - </td>
					<% } %>
					</tr>	
				</table>
			</fieldset>
			</div>
		</div>
		</div>
		
		<br><br><br><br><br><br>
		

<!-- 부트스트랩 참조 영역 -->
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="../../css/js/bootstrap.js"></script>
<script src="../../modalFunction.js"></script>

<script>
var rms_dl ='<%= rms_dl %>';
var erp = <%= erp %>;
var web = <%= web %>;
var summary = <%= summary %>;
	function amspptx() {
		var fn = '<%= cfilename %>';
		var efn = '<%= efilename %>';
		if(fn == "없음") {
			alert("지정된 캘린더가 없습니다. \n파일을 추가해주시기 바랍니다.");
		} else if(efn == "없음"){
			alert("지정된 엑셀이 없습니다. \n파일을 추가해주시기 바랍니다.");
		} else if (erp == -1){
			alert("지정된 ERP 파일이 없습니다. \nERP > 조회 밎 출력에서 출력해주시기 바랍니다.");
		}else if (web == -1){
			alert("지정된 WEB 파일이 없습니다. \nWEB > 조회 밎 출력에서 출력해주시기 바랍니다.");
		}else if (summary == -1){
			alert("지정된 Summary 파일이 없습니다. \nSummary > 조회 밎 출력에서 출력해주시기 바랍니다.");
		}else {
			//출력하는 page로 이동.
			location.href="/RMS/admin/ams/pptAction/AllAction.jsp?rms_dl="+rms_dl;
		}
	}
</script>

</body>
</html>