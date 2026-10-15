package com.rinatabu.app;
import android.webkit.CookieManager;import org.json.*;import javax.net.ssl.HttpsURLConnection;import java.io.*;import java.net.*;import java.util.*;
/** Cookie session shared with the official checkout WebView. Never submits an order. */
final class StoreCart{
 static final String ORIGIN="https://rinatabu.com";String nonce="";
 synchronized JSONObject request(String action,JSONObject data)throws Exception{
  if(data!=null&&nonce.isEmpty())request("",null);
  HttpsURLConnection c=(HttpsURLConnection)new URL(ORIGIN+"/wp-json/wc/store/v1/cart"+action+"?_app="+System.currentTimeMillis()).openConnection();
  c.setConnectTimeout(15000);c.setReadTimeout(25000);c.setInstanceFollowRedirects(false);c.setRequestProperty("Accept","application/json");c.setRequestProperty("Cache-Control","no-cache");
  String cookie=CookieManager.getInstance().getCookie(ORIGIN);if(cookie!=null)c.setRequestProperty("Cookie",cookie);
  try{if(data!=null){c.setRequestMethod("POST");c.setRequestProperty("Nonce",nonce);c.setRequestProperty("Content-Type","application/json");c.setDoOutput(true);try(OutputStream out=c.getOutputStream()){out.write(data.toString().getBytes("UTF-8"));}}
   int status=c.getResponseCode();String n=c.getHeaderField("Nonce");if(n!=null)nonce=n;
   for(Map.Entry<String,List<String>> e:c.getHeaderFields().entrySet())if("Set-Cookie".equalsIgnoreCase(e.getKey()))for(String value:e.getValue())CookieManager.getInstance().setCookie(ORIGIN,value);
   CookieManager.getInstance().flush();InputStream in=status>=400?c.getErrorStream():c.getInputStream();if(in==null)throw new IOException("HTTP "+status);
   ByteArrayOutputStream out=new ByteArrayOutputStream();try(InputStream stream=in){byte[] b=new byte[8192];int count;while((count=stream.read(b))!=-1){if(out.size()+count>3000000)throw new IOException("Response too large");out.write(b,0,count);}}
   JSONObject result=new JSONObject(out.toString("UTF-8"));if(status>=400){if(status==401||status==403)nonce="";throw new IOException(android.text.Html.fromHtml(result.optString("message","HTTP "+status),0).toString());}return result;
  }finally{c.disconnect();}
 }
}
