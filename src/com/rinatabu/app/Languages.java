package com.rinatabu.app;
import android.content.Context;import org.json.*;import java.io.*;import java.util.*;import java.util.regex.*;
public final class Languages{
 static JSONObject words=new JSONObject();static String current="he";static final String[] codes={"he","ar","ru","en"};static final String[] names={"עברית","العربية","Русский","English"};
 static void init(Context context){current=context.getSharedPreferences("rinat",0).getString("language","he");if(!Arrays.asList(codes).contains(current))current="he";try(InputStream in=context.getAssets().open("i18n.json")){ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] b=new byte[4096];int n;while((n=in.read(b))>0)out.write(b,0,n);words=new JSONObject(out.toString("UTF-8"));}catch(Exception ignored){}}
 static boolean rtl(){return current.equals("he")||current.equals("ar");}
 static Locale locale(){return Locale.forLanguageTag(current.equals("he")?"he-IL":current.equals("ar")?"ar-IL":current.equals("ru")?"ru-RU":"en-IL");}
 static String pick(String he,String en,String ar,String ru){return current.equals("en")?en:current.equals("ar")?ar:current.equals("ru")?ru:he;}
 static String tr(String source){if(current.equals("he")||source==null)return source;String s=source.trim();JSONObject row=words.optJSONObject(s);if(row!=null)return row.optString(current,source);if(s.startsWith("גרסת Android לבדיקה."))return pick("","Android preview. The public catalog syncs from the official website, with an offline copy. Favorites stay on this device. Purchases open the official website. In-app payments and push are not connected. Signed with a preview key; not a store release.","نسخة Android تجريبية. يتزامن الكتالوج من الموقع الرسمي مع نسخة للعمل دون اتصال. تُحفظ المفضلة على الجهاز. الشراء في الموقع الرسمي. الدفع داخل التطبيق والإشعارات غير متصلين بعد. توقيع تجريبي، وليست نسخة للمتجر.","Тестовая версия Android. Каталог синхронизируется с официальным сайтом, есть офлайн-копия. Избранное хранится на устройстве. Покупки на официальном сайте. Оплата в приложении и push пока не подключены. Тестовая подпись; не релиз для магазина.");if(s.contains("\n")){String[] lines=s.split("\n");for(int i=0;i<lines.length;i++)lines[i]=tr(lines[i]);return String.join("\n",lines);}String suffix="";String core=s;for(String mark:new String[]{"←","↕","×"})if(s.endsWith(mark)){core=s.substring(0,s.length()-mark.length()).trim();suffix=" "+(mark.equals("←")&&!rtl()?"→":mark);break;}row=words.optJSONObject(core);if(row!=null)return row.optString(current,core)+suffix;
 Matcher m=Pattern.compile("^(\\d+) פריטים( שמורים מחכים לך)?$").matcher(s);if(m.matches())return m.group(1)+pick("",m.group(2)==null?" items":" saved items",m.group(2)==null?" منتجات":" منتجات محفوظة",m.group(2)==null?" товаров":" сохранённых товаров");
 m=Pattern.compile("^(\\d+)% הנחה$").matcher(s);if(m.matches())return m.group(1)+pick("","% off","% خصم","% скидка");
 if(s.startsWith("הצגת מוצרים נוספים ("))return tr("מוצרים נוספים")+" "+s.substring(s.indexOf('('));
 if(s.startsWith("שמירה במועדפים: "))return tr("אהבתי")+": "+s.substring("שמירה במועדפים: ".length());
 if(s.startsWith("עודכן מהאתר: "))return pick("","Updated: ","تم التحديث: ","Обновлено: ")+s.substring("עודכן מהאתר: ".length());
 if(s.startsWith("מסנכרן מוצרים מהאתר · "))return tr("מתעדכן מהאתר…")+" "+s.substring(s.lastIndexOf('·')+1);
 if(s.startsWith("עדכון ")&&s.contains(" זמין להורדה"))return pick("","Update ","تحديث ","Обновление ")+s.split(" ")[1]+pick(""," is available on GitHub. Installation requires your confirmation."," متاح على GitHub. التثبيت يتطلب موافقتكم."," доступно на GitHub. Установка требует вашего подтверждения.");

 return source;}
 static String[] tr(String[] values){String[] out=values.clone();for(int i=0;i<out.length;i++)out[i]=tr(out[i]);return out;}
}
