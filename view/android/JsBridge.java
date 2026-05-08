import android.webkit.JavascriptInterface;

public class JsBridge {
    @JavascriptInterface
    public void getData(String data) {
        System.out.println(data);
    }
}
