package com.jungletrail.game;

/** Top-down city simulation. Positions are in world pixels. */
public final class GameModel {
    public static final float WIDTH = 2400, HEIGHT = 1600;
    public static final float[][] PICKUPS = {{800,400},{1600,800},{1200,1200}};
    public static final float[][] DROPS = {{1600,400},{400,1200},{2000,800}};
    public float x = 400, y = 400, carX = 455, carY = 400;
    public boolean driving, carrying;
    public int mission, cash;

    public float targetX() { return (carrying ? DROPS : PICKUPS)[mission][0]; }
    public float targetY() { return (carrying ? DROPS : PICKUPS)[mission][1]; }
    public boolean toggleCar() {
        if (!driving) {
            if (distance(x, y, carX, carY) > 95) return false;
            driving = true; x = carX; y = carY; return true;
        }
        float[][] offsets = {{0,55},{0,-55},{55,0},{-55,0}};
        for (float[] d : offsets) if (clear(carX+d[0], carY+d[1], 14)) {
            x = carX+d[0]; y = carY+d[1]; driving = false; return true;
        }
        return false;
    }
    /** Updates movement and returns true when a mission milestone changes. */
    public boolean update(float dt, int dx, int dy) {
        dt = Math.max(0, Math.min(dt, 0.05f));
        dx = Math.max(-1, Math.min(1, dx)); dy = Math.max(-1, Math.min(1, dy));
        float length = (float)Math.sqrt(dx*dx + dy*dy);
        if (length > 0) {
            float speed = driving ? 255 : 130, radius = driving ? 24 : 14;
            float nx = x + dx/length*speed*dt, ny = y + dy/length*speed*dt;
            if (clear(nx, y, radius)) x = nx;
            if (clear(x, ny, radius)) y = ny;
            if (driving) { carX = x; carY = y; }
        }
        if (distance(x,y,targetX(),targetY()) < 48) {
            if (!carrying) carrying = true;
            else { carrying = false; cash += 100; mission = (mission+1)%PICKUPS.length; }
            return true;
        }
        return false;
    }
    public static boolean clear(float x, float y, float r) {
        if (x-r < 0 || y-r < 0 || x+r > WIDTH || y+r > HEIGHT) return false;
        for (int bx = 0; bx < WIDTH; bx += 400) for (int by = 0; by < HEIGHT; by += 400)
            if (x+r > bx+110 && x-r < bx+290 && y+r > by+110 && y-r < by+290) return false;
        return true;
    }
    private static float distance(float ax,float ay,float bx,float by){ return (float)Math.hypot(ax-bx, ay-by); }
    public String save() { return x+","+y+","+carX+","+carY+","+driving+","+carrying+","+mission+","+cash; }
    public static GameModel load(String data) {
        GameModel m = new GameModel(); if(data == null) return m;
        try {
            String[] a=data.split(","); if(a.length!=8) return m;
            float x=Float.parseFloat(a[0]),y=Float.parseFloat(a[1]),cx=Float.parseFloat(a[2]),cy=Float.parseFloat(a[3]);
            boolean driving=Boolean.parseBoolean(a[4]),carrying=Boolean.parseBoolean(a[5]);
            int mission=Integer.parseInt(a[6]),cash=Integer.parseInt(a[7]);
            if (!Float.isFinite(x)||!Float.isFinite(y)||!Float.isFinite(cx)||!Float.isFinite(cy)||!clear(x,y,driving?24:14)||!clear(cx,cy,24)||mission<0||mission>=3||cash<0 || (driving && (x!=cx || y!=cy))) return m;
            m.x=x;m.y=y;m.carX=cx;m.carY=cy;m.driving=driving;m.carrying=carrying;m.mission=mission;m.cash=cash;
        } catch(RuntimeException e){return new GameModel();}
        return m;
    }
}
