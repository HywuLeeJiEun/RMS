<%@page import="net.sf.jasperreports.engine.json.expression.filter.FilterExpression.VALUE_TYPE"%>
<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsrept.rmsedps"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.ArrayList"%>
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
<title>RMS</title>
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="css/css/bootstrap.css">
</head>
<body>

<%
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)

	// RMSSUMM에 해당하는 rms_dl
	String rms_dl = request.getParameter("rms_dl");
	//e_state, w_state => 색상표

	
	// erp_bbs가 있다면, 데이터를 저장함!
	//erp 데이터가 있는지 확인
	ArrayList<rmsedps> erp_list = rms.geterp(rms_dl);
	
	//summary 데이터를 불러옴.
	//rms_dl로 검색하여 해당 데이터를 가져옴.
	//ERP
		//금주
	ArrayList<rmssumm> etlist = sumDAO.getSumDiv("ERP", rms_dl, "T");
		//차주
	ArrayList<rmssumm> enlist = sumDAO.getSumDiv("ERP", rms_dl, "N");
	
	//WEB
		//금주
	ArrayList<rmssumm> wtlist = sumDAO.getSumDiv("WEB", rms_dl, "T");
		//차주
	ArrayList<rmssumm> wnlist = sumDAO.getSumDiv("WEB", rms_dl, "N");
	
	//1)개인 pc 환경
	//String templatePath = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\SummaryAD.jrxml";
	//2)local pc환경
	String templatePath = "C:\\Users\\S-OIL\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\SummaryAD.jrxml";
	Connection conn = null;
	
	try {
	 // (1)템플레이트 XML 컴파일 (여기가 안됨!) => 이게 결국 .jasper를 불러오기 위함!! (jrxml을 컴파일 한 것이 jasper)
	 //JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 JasperReport jasperReport = JasperCompileManager.compileReport(templatePath);
	 
	
	 // (2)파라메타 생성	  
	 // 1) 개인 pc 환경
	 //String logo = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 // 2) local pc 환경
	 String logo = "C:\\Users\\S-OIL\\git\\BBS\\src\\main\\webapp\\WEB-INF\\reports\\s-oil.JPG";
	 Map<String,Object> paramMap = new HashMap<String,Object>();
	
	 paramMap.put("deadLine",rms_dl);	  
	 paramMap.put("logo",logo);
	 String e_state = "";
	 String w_state = "";
	 if(etlist.get(0).getSum_pro().equals("완료")) {
		 e_state ="#00ff00";
	 }else if(etlist.get(0).getSum_pro().equals("진행중")) {
		 e_state ="#ffff00";
	 }else {
		 e_state = "ff0000";
	 }
	 if(wtlist.get(0).getSum_pro().equals("완료")) {
		 w_state ="#00ff00";
	 }else if(wtlist.get(0).getSum_pro().equals("진행중")) {
		 w_state ="#ffff00";
	 }else {
		 w_state = "ff0000";
	 }
	 
	 paramMap.put("e_state",e_state);
	 paramMap.put("w_state",w_state);
	 
	 //erplist 데이터 저장
	 String econ = "";
	 String eend = "";
	 String encon = "";
	 String entarget = "";
	 int num = 0;
	 for (int i=0; i < etlist.size(); i++) {
		 if(i < etlist.size()-1) {
			 num = etlist.get(i).getSum_con().length() -  etlist.get(i).getSum_con().replaceAll("\r\n","").length() - 1;
			 econ += etlist.get(i).getSum_con() + "\r\n";
			 eend += etlist.get(i).getSum_enta() + "\r\n";
			 for(int j=0; j < num; j++) {
				 eend += "\r\n";
			 }
		 } else {
			 econ += etlist.get(i).getSum_con();
			 eend += etlist.get(i).getSum_enta();
		 }
	 }

	 for (int i=0; i < enlist.size(); i++) {
		 if(i < enlist.size()-1) {
			 num = enlist.get(i).getSum_con().length() -  enlist.get(i).getSum_con().replaceAll("\r\n","").length() - 1;
			 encon += enlist.get(i).getSum_con() + "\r\n";
			 entarget += enlist.get(i).getSum_enta() + "\r\n";
			 for(int j=0; j < num; j++) {
				 entarget += "\r\n";
			 }
		 } else {
			 encon += enlist.get(i).getSum_con();
			 entarget += enlist.get(i).getSum_enta();
		 }
	 }
 
	 paramMap.put("econ",econ);
	 paramMap.put("eend",eend);
	 paramMap.put("encon",encon);
	 paramMap.put("entarget",entarget);
	 paramMap.put("eprogress",etlist.get(0).getSum_pro());
	 paramMap.put("enote",etlist.get(0).getSum_note());
	 paramMap.put("ennote",enlist.get(0).getSum_note());
	 
	 //weblist 데이터 저장
	 String wcon = "";
	 String wend = "";
	 String wncon = "";
	 String wntarget = "";
	 for (int i=0; i < wtlist.size(); i++) {
		 if(i < wtlist.size()-1) {
			 num = wtlist.get(i).getSum_con().length() -  wtlist.get(i).getSum_con().replaceAll("\r\n","").length() - 1;
			 wcon += wtlist.get(i).getSum_con() + "\r\n";
			 wend += wtlist.get(i).getSum_enta() + "\r\n";
			 for(int j=0; j < num; j++) {
				 wend += "\r\n";
			 }
		 } else {
			 wcon += wtlist.get(i).getSum_con();
			 wend += wtlist.get(i).getSum_enta();
		 }
	 }
	 
	 for (int i=0; i < wnlist.size(); i++) {
		 if(i < wnlist.size()-1) {
			 num = wnlist.get(i).getSum_con().length() -  wnlist.get(i).getSum_con().replaceAll("\r\n","").length() - 1;
			 wncon += wnlist.get(i).getSum_con() + "\r\n";
			 wntarget += wnlist.get(i).getSum_enta() + "\r\n";
			 for(int j=0; j < num; j++) {
				 wntarget += "\r\n";
			 }
		 } else {
			 wncon += wnlist.get(i).getSum_con();
			 wntarget += wnlist.get(i).getSum_enta();
		 }
	 }
	 paramMap.put("wcon",wcon);
	 paramMap.put("wend",wend);
	 paramMap.put("wncon",wncon);
	 paramMap.put("wntarget",wntarget);
	 paramMap.put("wprogress",wtlist.get(0).getSum_pro());
	 paramMap.put("wnote",wtlist.get(0).getSum_note());
	 paramMap.put("wnnote",wnlist.get(0).getSum_note());
	 
	 //erp 데이터를 저장함
	 String a = "erp_date";
	 String b = "erp_user";
	 String c = "erp_stext";
	 String d = "erp_authority";
	 String e = "erp_division";
	 
	 if(erp_list.size() != 0) {
		 for(int i=0; i < erp_list.size(); i++) {
			 paramMap.put(a+i,erp_list.get(i).getErp_date());	  
			 paramMap.put(b+i,erp_list.get(i).getErp_user());	  
			 paramMap.put(c+i,erp_list.get(i).getErp_text());	  
			 paramMap.put(d+i,erp_list.get(i).getErp_anum());  
			 paramMap.put(e+i,erp_list.get(i).getErp_div());	  
		 }
	 } else { //만약, erp 데이터가 없다면!
		 paramMap.put(a+0," ");	  
		 paramMap.put(b+0," ");	  
		 paramMap.put(c+0," ");	  
		 paramMap.put(d+0," ");  
		 paramMap.put(e+0," ");	 
		 paramMap.put(a+1," ");	  
		 paramMap.put(b+1," ");	  
		 paramMap.put(c+1," ");	  
		 paramMap.put(d+1," ");  
		 paramMap.put(e+1," ");	
	 }
	 
	 
	 // (3)데이타소스 생성
	 Class.forName("org.mariadb.jdbc.Driver");
	 conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/rms", "root","7471350");
	
	 // (4)데이타의 동적 바인드
	 JasperPrint print = JasperFillManager.fillReport(jasperReport, paramMap, conn);
	
	 // (5) Ppt로 출력
	 //JasperExportManager.exportReportToPdfFile(print, destPath);	
	
	 JRPptxExporter pptxExporter = new JRPptxExporter();
	 pptxExporter.setExporterInput(new SimpleExporterInput(print));
	 //pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("D:\\git\\BBS\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\주간보고_sample.pptx")));
	 // 1) 개인 pc 환경
	 //pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx")));
	 // 2) local pc 환경
	 pptxExporter.setExporterOutput(new SimpleOutputStreamExporterOutput(new File("C:\\Users\\S-OIL\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx")));
	 
	 // frame으로 출력
	 /* JFrame frame = new JFrame("Report");
	 frame.getContentPane().add(new JRViewer(print));
	 frame.pack();
	 frame.setVisible(true); */
	 
	 
	 pptxExporter.exportReport();
     
	} catch (Exception ex) {
	     ex.printStackTrace();
	
	}
 	String fileName = "요약본_sample.pptx";
	// 1) 개인 pc 환경
	//String downLoadFile = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\" + fileName;
	// 2) local pc 환경
	String downLoadFile = "C:\\Users\\S-OIL\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\" + fileName;
	
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