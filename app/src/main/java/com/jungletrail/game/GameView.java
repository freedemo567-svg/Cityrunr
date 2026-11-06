package com.jungletrail.game;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.MotionEvent;
import android.view.View;

final class GameView extends View {
    private static final int W=960,H=540;
    private final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
    private final SharedPreferences prefs;
    private final GameModel game;
    private String screen="menu", message="Find the car or head for the yellow marker.";
    private int dx,dy;
    private long last;
    private float scale,ox,oy;
    GameView(Context c){super(c);prefs=c.getSharedPreferences("city_save",Context.MODE_PRIVATE);game=GameModel.load(prefs.getString("state",null));}
    private void save(){prefs.edit().putString("state",game.save()).apply();}
    void pauseGame(){if(screen.equals("play")){screen="pause";dx=dy=0;save();invalidate();}}
    @Override protected void onDraw(Canvas c){
        super.onDraw(c);scale=Math.min(getWidth()/(float)W,getHeight()/(float)H);ox=(getWidth()-W*scale)/2;oy=(getHeight()-H*scale)/2;
        c.drawColor(0xff101c2c);c.save();c.translate(ox,oy);c.scale(scale,scale);
        if(screen.equals("play")){
            long now=System.nanoTime();if(last!=0 && game.update((now-last)/1e9f,dx,dy)){message=game.carrying?"Package collected! Go to the green marker.":"Delivery complete! +$100";save();}last=now;
        }
        city(c);if(screen.equals("play"))controls(c);else overlay(c);c.restore();if(screen.equals("play"))postInvalidateOnAnimation();
    }
    private void city(Canvas c){
        c.drawColor(0xff789b6c);float camX=Math.max(0,Math.min(GameModel.WIDTH-W,game.x-W/2f));float camY=Math.max(0,Math.min(GameModel.HEIGHT-H,game.y-H/2f));
        c.save();c.translate(-camX,-camY);
        for(int x=0;x<=GameModel.WIDTH;x+=400){rect(c,x-100,0,x+100,GameModel.HEIGHT,0xff465262);for(int y=0;y<GameModel.HEIGHT;y+=55)rect(c,x-3,y,x+3,y+28,0xffe9d89d);}
        for(int y=0;y<=GameModel.HEIGHT;y+=400){rect(c,0,y-100,GameModel.WIDTH,y+100,0xff465262);for(int x=0;x<GameModel.WIDTH;x+=55)rect(c,x,y-3,x+28,y+3,0xffe9d89d);}
        for(int x=0;x<GameModel.WIDTH;x+=400)for(int y=0;y<GameModel.HEIGHT;y+=400){
            rect(c,x+100,y+100,x+300,y+300,0xffa5a9a3);rect(c,x+110,y+110,x+290,y+290,((x+y)/400)%2==0?0xffbc9077:0xff8f9da6);
            for(int i=0;i<3;i++)for(int j=0;j<3;j++)rect(c,x+130+i*50,y+130+j*50,x+150+i*50,y+155+j*50,0xffd4e4df);
        }
        float tx=game.targetX(),ty=game.targetY();circle(c,tx,ty,39,game.carrying?0x884bea91:0x88ffe066);circle(c,tx,ty,19,game.carrying?0xff5ee89a:0xffffd45e);
        car(c,game.carX,game.carY);if(!game.driving){circle(c,game.x,game.y,15,0xfff5d0a2);circle(c,game.x,game.y-4,8,0xff3c3040);}
        c.restore();
        round(c,15,12,600,77,0xe91b2c3c);text(c,"CITY RUN  |  $"+game.cash+"  |  JOB "+(game.mission+1)+"/3",30,39,21,Color.WHITE,false);
        int dist=(int)Math.hypot(game.x-tx,game.y-ty);String dir=Math.abs(tx-game.x)>Math.abs(ty-game.y)?(tx>game.x?"EAST":"WEST"):(ty>game.y?"SOUTH":"NORTH");
        text(c,(game.carrying?"DELIVER":"PICK UP")+"  "+dir+"  "+dist+"m",30,64,17,0xffffe28a,false);
        round(c,610,12,945,77,0xe91b2c3c);text(c,message,625,40,14,Color.WHITE,false);text(c,"Complete deliveries to earn cash",625,63,14,0xffb7d3d4,false);
        // Compact city map with current position and objective.
        round(c,795,92,945,202,0xd91b2c3c);float mx=805,my=102,mw=130,mh=90;
        for(int i=0;i<=6;i++)rect(c,mx+i*mw/6-1,my,mx+i*mw/6+1,my+mh,0xff71828c);
        for(int i=0;i<=4;i++)rect(c,mx,my+i*mh/4-1,mx+mw,my+i*mh/4+1,0xff71828c);
        circle(c,mx+game.x/GameModel.WIDTH*mw,my+game.y/GameModel.HEIGHT*mh,4,Color.WHITE);circle(c,mx+tx/GameModel.WIDTH*mw,my+ty/GameModel.HEIGHT*mh,5,game.carrying?0xff5ee89a:0xffffd45e);
    }
    private void car(Canvas c,float x,float y){round(c,x-29,y-17,x+29,y+17,0xffdf5f4d);rect(c,x-11,y-13,x+10,y+13,0xffa8d5df);rect(c,x-23,y-21,x-12,y-15,0xff202a34);rect(c,x+12,y-21,x+23,y-15,0xff202a34);rect(c,x-23,y+15,x-12,y+21,0xff202a34);rect(c,x+12,y+15,x+23,y+21,0xff202a34);}
    private void controls(Canvas c){button(c,90,380,65,65,"UP");button(c,20,450,65,65,"LEFT");button(c,90,450,65,65,"DOWN");button(c,160,450,65,65,"RIGHT");button(c,755,445,180,70,game.driving?"EXIT CAR":"ENTER CAR");button(c,850,220,85,48,"PAUSE");}
    private void overlay(Canvas c){round(c,175,90,785,430,0xee142c3b);text(c,screen.equals("menu")?"CITY RUN":"PAUSED",480,165,43,0xffffdc89,true);text(c,"Explore the city. Drive and deliver packages.",480,215,20,Color.WHITE,true);text(c,"Move with arrows. Enter a car when nearby.",480,250,18,0xffc7dce0,true);text(c,"Follow the map: yellow pickup, green delivery.",480,280,18,0xffc7dce0,true);button(c,330,325,300,65,screen.equals("menu")?"START":"RESUME");}
    private void rect(Canvas c,float l,float t,float r,float b,int col){p.setColor(col);c.drawRect(l,t,r,b,p);}private void circle(Canvas c,float x,float y,float r,int col){p.setColor(col);c.drawCircle(x,y,r,p);}private void round(Canvas c,float l,float t,float r,float b,int col){p.setColor(col);c.drawRoundRect(l,t,r,b,12,12,p);}private void text(Canvas c,String s,float x,float y,float size,int col,boolean center){p.setColor(col);p.setTextSize(size);p.setTypeface(android.graphics.Typeface.create("sans-serif",android.graphics.Typeface.BOLD));p.setTextAlign(center?Paint.Align.CENTER:Paint.Align.LEFT);c.drawText(s,x,y,p);}private void button(Canvas c,float x,float y,float w,float h,String s){round(c,x,y,x+w,y+h,0xeef0bc61);text(c,s,x+w/2,y+h/2+6,s.length()>8?16:18,0xff203549,true);}private boolean in(float x,float y,float l,float t,float r,float b){return x>=l&&x<=r&&y>=t&&y<=b;}
    @Override public boolean onTouchEvent(MotionEvent e){
        if(scale==0)return true;int action=e.getActionMasked(),idx=e.getActionIndex();float x=(e.getX(idx)-ox)/scale,y=(e.getY(idx)-oy)/scale;
        if(action==MotionEvent.ACTION_DOWN||action==MotionEvent.ACTION_POINTER_DOWN){
            if(!screen.equals("play")){if(in(x,y,330,325,630,390)){screen="play";last=0;}}
            else if(in(x,y,850,220,935,268))pauseGame();
            else if(in(x,y,755,445,935,515)){if(!game.toggleCar())message="Move closer to the car to enter.";else message=game.driving?"Driving! Follow the city map.":"On foot. Explore the city.";save();}
        }
        if(screen.equals("play")){boolean left=false,right=false,up=false,down=false;if(action!=MotionEvent.ACTION_CANCEL)for(int i=0;i<e.getPointerCount();i++){
            if((action==MotionEvent.ACTION_UP||action==MotionEvent.ACTION_POINTER_UP)&&i==idx)continue;float px=(e.getX(i)-ox)/scale,py=(e.getY(i)-oy)/scale;
            left|=in(px,py,20,450,85,515);right|=in(px,py,160,450,225,515);up|=in(px,py,90,380,155,445);down|=in(px,py,90,450,155,515);
        }dx=(right?1:0)-(left?1:0);dy=(down?1:0)-(up?1:0);}
        invalidate();return true;
    }
}
