

public class BulletManager {

  ArrayList<Bullet> bullets = new ArrayList<>();

  public void CreateBullet(PVector start, PVector velocity, float speed, BaseEntity owner) {
    bullets.add(new Bullet(start, velocity, speed, owner));
  }

  void update(float deltaTime) {
    Iterator<Bullet> it = bullets.iterator();
    while (it.hasNext()) {

      Bullet b = it.next();
      b.move(deltaTime);
      if (b.bulletCollide()) {
        it.remove();
      }
    }
  }

  void draw() {
    fill(#DBFF17, 100);

    for (Bullet b : bullets) {
      b.draw();
    }
  }
}

public class Bullet {

  PVector position;
  PVector velocity;
  float speed;

  float size = 10;

  BaseEntity owner;

  Bullet(PVector start, PVector velocity, float speed, BaseEntity owner) {
    this.position = new PVector(start.x, start.y);
    this.velocity = new PVector(velocity.x, velocity.y);
    this.speed = speed;
    this.owner = owner;
  }

  void move(float deltaTime) {
    position.x += velocity.x *speed * deltaTime;
    position.y += velocity.y *speed * deltaTime;
  }

  void draw() {
    circle(position.x, position.y, size);
  }

  boolean bulletCollide() {
    Set<Integer> keys = World.allEntities.keySet();

    for (Integer v : keys) {
      BaseEntity base = World.allEntities.get(v);
      if (base == owner ) {
        continue;
      }

      if (CollisionChecker.checkCollision(new CircleBox(position, size), new CircleBox(new PVector((float)base.pos().x, (float)base.pos().y), (float)base.colRadius()))) {
        return true;
      }
    }
    return false;
  }
}
