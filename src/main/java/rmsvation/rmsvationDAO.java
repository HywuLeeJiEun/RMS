package rmsvation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import rmsrept.rmsedps;

public class rmsvationDAO {

	private Connection conn; //자바와 데이터베이스를 연결
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public rmsvationDAO() {
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
	
	
	//RMSVATION 작성하기 (insert)
	public int writeVation(String vaca_ym, String user_id, String vaca_day, String vaca_info) {
		String sql = "insert into rmsvation values(?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, vaca_ym);
			pstmt.setString(2, user_id);
			pstmt.setString(3, vaca_day);
			pstmt.setString(4, vaca_info);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
		}
	
	
	//RMSVATION - 삭제(Delete)하기 - excel.jsp
	public int delVation(String vaca_ym) {
		String sql = "delete from rmsvation where vaca_ym=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, vaca_ym);
			return pstmt.executeUpdate();
		}catch (Exception e){
			e.printStackTrace();
		}
		return -1;
	}
	
	
	// 같은 날짜에 보고된 주간보고가 있는지 확인 (bbsDeadline을 사용해 rms에 저장되어 있는지 확인)
	public String getVacaym(String vaca_ym) {
		String sql = "select vaca_ym from rmsvation where vaca_ym = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, vaca_ym);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//RMSEDPS erp 검색하기 (select)
	public ArrayList<rmsvation> getVation(String vaca_ym){//특정한 리스트를 받아서 반환
	      ArrayList<rmsvation> list = new ArrayList<rmsvation>();
	      String SQL ="select * from rmsvation where vaca_ym=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, vaca_ym);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsvation rms = new rmsvation();
	        	 rms.setVaca_ym(rs.getString(1));
	        	 rms.setUser_id(rs.getString(2));
	        	 rms.setVaca_day(rs.getString(3));
	        	 rms.setVaca_info(rs.getString(4));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
}
