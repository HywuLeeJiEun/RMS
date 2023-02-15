<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="javax.swing.RepaintManager"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.Objects"%>
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
		RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)
		
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
		 
		 String rms_dl = "";
		 int rms_md = 0;
		 
		if(request.getParameter("rms_dl") != null) {
			rms_dl = request.getParameter("rms_dl");
		}
		if(request.getParameter("rms_md") != null) {
			rms_md = Integer.parseInt(request.getParameter("rms_md"));
		}
		
		if(rms_md == -1) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('제출일이 선택되지 않았습니다.')");
			script.println("location.href='/BBS/pl/bbsRkwrite.jsp'");
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
		
		//만약 이미 해당 날짜로 요약본이 작성되어 있다면, 뒤로 돌려보냄!
		ArrayList<rmssumm> list = sumDAO.getSumDL(rms_dl);
		if(list.size() != 0){ //데이터가 있다면,
			for(int i=0; i < list.size(); i++) {
				if(list.get(0).getUser_fd().equals(pl)) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('해당 날짜로 제출된 요약본이 있습니다.')");
				script.println("location.href='/BBS/pl/bbsRk.jsp'");
				script.println("</script>");
				}
			}
		} 
		
		//만약 제출자가 전체 인원보다 적을 경우, 경고창을 띄움!
		//pl 리스트 확인
		ArrayList<String> plist = userDAO.getpluser(pl); //pl 관련 유저의 아이디만 출력
		//pl에 해당하는 user_id 도출(pllist)
		String[] pllist = plist.toArray(new String[plist.size()]); //해당 pllist를 바꿔야함! (제출한 사람만)
		//해당 user_id를 통해 제출된 rms를 조회하기
		ArrayList<rmsrept> flist = rms.getRmsRkfull(rms_dl, pllist);
		
		//금주업무, 차주업무 나누기
		//금주
		ArrayList<rmsrept> tlist = rms.getRmsRkAll(rms_dl, pllist, "T");
		//차주
		ArrayList<rmsrept> nlist = rms.getRmsRkAll(rms_dl, pllist, "N");
 	
		//제출자 SubUser
		String SubUser = "";
		for(int i=0; i<flist.size(); i++) {
			if(i < flist.size()-1) {
				SubUser += userDAO.getName(flist.get(i).getUser_id())+", ";
			} else {
				SubUser += userDAO.getName(flist.get(i).getUser_id());
			}
		}
		
		// 미제출자 인원 계산 ()
		int psize = plist.size(); //pl 담당 유저의 아이디
		int lsize = flist.size(); //해당 pl을 담당하는 user들의 제출 rms
		int noSub =  psize - lsize;
		
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
		 //중복값을 제거하기 위해, rms_dl 빼기, 해당 데이터가 rmssumm에 저장되어 있는지 확인
		 for(int i=0; i < dllist.size(); i++) {
			 /* if(dllist.get(i).getRms_dl().equals(rms_dl)) {
				 dllist.remove(i);
			 } */
			 String useDl = sumDAO.getDluse(dllist.get(i).getRms_dl(), pl);
			 if(useDl != null && !useDl.isEmpty()) { //이미 요약본이 작성되어 있음!
				 dllist.remove(i);
			 } 
		 }
		
	%>
	<textarea id="rms_dl" style="display:none"><%= rms_dl %></textarea>


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
								<li><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
								<li class="active" id="summary_nav"><a href="bbsRkwrite.jsp">작성</a></li>
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
	
	
	<!-- 모달 영역! (날짜 선택 모달) -->
	<button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#RmsdlModal" id="rmsData" style="display:none"> get rms_dl </button>
	<div class="modal fade" id="RmsdlModal" role="dialog">
		   <div class="modal-dialog">
		    <div class="modal-content">
		     <div class="modal-header">
		      <!-- <button type="button" class="close" data-dismiss="modal">×</button> -->
		      <!-- <h3 class="modal-title" align="center">제출일 선택</h3> -->
		     </div>
		     <!-- 모달에 포함될 내용 -->
		     <form method="post" action="/BBS/pl/bbsRkwrite.jsp" id="modalform">
		     <div class="modal-body">
		     		<div class="row">
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label" data-toggle="tooltip" data-placement="top" title="요약본이 제출되지 않은 목록">제출일 선택</label>
		     				<i class="glyphicon glyphicon-info-sign"  style="left:5px;"></i>
		     				<select class="form-control" name="searchField" id="searchField" onchange="if(this.value) location.href=(this.value);">
								<option value="rms_dl" selected="selected">[선택]</option>
							<% for(int i=0; i < dllist.size(); i++) { %>
									<option value="/BBS/pl/bbsRkwrite.jsp?rms_dl=<%= dllist.get(i).getRms_dl() %>"><%= dllist.get(i).getRms_dl() %></option>
							<% } %>
							</select>
							<br>
		     				<h5 class="col-form-label">제출일을 선택하여 요약본을 작성합니다.</h5>
		     				<input type="password" maxlength="20" required class="form-control" style="width:100%; display:none" id="rms_md" name="rms_md" value="-1">
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
		     			<div class="modal-footer">
					     <div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6">
					     	<button type="button" class="btn btn-primary pull-right form-control" style="width:30%" onClick="location.href='/BBS/pl/bbsRk.jsp'" >취소</button>
				     	</div>
				     	 <div class="col-md-3" style="visibility:hidden">
			   			</div>	
		    </div>
   			</div>
		    </form>
		   </div>
	  </div>
	</div>

	
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
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-html="true" data-placement="bottom" title="제출자: <%= SubUser %> <br> 제출 인원: <%= flist.size() %> "> <%= pl  %> 요약본 작성
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
	<%	
	if(noSub != 0) {
	%>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:blue; font-size:13px " data-toggle="tooltip" data-html="true" data-placement="bottom" title="미제출자: <%= nouserdata %> <br> 미제출 인원: <%= noSub %> "> 미제출자 확인
					<i class="glyphicon glyphicon-info-sign" id="icon"  style="left:5px;"></i></th>
				</tr>
	<%
	}
	%>
			</thead>
		</table>
	</div>
	<br>
	

	
	<!-- 목록 조회 table -->
	<div class="container">
	<form method="post" action="/BBS/pl/bbsRkwriteFinal.jsp" id="Rkwrite">
		<div class="row">
			<div class="col-6 col-md-6">
				<table id="Table" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="3"style="background-color:#D4D2FF; align:left; font-size:15px"> &nbsp;금주 업무 실적 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; border: 1px solid; border-top: 1px solid #ffffff">
							<th width="55%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">업무 내용</th>
							<th width="15%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">완료일</th>
							<th width="25%" style="border: 1px solid #ffffff; font-size:13px" class="text-center"><input type="checkbox" style="zoom:2.0;" name="chk" id="chk" value="selectall" onclick="selectAll(this)"></th>
						</tr>
						
						<%
						//금주 업무 내용을 나열!
						for(int i=0; i< tlist.size(); i++) { //content
							//content의 "-" 제거하기
							String bbsContent = "";
							if(tlist.get(i).getRms_con().indexOf('-') > -1 && tlist.get(i).getRms_con().indexOf('-') < 2) { //맨 앞이 - 라면,
								bbsContent = tlist.get(i).getRms_con().replaceFirst("-", "");
							} else { //bbsContent의 앞에 '-'이 없거나, 또는 빈칸일때 -> 이 경우는 저장부터 문제가 발생하는 경우!
								bbsContent = tlist.get(i).getRms_con();
							}
							//bbsContent 줄바꿈 제거
							bbsContent = bbsContent.replaceAll(System.lineSeparator(), ""); //줄바꿈 모두 제거
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="content<%=i%>" id="content<%=i%>" readonly rows="2" style="resize: none; height:30px; width:300px;"><%= bbsContent %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="end<%=i%>" id="end<%=i%>" rows="1" readonly style="resize: none; height:30px; width:60px; text-align: center;"><%= tlist.get(i).getRms_end() %></textarea>
								<textarea name="rms_dl" id="rms_dl" rows="1" style="resize: none; height:30px; width:60px; text-align: center; display:none"><%= rms_dl %></textarea>
							</td>
							<td>
								<input type="checkbox" name="chk" id="chk<%=i%>" style="zoom:2.0;" value="<%= i %>" onclick='checkSelectAll(this)'>
							</td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>
			
			<!-- 차주 업무 계획 -->
			<div class="col-6 col-md-6">
				<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
					<thead>
						<tr>
							<th colspan="3"style="background-color:#ff9900; align:left"> &nbsp;차주 업무 계획 </th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; border: 1px solid; border-top: 1px solid #ffffff">
							<th width="60%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">업무 내용</th>
							<th width="20%" style="border: 1px solid #ffffff; font-size:13px; vertical-align:middle">완료예정</th>
							<th width="20%" style="border: 1px solid #ffffff; font-size:13px" class="text-center"><input type="checkbox" id="nchk" name="nchk" style="zoom:2.0;" value="selectall" onclick="nselectAll(this)"></th>
						</tr>
						<%
						//차주 업무 목록
						for(int i=0; i< nlist.size(); i++) { 
							
							//content의 "-" 제거하기
							String bbsNContent = "";
							if(nlist.get(i).getRms_con().indexOf('-') > -1 && nlist.get(i).getRms_con().indexOf('-') < 2) { //맨 앞이 - 라면,
								bbsNContent = nlist.get(i).getRms_con().replaceFirst("-", "");
							} else { //bbsContent의 앞에 '-'이 없거나, 또는 빈칸일때 -> 이 경우는 저장부터 문제가 발생하는 경우!
								bbsNContent = nlist.get(i).getRms_con();
							}
							//bbsContent 줄바꿈 제거
							bbsNContent = bbsNContent.replaceAll(System.lineSeparator(), ""); //줄바꿈 모두 제거
							
							//bbsNTarget이 가공되지 않음!
							//해당 데이터 가공하여 출력하기!
							String bbsNTarget = "";
							if(nlist.get(i).getRms_tar().isEmpty()) { //보류 표시
								bbsNTarget = "[보류]";
							} else { //데이터가 들어가 있는 경우 (ex> 2023-01-16) ...
								bbsNTarget = nlist.get(i).getRms_tar().substring(5);
								bbsNTarget = bbsNTarget.replace("-", "/");
							}
						%>
						<tr>
							<td style="text-align: left; font-size:13px">
								<textarea name="ncontent<%=i%>" id="ncontent<%=i%>" readonly rows="2" style="resize: none; height:30px; width:300px;"><%= bbsNContent %></textarea>
							</td>
							<td style="text-align: left; font-size:13px">
								<textarea name="ntarget<%=i%>" id="ntarget<%=i%>" readonly rows="1" style="resize: none; height:30px; width:60px; text-align: center;"><%= bbsNTarget %></textarea>
							</td>
							<td>
								<input type="checkbox" name="nchk" id="nchk<%=i%>" style="zoom:2.0;" value="<%= i %>" onclick='ncheckSelectAll(this)'>
							</td>
						</tr>
						<%
						}
						%> 
	
					</tbody>
				</table>
			</div>
			</div>
		</form>
		<a type="button" style="width:50px" class="btn btn-primary pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="선택된 내용으로 요약본 생성" id="save" >선택</a>
	</div>
	<br><br><br> 
	
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	
	<script>
	// rms modal 띄우기
	$(document).ready(function() {
		var rms_dl = document.getElementById("rms_dl").value;
		if(rms_dl == null || rms_dl === "") {
			$("#rmsData").hide();
			$("#rmsData").trigger('click');
		}
		
		$('#RmsdlModal').on('hidden.bs.modal', function (){
			var rms_md = document.getElementById("rms_md").value;
			location.href="/BBS/pl/bbsRkwrite.jsp?rms_md="+rms_md;
		})
	});
	</script>
	
	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('propertychange input keyup keydown focusin focusout blur mousemove', function() {
			//var offset = this.offsetHeight - this.clientHeight;
			//var resizeTextarea = function(el) {
				//$(el).css('height','auto').css('height',el.scrollHeight + offset);
				$(this).height(2).height($(this).prop('scrollHeight'));
			//};
			//$(this).on('propertychange keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
			
		});
	</script>	
	
	<script>
	//금주
	function checkSelectAll(checkbox) {
		const selectall
		= document.getElementById("chk");
		
		if(checkbox.checked === false) {
			selectall.checked = false;
		} 
	}
	//클릭시, 체크박스 전체 선택
	function selectAll(selectAll){
		var checkboxes = document.getElementsByName('chk');
		
		checkboxes.forEach((checkbox) => {
			checkbox.checked = selectAll.checked;
		})	
	}
	
	
	//차주
	function ncheckSelectAll(checkbox) {
		const selectall
		= document.getElementById("nchk");
		
		if(checkbox.checked === false) {
			selectall.checked = false;
		} 
	}
	//클릭시, 체크박스 전체 선택
	function nselectAll(selectAll){
		var checkboxes = document.getElementsByName('nchk');
		
		checkboxes.forEach((checkbox) => {
			checkbox.checked = selectAll.checked;
		})
	}
	</script>
	
	<script>
	// 데이터 송신
	//해당 배열에 저장(몇번인지!)
	var chk_arr = [];
	var nchk_arr = [];
	
	var content ="";
	var end ="";
	var ncontent ="";
	var ntarget ="";
	
	$(document).ready(function() {
		var noSub = <%= noSub %>;
		$('#save').click(function () {
			//alert($("input[type=checkbox][name=chk]:checked").val());	
			$("input[type=checkbox][name=chk]:checked").each(function(){
				var chk = $(this).val();
			chk_arr.push(chk);
			})
			
			$("input[type=checkbox][name=nchk]:checked").each(function(){
				var nchk = $(this).val();
			nchk_arr.push(nchk);
			})
			
			//alert(chk_arr);
			//alert(nchk_arr);
			
			if(chk_arr == null || chk_arr =="") {
				alert('금주 업무 실적 중, 내용이 선택되지 않았습니다. \n1개 이상을 선택하여 주십시오.');
				chk_arr = [];
				nchk_arr = [];
			}else if(nchk_arr == null || nchk_arr =="") {
				alert('차주 업무 계획 중, 내용이 선택되지 않았습니다. \n1개 이상을 선택하여 주십시오.');
				chk_arr = [];
				nchk_arr = [];
			} else {
				if(noSub != 0) {
					var con = confirm('미제출 인원이 있습니다. 요약본을 작성하시겠습니까?')
					if(con) {	
						// 데이터 넘기기 
						var innerHtml = "";
						//innerHtml += '<td><textarea class="textarea" id="chk_arr" name="chk_arr" readonly>'+ chk_arr +'</textarea></td>';
						//innerHtml += '<td><textarea class="textarea" id="nchk_arr" name="nchk_arr" readonly>'+ nchk_arr +'</textarea></td>';
						/* innerHtml += '<td><textarea class="textarea" id="content" name="content" readonly style="display:none">'+ content +'</textarea></td>';
						innerHtml += '<td><textarea class="textarea" id="end" name="end" readonly style="display:none">'+ end +'</textarea></td>';
						innerHtml += '<td><textarea class="textarea" id="ncontent" name="ncontent" readonly style="display:none">'+ ncontent +'</textarea></td>';
						innerHtml += '<td><textarea class="textarea" id="ntarget" name="ntarget" readonly style="display:none">'+ ntarget +'</textarea></td>'; */
						innerHtml += '<td><textarea class="textarea" id="chk_arr" name="chk_arr" readonly style="display:none">'+ chk_arr +'</textarea></td>';
						innerHtml += '<td><textarea class="textarea" id="nchk_arr" name="nchk_arr" readonly style="display:none">'+ nchk_arr +'</textarea></td>';
						$('#Table > tbody > tr:last').append(innerHtml);
						$('#Rkwrite').submit(); 
					} else {
						chk_arr = [];
						nchk_arr = [];
					}
				}else {		
				//데이터를 다른 페이지로 보냄!
				// 데이터 넘기기 
				var innerHtml = "";
				innerHtml += '<td><textarea class="textarea" id="chk_arr" name="chk_arr" readonly style="display:none">'+ chk_arr +'</textarea></td>';
				innerHtml += '<td><textarea class="textarea" id="nchk_arr" name="nchk_arr" readonly style="display:none">'+ nchk_arr +'</textarea></td>';
				$('#Table > tbody > tr:last').append(innerHtml);
				$('#Rkwrite').submit(); 
				}
			}
		})
	});
	
	</script>
</body>
</html>