package com.quanlychitieu.tests;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Lớp kiểm thử minh họa đầy đủ 3 Kỹ thuật: Hộp Trắng, Hộp Đen, Hộp Xám
 * (Dùng JUnit 5)
 */
public class JUnitTestingTiers {

    // ============================================
    // 1. KIỂM THỬ HỘP TRẮNG (WHITE BOX TESTING)
    // ============================================
    public String checkBudgetStatus(double spent, double limit) {
        if (spent < 0 || limit < 0) return "INVALID";
        if (spent >= limit) {
            return "OVER_BUDGET";
        } else if (spent > limit * 0.8) {
            return "WARNING";
        } else {
            return "SAFE";
        }
    }

    @Test
    @DisplayName("UT_W_01 - Nhánh 1: Dữ liệu âm (spent < 0)")
    public void testWhiteBox_NegativeSpent() {
        assertEquals("INVALID", checkBudgetStatus(-50, 1000));
    }

    @Test
    @DisplayName("UT_W_02 - Nhánh 1: Dữ liệu âm (limit < 0)")
    public void testWhiteBox_NegativeLimit() {
        assertEquals("INVALID", checkBudgetStatus(500, -100));
    }

    @Test
    @DisplayName("UT_W_03 - Nhánh 2: Vượt ngân sách (> limit)")
    public void testWhiteBox_OverBudget() {
        assertEquals("OVER_BUDGET", checkBudgetStatus(1200, 1000));
    }

    @Test
    @DisplayName("UT_W_04 - Nhánh 2: Vượt ngân sách (== limit)")
    public void testWhiteBox_ExactBudget() {
        assertEquals("OVER_BUDGET", checkBudgetStatus(1000, 1000));
    }

    @Test
    @DisplayName("UT_W_05 - Nhánh 3: Cảnh báo (sát biên 80%)")
    public void testWhiteBox_WarningEdge() {
        assertEquals("WARNING", checkBudgetStatus(801, 1000));
    }

    @Test
    @DisplayName("UT_W_06 - Nhánh 3: Cảnh báo (cao)")
    public void testWhiteBox_WarningHigh() {
        assertEquals("WARNING", checkBudgetStatus(950, 1000));
    }

    @Test
    @DisplayName("UT_W_07 - Nhánh 4: An toàn (chạm mốc 80%)")
    public void testWhiteBox_SafeEdge() {
        assertEquals("SAFE", checkBudgetStatus(800, 1000));
    }

    @Test
    @DisplayName("UT_W_08 - Nhánh 4: An toàn (thấp)")
    public void testWhiteBox_SafeLow() {
        assertEquals("SAFE", checkBudgetStatus(200, 1000));
    }


    // ============================================
    // 2. KIỂM THỬ HỘP ĐEN (BLACK BOX TESTING)
    // ============================================
    public boolean register(String password) {
        return password != null && password.length() >= 6;
    }

    @Test
    @DisplayName("UT_B_01 - Biên dưới (5 ký tự)")
    public void testBlackBox_BelowBoundary() {
        assertFalse(register("12345"));
    }

    @Test
    @DisplayName("UT_B_02 - Biên đúng (6 ký tự)")
    public void testBlackBox_ExactBoundary() {
        assertTrue(register("123456")); 
    }

    @Test
    @DisplayName("UT_B_03 - Biên trên (7 ký tự)")
    public void testBlackBox_AboveBoundary() {
        assertTrue(register("1234567"));
    }

    @Test
    @DisplayName("UT_B_04 - Vùng hợp lệ mạnh")
    public void testBlackBox_StrongValid() {
        assertTrue(register("Admin@123"));
    }

    @Test
    @DisplayName("UT_B_05 - Vùng không hợp lệ (Rỗng)")
    public void testBlackBox_EmptyString() {
        assertFalse(register(""));
    }

    @Test
    @DisplayName("UT_B_06 - Giá trị vô hiệu hoá (Null)")
    public void testBlackBox_NullValue() {
        assertFalse(register(null));
    }


    // ============================================
    // 3. KIỂM THỬ HỘP XÁM (GRAY BOX TESTING)
    // ============================================
    static class UserService {
        // Cờ nội bộ mô phỏng Database
        public boolean isPremiumDatabaseFlag = false; 

        public boolean upgradePremium(double moneyPaid) {
            if (moneyPaid >= 50.0) {
                isPremiumDatabaseFlag = true; 
                return true;
            }
            return false;
        }
    }

    @Test
    @DisplayName("UT_G_01 - Trạng thái Premium (Không đạt)")
    public void testGrayBox_FailUpgrade() {
        UserService service = new UserService();
        boolean result = service.upgradePremium(40.0);
        
        assertFalse(result, "Hàm phải trả về rớt mạng");
        assertFalse(service.isPremiumDatabaseFlag, "DB Flag không được thay đổi");
    }

    @Test
    @DisplayName("UT_G_02 - Trạng thái Premium (Biên sát 49.9)")
    public void testGrayBox_FailUpgradeEdge() {
        UserService service = new UserService();
        boolean result = service.upgradePremium(49.9);
        
        assertFalse(result);
        assertFalse(service.isPremiumDatabaseFlag);
    }

    @Test
    @DisplayName("UT_G_03 - Trạng thái Premium (Vừa đủ 50.0)")
    public void testGrayBox_SuccessUpgradeExact() {
        UserService service = new UserService();
        boolean result = service.upgradePremium(50.0);
        
        assertTrue(result);
        assertTrue(service.isPremiumDatabaseFlag, "DB Flag phải được bật True khi vừa đủ tiền");
    }

    @Test
    @DisplayName("UT_G_04 - Trạng thái Premium (Dư tiền 100.0)")
    public void testGrayBox_SuccessUpgradeOver() {
        UserService service = new UserService();
        boolean result = service.upgradePremium(100.0);
        
        assertTrue(result);
        assertTrue(service.isPremiumDatabaseFlag);
    }
}
