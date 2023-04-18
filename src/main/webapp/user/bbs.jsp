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
			script.println("location.href='/RMS/admin/bbsAdmin.jsp'");
			script.println("</script>");
		}
		
		//기존 데이터 불러오기 (가장 최근에 작성된 rms 조회)
		ArrayList<rmsrept> list = rms.getrms(id, pageNumber);
		
		//다음 페이지가 있는지 확인!
		ArrayList<rmsrept> aflist = rms.getrms(id, pageNumber+1);
		
		
	%>
	    
	<!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>
	
		
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
			<form method="post" name="search" action="/RMS/user/searchbbs.jsp">
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
						<a href="/RMS/user/update.jsp?rms_dl=<%= list.get(i).getRms_dl() %>">
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
								//pptxrmsMake 관련 불러오기
									//forward
								//pageContext.forward("/RMS/user/action/pptxrmsMake.jsp");
								//RequestDispatcher dispatcher = request.getRequestDispatcher("/RMS/user/action/pptxrmsMake.jsp");
								//dispatcher.forward(request, response);
									//redirect
								//response.sendRedirect("/RMS/user/action/pptxrmsMake.jsp");
									//java
								rms.WritePptx(list.get(i).getRms_dl(), id);
							}
						} else if(dldate.after(today) && list.get(i).getRms_sign().equals("미승인")) {
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
								//pptxrmsMake 관련 불러오기
									//forward
								//pageContext.forward("/RMS/user/action/pptxrmsMake.jsp");
								//RequestDispatcher dispatcher = request.getRequestDispatcher("/RMS/user/action/pptxrmsMake.jsp");
								//dispatcher.forward(request, response);
									//redirect
								//response.sendRedirect("/RMS/user/action/pptxrmsMake.jsp");
									//java
								rms.WritePptx(list.get(i).getRms_dl(), id);
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
				<%-- <a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left" style="display:inline-block">이전</a> --%>
					<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(aflist.size() != 0){
			%>
				<%-- <a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next" style="display:inline-block">다음</a> --%>
					<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			
			<!-- 글쓰기 버튼 생성 -->
			<a href="/RMS/user/bbsUpdate.jsp" class="btn btn-info pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="주간보고 작성">작성</a>
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