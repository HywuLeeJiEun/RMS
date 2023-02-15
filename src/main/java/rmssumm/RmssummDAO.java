package rmssumm;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;


public class RmssummDAO {
	private Connection conn; //자바와 데이터베이스를 연결
	private PreparedStatement pstmt; //쿼리문 설정 및 실행
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public RmssummDAO() {
		try {
			String dbURL = "jdbc:mariadb://localhost:3306/rms"; //연결할 DB
			String dbID = "root"; //DB 접속 ID
			String dbPassword = "7471350"; //DB 접속 password
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/*********** 기능 구현(메소드 구현) 영역 ***********/
	//RMSSUMM - 주간보고 요약본 작성하기(insert)   //user_fd, sum_enta 변경!
	public int SummaryWrite(String user_fd, String rms_dl, String sum_con, String sum_enta, String sum_pro, String sum_sta, String sum_note, String sum_div, String sum_sign, java.sql.Timestamp sum_time, String sum_updu ) {
		String sql = "insert into rmssumm values(?,?,?,?,?,?,?,?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_fd); //user_fd -> pl(ERP, WEB)
			pstmt.setString(2, rms_dl); //rms_dl(bbsDeadline)
			pstmt.setString(3, sum_con); //summary content (요약본 업무 내용)
			pstmt.setString(4, sum_enta); //summary end,Target (요약본 완료일/목표일(완료예정일))
			pstmt.setString(5, sum_pro); //summary progress (요약본 진행율)
			pstmt.setString(6, sum_sta); //summary state (요약본 상태)
			pstmt.setString(7, sum_note); //summary  note (요약본 비고)
			pstmt.setString(8, sum_div); //summary division (금주 차주 구분 T, N)
			pstmt.setString(9, sum_sign); //승인 상태
			pstmt.setTimestamp(10, sum_time); //작성 또는 수정 시간
			pstmt.setString(11, sum_updu); //작성 또는 수정한 사용자의 아이디
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//RMSSUMM user_fd(erp,web)를 통해 내용 가져오기 (전체목록)
	public ArrayList<rmssumm> getSumAll(String user_fd, int pageNumber){
		String sql =  "select distinct user_fd, rms_dl, sum_sign, sum_time, sum_updu from rmssumm where user_fd=? order by rms_dl desc limit ?,10";
				ArrayList<rmssumm> list = new ArrayList<rmssumm>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_fd);
			pstmt.setInt(2, (pageNumber-1)  * 10);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				rmssumm sum = new rmssumm();
				sum.setUser_fd(rs.getString(1)); 
				sum.setRms_dl(rs.getString(2)); 
				sum.setSum_sign(rs.getString(3)); 
				sum.setSum_time(rs.getString(4)); 
				sum.setSum_updu(rs.getString(5)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//RMSSUMM user_fd(erp,web)를 통해 내용 가져오기 (전체목록)
	public ArrayList<rmssumm> getSumSgin(String user_fd, String sum_sign, int pageNumber){
		String sql =  "select distinct user_fd, rms_dl, sum_sign, sum_time, sum_updu from rmssumm where user_fd=? and sum_sign=? order by rms_dl desc limit ?,10";
				ArrayList<rmssumm> list = new ArrayList<rmssumm>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_fd);
			pstmt.setString(2, sum_sign);
			pstmt.setInt(3, (pageNumber-1)  * 10);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				rmssumm sum = new rmssumm();
				sum.setUser_fd(rs.getString(1)); 
				sum.setRms_dl(rs.getString(2)); 
				sum.setSum_sign(rs.getString(3)); 
				sum.setSum_time(rs.getString(4)); 
				sum.setSum_updu(rs.getString(5)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//RMSSUMM update를 위한 데이터 조회 << user_fd(erp,web), rms_dl, sum_div ... >>
	public ArrayList<rmssumm> getSumDiv(String user_fd, String rms_dl, String sum_div){
		String sql =  "select * from rmssumm where user_fd=? and rms_dl=? and sum_div=?";
				ArrayList<rmssumm> list = new ArrayList<rmssumm>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_fd);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, sum_div);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				rmssumm sum = new rmssumm();
				sum.setUser_fd(rs.getString(1)); 
				sum.setRms_dl(rs.getString(2)); 
				sum.setSum_con(rs.getString(3));
				sum.setSum_enta(rs.getString(4));
				sum.setSum_pro(rs.getString(5));
				sum.setSum_sta(rs.getString(6));
				sum.setSum_note(rs.getString(7));
				sum.setSum_div(rs.getString(8));
				sum.setSum_sign(rs.getString(9)); 
				sum.setSum_time(rs.getString(10)); 
				sum.setSum_updu(rs.getString(11)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//RMSSUMM rms_dl(제출일)로 작성 내용 검색 (bbsRkwrite.jsp 중, 작성된 데이터가 있는지 확인!)
	public ArrayList<rmssumm> getSumDL(String rms_dl){
		String sql =  "select distinct user_fd, rms_dl, sum_sign, sum_time, sum_updu from rmssumm where rms_dl=?";
				ArrayList<rmssumm> list = new ArrayList<rmssumm>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, rms_dl);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				rmssumm sum = new rmssumm();
				sum.setUser_fd(rs.getString(1)); 
				sum.setRms_dl(rs.getString(2)); 
				sum.setSum_sign(rs.getString(3)); 
				sum.setSum_time(rs.getString(4)); 
				sum.setSum_updu(rs.getString(5)); 
				list.add(sum);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
		
	
	// summary의 Sign을 마감으로 변경함! ((제출 날짜가 지남!))
	public int sumSign(String rms_dl) {
		String sql = " update rmssumm set sum_sign='마감' where rms_dl=?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, rms_dl);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}
	
	
	//RMSSUMM - 게시글 수정(Update) 메소드 - summaryRkUpdate.jsp - bbsRkUpdate.jsp
	public int updateSum(String sum_con, String sum_enta, String sum_pro, String sum_sta, String sum_note, String sum_sign, java.sql.Timestamp sum_time, String sum_updu, String user_fd, String rms_dl, String sum_div) {
		String sql = "update rmssumm set sum_con=?, sum_enta=?, sum_pro=?, sum_sta=?, sum_note=?, sum_sign=?, sum_time=?, sum_updu=? where user_fd =? and rms_dl =? and sum_div = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sum_con);
			pstmt.setString(2, sum_enta);
			pstmt.setString(3, sum_pro);
			pstmt.setString(4, sum_sta);
			pstmt.setString(5, sum_note);
			pstmt.setString(6, sum_sign);
			pstmt.setTimestamp(7, sum_time);
			pstmt.setString(8, sum_updu);
			pstmt.setString(9, user_fd);
			pstmt.setString(10, rms_dl);
			pstmt.setString(11, sum_div);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//RMSSUMM - 게시글 삭제(Delete) 메소드 - summaryRkUpdate.jsp - bbsRkDelete.jsp
	public int deleteSum(String rms_dl, String user_fd) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rmssumm where rms_dl = ? and user_fd = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, rms_dl);
			pstmt.setString(2, user_fd);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}

	
	//RMSSUMM - 게시글 삭제(Delete) 메소드 - summaryRkUpdate.jsp - bbsRkDelete.jsp
		public int deleteSumSign(String rms_dl, String user_fd,String sum_sign) {
			//실제 데이터 또한 삭제한다.
			String sql = "delete from rmssumm where rms_dl = ? and user_fd = ? and sum_sign=?";
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, rms_dl);
				pstmt.setString(2, user_fd);
				pstmt.setString(3, sum_sign);
				return pstmt.executeUpdate();
			}catch (Exception e) {
				e.printStackTrace();
			}
			return -1; //데이터베이스 오류 
		}
	
	
	//RMSSUMM - 저장된 rms_dl을 모두 불러온다. (페이징처리)
	public ArrayList<String> getSumDlAll(int pageNumber) {
		String sql = "select distinct rms_dl from rmssumm order by rms_dl desc limit ?,10";
		ArrayList<String> list = new ArrayList<String>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, (pageNumber-1)  * 10);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				list.add(rs.getString(1)); //task_num		
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list; //데이터베이스 오류
	}
	
	
	//RMSSUMM - 저장된 rms_dl을 (마감 또는 승인된) 불러온다. (페이징처리) - summaryRkSign.jsp (PL)
		public ArrayList<String> getSumDlSign(int pageNumber) {
			String sql = "select distinct rms_dl from rmssumm where sum_sign='승인' or sum_sign='마감' order by rms_dl desc limit ?,10";
			ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, (pageNumber-1)  * 10);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //task_num		
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list; //데이터베이스 오류
		}
	
	
	//RMSSUMM 승인(sum_sign)으로 변경하기 - summaryadsignOnAction.jsp
	public int signSum(String sum_sign, String id, String rms_dl) {
		String sql = "update rmssumm set sum_sign = ?, sum_updu=? where rms_dl= ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, sum_sign);
			pstmt.setString(2, id);
			pstmt.setString(3, rms_dl);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//RMSSUMM - rms_dl을 기준으로, 작성된 summary가 있는지 확인 (bbsRkwrite.jsp)
	public String getDluse(String rms_dl, String user_fd) { 
		 String sql ="select distinct rms_dl from rmssumm where rms_dl=? and user_fd=?";
		 try { PreparedStatement pstmt = conn.prepareStatement(sql);
		 	pstmt.setString(1, rms_dl); 
		 	pstmt.setString(2, user_fd);
		 	rs =pstmt.executeQuery(); 
		 	if(rs.next()) { return rs.getString(1); } 
		 }catch (Exception e) { 
		 e.printStackTrace(); } return ""; //데이터베이스 오류 
	 }
}
