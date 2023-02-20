<%@page import="java.io.OutputStream"%>
<%@page import="net.sf.jasperreports.swing.JRViewer"%>
<%@page import="javax.swing.JFrame"%>
<%@page import="net.sf.jasperreports.export.SimplePptxReportConfiguration"%>
<%@page import="net.sf.jasperreports.export.SimplePptxExporterConfiguration"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="net.sf.jasperreports.export.SimpleOutputStreamExporterOutput"%>
<%@page import="net.sf.jasperreports.export.SimpleExporterInput"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page import="javax.management.remote.JMXServerErrorException"%>
<%@page import="java.io.File"%>
<%@page import="net.sf.jasperreports.engine.export.ooxml.JRPptxExporter"%>
<%@page import="java.sql.SQLException"%>
<%@page import="net.sf.jasperreports.engine.JasperExportManager"%>
<%@page import="net.sf.jasperreports.engine.JasperFillManager"%>
<%@page import="net.sf.jasperreports.engine.JasperPrint"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import= "net.sf.jasperreports.engine.DefaultJasperReportsContext" %>
<%@page import= "net.sf.jasperreports.*" %>
<%@page import="net.sf.jasperreports.engine.*"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
</head>
<body>

<%

	String rms_dl = request.getParameter("rms_dl");
	String pluser = request.getParameter("pluser"); // 해당되는 pluser가 나옴(web, erp)
	String templatePath = null;
	String newfile = null;
	// 1) 개인 pc 환경
	//templatePath = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\RMS_EW.jrxml";
	// 2) local pc 환경
	templatePath = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\RMS_EW.jrxml";
	
	if(pluser.equals("WEB")) {
		//newfile = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\web_sample.pptx";
		newfile = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\web_sample.pptx";
	} else if(pluser.equals("ERP")) {
		//newfile = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\erp_sample.pptx";
		newfile = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\erp_sample.pptx";
	}
	
	Connection conn = null;
	
	try {
	 // (1)템플레이트 XML 컴파일 (여기가 안됨!) => 이게 결국 .jasper를 불러오기 위함!! (jrxml을 컴파일 한 것이 jasper)
	 JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 
	
	 // (2)파라메타 생성	  
	 //String logo = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 String logo = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 Map<String,Object> paramMap = new HashMap<String,Object>();
	
	 paramMap.put("deadLine",rms_dl);	  
	 paramMap.put("logo",logo);
	 paramMap.put("pluser",pluser);
	
	 // (3)데이타소스 생성
	 Class.forName("org.mariadb.jdbc.Driver");
	 conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/rms", "root","7471350");
	
	 // (4)데이타의 동적 바인드
	 JasperPrint print = JasperFillManager.fillReport(jasperReport, paramMap, conn);
	
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
	
	String fileName = null;
	if(pluser.equals("WEB")) {
		fileName = "web_"+rms_dl+".pptx";
	} else if(pluser.equals("ERP")) {
		fileName = "erp_"+rms_dl+".pptx";
	}
	//String downLoadFile = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\" + fileName;
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
%>



</body>
</html>
