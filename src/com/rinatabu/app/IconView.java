package com.rinatabu.app;
import android.content.Context;import android.graphics.*;import android.view.View;
public class IconView extends View {
 final String kind;final int color;boolean filled=false;Paint p=new Paint(3);
 public IconView(Context c,String k,int col){super(c);kind=k;color=col;setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO);}
 protected void onDraw(Canvas c){super.onDraw(c);float size=Math.min(getWidth(),getHeight())*.62f;c.save();c.translate((getWidth()-size)/2,(getHeight()-size)/2);c.scale(size/24,size/24);p.setColor(color);p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(1.65f);p.setStrokeCap(Paint.Cap.ROUND);p.setStrokeJoin(Paint.Join.ROUND);Path x=new Path();
 switch(kind){case "heart":x.moveTo(12,21);x.cubicTo(8,17,2,13,2,7);x.cubicTo(2,1,9,0,12,6);x.cubicTo(15,0,22,1,22,7);x.cubicTo(22,13,16,17,12,21);if(filled)p.setStyle(Paint.Style.FILL);c.drawPath(x,p);break;
 case "home":x.moveTo(2,10);x.lineTo(12,2);x.lineTo(22,10);x.moveTo(5,9);x.lineTo(5,22);x.lineTo(10,22);x.lineTo(10,15);x.lineTo(15,15);x.lineTo(15,22);x.lineTo(20,22);x.lineTo(20,9);c.drawPath(x,p);break;
 case "gift":c.drawRoundRect(3,9,21,14,1,1,p);c.drawRect(5,14,19,22,p);c.drawLine(12,9,12,22,p);x.moveTo(12,9);x.cubicTo(0,9,6,-4,12,9);x.cubicTo(24,-4,24,9,12,9);c.drawPath(x,p);break;
 case "spark":x.moveTo(12,1);x.quadTo(14,10,23,12);x.quadTo(14,14,12,23);x.quadTo(10,14,1,12);x.quadTo(10,10,12,1);c.drawPath(x,p);break;
 case "user":c.drawCircle(12,7,4,p);c.drawArc(3,14,21,30,180,180,false,p);break;
 default:c.drawLine(4,6,20,6,p);c.drawLine(8,12,20,12,p);c.drawLine(4,18,20,18,p);
 }c.restore();}
}
