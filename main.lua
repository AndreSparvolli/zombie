function love.load()
  sprites = {};
  sprites.player = love.graphics.newImage( "sprites/player.png" );
  sprites.bullet = love.graphics.newImage( "sprites/bullet.png" );
  sprites.zombie = love.graphics.newImage( "sprites/zombie.png" );
  sprites.background = love.graphics.newImage( "sprites/background.png" );

  player = {};
  player.x = 200;
  player.y = 200;
  player.speed = 180;
  player.centerX = sprites.player:getWidth() / 2;
  player.centerY = sprites.player:getHeight() / 2;

  zombies = {};
end

function love.update(dt)
  if love.keyboard.isDown( "s" ) then
    player.y = player.y + player.speed * dt;
  elseif love.keyboard.isDown( "w" ) then
    player.y = player.y - player.speed * dt;
  end

  if love.keyboard.isDown( "a" ) then
    player.x = player.x - player.speed * dt;
  elseif love.keyboard.isDown( "d" ) then
    player.x = player.x + player.speed * dt;
  end

  for i,z in ipairs( zombies ) do
    z.x = z.x + math.cos( getZombieAngleTowardsPlayer( z ) ) * z.speed * dt;
    z.y = z.y + math.sin( getZombieAngleTowardsPlayer( z ) ) * z.speed * dt;

    if getDistanceBetweenPlayerAndZombie( z.x, z.y, player.x, player.y ) < 30dsd   then
      for i,z in ipairs( zombies ) do
        zombies[i] = nil;
      end
    end
  end
end

function love.draw()
  -- Draw the background
  love.graphics.draw( sprites.background, 0, 0 );

  -- Draw the Player
  love.graphics.draw( sprites.player, player.x, player.y, getPlayerAngle(), nil, nil, player.centerX, player.centerX );

  -- Draw the Zombies
  for i,z in ipairs( zombies ) do
    love.graphics.draw( sprites.zombie, z.x, z.y, getZombieAngleTowardsPlayer( z ), nil, nil, zombie.centerX, zombie.centerY );
  end
end

function getPlayerAngle()
  return math.atan2( player.y - love.mouse.getY(), player.x - love.mouse.getX() ) + math.pi;
end

function getZombieAngleTowardsPlayer( enemy )
  return math.atan2( player.y - enemy.y, player.x - enemy.x );
end

function spawnZombie()
  zombie = {};
  zombie.x = math.random( 0, love.graphics.getWidth() );
  zombie.y = math.random( 0, love.graphics.getHeight() );
  zombie.centerX = sprites.zombie:getWidth() / 2;
  zombie.centerY = sprites.zombie:getHeight() / 2;
  zombie.speed = 140;

  table.insert(zombies, zombie);
end

function love.keypressed( key, scancode, isrepeat)
  if key == "space" then
    spawnZombie();
  end
end

function getDistanceBetweenPlayerAndZombie( x1, y1, x2, y2 )
  return math.sqrt( ( y2 - y1 )^2 + ( x2 - x1 )^2 );
end
