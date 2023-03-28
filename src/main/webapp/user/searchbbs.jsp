<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.List"%>
<%@page import="org.mariadb.jdbc.internal.failover.tools.SearchFilter"%>
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
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../login.jsp'");
			script.println("</script>");
		}
		int pageNumber = 1; //기본은 1 페이지를 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'pageNumber'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'pageNumber'변수에 저장한다
		if(request.getParameter("pageNumber") != null){
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
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
		
		
		//검색을 위한 설정
		String category = request.getParameter("searchField");
		String str = request.getParameter("searchText");
		if(category == null) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('검색 내용이 비어있습니다.')");
			script.println("location.href='/RMS/user/bbs.jsp'");
			script.println("</script>");
		}
		
		if(category.equals("rms_dl")) {
			int len = str.length();
			//포맷 형태 확인하기
			if(len > 2 && len < 11) {
				if(str.contains(".")) { // .으로 작성된 경우, YYYY.MM.DD
					str = String.join("-", str.split("\\."));
				} else if(str.contains("-")) { // -으로 작성된 경우, YYYY-MM-DD
					str.replaceAll("-", "-");
				} else if(len == 8){ //8글자라면 -> 다른 특수기호 없이 숫자만 작성됨.   
					StringBuffer bstr = new StringBuffer(str);
					bstr.insert(4,"-"); //yyyy-MMdd
					bstr.insert(7,"-"); //yyyy-mm-dd
					str = bstr.toString();
				}
			}
			if (str.matches(".*[ㄱ-ㅎㅏ-ㅣa-z가-힣]+.*")) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('제출일은 숫자와 특수문자(.) 또는(-)만 입력이 가능합니다.')");
				script.println("location.href='/RMS/user/bbs.jsp'");
				script.println("</script>");
			} 
		}
		
		// 검색 결과 조회
		ArrayList<rmsrept> list =  rms.getrmsSearch(id, category, str, pageNumber);

		
		if (list.size() == 0) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('검색결과가 없습니다.')");
			script.println("location.href='/RMS/user/bbs.jsp'");
			script.println("</script>");
		} 
		
		
		
		//다음 페이지가 있는지,
		ArrayList<rmsrept> aflist =  rms.getrmsSearch(id, category, str, pageNumber+1);
		
			
		//미승인 -> 미제출로 변경
		String[] sign = new String[list.size()];
		for(int i=0; i < list.size(); i++) {
			if(list.get(i).getRms_sign().equals("미승인")) {
				sign[i] = "미제출";
			} else if(list.get(i).getRms_sign().equals("승인")){
				sign[i] = "제출";						
			} else {
				sign[i] = list.get(i).getRms_sign();						
			}
		}
				
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
			<form method="post" name="search" id="search" action="/RMS/user/searchbbs.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="rms_dl" <%= category.equals("rms_dl")?"selected":""%>>제출일</option>
								<option value="rms_title" <%= category.equals("rms_title")?"selected":""%>>제목</option>
						</select></td>
						<td>
							<input type="text" class="form-control"
							placeholder="" name="searchText" maxlength="100" value="<%= str %>"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success" formaction="/RMS/user/searchbbs.jsp">검색</button></td>
						<!-- <td><button type="submit" class="btn btn-warning pull-right" formaction="gathering.jsp" onclick="return submit2(this.form)">취합</button></td> -->
					</tr>

				</table>
			</form>
		</div>
	</div>
	<br>
	
	
	<!-- # <검색된게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
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
					%>
					<tr>
						<td><%= list.get(i).getRms_dl() %></td>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/RMS/user/update.jsp?rms_dl=<%= list.get(i).getRms_dl() %>">
							<%= list.get(i).getRms_title() %></a></td>
						<td><%= name %></td>
						<td><%= list.get(i).getRms_time().substring(0, 11) + list.get(i).getRms_time().substring(11, 13) + "시"
							+ list.get(i).getRms_time().substring(14, 16) + "분" %></td>	
						<td><%= pl %></td>		
						<td><%= sign[i] %></td>
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
				<a href="/RMS/user/searchbbs.jsp?pageNumber=<%=pageNumber - 1 %>&searchField=<%= category %>&searchText=<%= str %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(aflist.size() != 0){
			%>
				<a href="/RMS/user/searchbbs.jsp?pageNumber=<%=pageNumber + 1 %>&searchField=<%= category %>&searchText=<%= str %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			
			
			<a href="/RMS/user/bbs.jsp" class="btn btn-primary pull-right">목록</a> 
		</div>
	</div>
	<!-- 게시판 메인 페이지 영역 끝 -->
	
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	
	 <!-- 보고 개수에 따라 버튼 노출 (list.size()) -->
	<script>
	var trCnt = $('#bbsTable tr').length; 
	
	if(trCnt < 11) {
		$('#next').hide();
	}
	</script>
	

</body>
</html>