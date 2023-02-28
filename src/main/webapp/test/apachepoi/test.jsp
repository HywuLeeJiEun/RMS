<%@page import="org.apache.poi.xslf.usermodel.XSLFBackground"%>
<%@page import="java.util.concurrent.CopyOnWriteArraySet"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.awt.Dimension"%>
<%@page import="org.apache.poi.sl.usermodel.SlideShowFactory"%>
<%@page import="org.apache.poi.sl.usermodel.SlideShow"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideLayout"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideMaster"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlide"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XMLSlideShow"%>
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
	//String rms_dl = request.getParameter("rms_dl");
	String rms_dl = "2023-02-20";
	String[] dl = rms_dl.split("-");
	
	
	/* ******** 몆주차인지 구하는 메소드 ******** (mon - 월 / getWeek - 주차) */
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.KOREA);	
	//int thisWeek = getWeekOfYear(sdf.format(new Date()));
	String Date = rms_dl;
	
    Calendar calendar = Calendar.getInstance();
    String[] dates = Date.split("-");
    int year = Integer.parseInt(dates[0]);
    int month = Integer.parseInt(dates[1]);
    int day = Integer.parseInt(dates[2]);
    calendar.set(year, month - 1, day);
    int getWeek = calendar.get(Calendar.WEEK_OF_YEAR);
	//월주차로 만들기
	int mon = Integer.parseInt(dates[1]);
		//달이 1개월보다 크다면, (이후부터 4주차를 계속 제거)
	if(mon > 1) { 
		getWeek = getWeek - (mon-1) * 4 ;
	}
		
		
	
	//원본파일 경로
		//title  (주마다)
	String file1 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\title"+rms_dl+".pptx";
		//calendar (달마다)
	String file2 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\calendar"+dl[1]+".pptx";
		//index
	String file3 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\2.index.pptx";
		//summary(erp/web)
	String file4 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\summary"+rms_dl+".pptx";
		//summary
	String file5 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\3.summary.pptx";
		//주간보고 CP
	String file6 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\4.CP.pptx";
		//주간보고 ERP
	String file7 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\erp"+rms_dl+".pptx";
		//주간보고 WEB
	String file8 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\web"+rms_dl+".pptx";
		//주간보고 CRM
	String file9 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\5.CRM.pptx";
		//별첨- ERP
	//String file10 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\6.erp.pptx";
		//별첨- 휴가계획
	String file11 = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\10.calendar"+dl[1]+".pptx";
	String[] inputFiles = {file1, file2, file3, file4, file5, file6, file7, file8, file9, file11};
	
	//ppt 사이즈 새로 정하기
	int width = 815;
	int height = 595;

	//slide show 생성
	XMLSlideShow ppt = new XMLSlideShow();
	ppt.setPageSize(new java.awt.Dimension(width, height));
	
	for(String files : inputFiles) {
		//원본 파일 읽기
		FileInputStream input = new FileInputStream(files);
		XMLSlideShow xmlslideShow = new XMLSlideShow(input);
		for(XSLFSlide srcSlide : xmlslideShow.getSlides()) { //ppt 슬라이드를 가져옴.
				ppt.createSlide().importContent(srcSlide);
		}
	}  
	
	//slide 마스터 복사
	XMLSlideShow fromppt = new XMLSlideShow(new FileInputStream(file2));
	for(XSLFSlide fromSlide : fromppt.getSlides()) {
		XSLFSlide toSlide = ppt.createSlide();
		
		if(toSlide.getSlideNumber() > 1) { //1일때, fromSlide.getSlideNumber() > 1
		//copy Slide
		toSlide.setFollowMasterGraphics(true);
		toSlide.setFollowMasterObjects(true);
		
		XSLFSlideLayout fromLayout = fromSlide.getSlideLayout();
		XSLFSlideMaster fromMaster = fromSlide.getSlideMaster();
		XSLFBackground fromBackground = fromSlide.getBackground();
		
		XSLFSlideLayout toLayout = toSlide.getSlideLayout();
		XSLFSlideMaster toMaster = toSlide.getSlideMaster();
		XSLFBackground toBackground = toSlide.getBackground();
	
		toLayout.importContent(fromLayout);
		toMaster.importContent(fromMaster);
		toBackground.setFillColor(fromBackground.getFillColor());
		
		
			
		}
	}
	
	// 레이아웃 변경 
	XSLFSlide toSlide = ppt.getSlides().get(0);
	XSLFSlideMaster tomaster =  toSlide.getSlideMaster();
	XSLFSlideLayout tolayout = toSlide.getSlideLayout();
	
	
	//toSlide.set
	tolayout.setCommitted(false);
	tomaster.getLayout("Title Only").clear();
	tomaster.getLayout("Title Only").setCommitted(false);
	
	tolayout.importContent(tomaster.getLayout("Title Only"));
	
	
	String fileName = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+month+"월"+getWeek+"주차_주간보고_AMS.pptx";
	FileOutputStream ppt_out = new FileOutputStream(fileName);
	ppt.write(ppt_out);
	ppt_out.close();
	ppt.close();
	
	//파일 저장하기
	File dFile = new File(fileName);
	FileInputStream in = new FileInputStream(fileName);
	int fSize = (int)dFile.length();
	
	String filename = month+"월"+getWeek+"주차_주간보고_AMS.pptx";
	filename = new String(filename.getBytes("utf-8"),"8859_1");
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition","attachment; filename="+filename);
	out.clear();
	out = pageContext.pushBody();
	
	OutputStream os = response.getOutputStream();
	
	int length;
	byte[] b = new byte[(int)fileName.length()];
	
	while ((length = in.read(b)) > 0) {
		os.write(b,0,length);
	}
	
	os.flush();
	os.close();
	in.close();   
	
	//XSLFSlide fromSlide_test = fromppt.getSlides().get(0);
	//title에 다른 레이아웃 설정
	//XSLFSlide fromSlide = fromppt.getSlides().get(0);
	
%>
slideLayout : 
<textarea><%= tolayout %></textarea><br>
master Slide : 
<textarea><%= toSlide.getSlideMaster().getLayout("빈 화면") %></textarea><br>
<br><br>
<textarea><%= tomaster.getLayout("Title Only") %></textarea><br>
</body>
</html>