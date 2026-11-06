import com.jungletrail.game.GameModel;

public class GameModelTest {
    private static void check(boolean x,String why){if(!x)throw new AssertionError(why);}
    private static void move(GameModel g,int dx,int dy,int frames){for(int i=0;i<frames;i++)g.update(.016f,dx,dy);}
    public static void main(String[] args){
        GameModel g=new GameModel();check(g.toggleCar()&&g.driving,"enter nearby car");
        float x=g.x;move(g,1,0,30);check(g.x>x+100,"car moves");
        check(g.toggleCar()&&!g.driving,"exit car");g.x=0;g.y=0;check(!g.toggleCar(),"cannot enter distant car");
        g=new GameModel();g.x=80;g.y=200;move(g,1,0,100);check(g.x<=96.1f || g.x<=110-14+.1f,"building blocks player");
        check(!GameModel.clear(200,200,14),"building interior blocked");check(!GameModel.clear(-1,400,14),"city boundary blocked");
        g=new GameModel();check(g.toggleCar(),"enter for delivery");
        for(int i=0;i<3;i++){
            g.x=GameModel.PICKUPS[i][0];g.y=GameModel.PICKUPS[i][1];g.carX=g.x;g.carY=g.y;
            check(g.update(0,0,0)&&g.carrying,"pickup "+i);
            GameModel restored=GameModel.load(g.save());check(restored.carrying&&restored.driving&&restored.mission==i,"save pickup");g=restored;
            g.x=GameModel.DROPS[i][0];g.y=GameModel.DROPS[i][1];g.carX=g.x;g.carY=g.y;
            check(g.update(0,0,0)&&!g.carrying,"delivery "+i);check(g.cash==(i+1)*100,"reward once");
            check(g.mission==(i+1)%3,"next job");
        }
        GameModel restored=GameModel.load(g.save());check(restored.cash==300 && restored.mission==0,"progress persisted");
        check(GameModel.load("broken").cash==0,"bad save safe");
        System.out.println("City game rules passed");
    }
}
