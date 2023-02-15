<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmssumm.RmssummDAO"%>
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
	

		//RMSSUMM - 해당 테이블에서 데이터를 가져옴 (승인상태(미승인,승인,마감...)에 상관없이 데이터를 받아오되, 해당 rms_dl에 T,N이 모두 있는지 확인 -> 있다면 등록?)		 
		//Admin 테이블 없이, rmssumm으로 통일하여 사용함!
			//1. 작성된 rms_dl(제출일)를 가져옴
			ArrayList<String> dllist = sumDAO.getSumDlAll(pageNumber); //dl 개수로 표시하기
			//2. 제출일에 해당되는 erp, web 데이터를 가져옴 -> rms_dl 개수로 반복 ... 
		
		//다음페이지가 있는지 확인하기
		ArrayList<String> afdllist = sumDAO.getSumDlAll(pageNumber+1); //dl 개수로 표시하기
		
		String str = "작성된 [ERP/WEB] 요약본을 <br>";
		str += "확인할 수 있습니다.";
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
							<li ><a href="/BBS/admin/bbsAdmin.jsp">조회</a></li>
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
								<li class="active" id="summary_nav"><a href="/BBS/pl/summaryRkSign.jsp">조회 및 출력</a></li>
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
								<li class="active"><a href="/BBS/admin/summaryadRk.jsp">조회 및 승인</a></li>
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

		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= str %>">[ERP/WEB] 요약본 조회
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
						<th style="background-color: #eeeeee; text-align: center;">제출일</th>
						<th style="background-color: #eeeeee; text-align: center; text-align: left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;요약본 상세정보</th>
						<!-- <th style="background-color: #eeeeee; text-align: center;">작성자</th> -->
						<th style="background-color: #eeeeee; text-align: center;">작성일(수정일)</th>
						<th style="background-color: #eeeeee; text-align: center;">수정자</th>
						<th style="background-color: #eeeeee; text-align: center;">상태</th>
						<th style="background-color: #eeeeee; text-align: center;" data-toggle="tooltip" data-html="true" data-placement="right" title="승인 후, <br>pptx로 출력할 수 있습니다.">승인</th>
					</tr>
				</thead>
				<tbody>
					<%
					if(dllist.size() != 0) {
						for(int i = 0; i < dllist.size(); i++){
							
							//ERP
							ArrayList<rmssumm> elist = sumDAO.getSumDiv("ERP", dllist.get(i), "T");
							//WEB
							ArrayList<rmssumm> wlist = sumDAO.getSumDiv("WEB", dllist.get(i), "T");
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							
							//bbsDeadline 찾아오기
							String dl = dllist.get(i);
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
							
							//상세정보 타이틀 작성
							String etitle = "";
							String wtitle = "";
							String plus = "";
							
							//작성일(수정일) 및 작성자 구분을 위한 로직
							SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
							Date edate = null;
							Date wdate = null;
							String date ="";
							String writer = "";
							
							//승인 상태 확인용 
							String getSign = "";
							
							if(wlist.size() != 0) { //web이 있다면,
								wtitle = "WEB";
								plus = "/";
								wdate = dateFmt.parse(wlist.get(0).getSum_time());
								getSign = wlist.get(0).getSum_sign();
							}
							if(elist.size() != 0) { //erp가 있다면,
								etitle = "ERP";
								edate = dateFmt.parse(elist.get(0).getSum_time());
								getSign = elist.get(0).getSum_sign();
							}else { //erp가 없는 경우 구분자 제외!
								plus = "";
							}
							
							if(edate != null && wdate != null) {
								//날짜 데이터가 둘다 있을 경우,
								if(edate.before(wdate)) {
									//erp가 web 보다 작다면(이전에 수정함),
									date = dateFmt.format(wdate);
									writer = userDAO.getName(wlist.get(0).getSum_updu());
								} else {
									date = dateFmt.format(edate);
									writer = userDAO.getName(elist.get(0).getSum_updu());
								}
							//둘중, 하나만 데이터가 없다면
							} else if(edate == null) {
								date = dateFmt.format(wdate);
								writer = userDAO.getName(wlist.get(0).getSum_updu());
							} else if(wdate == null) {
								date = dateFmt.format(edate);
								writer = userDAO.getName(elist.get(0).getSum_updu());
							}

						
					%>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= dl %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/BBS/admin/summaryadRkUpdate.jsp?rms_dl=<%= dl %>" data-toggle="tooltip" data-html="true" data-placement="bottom" title="미승인 상태인 경우, 수정 및 삭제가 가능합니다.">
							[<%= etitle+plus+wtitle %>] - summary (<%= dl %>)</a></td>
						<td><%= date.substring(0, 11) + date.substring(11, 13) +"시"+ date.substring(14, 16)+"분" %></td>
						<td><%= writer %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td><%= getSign %></td>
						<td data-toggle="tooltip" data-html="true" data-placement="right" title="승인시, <br>수정이 불가합니다.">
						<% if((dldate.after(today) || dldate.equals(today))  && getSign.equals("미승인")) { %>
							<a class="btn btn-success" style="font-size:12px" href="/BBS/admin/action/summaryadsignOnAction.jsp?rms_dl=<%= dl %>" onclick="return confirm('승인하시겠습니까?\n승인시, 수정이 불가합니다.')"> 승인 </a>
						<% }else if((dldate.after(today) || dldate.equals(today))  && getSign.equals("승인")){ //승인 상태라면 %>
							완료
						<% }else{ //summary - 마감 상태는 아직 존재하지 않음!
							sumDAO.sumSign(dl); %>
							마감 
						<% } %>
						</td>
					</tr>
					<%
						}
					} else {
					%>
						<tr valign="top" style="height:100px; border:none">
						</tr>
						<tr valign="bottom" style="height:120px; border:none" data-html="true" data-toggle="tooltip" data-placement="bottom">
							<th colspan="6" style=" text-align: center; color:black  ; border:none">작성된 요약본 목록이 없습니다. <br><br><br><br></th>
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
				<a href="/BBS/admin/summaryadRk.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(afdllist.size() != 0){
			%>
				<a href="/BBS/admin/summaryadRk.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			<%-- <a href="ppt.jsp?bbsDeadline=<%=list.get(0).getBbsDeadline()%>&pluser=<%= work %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력" id="pptx" type="button"> 요약 pptx</a> --%>
			<!-- <a href="/BBS/admin/summaryadAdmin.jsp" style="width:50px;" class="btn btn-info pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="[ERP/WEB] 요약본 작성" id="summary"> 작성 </a> -->
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
	
</body>
</html>