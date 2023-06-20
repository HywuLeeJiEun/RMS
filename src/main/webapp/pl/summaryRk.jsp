<%@page import="rmssumm.rmssumm"%>
<%@page import="rmssumm.RmssummDAO"%>
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
		//String bbsDeadline = "2023-01-16";

		//현재 사용자의 담당 업무 보기
		String user_fd = "";
		//1. user_au -> pl인지 확인하기
		if(au.equals("PL")) {
			//2. user_fd -> 담당 업무 확인하기
			user_fd = userDAO.getFD(id); //ERP 또는 WEB ... 
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
		// 데이터 불러오기
		ArrayList<rmssumm> sumlist = sumDAO.getSumAll(user_fd, pageNumber);
		//다음 리스트가 있는지 확인
		ArrayList<rmssumm> afsumlist = sumDAO.getSumAll(user_fd, pageNumber+1);
				
		String str = "작성된 요약본을 <br>";
		str += "확인할 수 있습니다.";
	%>

	<!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>
		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= str %>"> <%= pl %> 요약본 
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
						<!-- <th style="background-color: #eeeeee; text-align: center;">번호</th> -->
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(0)">제출일<input type="text" readonly id="0" style="border:none; width:18px; background-color:transparent;" value="▽"></input></th>
						<th style="background-color: #eeeeee; text-align: center; text-align: left" onclick="sortTable(1)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;요약본 상세정보<input type="hidden" readonly id="1" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(2)">작성자<input type="hidden" readonly id="2" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(3)">작성일(수정일)<input type="hidden" readonly id="3" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(4)">수정자<input type="hidden" readonly id="4" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;" data-toggle="tooltip" data-html="true" data-placement="right" title="관리자의 승인 이후, <br>상태가 변경됩니다."onclick="sortTable(5)">승인<input type="hidden" readonly id="5" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
					</tr>
				</thead>
				<tbody>
					<%
						for(int i = 0; i < sumlist.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							
							//bbsDeadline 찾아오기
							String dl = sumlist.get(i).getRms_dl();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
					%>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= dl %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/RMS/pl/summaryRkUpdate.jsp?rms_dl=<%= sumlist.get(i).getRms_dl() %>" data-toggle="tooltip" data-html="true" data-placement="bottom" title="미승인 상태인 경우, 수정 및 삭제가 가능합니다.">
							[<%= pl %>] - summary (<%= dl %>)</a></td>
						<td><%= name %></td>
						<td><%= sumlist.get(i).getSum_time().substring(0, 11) + sumlist.get(i).getSum_time().substring(11, 13) + "시"
							+ sumlist.get(i).getSum_time().substring(14, 16) + "분" %></td>
						<td><%= userDAO.getName(sumlist.get(i).getSum_updu()) %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td data-toggle="tooltip" data-html="true" data-placement="right" title="관리자의 승인 이후, <br>상태가 변경됩니다.">
						<%
						String sign = null;
						if(dldate.after(today) || dldate.equals(today)) { //현재 날짜가 마감일을 아직 넘지 않으면,
							sign = sumlist.get(i).getSum_sign();
						} else {
							sign="마감";
							// 데이터베이스에 마감처리 진행
							int a = sumDAO.sumSign(sumlist.get(i).getRms_dl());
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
			<%
				if(pageNumber != 1){
			%>
				<a href="/RMS/pl/summaryRk.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(afsumlist.size() != 0){
			%>
				<a href="/RMS/pl/summaryRk.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			<%-- <a href="ppt.jsp?bbsDeadline=<%=list.get(0).getBbsDeadline()%>&pluser=<%= work %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력" id="pptx" type="button"> 요약 pptx</a> --%>

			<a href="/RMS/pl/bbsRkwrite.jsp" style="width:50px;" class="btn btn-info pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="요약본(Summary) 작성" id="summary"> 작성 </a>

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