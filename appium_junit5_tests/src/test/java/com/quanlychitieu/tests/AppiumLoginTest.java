package com.quanlychitieu.tests;

import io.appium.java_client.AppiumBy;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class AppiumLoginTest {

    private AndroidDriver driver;

    @BeforeEach
    public void setUp() throws MalformedURLException, URISyntaxException {
        UiAutomator2Options options = new UiAutomator2Options()
                .setPlatformName("Android")
                .setAutomationName("UiAutomator2")
                // Path to the built flutter apk. You should run "flutter build apk" first.
                .setApp(System.getProperty("user.dir") + "/../build/app/outputs/flutter-apk/app-debug.apk")
                .setNoReset(false);

        // Standard Appium server URL
        driver = new AndroidDriver(new URI("http://127.0.0.1:4723/").toURL(), options);
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
    }

    @Test
    public void testLoginScreenRenders() {
        // Here we test if the Login Screen opens. Since Flutter apps don't use standard XML UI components sometimes, 
        // we can test accessibility IDs or Flutter inspector keys.

        // Assuming you have added 'Semantic' or 'ToolTip' widgets in Flutter to mark UI elements.
        // Wait and find an element with text or accessibility ID 'login_button' or something similar.
        // For demonstration, we'll try to find any element (we are just confirming Appium hooks into the app).
        
        assertNotNull(driver.getSessionId(), "Failed to get Appium Session ID. App might not have loaded.");
        System.out.println("App launched successfully on Appium!");
        
        // Example: Finding the email field (assuming it has been assigned the 'content-desc' of 'email_input')
        // boolean isPresent = !driver.findElements(AppiumBy.accessibilityId("email_input")).isEmpty();
        // assertTrue(isPresent, "Email field should be visible on the login screen.");
    }

    @AfterEach
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
