<%@page import="java.io.BufferedOutputStream"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>
<%@page import="javax.rmi.ssl.SslRMIClientSocketFactory"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.util.List"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
	//원본파일 경로
	String file = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\1.pptx";
	String otherfile = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\5.pptx";
	String[] inputFiles = {file, otherfile};

	//slide show 생성
	XMLSlideShow ppt = new XMLSlideShow();
	
	for(String files : inputFiles) {
		//원본 파일 읽기
		FileInputStream input = new FileInputStream(files);
		XMLSlideShow xmlslideShow = new XMLSlideShow(input);
		for(XSLFSlide srcSlide : xmlslideShow.getSlides()) { //ppt 슬라이드를 가져옴.
				//merging the contents
				//XSLFSheet slide = srcSlide;
				ppt.createSlide().importContent(srcSlide);
		}
	}  

	/* FileInputStream input = new FileInputStream(file);
	XMLSlideShow xmlslideShow = new XMLSlideShow(input);
	List<XSLFSlide> slide = xmlslideShow.getSlides();
	
	//슬라이드 구성 요소
	List<XSLFShape> shapes = slide.get(0).getShapes();  */
		
	//파일 저장하기
	//String fileName = "ex.pptx";
	String fileName = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\merge.pptx";
	
	/* FileOutputStream ppt_out = new FileOutputStream(fileName);
	ppt.write(ppt_out);
	ppt_out.close();
	ppt_out.flush(); */
	
	//파일 저장하기
	File dFile = new File(fileName);
	FileInputStream in = new FileInputStream(fileName);
	int fSize = (int)dFile.length();
	
	//encode 설정 
	//String encodeFilename = "attachment; filename*=" + "UTF-8" + "''" + URLEncoder.encode(name,"UTF-8");
	//response.setContentType("application/octet-stream;  charset=utf-8");
	//response.setHeader("Contetn-Dispostion", encodeFilename);
	//response.setContentLengthLong(fSize);
	fileName = new String(fileName.getBytes("utf-8"),"8859_1");
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition","attachment; filename=merge.pptx");
	out.clear();
	out = pageContext.pushBody();
	
	OutputStream os = response.getOutputStream();
	
	int length;
	byte[] b = new byte[(int)file.length()];
	
	while ((length = in.read(b)) > 0) {
		os.write(b,0,length);
	}
	
	os.flush();
	os.close();
	in.close();
	
%>

</body>
</html>