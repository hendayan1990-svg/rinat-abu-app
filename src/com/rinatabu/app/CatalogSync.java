package com.rinatabu.app;
import org.json.*;import java.io.*;import java.net.*;import java.util.*;import javax.net.ssl.HttpsURLConnection;
public final class CatalogSync {
 public interface Progress{void update(int page,int total);}
 public static JSONArray fetch(Progress progress)throws Exception{
  JSONArray result=new JSONArray();Set<Long> ids=new HashSet<>();int totalPages=1,expected=-1;
  for(int page=1;page<=totalPages;page++){
   URL url=new URL("https://rinatabu.com/wp-json/wc/store/v1/products?per_page=100&orderby=id&order=asc&page="+page);
   HttpsURLConnection c=(HttpsURLConnection)url.openConnection();c.setConnectTimeout(15000);c.setReadTimeout(25000);c.setInstanceFollowRedirects(false);c.setRequestProperty("Accept","application/json");
   try{if(c.getResponseCode()!=200)throw new IOException("HTTP "+c.getResponseCode());
    int pages=Integer.parseInt(c.getHeaderField("X-WP-TotalPages"));int total=Integer.parseInt(c.getHeaderField("X-WP-Total"));
    if(page==1){totalPages=pages;expected=total;if(pages<1||pages>50||total<1||total>5000)throw new IOException("Unexpected catalogue size");}
    else if(pages!=totalPages||total!=expected)throw new IOException("Catalogue changed during sync");
    ByteArrayOutputStream out=new ByteArrayOutputStream();try(InputStream in=c.getInputStream()){byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1){if(out.size()+n>15000000)throw new IOException("Page too large");out.write(b,0,n);}}
    JSONArray a=new JSONArray(out.toString("UTF-8"));for(int i=0;i<a.length();i++){JSONObject p=a.getJSONObject(i);long id=p.getLong("id");if(!ids.add(id))throw new IOException("Duplicate product");JSONObject price=p.getJSONObject("prices");if(!"ILS".equals(price.getString("currency_code")))throw new IOException("Unsupported currency");int minor=price.getInt("currency_minor_unit");if(minor<0||minor>4)throw new IOException("Invalid currency unit");double factor=Math.pow(10,minor);JSONObject n=new JSONObject();n.put("id",id);n.put("name",p.getString("name"));n.put("url",safe(p.getString("permalink")));n.put("price",amount(price.optString("price"),factor));n.put("old",amount(price.optString("regular_price"),factor));n.put("sale",p.optBoolean("on_sale"));n.put("stock",p.optBoolean("is_in_stock"));n.put("purchasable",p.optBoolean("is_purchasable"));n.put("range",!price.isNull("price_range"));JSONArray ims=p.optJSONArray("images");String image="";if(ims!=null&&ims.length()>0){JSONObject im=ims.getJSONObject(0);image=safe(im.optString("src",im.optString("thumbnail")));}n.put("image",image);JSONArray cats=p.optJSONArray("categories");String category="";if(cats!=null)for(int j=0;j<cats.length();j++)category+=" "+cats.getJSONObject(j).optString("name");n.put("category",category.trim());result.put(n);}
    progress.update(page,totalPages);
   }finally{c.disconnect();}
  }
  if(result.length()!=expected)throw new IOException("Incomplete catalogue");return result;
 }
 static String safe(String s)throws Exception{URI u=new URI(s);if(!"https".equals(u.getScheme())||!"rinatabu.com".equals(u.getHost()))throw new IOException("Unexpected product URL");return s;}
 static double amount(String s,double factor)throws Exception{if(s.isEmpty())return 0;double v=Double.parseDouble(s)/factor;if(!Double.isFinite(v)||v<0)throw new IOException("Invalid price");return v;}
}
