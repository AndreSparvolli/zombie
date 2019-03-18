function love.load()
  sprites = {};
  sprites.player = love.graphics.newImage( "sprites/player.png" );
  sprites.bullet = love.graphics.newImage( "sprites/bullet.png" );
  sprites.zombie = love.graphics.newImage( "sprites/zombie.png" );
  sprites.background = love.graphics.newImage( "sprites/background.png" );

  player = {};
  player.x = love.graphics.getWidth() / 2;
  player.y = love.graphics.getHeight() / 2;
  player.speed = 180;
  player.centerX = sprites.player:getWidth() / 2;
  player.centerY = sprites.player:getHeight() / 2;

  zombies = {};
  bullets = {};

  gameState = 1;
  maxTime = 2;
  timer = maxTime;
  score = 0;

  myFont = love.graphics.newFont( 40 );
end

function love.update(dt)
  if gameState == 2 then
    -- Player movement
    if love.keyboard.isDown( "s" ) and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt;
    elseif love.keyboard.isDown( "w" ) and player.y > 0 then
      player.y = player.y - player.speed * dt;
    end

    if love.keyboard.isDown( "a" ) and player.x > 0 then
      player.x = player.x - player.speed * dt;
    elseif love.keyboard.isDown( "d" ) and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt;
    end
  end

  -- Updates the Zombies movement
  for i,z in ipairs( zombies ) do
    z.x = z.x + math.cos( getZombieAngleTowardsPlayer( z ) ) * z.speed * dt;
    z.y = z.y + math.sin( getZombieAngleTowardsPlayer( z ) ) * z.speed * dt;

    -- Check for collision between Zombies and the Player
    if getDistanceBetween( z.x, z.y, player.x, player.y ) < 30 then
      for i,z in ipairs( zombies ) do
        zombies[i] = nil;
        gameState = 1;
        player.x = love.graphics.getWidth() / 2;
        player.y = love.graphics.getHeight() / 2;
      end
    end
  end

  -- Updates the Bullets movement
  for i,b in ipairs( bullets ) do
    b.x = b.x + math.cos( b.direction ) * b.speed * dt;
    b.y = b.y + math.sin( b.direction ) * b.speed * dt;
  end

  -- Remove the bullets out of bounds
  for i = #bullets, 1, -1 do
    local b = bullets[i];

    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      table.remove( bullets, i );
    end
  end

  -- Checks for Bulets and Zombies collisions
  for i,z in ipairs( zombies ) do
    for j,b in ipairs( bullets ) do
      if getDistanceBetween( z.x, z.y, b.x, b.y ) < 20 then
        z.dead = true;
        b.dead = true;
        score = score + 1;
      end
    end
  end

  -- Remove Zombies that got hit by a Bullet
  for i = #zombies, 1, -1 do
    local z = zombies[i];

    if z.dead == true then
      table.remove( zombies, i );
    end
  end

  -- Remove Bullets that did hit a Zombie
  for i = #bullets, 1, -1 do
    local b = bullets[i];

    if b.dead == true then
      table.remove( bullets, i );
    end
  end

  if gameState == 2 then
    timer = timer - dt;

    if timer <= 0 then
      spawnZombie();
      maxTime = maxTime * 0.95;
      timer = maxTime;
    end
  end

end

function love.draw()
  -- Draw the background
  love.graphics.draw( sprites.background, 0, 0 );

  -- Game Message
  if gameState == 1 then
    love.graphics.setFont( myFont );
    love.graphics.printf( "Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center" );
  end

  -- Draw the score
  love.graphics.printf( "Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center" );

  -- Draw the Player
  love.graphics.draw( sprites.player, player.x, player.y, getPlayerAngle(), nil, nil, player.centerX, player.centerX );

  -- Draw the Zombies
  for i,z in ipairs( zombies ) do
    love.graphics.draw( sprites.zombie, z.x, z.y, getZombieAngleTowardsPlayer( z ), nil, nil, z.centerX, z.centerY );
  end

  -- Draw the bullets
  for i,b in ipairs( bullets ) do
    love.graphics.draw( sprites.bullet, b.x, b.y, nil, 0.3, 0.3, b.centerX, b.centerY );
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
  zombie.x = 0;
  zombie.y = 0;
  zombie.centerX = sprites.zombie:getWidth() / 2;
  zombie.centerY = sprites.zombie:getHeight() / 2;
  zombie.speed = 140;
  zombie.dead = false;

  local side = math.random(1, 4);

  if side == 1 then -- Left side of the screen
    zombie.x = -30
    zombie.y = math.random( 0, love.graphics.getHeight() );
  elseif side == 2 then -- Top of the screen
    zombie.x = math.random( 0, love.graphics.getWidth() );
    zombie.y = -30
  elseif side == 3 then -- Right side of the screen
    zombie.x = love.graphics.getWidth() + 30;
    zombie.y = math.random( 0, love.graphics.getHeight() );
  else -- Bottom of the screen
    zombie.x = math.random( 0, love.graphics.getWidth() );
    zombie.y = love.graphics.getHeight() + 30;
  end

  table.insert(zombies, zombie);
end

function spawnBullet()
  bullet = {};
  bullet.centerX = sprites.bullet:getWidth() / 2;
  bullet.centerY = sprites.bullet:getHeight() / 2;
  bullet.x = player.x;
  bullet.y = player.y;
  bullet.speed = 500;
  bullet.direction = getPlayerAngle();
  bullet.dead = false;

  table.insert(bullets, bullet);
end

function love.keypressed( key, scancode, isrepeat)
  if key == "space" then
    spawnZombie();
  end
end

function love.mousepressed( x, y, button, isTouch )
  if button == 1 and gameState == 2 then
    spawnBullet();
  end

  if gameState == 1 then
    gameState = 2;
    maxTime = 2;
    timer = maxTime;
    score = 0;
  end
end

function getDistanceBetween( x1, y1, x2, y2 )
  return math.sqrt( ( y2 - y1 )^2 + ( x2 - x1 )^2 );
end
