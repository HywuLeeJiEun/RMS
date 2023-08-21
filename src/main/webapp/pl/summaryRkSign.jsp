<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmssumm.RmssummDAO"%>
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
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
		
		
		//RMSSUMM - 해당 테이블에서 데이터를 가져옴 (승인상태(미승인,승인,마감...)에 상관없이 데이터를 받아오되, 해당 rms_dl에 T,N이 모두 있는지 확인 -> 있다면 등록?)		 
		//Admin 테이블 없이, rmssumm으로 통일하여 사용함!
			//1. 작성된 rms_dl(제출일)를 가져옴 (++ 승인 또는 마감 상태여야 함!!)
			ArrayList<String> dllist = sumDAO.getSumDlSign(pageNumber); //dl 개수로 표시하기
			//2. 제출일에 해당되는 erp, web 데이터를 가져옴 -> rms_dl 개수로 반복 ... 
		
		//다음페이지가 있는지 확인하기
		ArrayList<String> afdllist = sumDAO.getSumDlSign(pageNumber+1); //dl 개수로 표시하기
		
		if(!au.equals("PL")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('PL(파트리더) 권한이 없습니다. 관리자에게 문의바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		}

		String str = "승인처리 된 요약본을 <br>";
		str += "출력할 수 있습니다.";
		
	%>

	<!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>
		
	<div class="container area" style="cursor:pointer;" id="jb-title">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center;" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%= str %>"> [ERP/WEB] 요약본 출력 
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
						<th style="background-color: #eeeeee; text-align: center; text-align: left"onclick="sortTable(1)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;요약본 상세정보<input type="hidden" readonly id="1" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(2)">작성일(수정일)<input type="hidden" readonly id="2" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(3)">수정자<input type="hidden" readonly id="3" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(4)">상태<input type="hidden" readonly id="4" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;">pptx</th>
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
							
							//bbsDeadline 찾아오기
							String dl = dllist.get(i);
							
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
					%>
						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= dl %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/RMS/pl/bbsRkAdmin.jsp?rms_dl=<%= dl %>" data-toggle="tooltip" data-html="true" data-placement="bottom" title="상세 조회 및 출력이 가능합니다.">
							[<%= wtitle+plus+etitle %>] - summary (<%= dl %>)</a></td>
						<td><%= date.substring(0, 11) + date.substring(11, 13) +"시"+ date.substring(14, 16)+"분" %></td>
						<td><%= writer %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td>	
						<%= getSign %>
						</td>
						<td data-toggle="tooltip" data-html="true" data-placement="right" title="버튼을 통해,<br>pptx 출력">
							<a class="btn btn-success" style="font-size:12px" href="/RMS/admin/pptx/pptAdmin.jsp?rms_dl=<%= dl %>"> 출력 </a>
						</td>
					</tr>
					<%	
							}
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
				<a href="/RMS/pl/summaryRkSign.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(afdllist.size() != 0){
			%>
				<a href="/RMS/pl/summaryRkSign.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			<%-- <a href="ppt.jsp?bbsDeadline=<%=list.get(0).getBbsDeadline()%>&pluser=<%= work %>" style="width:50px" class="btn btn-success pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="pptx 출력" id="pptx" type="button"> 요약 pptx</a> --%>
			<a href="summaryRk.jsp" style="width:50px;" class="btn btn-primary pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="<%= pl %> Summary 조회"> 목록 </a>
			<a href="/RMS/pl/bbsRkwrite.jsp" style="width:100px; margin-right:20px; display:none" class="btn btn-info pull-right form-control" data-toggle="tooltip" data-placement="bottom" title="요약본(Summary) 작성" id="summary"> Summary</a>
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
	
	<script>
	$("#summary_nav").on('mousedown', function() {
		//noSub -> 미제출자
				document.getElementById("summary").click();
	});
	</script>

	
</body>
</html>