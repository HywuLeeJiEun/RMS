<%@page import="net.sf.jasperreports.engine.JRResultSetDataSource"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="net.sf.jasperreports.engine.design.JRDesignQuery"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="net.sf.jasperreports.export.SimpleOutputStreamExporterOutput"%>
<%@page import="net.sf.jasperreports.export.SimpleExporterInput"%>
<%@page import="net.sf.jasperreports.engine.export.ooxml.JRPptxExporter"%>
<%@page import="net.sf.jasperreports.engine.JasperFillManager"%>
<%@page import="net.sf.jasperreports.engine.JasperPrint"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.HashMap"%>
<%@page import="net.sf.jasperreports.engine.JasperCompileManager"%>
<%@page import="java.util.Map"%>
<%@page import="net.sf.jasperreports.engine.JasperReport"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.File"%>
<%@page import="org.w3.x2000.x09.xmldsig.impl.X509IssuerSerialTypeImpl"%>
<%@page import="java.awt.FontMetrics"%>
<%@page import="javax.swing.SwingUtilities"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>

<% 
		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
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
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		}

		
		//전달된 rms_dl 2개의 정보를 각각 A, B에 담기
		String  A = request.getParameter("rms_dl1");
		String B = "";

		
		// Tip. 요청시마다 생성 및 삭제할 수 있도록 구성
		// ******** Pptx 출력을 위한 자료 생성
		String name = userDAO.getName(id);	
				
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
	
		// 최종 매개변수로 넘겨질 값.
		//String rmsfull = "";
		List<String> rmsfull = new ArrayList<String>();
		String localfile = "";
		
		// B 값의 존재에 따라 결과가 달라짐. 
		if(request.getParameter("rms_dl2") == null || request.getParameter("rms_dl2").equals("rms_dl")) {
			//B값이 존재하지 않는 경우,
			//rmsfull = A;
			rmsfull.add(A);
			localfile = A;
			
		} else {
			
			//B값이 존재하는 경우,
			B = request.getParameter("rms_dl2");
			
			// rms_dl 범위를 지정해야 한다!
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(sdf.parse(A));
	
			
			
			while(!sdf.format(calendar.getTime()).equals(B) && !B.equals("rms_dl")) {
			    calendar.add(Calendar.DAY_OF_MONTH, 7);
			    
			    String rms_dl = sdf.format(calendar.getTime());
			    
			    if(sdf.format(calendar.getTime()).equals(B)) {
			    	//rmsfull += rms_dl;
			    	rmsfull.add(rms_dl);
			    	break;
			    } else {
			    	//rmsfull += rms_dl+",";
			    	rmsfull.add(rms_dl);
			    }
			}
			
			localfile = A + "~" + B;
		}
		
		//sql문 작성하기
		String SQL = "SELECT p.*, np.RMS_CON AS RMS_NCON, np.RMS_STR AS RMS_NSTR, np.RMS_TAR AS RMS_NTAR "+
				"FROM (SELECT * FROM rms.pptxrms WHERE rms_div = 'N' AND rms_dl IN (";
				for(int i=0; i < rmsfull.size(); i++) {
					if(i < rmsfull.size() - 1) {
						SQL += "'"+rmsfull.get(i)+"',";
					}else {
						SQL += "'"+rmsfull.get(i)+"'";
					}
				}
				SQL += ") and user_id = '"+id+"') np "+
				"LEFT JOIN (SELECT * FROM rms.pptxrms WHERE rms_div = 'T' AND rms_dl IN (";
				for(int i=0; i < rmsfull.size(); i++) {
					if(i < rmsfull.size() - 1) {
						SQL += "'"+rmsfull.get(i)+"',";
					}else {
						SQL += "'"+rmsfull.get(i)+"'";
					}
				}
				SQL += ") and user_id = '"+id+"') p "+
				"ON p.rms_dl = np.rms_dl order by rms_dl";
		
		
		 //String rmsfulllist = rmsfull.toString().replaceAll("[\\[\\]]", "");
		 
		// String test = String.join(",", rmsfull);
		
		String rmsfulllist = String.join(",",rmsfull);
		
		//JRDesignQuery query = new JRDesignQuery();
		//query.setText(SQL);
		//query.setLanguage("SQL");
		
		
		// ******** Pptx 제작 *********
		String templatePath = null;
		String newfile = null;
		// 1) 개인 pc 환경
		templatePath = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\RMS_Personal.jrxml";
		// 2) local pc 환경
		//templatePath = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\RMS_EW.jrxml";
		
		
		String local = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\personal";
		//폴더가 없다면, 생성
		File folder = new File(local); //외부 폴더가 있는지 부터 확인,
		if(!folder.exists()) {
			//폴더가 없는 경우,
			folder.mkdir();
		}
		
		newfile = local+"\\주간보고"+localfile+".pptx";
		
		
		Connection conn = null;
		
		try {
		 // (1)템플레이트 XML 컴파일 (여기가 안됨!) => 이게 결국 .jasper를 불러오기 위함!! (jrxml을 컴파일 한 것이 jasper)
		 JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
		 
		
		 // (2)파라메타 생성	  
		 //String logo = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
		 //String logo = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
		 Map<String,Object> paramMap = new HashMap<String,Object>();
		
		 paramMap.put("sql", SQL);
		 paramMap.put("mgr", workSet + userDAO.getName(id));
		// paramMap.put("rmsfull",rmsfulllist);	  
		// paramMap.put("user_id",id);	 
		
		 // (3)데이타소스 생성
		 Class.forName("org.mariadb.jdbc.Driver");
		 conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/rms", "root","7471350");
		
		 //쿼리 저장 및 결과값 저장
		 Statement stmt = conn.createStatement();
		 ResultSet rs = stmt.executeQuery(SQL);
		 
		 JRResultSetDataSource dataSource = new JRResultSetDataSource(rs);
		 
		 // (4)데이타의 동적 바인드
		 JasperPrint print = JasperFillManager.fillReport(jasperReport, paramMap, dataSource); //sql문 전달
		
		 // (5) Ppt로 출력
		 //JasperExportManager.exportReportToPdfFile(print, destPath);	
		
		 
		 JRPptxExporter pptxExporter = new JRPptxExporter();
		 pptxExporter.setExporterInput(new SimpleExporterInput(print));
		 //pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("D:\\git\\RMS\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\주간보고_sample.pptx")));
		 pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File(newfile)));
		 
		 
		 pptxExporter.exportReport();
	     
		} catch (Exception ex) {
		     ex.printStackTrace();
		
		}
		
		String fileName = "주간보고"+localfile+".pptx";
		//String downLoadFile = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\"+fileName;
		String downLoadFile = newfile;
		
		File file = new File(downLoadFile);
		FileInputStream in = new FileInputStream(downLoadFile);
		
		fileName = new String(fileName.getBytes("utf-8"), "8859_1");
		
		response.setContentType("application/octet-stream");
		response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
		
		out.clear();
		out = pageContext.pushBody();
		
		OutputStream os = response.getOutputStream();
		
		int length;
		byte[] b = new byte[(int)file.length()];
		
		while ((length = in.read(b)) >0) {
			os.write(b,0,length);
		}
		
		os.flush();  
		in.close();
		
		// 완료 후 파일 삭제
		file.delete();
		
		
				
%>

<textarea><%= rmsfull.toString() %></textarea>
<br><br>
<textarea><%= SQL %></textarea>
<br>
<textarea><%= workSet + userDAO.getName(id) %></textarea>


</body>
</html>